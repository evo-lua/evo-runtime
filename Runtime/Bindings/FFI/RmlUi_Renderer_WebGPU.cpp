#include "RmlUi_Renderer_WebGPU.hpp"
#include "interop_ffi.hpp"
#include "stbi_ffi.hpp"
#include "stb_image.h"
#include "stb_image_write.h"

#define RMLUI_MATRIX_ROW_MAJOR
#include <RmlUi/Core.h>
#include <webgpu.h>

#include <cassert>
#include <cstdint>
#include <iostream>
#include <fstream>
#include <map>
#include <string>
#include <memory>

size_t RenderInterface_WebGPU::GetAlignedBufferSize(size_t unalignedSize) {
	constexpr uint8_t ALIGNMENT_IN_BYTES = 4; // As per the WebGPU spec

	size_t numUnalignedBytes = unalignedSize % ALIGNMENT_IN_BYTES;
	size_t numRequiredPaddingBytes = (ALIGNMENT_IN_BYTES - numUnalignedBytes) % ALIGNMENT_IN_BYTES;
	size_t paddedSize = unalignedSize + numRequiredPaddingBytes;

	return paddedSize;
}

WGPUBuffer RenderInterface_WebGPU::CreateVertexBuffer(Rml::Vertex* vertices, int num_vertices) {
	size_t rawBufferSizeInBytes = num_vertices * sizeof(Rml::Vertex);
	size_t alignedBufferSizeInBytes = GetAlignedBufferSize(rawBufferSizeInBytes);
	WGPUBufferDescriptor bufferDescriptor = {
		.usage = WGPUBufferUsage_CopyDst | WGPUBufferUsage_Vertex,
		.size = alignedBufferSizeInBytes,
		.mappedAtCreation = false,
	};
	WGPUBuffer vertexBuffer = wgpuDeviceCreateBuffer(m_wgpuDevice, &bufferDescriptor);
	WGPUQueue deviceQueue = wgpuDeviceGetQueue(m_wgpuDevice);
	wgpuQueueWriteBuffer(deviceQueue, vertexBuffer, 0, vertices, rawBufferSizeInBytes);

	return vertexBuffer;
}

WGPUBuffer RenderInterface_WebGPU::CreateIndexBuffer(int* indices, int num_indices) {
	size_t rawBufferSizeInBytes = num_indices * sizeof(int);
	size_t alignedBufferSizeInBytes = GetAlignedBufferSize(rawBufferSizeInBytes);
	WGPUBufferDescriptor bufferDescriptor = {
		.usage = WGPUBufferUsage_CopyDst | WGPUBufferUsage_Index,
		.size = alignedBufferSizeInBytes,
		.mappedAtCreation = false,
	};

	WGPUBuffer indexBuffer = wgpuDeviceCreateBuffer(m_wgpuDevice, &bufferDescriptor);
	WGPUQueue deviceQueue = wgpuDeviceGetQueue(m_wgpuDevice);
	wgpuQueueWriteBuffer(deviceQueue, indexBuffer, 0, indices, rawBufferSizeInBytes);

	return indexBuffer;
}

WGPUTexture RenderInterface_WebGPU::CreateTexture(const uint8_t* rgbaImageBytes, const uint32_t textureWidth, const uint32_t textureHeight) {
	constexpr size_t BPP = 4; // RGBA texture format is assumed
	size_t textureBufferSize = static_cast<size_t>(textureWidth) * static_cast<size_t>(textureHeight) * BPP;

	WGPUTextureDescriptor textureDescriptor = {
		.usage = WGPUTextureUsage_CopyDst | WGPUTextureUsage_TextureBinding,
		.dimension = WGPUTextureDimension_2D,
		.size = {
			.width = textureWidth,
			.height = textureHeight,
			.depthOrArrayLayers = 1,
		},
		.format = WGPUTextureFormat_RGBA8Unorm,
		.mipLevelCount = 1,
		.sampleCount = 1,
		.viewFormatCount = 0,
	};

	WGPUTexture wgpuTexture = wgpuDeviceCreateTexture(m_wgpuDevice, &textureDescriptor);

	const WGPUImageCopyTexture destination = {
		.texture = wgpuTexture,
		.mipLevel = 0,
		.origin = { 0, 0, 0 },
		.aspect = WGPUTextureAspect_All,
	};
	const WGPUTextureDataLayout source = {
		.offset = 0,
		.bytesPerRow = 4 * textureWidth,
		.rowsPerImage = textureHeight,
	};
	wgpuQueueWriteTexture(
		wgpuDeviceGetQueue(m_wgpuDevice),
		&destination,
		rgbaImageBytes,
		textureBufferSize,
		&source,
		&textureDescriptor.size);

	return wgpuTexture;
}

void RenderInterface_WebGPU::RenderGeometry(Rml::Vertex* vertices, int num_vertices, int* indices, int num_indices,
	Rml::TextureHandle rmlTextureHandle, const Rml::Vector2f& rmlTranslationVector) {
	RML_DEBUG_TRACE("Rendering geometry: %d vertices, %d indices", num_vertices, num_indices);

	assert(num_vertices > 0);
	assert(num_indices > 0);

	WGPUBuffer vertexBuffer = CreateVertexBuffer(vertices, num_vertices);
	WGPUBuffer indexBuffer = CreateIndexBuffer(indices, num_indices);

	rml_geometry_info_t geometry {
		.vertex_buffer = vertexBuffer,
		.num_vertices = num_vertices,
		.index_buffer = indexBuffer,
		.num_indices = num_indices,
		.texture = reinterpret_cast<WGPUTexture>(rmlTextureHandle)
	};
	geometry_render_event_t payload {
		.type = GEOMETRY_RENDER_EVENT,
		.geometry = geometry,
		.translate_u = rmlTranslationVector.x,
		.translate_v = rmlTranslationVector.y
	};
	deferred_event_t event { .geometry_render_details = payload };
	m_deferredEventsQueue->push(event);
}

Rml::CompiledGeometryHandle RenderInterface_WebGPU::CompileGeometry(Rml::Vertex* vertices, int num_vertices, int* indices, int num_indices, Rml::TextureHandle rmlTextureHandle) {
	assert(num_vertices > 0);
	assert(num_indices > 0);

	WGPUBuffer vertexBuffer = CreateVertexBuffer(vertices, num_vertices);
	WGPUBuffer indexBuffer = CreateIndexBuffer(indices, num_indices);

	rml_geometry_info_t* geometry = new rml_geometry_info_t;
	geometry->vertex_buffer = vertexBuffer;
	geometry->num_vertices = num_vertices;
	geometry->index_buffer = indexBuffer;
	geometry->num_indices = num_indices;
	geometry->texture = reinterpret_cast<WGPUTexture>(rmlTextureHandle);

	if(DEBUG_RML_GEOMETRY_GENERATION) {
		std::ofstream vertexFile("rml-vertices.bin", std::ios::out | std::ios::binary);
		if(vertexFile.is_open()) {
			vertexFile.write(reinterpret_cast<const char*>(vertices), num_vertices * sizeof(Rml::Vertex));
			vertexFile.close();
		}

		std::ofstream indexFile("rml-indices.bin", std::ios::out | std::ios::binary);
		if(indexFile.is_open()) {
			indexFile.write(reinterpret_cast<const char*>(indices), num_indices * sizeof(int));
			indexFile.close();
		}
	}

	RML_DEBUG_TRACE("Compiled geometry %p with texture %p (%d vertices + %d indices; %d bytes per vertex)", geometry, reinterpret_cast<void*>(rmlTextureHandle), num_vertices, num_indices, sizeof(Rml::Vertex));

	geometry_compile_event_t payload {
		.type = GEOMETRY_COMPILE_EVENT,
		.compiled_geometry = *geometry,
	};
	deferred_event_t event { .geometry_compilation_details = payload };
	m_deferredEventsQueue->push(event);

	return reinterpret_cast<Rml::CompiledGeometryHandle>(geometry);
}

void RenderInterface_WebGPU::RenderCompiledGeometry(Rml::CompiledGeometryHandle rmlGeometryHandle, const Rml::Vector2f& rmlTranslationVector) {
	rml_geometry_info_t* geometry = reinterpret_cast<rml_geometry_info_t*>(rmlGeometryHandle);

	RML_DEBUG_TRACE("Rendering compiled geometry %p with translation (%.2f, %.2f)", geometry, rmlTranslationVector.x, rmlTranslationVector.y);

	compilation_render_event_t payload {
		.type = COMPILATION_RENDER_EVENT,
		.compiled_geometry = *geometry,
		.translate_u = rmlTranslationVector.x,
		.translate_v = rmlTranslationVector.y
	};
	deferred_event_t event { .compilation_render_details = payload };
	m_deferredEventsQueue->push(event);
}

void RenderInterface_WebGPU::ReleaseCompiledGeometry(Rml::CompiledGeometryHandle rmlGeometryHandle) {
	rml_geometry_info_t* geometry = reinterpret_cast<rml_geometry_info_t*>(rmlGeometryHandle);
	RML_DEBUG_TRACE("Releasing compiled geometry %p", geometry);

	compilation_release_event_t payload {
		.type = COMPILATION_RELEASE_EVENT,
		.compiled_geometry = *geometry,
	};
	deferred_event_t event { .compilation_release_details = payload };
	m_deferredEventsQueue->push(event);
}

void RenderInterface_WebGPU::EnableScissorRegion(bool enabledFlag) {
	RML_DEBUG_TRACE("Scissor testing is now %s", enabledFlag ? "ON" : "OFF");

	scissortest_status_event_t payload {
		.type = SCISSORTEST_STATUS_EVENT,
		.enabled_flag = enabledFlag,
	};
	deferred_event_t event { .scissortest_status_details = payload };
	m_deferredEventsQueue->push(event);
}

void RenderInterface_WebGPU::SetScissorRegion(int x, int y, int width, int height) {
	RML_DEBUG_TRACE("Enabling scissor testing for the region from (%d, %d) to (%d, %d)", x, y, x + width, y + height);

	scissortest_region_event_t payload {
		.type = SCISSORTEST_REGION_EVENT,
		.u = x,
		.v = y,
		.width = width,
		.height = height
	};
	deferred_event_t event { .scissortest_region_details = payload };
	m_deferredEventsQueue->push(event);
}

bool RenderInterface_WebGPU::LoadTexture(Rml::TextureHandle& rmlTextureHandle, Rml::Vector2i& textureDimensions, const Rml::String& source) {
	RML_DEBUG_TRACE("Loading texture from source %s", source.c_str());

	// Should probably defer this for async/background loading (later)
	int inputChannels;
	unsigned char* rgbaImageBytes = stbi_load(source.c_str(), &textureDimensions.x, &textureDimensions.y, &inputChannels, CONVERT_TO_RGB_WITH_ALPHA);
	if(!rgbaImageBytes) return false;

	WGPUTexture wgpuTexture = CreateTexture(rgbaImageBytes, textureDimensions.x, textureDimensions.y);
	rmlTextureHandle = reinterpret_cast<Rml::TextureHandle>(wgpuTexture);

	texture_load_event_t payload {
		.type = TEXTURE_LOAD_EVENT,
		.texture = wgpuTexture,
	};
	deferred_event_t event { .texture_load_details = payload };
	m_deferredEventsQueue->push(event);

	return true;
}

bool RenderInterface_WebGPU::GenerateTexture(Rml::TextureHandle& rmlTextureHandle, const Rml::byte* rgbaImageBytes, const Rml::Vector2i& sourceDimensions) {
	const uint32_t textureWidth = static_cast<uint32_t>(sourceDimensions.x);
	const uint32_t textureHeight = static_cast<uint32_t>(sourceDimensions.y);
	const uint32_t textureBufferSize = textureWidth * textureHeight * 4; // RGBA
	WGPUTexture wgpuTexture = CreateTexture(rgbaImageBytes, textureWidth, textureHeight);

	RML_DEBUG_TRACE("Generated WebGPU texture %p with dimensions %d x %d (%d bytes)", wgpuTexture, textureWidth, textureHeight, textureBufferSize);

	rmlTextureHandle = reinterpret_cast<Rml::TextureHandle>(wgpuTexture);

	texture_generation_event_t payload {
		.type = TEXTURE_GENERATION_EVENT,
		.texture = wgpuTexture,
	};
	deferred_event_t event { .texture_generation_details = payload };
	m_deferredEventsQueue->push(event);

	if(DEBUG_RML_TEXTURE_GENERATION) {
		std::string pngFileName = "rml-texture-" + std::to_string(rmlTextureHandle) + ".png";
		std::vector<uint8_t> pngImageBytes(rgbaImageBytes, rgbaImageBytes + textureBufferSize);
		stbi_write_png(pngFileName.c_str(), textureWidth, textureHeight, 4, pngImageBytes.data(), textureWidth * 4);
	}

	return true;
}

void RenderInterface_WebGPU::ReleaseTexture(Rml::TextureHandle rmlTextureHandle) {
	auto wgpuTexture = reinterpret_cast<WGPUTexture>(rmlTextureHandle);
	RML_DEBUG_TRACE("Releasing texture %p", wgpuTexture);

	texture_release_event_t payload {
		.type = TEXTURE_RELEASE_EVENT,
		.texture = wgpuTexture,
	};
	deferred_event_t event { .texture_release_details = payload };
	m_deferredEventsQueue->push(event);
}

void RenderInterface_WebGPU::SetTransform(const Rml::Matrix4f* rmlTransformationMatrix) {
	bool shouldResetTransform = (rmlTransformationMatrix == nullptr);
	if(shouldResetTransform) rmlTransformationMatrix = &Rml::Matrix4f::Identity();

	auto transform = rmlTransformationMatrix->data();
	RML_DEBUG_TRACE("Setting CSS transform: (%.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f)",
		transform[0],
		transform[1],
		transform[2],
		transform[3],
		transform[4],
		transform[5],
		transform[6],
		transform[7],
		transform[8],
		transform[9],
		transform[10],
		transform[11],
		transform[12],
		transform[13],
		transform[14],
		transform[15]);

	transformation_update_event_t payload {
		.type = TRANSFORMATION_UPDATE_EVENT,
		.x1 = transform[0],
		.x2 = transform[1],
		.x3 = transform[2],
		.x4 = transform[4],
		.y1 = transform[5],
		.y2 = transform[6],
		.y3 = transform[7],
		.y4 = transform[8],
		.z1 = transform[9],
		.z2 = transform[10],
		.z3 = transform[11],
		.z4 = transform[12],
		.w1 = transform[13],
		.w2 = transform[14],
		.w3 = transform[15],
		.w4 = transform[16],
	};
	deferred_event_t event { .transformation_update_details = payload };
	m_deferredEventsQueue->push(event);
}