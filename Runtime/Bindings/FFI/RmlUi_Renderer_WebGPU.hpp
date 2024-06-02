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
	WGPUBuffer CreateVertexBuffer(const Rml::Vertex* vertices, int num_vertices);
	WGPUBuffer CreateIndexBuffer(const int* indices, int num_indices);
	WGPUTexture CreateTexture(const uint8_t* rgbaImageBytes, const uint32_t textureWidth, const uint32_t textureHeight);

	// RML command handlers
	Rml::CompiledGeometryHandle CompileGeometry(Rml::Span<const Rml::Vertex> vertices, Rml::Span<const int> indices) override;
	void RenderGeometry(Rml::CompiledGeometryHandle rmlGeometryHandle, Rml::Vector2f rmlTranslationVector, Rml::TextureHandle rmlTextureHandle) override;
	void ReleaseGeometry(Rml::CompiledGeometryHandle rmlGeometryHandle) override;
	void EnableScissorRegion(bool enable) override;
	void SetScissorRegion(Rml::Rectanglei region) override;
	Rml::TextureHandle LoadTexture(Rml::Vector2i& textureDimensions, const Rml::String& source) override;
	Rml::TextureHandle GenerateTexture(Rml::Span<const Rml::byte> rgbaImageBytes, Rml::Vector2i sourceDimensions) override;
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