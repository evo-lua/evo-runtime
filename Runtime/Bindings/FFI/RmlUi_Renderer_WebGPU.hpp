#pragma once

#define MATRIX_ROW_MAJOR
#define RMLUI_STATIC_LIB

#include <RmlUi/Core.h>
#include <webgpu.h>

#include "interop_ffi.hpp"

#include <cstdint>
#include <iostream>
#include <map>
#include <string>

class RenderInterface_WebGPU : public Rml::RenderInterface {
public:
	WGPUDevice m_wgpuDevice;
	deferred_event_queue_t m_deferredEventsQueue;

	RenderInterface_WebGPU(WGPUDevice wgpuDevice, deferred_event_queue_t queue)
		: m_wgpuDevice(wgpuDevice)
		, m_deferredEventsQueue(queue) {};

	// Utilities and glue code (creating GPU buffers immediately avoids unnecessary copies)
	size_t GetAlignedBufferSize(size_t unalignedSize);
	WGPUBuffer CreateVertexBuffer(Rml::Vertex* vertices, int num_vertices);
	WGPUBuffer CreateIndexBuffer(int* indices, int num_indices);
	WGPUTexture CreateTexture(const uint8_t* rgbaImageBytes, const uint32_t textureWidth, const uint32_t textureHeight);

	// RML command handlers
	void RenderGeometry(Rml::Vertex* vertices, int num_vertices, int* indices, int num_indices,
		Rml::TextureHandle texture, const Rml::Vector2f& translation) override;
	Rml::CompiledGeometryHandle CompileGeometry(Rml::Vertex* vertices, int num_vertices, int* indices, int num_indices, Rml::TextureHandle texture) override;
	void RenderCompiledGeometry(Rml::CompiledGeometryHandle geometry, const Rml::Vector2f& translation) override;
	void ReleaseCompiledGeometry(Rml::CompiledGeometryHandle geometry) override;
	void EnableScissorRegion(bool enable) override;
	void SetScissorRegion(int x, int y, int width, int height) override;
	bool LoadTexture(Rml::TextureHandle& rmlTextureHandle, Rml::Vector2i& textureDimensions, const Rml::String& source) override;
	bool GenerateTexture(Rml::TextureHandle& rmlTextureHandle, const Rml::byte* rgbaImageBytes, const Rml::Vector2i& sourceDimensions) override;
	void ReleaseTexture(Rml::TextureHandle rmlTextureHandle) override;
	void SetTransform(const Rml::Matrix4f* transform) override;
};

constexpr bool DEBUG_RML_RENDER_COMMANDS = false;
constexpr bool DEBUG_RML_GEOMETRY_GENERATION = false;
constexpr bool DEBUG_RML_TEXTURE_GENERATION = false;

template <typename... Args>
constexpr void RML_DEBUG_TRACE(Args&&... args) {
	if constexpr(DEBUG_RML_RENDER_COMMANDS) {
		printf("[RML] ");
		printf(std::forward<Args>(args)...);
		printf("\n");
	}
}