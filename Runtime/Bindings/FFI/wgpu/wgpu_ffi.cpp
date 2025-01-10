#include "wgpu_ffi.hpp"

const char* wgpu_version() {
	return WGPU_VERSION;
}

namespace wgpu_ffi {

	void* getExportsTable() {
		static struct static_wgpu_exports_table exports = {

			// Custom
			.wgpu_version = wgpu_version,

			// Global
			.wgpu_create_instance = wgpuCreateInstance,
			.wgpu_get_proc_address = wgpuGetProcAddress,

			// Adapter
			.wgpu_adapter_enumerate_features = wgpuAdapterEnumerateFeatures,
			.wgpu_adapter_get_info = wgpuAdapterGetInfo,
			.wgpu_adapter_get_limits = wgpuAdapterGetLimits,
			.wgpu_adapter_has_feature = wgpuAdapterHasFeature,
			.wgpu_adapter_request_device = wgpuAdapterRequestDevice,
			.wgpu_adapter_reference = wgpuAdapterReference,
			.wgpu_adapter_release = wgpuAdapterRelease,

			// AdapterInfo
			.wgpu_adapter_info_free_members = wgpuAdapterInfoFreeMembers,

			// BindGroup
			.wgpu_bind_group_set_label = wgpuBindGroupSetLabel,
			.wgpu_bind_group_reference = wgpuBindGroupReference,
			.wgpu_bind_group_release = wgpuBindGroupRelease,

			// BindGroupLayout
			.wgpu_bind_group_layout_set_label = wgpuBindGroupLayoutSetLabel,
			.wgpu_bind_group_layout_reference = wgpuBindGroupLayoutReference,
			.wgpu_bind_group_layout_release = wgpuBindGroupLayoutRelease,

			// Buffer
			.wgpu_buffer_destroy = wgpuBufferDestroy,
			.wgpu_buffer_get_const_mapped_range = wgpuBufferGetConstMappedRange,
			.wgpu_buffer_get_map_state = wgpuBufferGetMapState,
			.wgpu_buffer_get_mapped_range = wgpuBufferGetMappedRange,
			.wgpu_buffer_get_size = wgpuBufferGetSize,
			.wgpu_buffer_get_usage = wgpuBufferGetUsage,
			.wgpu_buffer_map_async = wgpuBufferMapAsync,
			.wgpu_buffer_set_label = wgpuBufferSetLabel,
			.wgpu_buffer_unmap = wgpuBufferUnmap,
			.wgpu_buffer_reference = wgpuBufferReference,
			.wgpu_buffer_release = wgpuBufferRelease,

			// CommandBuffer
			.wgpu_command_buffer_set_label = wgpuCommandBufferSetLabel,
			.wgpu_command_buffer_reference = wgpuCommandBufferReference,
			.wgpu_command_buffer_release = wgpuCommandBufferRelease,

			// CommandEncoder
			.wgpu_command_encoder_begin_compute_pass = wgpuCommandEncoderBeginComputePass,
			.wgpu_command_encoder_begin_render_pass = wgpuCommandEncoderBeginRenderPass,
			.wgpu_command_encoder_clear_buffer = wgpuCommandEncoderClearBuffer,
			.wgpu_command_encoder_copy_buffer_to_buffer = wgpuCommandEncoderCopyBufferToBuffer,
			.wgpu_command_encoder_copy_buffer_to_texture = wgpuCommandEncoderCopyBufferToTexture,
			.wgpu_command_encoder_copy_texture_to_buffer = wgpuCommandEncoderCopyTextureToBuffer,
			.wgpu_command_encoder_copy_texture_to_texture = wgpuCommandEncoderCopyTextureToTexture,
			.wgpu_command_encoder_finish = wgpuCommandEncoderFinish,
			.wgpu_command_encoder_insert_debug_marker = wgpuCommandEncoderInsertDebugMarker,
			.wgpu_command_encoder_pop_debug_group = wgpuCommandEncoderPopDebugGroup,
			.wgpu_command_encoder_push_debug_group = wgpuCommandEncoderPushDebugGroup,
			.wgpu_command_encoder_resolve_query_set = wgpuCommandEncoderResolveQuerySet,
			.wgpu_command_encoder_set_label = wgpuCommandEncoderSetLabel,
			.wgpu_command_encoder_write_timestamp = wgpuCommandEncoderWriteTimestamp,
			.wgpu_command_encoder_reference = wgpuCommandEncoderReference,
			.wgpu_command_encoder_release = wgpuCommandEncoderRelease,

			// ComputePassEncoder
			.wgpu_compute_pass_encoder_dispatch_workgroups = wgpuComputePassEncoderDispatchWorkgroups,
			.wgpu_compute_pass_encoder_dispatch_workgroups_indirect = wgpuComputePassEncoderDispatchWorkgroupsIndirect,
			.wgpu_compute_pass_encoder_end = wgpuComputePassEncoderEnd,
			.wgpu_compute_pass_encoder_insert_debug_marker = wgpuComputePassEncoderInsertDebugMarker,
			.wgpu_compute_pass_encoder_pop_debug_group = wgpuComputePassEncoderPopDebugGroup,
			.wgpu_compute_pass_encoder_push_debug_group = wgpuComputePassEncoderPushDebugGroup,
			.wgpu_compute_pass_encoder_set_bind_group = wgpuComputePassEncoderSetBindGroup,
			.wgpu_compute_pass_encoder_set_label = wgpuComputePassEncoderSetLabel,
			.wgpu_compute_pass_encoder_set_pipeline = wgpuComputePassEncoderSetPipeline,
			.wgpu_compute_pass_encoder_reference = wgpuComputePassEncoderReference,
			.wgpu_compute_pass_encoder_release = wgpuComputePassEncoderRelease,

			// ComputePipeline
			.wgpu_compute_pipeline_get_bind_group_layout = wgpuComputePipelineGetBindGroupLayout,
			.wgpu_compute_pipeline_set_label = wgpuComputePipelineSetLabel,
			.wgpu_compute_pipeline_reference = wgpuComputePipelineReference,
			.wgpu_compute_pipeline_release = wgpuComputePipelineRelease,

			// Device
			.wgpu_device_create_bind_group = wgpuDeviceCreateBindGroup,
			.wgpu_device_create_bind_group_layout = wgpuDeviceCreateBindGroupLayout,
			.wgpu_device_create_buffer = wgpuDeviceCreateBuffer,
			.wgpu_device_create_command_encoder = wgpuDeviceCreateCommandEncoder,
			.wgpu_device_create_compute_pipeline = wgpuDeviceCreateComputePipeline,
			.wgpu_device_create_compute_pipeline_async = wgpuDeviceCreateComputePipelineAsync,
			.wgpu_device_create_pipeline_layout = wgpuDeviceCreatePipelineLayout,
			.wgpu_device_create_query_set = wgpuDeviceCreateQuerySet,
			.wgpu_device_create_render_bundle_encoder = wgpuDeviceCreateRenderBundleEncoder,
			.wgpu_device_create_render_pipeline = wgpuDeviceCreateRenderPipeline,
			.wgpu_device_create_render_pipeline_async = wgpuDeviceCreateRenderPipelineAsync,
			.wgpu_device_create_sampler = wgpuDeviceCreateSampler,
			.wgpu_device_create_shader_module = wgpuDeviceCreateShaderModule,
			.wgpu_device_create_texture = wgpuDeviceCreateTexture,
			.wgpu_device_destroy = wgpuDeviceDestroy,
			.wgpu_device_enumerate_features = wgpuDeviceEnumerateFeatures,
			.wgpu_device_get_limits = wgpuDeviceGetLimits,
			.wgpu_device_get_queue = wgpuDeviceGetQueue,
			.wgpu_device_has_feature = wgpuDeviceHasFeature,
			.wgpu_device_pop_error_scope = wgpuDevicePopErrorScope,
			.wgpu_device_push_error_scope = wgpuDevicePushErrorScope,
			.wgpu_device_set_label = wgpuDeviceSetLabel,
			.wgpu_device_reference = wgpuDeviceReference,
			.wgpu_device_release = wgpuDeviceRelease,

			// Instance
			.wgpu_instance_create_surface = wgpuInstanceCreateSurface,
			.wgpu_instance_has_wgsl_language_feature = wgpuInstanceHasWGSLLanguageFeature,
			.wgpu_instance_process_events = wgpuInstanceProcessEvents,
			.wgpu_instance_request_adapter = wgpuInstanceRequestAdapter,
			.wgpu_instance_reference = wgpuInstanceReference,
			.wgpu_instance_release = wgpuInstanceRelease,

			// PipelineLayout
			.wgpu_pipeline_layout_set_label = wgpuPipelineLayoutSetLabel,
			.wgpu_pipeline_layout_reference = wgpuPipelineLayoutReference,
			.wgpu_pipeline_layout_release = wgpuPipelineLayoutRelease,

			// QuerySet
			.wgpu_query_set_destroy = wgpuQuerySetDestroy,
			.wgpu_query_set_get_count = wgpuQuerySetGetCount,
			.wgpu_query_set_get_type = wgpuQuerySetGetType,
			.wgpu_query_set_set_label = wgpuQuerySetSetLabel,
			.wgpu_query_set_reference = wgpuQuerySetReference,
			.wgpu_query_set_release = wgpuQuerySetRelease,

			// Queue
			.wgpu_queue_on_submitted_work_done = wgpuQueueOnSubmittedWorkDone,
			.wgpu_queue_set_label = wgpuQueueSetLabel,
			.wgpu_queue_submit = wgpuQueueSubmit,
			.wgpu_queue_write_buffer = wgpuQueueWriteBuffer,
			.wgpu_queue_write_texture = wgpuQueueWriteTexture,
			.wgpu_queue_reference = wgpuQueueReference,
			.wgpu_queue_release = wgpuQueueRelease,

			// RenderBundle
			.wgpu_render_bundle_set_label = wgpuRenderBundleSetLabel,
			.wgpu_render_bundle_reference = wgpuRenderBundleReference,
			.wgpu_render_bundle_release = wgpuRenderBundleRelease,

			// RenderBundleEncoder
			.wgpu_render_bundle_encoder_draw = wgpuRenderBundleEncoderDraw,
			.wgpu_render_bundle_encoder_draw_indexed = wgpuRenderBundleEncoderDrawIndexed,
			.wgpu_render_bundle_encoder_draw_indexed_indirect = wgpuRenderBundleEncoderDrawIndexedIndirect,
			.wgpu_render_bundle_encoder_draw_indirect = wgpuRenderBundleEncoderDrawIndirect,
			.wgpu_render_bundle_encoder_finish = wgpuRenderBundleEncoderFinish,
			.wgpu_render_bundle_encoder_insert_debug_marker = wgpuRenderBundleEncoderInsertDebugMarker,
			.wgpu_render_bundle_encoder_pop_debug_group = wgpuRenderBundleEncoderPopDebugGroup,
			.wgpu_render_bundle_encoder_push_debug_group = wgpuRenderBundleEncoderPushDebugGroup,
			.wgpu_render_bundle_encoder_set_bind_group = wgpuRenderBundleEncoderSetBindGroup,
			.wgpu_render_bundle_encoder_set_index_buffer = wgpuRenderBundleEncoderSetIndexBuffer,
			.wgpu_render_bundle_encoder_set_label = wgpuRenderBundleEncoderSetLabel,
			.wgpu_render_bundle_encoder_set_pipeline = wgpuRenderBundleEncoderSetPipeline,
			.wgpu_render_bundle_encoder_set_vertex_buffer = wgpuRenderBundleEncoderSetVertexBuffer,
			.wgpu_render_bundle_encoder_reference = wgpuRenderBundleEncoderReference,
			.wgpu_render_bundle_encoder_release = wgpuRenderBundleEncoderRelease,

			// RenderPassEncoder
			.wgpu_render_pass_encoder_begin_occlusion_query = wgpuRenderPassEncoderBeginOcclusionQuery,
			.wgpu_render_pass_encoder_draw = wgpuRenderPassEncoderDraw,
			.wgpu_render_pass_encoder_draw_indexed = wgpuRenderPassEncoderDrawIndexed,
			.wgpu_render_pass_encoder_draw_indexed_indirect = wgpuRenderPassEncoderDrawIndexedIndirect,
			.wgpu_render_pass_encoder_draw_indirect = wgpuRenderPassEncoderDrawIndirect,
			.wgpu_render_pass_encoder_end = wgpuRenderPassEncoderEnd,
			.wgpu_render_pass_encoder_end_occlusion_query = wgpuRenderPassEncoderEndOcclusionQuery,
			.wgpu_render_pass_encoder_execute_bundles = wgpuRenderPassEncoderExecuteBundles,
			.wgpu_render_pass_encoder_insert_debug_marker = wgpuRenderPassEncoderInsertDebugMarker,
			.wgpu_render_pass_encoder_pop_debug_group = wgpuRenderPassEncoderPopDebugGroup,
			.wgpu_render_pass_encoder_push_debug_group = wgpuRenderPassEncoderPushDebugGroup,
			.wgpu_render_pass_encoder_set_bind_group = wgpuRenderPassEncoderSetBindGroup,
			.wgpu_render_pass_encoder_set_blend_constant = wgpuRenderPassEncoderSetBlendConstant,
			.wgpu_render_pass_encoder_set_index_buffer = wgpuRenderPassEncoderSetIndexBuffer,
			.wgpu_render_pass_encoder_set_label = wgpuRenderPassEncoderSetLabel,
			.wgpu_render_pass_encoder_set_pipeline = wgpuRenderPassEncoderSetPipeline,
			.wgpu_render_pass_encoder_set_scissor_rect = wgpuRenderPassEncoderSetScissorRect,
			.wgpu_render_pass_encoder_set_stencil_reference = wgpuRenderPassEncoderSetStencilReference,
			.wgpu_render_pass_encoder_set_vertex_buffer = wgpuRenderPassEncoderSetVertexBuffer,
			.wgpu_render_pass_encoder_set_viewport = wgpuRenderPassEncoderSetViewport,
			.wgpu_render_pass_encoder_reference = wgpuRenderPassEncoderReference,
			.wgpu_render_pass_encoder_release = wgpuRenderPassEncoderRelease,

			// RenderPipeline
			.wgpu_render_pipeline_get_bind_group_layout = wgpuRenderPipelineGetBindGroupLayout,
			.wgpu_render_pipeline_set_label = wgpuRenderPipelineSetLabel,
			.wgpu_render_pipeline_reference = wgpuRenderPipelineReference,
			.wgpu_render_pipeline_release = wgpuRenderPipelineRelease,

			// Sampler
			.wgpu_sampler_set_label = wgpuSamplerSetLabel,
			.wgpu_sampler_reference = wgpuSamplerReference,
			.wgpu_sampler_release = wgpuSamplerRelease,

			// ShaderModule
			.wgpu_shader_module_get_compilation_info = wgpuShaderModuleGetCompilationInfo,
			.wgpu_shader_module_set_label = wgpuShaderModuleSetLabel,
			.wgpu_shader_module_reference = wgpuShaderModuleReference,
			.wgpu_shader_module_release = wgpuShaderModuleRelease,

			// Surface
			.wgpu_surface_configure = wgpuSurfaceConfigure,
			.wgpu_surface_get_capabilities = wgpuSurfaceGetCapabilities,
			.wgpu_surface_get_current_texture = wgpuSurfaceGetCurrentTexture,
			.wgpu_surface_present = wgpuSurfacePresent,
			.wgpu_surface_set_label = wgpuSurfaceSetLabel,
			.wgpu_surface_unconfigure = wgpuSurfaceUnconfigure,
			.wgpu_surface_reference = wgpuSurfaceReference,
			.wgpu_surface_release = wgpuSurfaceRelease,

			// SurfaceCapabilities
			.wgpu_surface_capabilities_free_members = wgpuSurfaceCapabilitiesFreeMembers,

			// Texture
			.wgpu_texture_create_view = wgpuTextureCreateView,
			.wgpu_texture_destroy = wgpuTextureDestroy,
			.wgpu_texture_get_depth_or_array_layers = wgpuTextureGetDepthOrArrayLayers,
			.wgpu_texture_get_dimension = wgpuTextureGetDimension,
			.wgpu_texture_get_format = wgpuTextureGetFormat,
			.wgpu_texture_get_height = wgpuTextureGetHeight,
			.wgpu_texture_get_mip_level_count = wgpuTextureGetMipLevelCount,
			.wgpu_texture_get_sample_count = wgpuTextureGetSampleCount,
			.wgpu_texture_get_usage = wgpuTextureGetUsage,
			.wgpu_texture_get_width = wgpuTextureGetWidth,
			.wgpu_texture_set_label = wgpuTextureSetLabel,
			.wgpu_texture_reference = wgpuTextureReference,
			.wgpu_texture_release = wgpuTextureRelease,

			// TextureView
			.wgpu_texture_view_set_label = wgpuTextureViewSetLabel,
			.wgpu_texture_view_reference = wgpuTextureViewReference,
			.wgpu_texture_view_release = wgpuTextureViewRelease,

			// Native wgpu extensions (from wgpu.h)
			.wgpu_generate_report = wgpuGenerateReport,
			.wgpu_instance_enumerate_adapters = wgpuInstanceEnumerateAdapters,
			.wgpu_queue_submit_for_index = wgpuQueueSubmitForIndex,
			.wgpu_device_create_shader_module_spirv = wgpuDeviceCreateShaderModuleSpirV,
			.wgpu_device_poll = wgpuDevicePoll,
			.wgpu_set_log_callback = wgpuSetLogCallback,
			.wgpu_set_log_level = wgpuSetLogLevel,
			.wgpu_get_version = wgpuGetVersion,
			.wgpu_compute_pass_encoder_set_push_constants = wgpuComputePassEncoderSetPushConstants,
			.wgpu_render_pass_encoder_set_push_constants = wgpuRenderPassEncoderSetPushConstants,
			.wgpu_render_bundle_encoder_set_push_constants = wgpuRenderBundleEncoderSetPushConstants,
			.wgpu_render_pass_encoder_multi_draw_indirect = wgpuRenderPassEncoderMultiDrawIndirect,
			.wgpu_render_pass_encoder_multi_draw_indexed_indirect = wgpuRenderPassEncoderMultiDrawIndexedIndirect,
			.wgpu_render_pass_encoder_multi_draw_indirect_count = wgpuRenderPassEncoderMultiDrawIndirectCount,
			.wgpu_render_pass_encoder_multi_draw_indexed_indirect_count = wgpuRenderPassEncoderMultiDrawIndexedIndirectCount,
			.wgpu_compute_pass_encoder_begin_pipeline_statistics_query = wgpuComputePassEncoderBeginPipelineStatisticsQuery,
			.wgpu_compute_pass_encoder_end_pipeline_statistics_query = wgpuComputePassEncoderEndPipelineStatisticsQuery,
			.wgpu_render_pass_encoder_begin_pipeline_statistics_query = wgpuRenderPassEncoderBeginPipelineStatisticsQuery,
			.wgpu_render_pass_encoder_end_pipeline_statistics_query = wgpuRenderPassEncoderEndPipelineStatisticsQuery,
			.wgpu_compute_pass_encoder_write_timestamp = wgpuComputePassEncoderWriteTimestamp,
			.wgpu_render_pass_encoder_write_timestamp = wgpuRenderPassEncoderWriteTimestamp,
		};

		return &exports;
	}
}