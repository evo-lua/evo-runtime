#include "macros.hpp"
#include "webgpu_ffi.hpp"

#include <string>

const char* wgpu_version() {
	return WGPU_VERSION;
}

EMBED_BINARY(webgpu_aliased_types, "Runtime/Bindings/webgpu_aliases.h")
EMBED_BINARY(webgpu_exported_types, "Runtime/Bindings/webgpu_exports.h")

namespace webgpu_ffi {

	std::string getTypeDefinitions() {
		std::string cdefs;

		cdefs.append(SYMBOL_NAME(webgpu_aliased_types));
		cdefs.append("\n");
		cdefs.append(SYMBOL_NAME(webgpu_exported_types));

		return cdefs;
	}

	void* getExportsTable() {
		static struct static_webgpu_exports_table webgpu_exports_table;

		// Custom
		webgpu_exports_table.wgpu_version = wgpu_version;

		// Global
		webgpu_exports_table.wgpu_create_instance = wgpuCreateInstance;
		webgpu_exports_table.wgpu_get_proc_address = wgpuGetProcAddress;

		// Adapter
		webgpu_exports_table.wgpu_adapter_enumerate_features = wgpuAdapterEnumerateFeatures;
		webgpu_exports_table.wgpu_adapter_get_limits = wgpuAdapterGetLimits;
		webgpu_exports_table.wgpu_adapter_get_properties = wgpuAdapterGetProperties;
		webgpu_exports_table.wgpu_adapter_has_feature = wgpuAdapterHasFeature;
		webgpu_exports_table.wgpu_adapter_request_device = wgpuAdapterRequestDevice;
		webgpu_exports_table.wgpu_adapter_reference = wgpuAdapterReference;
		webgpu_exports_table.wgpu_adapter_release = wgpuAdapterRelease;

		// BindGroup
		webgpu_exports_table.wgpu_bind_group_set_label = wgpuBindGroupSetLabel;
		webgpu_exports_table.wgpu_bind_group_reference = wgpuBindGroupReference;
		webgpu_exports_table.wgpu_bind_group_release = wgpuBindGroupRelease;

		// BindGroupLayout
		webgpu_exports_table.wgpu_bind_group_layout_set_label = wgpuBindGroupLayoutSetLabel;
		webgpu_exports_table.wgpu_bind_group_layout_reference = wgpuBindGroupLayoutReference;
		webgpu_exports_table.wgpu_bind_group_layout_release = wgpuBindGroupLayoutRelease;

		// Buffer
		webgpu_exports_table.wgpu_buffer_destroy = wgpuBufferDestroy;
		webgpu_exports_table.wgpu_buffer_get_const_mapped_range = wgpuBufferGetConstMappedRange;
		webgpu_exports_table.wgpu_buffer_get_map_state = wgpuBufferGetMapState;
		webgpu_exports_table.wgpu_buffer_get_mapped_range = wgpuBufferGetMappedRange;
		webgpu_exports_table.wgpu_buffer_get_size = wgpuBufferGetSize;
		webgpu_exports_table.wgpu_buffer_get_usage = wgpuBufferGetUsage;
		webgpu_exports_table.wgpu_buffer_map_async = wgpuBufferMapAsync;
		webgpu_exports_table.wgpu_buffer_set_label = wgpuBufferSetLabel;
		webgpu_exports_table.wgpu_buffer_unmap = wgpuBufferUnmap;
		webgpu_exports_table.wgpu_buffer_reference = wgpuBufferReference;
		webgpu_exports_table.wgpu_buffer_release = wgpuBufferRelease;

		// CommandBuffer
		webgpu_exports_table.wgpu_command_buffer_reference = wgpuCommandBufferReference;
		webgpu_exports_table.wgpu_command_buffer_release = wgpuCommandBufferRelease;

		// CommandEncoder
		webgpu_exports_table.wgpu_command_encoder_begin_compute_pass = wgpuCommandEncoderBeginComputePass;
		webgpu_exports_table.wgpu_command_encoder_begin_render_pass = wgpuCommandEncoderBeginRenderPass;
		webgpu_exports_table.wgpu_command_encoder_clear_buffer = wgpuCommandEncoderClearBuffer;
		webgpu_exports_table.wgpu_command_encoder_copy_buffer_to_buffer = wgpuCommandEncoderCopyBufferToBuffer;
		webgpu_exports_table.wgpu_command_encoder_copy_buffer_to_texture = wgpuCommandEncoderCopyBufferToTexture;
		webgpu_exports_table.wgpu_command_encoder_copy_texture_to_buffer = wgpuCommandEncoderCopyTextureToBuffer;
		webgpu_exports_table.wgpu_command_encoder_copy_texture_to_texture = wgpuCommandEncoderCopyTextureToTexture;
		webgpu_exports_table.wgpu_command_encoder_finish = wgpuCommandEncoderFinish;
		webgpu_exports_table.wgpu_command_encoder_insert_debug_marker = wgpuCommandEncoderInsertDebugMarker;
		webgpu_exports_table.wgpu_command_encoder_pop_debug_group = wgpuCommandEncoderPopDebugGroup;
		webgpu_exports_table.wgpu_command_encoder_push_debug_group = wgpuCommandEncoderPushDebugGroup;
		webgpu_exports_table.wgpu_command_encoder_resolve_query_set = wgpuCommandEncoderResolveQuerySet;
		webgpu_exports_table.wgpu_command_encoder_set_label = wgpuCommandEncoderSetLabel;
		webgpu_exports_table.wgpu_command_encoder_write_timestamp = wgpuCommandEncoderWriteTimestamp;
		webgpu_exports_table.wgpu_command_encoder_reference = wgpuCommandEncoderReference;
		webgpu_exports_table.wgpu_command_encoder_release = wgpuCommandEncoderRelease;

		// ComputePassEncoder
		webgpu_exports_table.wgpu_compute_pass_encoder_dispatch_workgroups = wgpuComputePassEncoderDispatchWorkgroups;
		webgpu_exports_table.wgpu_compute_pass_encoder_dispatch_workgroups_indirect = wgpuComputePassEncoderDispatchWorkgroupsIndirect;
		webgpu_exports_table.wgpu_compute_pass_encoder_end = wgpuComputePassEncoderEnd;
		webgpu_exports_table.wgpu_compute_pass_encoder_insert_debug_marker = wgpuComputePassEncoderInsertDebugMarker;
		webgpu_exports_table.wgpu_compute_pass_encoder_pop_debug_group = wgpuComputePassEncoderPopDebugGroup;
		webgpu_exports_table.wgpu_compute_pass_encoder_push_debug_group = wgpuComputePassEncoderPushDebugGroup;
		webgpu_exports_table.wgpu_compute_pass_encoder_set_bind_group = wgpuComputePassEncoderSetBindGroup;
		webgpu_exports_table.wgpu_compute_pass_encoder_set_label = wgpuComputePassEncoderSetLabel;
		webgpu_exports_table.wgpu_compute_pass_encoder_set_pipeline = wgpuComputePassEncoderSetPipeline;
		webgpu_exports_table.wgpu_compute_pass_encoder_reference = wgpuComputePassEncoderReference;
		webgpu_exports_table.wgpu_compute_pass_encoder_release = wgpuComputePassEncoderRelease;

		// ComputePipeline
		webgpu_exports_table.wgpu_compute_pipeline_get_bind_group_layout = wgpuComputePipelineGetBindGroupLayout;
		webgpu_exports_table.wgpu_compute_pipeline_set_label = wgpuComputePipelineSetLabel;
		webgpu_exports_table.wgpu_compute_pipeline_reference = wgpuComputePipelineReference;
		webgpu_exports_table.wgpu_compute_pipeline_release = wgpuComputePipelineRelease;

		// Device
		webgpu_exports_table.wgpu_device_create_bind_group = wgpuDeviceCreateBindGroup;
		webgpu_exports_table.wgpu_device_create_bind_group_layout = wgpuDeviceCreateBindGroupLayout;
		webgpu_exports_table.wgpu_device_create_buffer = wgpuDeviceCreateBuffer;
		webgpu_exports_table.wgpu_device_create_command_encoder = wgpuDeviceCreateCommandEncoder;
		webgpu_exports_table.wgpu_device_create_compute_pipeline = wgpuDeviceCreateComputePipeline;
		webgpu_exports_table.wgpu_device_create_compute_pipeline_async = wgpuDeviceCreateComputePipelineAsync;
		webgpu_exports_table.wgpu_device_create_pipeline_layout = wgpuDeviceCreatePipelineLayout;
		webgpu_exports_table.wgpu_device_create_query_set = wgpuDeviceCreateQuerySet;
		webgpu_exports_table.wgpu_device_create_render_bundle_encoder = wgpuDeviceCreateRenderBundleEncoder;
		webgpu_exports_table.wgpu_device_create_render_pipeline = wgpuDeviceCreateRenderPipeline;
		webgpu_exports_table.wgpu_device_create_render_pipeline_async = wgpuDeviceCreateRenderPipelineAsync;
		webgpu_exports_table.wgpu_device_create_sampler = wgpuDeviceCreateSampler;
		webgpu_exports_table.wgpu_device_create_shader_module = wgpuDeviceCreateShaderModule;
		webgpu_exports_table.wgpu_device_create_texture = wgpuDeviceCreateTexture;
		webgpu_exports_table.wgpu_device_destroy = wgpuDeviceDestroy;
		webgpu_exports_table.wgpu_device_enumerate_features = wgpuDeviceEnumerateFeatures;
		webgpu_exports_table.wgpu_device_get_limits = wgpuDeviceGetLimits;
		webgpu_exports_table.wgpu_device_get_queue = wgpuDeviceGetQueue;
		webgpu_exports_table.wgpu_device_has_feature = wgpuDeviceHasFeature;
		webgpu_exports_table.wgpu_device_pop_error_scope = wgpuDevicePopErrorScope;
		webgpu_exports_table.wgpu_device_push_error_scope = wgpuDevicePushErrorScope;
		webgpu_exports_table.wgpu_device_set_label = wgpuDeviceSetLabel;
		webgpu_exports_table.wgpu_device_set_uncaptured_error_callback = wgpuDeviceSetUncapturedErrorCallback;
		webgpu_exports_table.wgpu_device_reference = wgpuDeviceReference;
		webgpu_exports_table.wgpu_device_release = wgpuDeviceRelease;

		// Instance
		webgpu_exports_table.wgpu_instance_create_surface = wgpuInstanceCreateSurface;
		webgpu_exports_table.wgpu_instance_process_events = wgpuInstanceProcessEvents;
		webgpu_exports_table.wgpu_instance_request_adapter = wgpuInstanceRequestAdapter;
		webgpu_exports_table.wgpu_instance_reference = wgpuInstanceReference;
		webgpu_exports_table.wgpu_instance_release = wgpuInstanceRelease;

		// PipelineLayout
		webgpu_exports_table.wgpu_pipeline_layout_set_label = wgpuPipelineLayoutSetLabel;
		webgpu_exports_table.wgpu_pipeline_layout_reference = wgpuPipelineLayoutReference;
		webgpu_exports_table.wgpu_pipeline_layout_release = wgpuPipelineLayoutRelease;

		// QuerySet
		webgpu_exports_table.wgpu_query_set_destroy = wgpuQuerySetDestroy;
		webgpu_exports_table.wgpu_query_set_get_count = wgpuQuerySetGetCount;
		webgpu_exports_table.wgpu_query_set_get_type = wgpuQuerySetGetType;
		webgpu_exports_table.wgpu_query_set_set_label = wgpuQuerySetSetLabel;
		webgpu_exports_table.wgpu_query_set_reference = wgpuQuerySetReference;
		webgpu_exports_table.wgpu_query_set_release = wgpuQuerySetRelease;

		// Queue
		webgpu_exports_table.wgpu_queue_on_submitted_work_done = wgpuQueueOnSubmittedWorkDone;
		webgpu_exports_table.wgpu_queue_set_label = wgpuQueueSetLabel;
		webgpu_exports_table.wgpu_queue_submit = wgpuQueueSubmit;
		webgpu_exports_table.wgpu_queue_write_buffer = wgpuQueueWriteBuffer;
		webgpu_exports_table.wgpu_queue_write_texture = wgpuQueueWriteTexture;
		webgpu_exports_table.wgpu_queue_reference = wgpuQueueReference;
		webgpu_exports_table.wgpu_queue_release = wgpuQueueRelease;

		// RenderBundle
		webgpu_exports_table.wgpu_render_bundle_set_label = wgpuRenderBundleSetLabel;
		webgpu_exports_table.wgpu_render_bundle_reference = wgpuRenderBundleReference;
		webgpu_exports_table.wgpu_render_bundle_release = wgpuRenderBundleRelease;

		// RenderBundleEncoder
		webgpu_exports_table.wgpu_render_bundle_encoder_draw = wgpuRenderBundleEncoderDraw;
		webgpu_exports_table.wgpu_render_bundle_encoder_draw_indexed = wgpuRenderBundleEncoderDrawIndexed;
		webgpu_exports_table.wgpu_render_bundle_encoder_draw_indexed_indirect = wgpuRenderBundleEncoderDrawIndexedIndirect;
		webgpu_exports_table.wgpu_render_bundle_encoder_draw_indirect = wgpuRenderBundleEncoderDrawIndirect;
		webgpu_exports_table.wgpu_render_bundle_encoder_finish = wgpuRenderBundleEncoderFinish;
		webgpu_exports_table.wgpu_render_bundle_encoder_insert_debug_marker = wgpuRenderBundleEncoderInsertDebugMarker;
		webgpu_exports_table.wgpu_render_bundle_encoder_pop_debug_group = wgpuRenderBundleEncoderPopDebugGroup;
		webgpu_exports_table.wgpu_render_bundle_encoder_push_debug_group = wgpuRenderBundleEncoderPushDebugGroup;
		webgpu_exports_table.wgpu_render_bundle_encoder_set_bind_group = wgpuRenderBundleEncoderSetBindGroup;
		webgpu_exports_table.wgpu_render_bundle_encoder_set_index_buffer = wgpuRenderBundleEncoderSetIndexBuffer;
		webgpu_exports_table.wgpu_render_bundle_encoder_set_label = wgpuRenderBundleEncoderSetLabel;
		webgpu_exports_table.wgpu_render_bundle_encoder_set_pipeline = wgpuRenderBundleEncoderSetPipeline;
		webgpu_exports_table.wgpu_render_bundle_encoder_set_vertex_buffer = wgpuRenderBundleEncoderSetVertexBuffer;
		webgpu_exports_table.wgpu_render_bundle_encoder_reference = wgpuRenderBundleEncoderReference;
		webgpu_exports_table.wgpu_render_bundle_encoder_release = wgpuRenderBundleEncoderRelease;

		// RenderPassEncoder
		webgpu_exports_table.wgpu_render_pass_encoder_begin_occlusion_query = wgpuRenderPassEncoderBeginOcclusionQuery;
		webgpu_exports_table.wgpu_render_pass_encoder_draw = wgpuRenderPassEncoderDraw;
		webgpu_exports_table.wgpu_render_pass_encoder_draw_indexed = wgpuRenderPassEncoderDrawIndexed;
		webgpu_exports_table.wgpu_render_pass_encoder_draw_indexed_indirect = wgpuRenderPassEncoderDrawIndexedIndirect;
		webgpu_exports_table.wgpu_render_pass_encoder_draw_indirect = wgpuRenderPassEncoderDrawIndirect;
		webgpu_exports_table.wgpu_render_pass_encoder_end = wgpuRenderPassEncoderEnd;
		webgpu_exports_table.wgpu_render_pass_encoder_end_occlusion_query = wgpuRenderPassEncoderEndOcclusionQuery;
		webgpu_exports_table.wgpu_render_pass_encoder_execute_bundles = wgpuRenderPassEncoderExecuteBundles;
		webgpu_exports_table.wgpu_render_pass_encoder_insert_debug_marker = wgpuRenderPassEncoderInsertDebugMarker;
		webgpu_exports_table.wgpu_render_pass_encoder_pop_debug_group = wgpuRenderPassEncoderPopDebugGroup;
		webgpu_exports_table.wgpu_render_pass_encoder_push_debug_group = wgpuRenderPassEncoderPushDebugGroup;
		webgpu_exports_table.wgpu_render_pass_encoder_set_bind_group = wgpuRenderPassEncoderSetBindGroup;
		webgpu_exports_table.wgpu_render_pass_encoder_set_blend_constant = wgpuRenderPassEncoderSetBlendConstant;
		webgpu_exports_table.wgpu_render_pass_encoder_set_index_buffer = wgpuRenderPassEncoderSetIndexBuffer;
		webgpu_exports_table.wgpu_render_pass_encoder_set_label = wgpuRenderPassEncoderSetLabel;
		webgpu_exports_table.wgpu_render_pass_encoder_set_pipeline = wgpuRenderPassEncoderSetPipeline;
		webgpu_exports_table.wgpu_render_pass_encoder_set_scissor_rect = wgpuRenderPassEncoderSetScissorRect;
		webgpu_exports_table.wgpu_render_pass_encoder_set_stencil_reference = wgpuRenderPassEncoderSetStencilReference;
		webgpu_exports_table.wgpu_render_pass_encoder_set_vertex_buffer = wgpuRenderPassEncoderSetVertexBuffer;
		webgpu_exports_table.wgpu_render_pass_encoder_set_viewport = wgpuRenderPassEncoderSetViewport;
		webgpu_exports_table.wgpu_render_pass_encoder_reference = wgpuRenderPassEncoderReference;
		webgpu_exports_table.wgpu_render_pass_encoder_release = wgpuRenderPassEncoderRelease;

		// RenderPipeline
		webgpu_exports_table.wgpu_render_pipeline_get_bind_group_layout = wgpuRenderPipelineGetBindGroupLayout;
		webgpu_exports_table.wgpu_render_pipeline_set_label = wgpuRenderPipelineSetLabel;
		webgpu_exports_table.wgpu_render_pipeline_reference = wgpuRenderPipelineReference;
		webgpu_exports_table.wgpu_render_pipeline_release = wgpuRenderPipelineRelease;

		// Sampler
		webgpu_exports_table.wgpu_sampler_set_label = wgpuSamplerSetLabel;
		webgpu_exports_table.wgpu_sampler_reference = wgpuSamplerReference;
		webgpu_exports_table.wgpu_sampler_release = wgpuSamplerRelease;

		// ShaderModule
		webgpu_exports_table.wgpu_shader_module_get_compilation_info = wgpuShaderModuleGetCompilationInfo;
		webgpu_exports_table.wgpu_shader_module_set_label = wgpuShaderModuleSetLabel;
		webgpu_exports_table.wgpu_shader_module_reference = wgpuShaderModuleReference;
		webgpu_exports_table.wgpu_shader_module_release = wgpuShaderModuleRelease;

		// Surface
		webgpu_exports_table.wgpu_surface_configure = wgpuSurfaceConfigure;
		webgpu_exports_table.wgpu_surface_get_capabilities = wgpuSurfaceGetCapabilities;
		webgpu_exports_table.wgpu_surface_get_current_texture = wgpuSurfaceGetCurrentTexture;
		webgpu_exports_table.wgpu_surface_get_preferred_format = wgpuSurfaceGetPreferredFormat;
		webgpu_exports_table.wgpu_surface_present = wgpuSurfacePresent;
		webgpu_exports_table.wgpu_surface_unconfigure = wgpuSurfaceUnconfigure;
		webgpu_exports_table.wgpu_surface_reference = wgpuSurfaceReference;
		webgpu_exports_table.wgpu_surface_release = wgpuSurfaceRelease;

		// SurfaceCapabilities
		webgpu_exports_table.wgpu_surface_capabilities_free_members = wgpuSurfaceCapabilitiesFreeMembers;

		// Texture
		webgpu_exports_table.wgpu_texture_create_view = wgpuTextureCreateView;
		webgpu_exports_table.wgpu_texture_destroy = wgpuTextureDestroy;
		webgpu_exports_table.wgpu_texture_get_depth_or_array_layers = wgpuTextureGetDepthOrArrayLayers;
		webgpu_exports_table.wgpu_texture_get_dimension = wgpuTextureGetDimension;
		webgpu_exports_table.wgpu_texture_get_format = wgpuTextureGetFormat;
		webgpu_exports_table.wgpu_texture_get_height = wgpuTextureGetHeight;
		webgpu_exports_table.wgpu_texture_get_mip_level_count = wgpuTextureGetMipLevelCount;
		webgpu_exports_table.wgpu_texture_get_sample_count = wgpuTextureGetSampleCount;
		webgpu_exports_table.wgpu_texture_get_usage = wgpuTextureGetUsage;
		webgpu_exports_table.wgpu_texture_get_width = wgpuTextureGetWidth;
		webgpu_exports_table.wgpu_texture_set_label = wgpuTextureSetLabel;
		webgpu_exports_table.wgpu_texture_reference = wgpuTextureReference;
		webgpu_exports_table.wgpu_texture_release = wgpuTextureRelease;

		// TextureView
		webgpu_exports_table.wgpu_texture_view_set_label = wgpuTextureViewSetLabel;
		webgpu_exports_table.wgpu_texture_view_reference = wgpuTextureViewReference;
		webgpu_exports_table.wgpu_texture_view_release = wgpuTextureViewRelease;

		// Native wgpu extensions (from wgpu.h)
		webgpu_exports_table.wgpu_generate_report = wgpuGenerateReport;
		webgpu_exports_table.wgpu_instance_enumerate_adapters = wgpuInstanceEnumerateAdapters;
		webgpu_exports_table.wgpu_queue_submit_for_index = wgpuQueueSubmitForIndex;
		webgpu_exports_table.wgpu_device_poll = wgpuDevicePoll;
		webgpu_exports_table.wgpu_set_log_callback = wgpuSetLogCallback;
		webgpu_exports_table.wgpu_set_log_level = wgpuSetLogLevel;
		webgpu_exports_table.wgpu_get_version = wgpuGetVersion;
		webgpu_exports_table.wgpu_render_pass_encoder_set_push_constants = wgpuRenderPassEncoderSetPushConstants;
		webgpu_exports_table.wgpu_render_pass_encoder_multi_draw_indirect = wgpuRenderPassEncoderMultiDrawIndirect;
		webgpu_exports_table.wgpu_render_pass_encoder_multi_draw_indexed_indirect = wgpuRenderPassEncoderMultiDrawIndexedIndirect;
		webgpu_exports_table.wgpu_render_pass_encoder_multi_draw_indirect_count = wgpuRenderPassEncoderMultiDrawIndirectCount;
		webgpu_exports_table.wgpu_render_pass_encoder_multi_draw_indexed_indirect_count = wgpuRenderPassEncoderMultiDrawIndexedIndirectCount;
		webgpu_exports_table.wgpu_compute_pass_encoder_begin_pipeline_statistics_query = wgpuComputePassEncoderBeginPipelineStatisticsQuery;
		webgpu_exports_table.wgpu_compute_pass_encoder_end_pipeline_statistics_query = wgpuComputePassEncoderEndPipelineStatisticsQuery;
		webgpu_exports_table.wgpu_render_pass_encoder_begin_pipeline_statistics_query = wgpuRenderPassEncoderBeginPipelineStatisticsQuery;
		webgpu_exports_table.wgpu_render_pass_encoder_end_pipeline_statistics_query = wgpuRenderPassEncoderEndPipelineStatisticsQuery;

		return &webgpu_exports_table;
	}
}