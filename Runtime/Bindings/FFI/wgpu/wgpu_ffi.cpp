#include "wgpu_ffi.hpp"

const char* wgpu_version() {
	return WGPU_VERSION;
}

namespace wgpu_ffi {

	void* getExportsTable() {
		static struct static_wgpu_exports_table wgpu_exports_table;

		// Custom
		wgpu_exports_table.wgpu_version = wgpu_version;

		// Global
		wgpu_exports_table.wgpu_create_instance = wgpuCreateInstance;
		wgpu_exports_table.wgpu_get_proc_address = wgpuGetProcAddress;

		// Adapter
		wgpu_exports_table.wgpu_adapter_enumerate_features = wgpuAdapterEnumerateFeatures;
		wgpu_exports_table.wgpu_adapter_get_limits = wgpuAdapterGetLimits;
		wgpu_exports_table.wgpu_adapter_get_properties = wgpuAdapterGetProperties;
		wgpu_exports_table.wgpu_adapter_has_feature = wgpuAdapterHasFeature;
		wgpu_exports_table.wgpu_adapter_request_device = wgpuAdapterRequestDevice;
		wgpu_exports_table.wgpu_adapter_reference = wgpuAdapterReference;
		wgpu_exports_table.wgpu_adapter_release = wgpuAdapterRelease;

		// BindGroup
		wgpu_exports_table.wgpu_bind_group_set_label = wgpuBindGroupSetLabel;
		wgpu_exports_table.wgpu_bind_group_reference = wgpuBindGroupReference;
		wgpu_exports_table.wgpu_bind_group_release = wgpuBindGroupRelease;

		// BindGroupLayout
		wgpu_exports_table.wgpu_bind_group_layout_set_label = wgpuBindGroupLayoutSetLabel;
		wgpu_exports_table.wgpu_bind_group_layout_reference = wgpuBindGroupLayoutReference;
		wgpu_exports_table.wgpu_bind_group_layout_release = wgpuBindGroupLayoutRelease;

		// Buffer
		wgpu_exports_table.wgpu_buffer_destroy = wgpuBufferDestroy;
		wgpu_exports_table.wgpu_buffer_get_const_mapped_range = wgpuBufferGetConstMappedRange;
		wgpu_exports_table.wgpu_buffer_get_map_state = wgpuBufferGetMapState;
		wgpu_exports_table.wgpu_buffer_get_mapped_range = wgpuBufferGetMappedRange;
		wgpu_exports_table.wgpu_buffer_get_size = wgpuBufferGetSize;
		wgpu_exports_table.wgpu_buffer_get_usage = wgpuBufferGetUsage;
		wgpu_exports_table.wgpu_buffer_map_async = wgpuBufferMapAsync;
		wgpu_exports_table.wgpu_buffer_set_label = wgpuBufferSetLabel;
		wgpu_exports_table.wgpu_buffer_unmap = wgpuBufferUnmap;
		wgpu_exports_table.wgpu_buffer_reference = wgpuBufferReference;
		wgpu_exports_table.wgpu_buffer_release = wgpuBufferRelease;

		// CommandBuffer
		wgpu_exports_table.wgpu_command_buffer_reference = wgpuCommandBufferReference;
		wgpu_exports_table.wgpu_command_buffer_release = wgpuCommandBufferRelease;
		wgpu_exports_table.wgpu_command_buffer_set_label = wgpuCommandBufferSetLabel;

		// CommandEncoder
		wgpu_exports_table.wgpu_command_encoder_begin_compute_pass = wgpuCommandEncoderBeginComputePass;
		wgpu_exports_table.wgpu_command_encoder_begin_render_pass = wgpuCommandEncoderBeginRenderPass;
		wgpu_exports_table.wgpu_command_encoder_clear_buffer = wgpuCommandEncoderClearBuffer;
		wgpu_exports_table.wgpu_command_encoder_copy_buffer_to_buffer = wgpuCommandEncoderCopyBufferToBuffer;
		wgpu_exports_table.wgpu_command_encoder_copy_buffer_to_texture = wgpuCommandEncoderCopyBufferToTexture;
		wgpu_exports_table.wgpu_command_encoder_copy_texture_to_buffer = wgpuCommandEncoderCopyTextureToBuffer;
		wgpu_exports_table.wgpu_command_encoder_copy_texture_to_texture = wgpuCommandEncoderCopyTextureToTexture;
		wgpu_exports_table.wgpu_command_encoder_finish = wgpuCommandEncoderFinish;
		wgpu_exports_table.wgpu_command_encoder_insert_debug_marker = wgpuCommandEncoderInsertDebugMarker;
		wgpu_exports_table.wgpu_command_encoder_pop_debug_group = wgpuCommandEncoderPopDebugGroup;
		wgpu_exports_table.wgpu_command_encoder_push_debug_group = wgpuCommandEncoderPushDebugGroup;
		wgpu_exports_table.wgpu_command_encoder_resolve_query_set = wgpuCommandEncoderResolveQuerySet;
		wgpu_exports_table.wgpu_command_encoder_set_label = wgpuCommandEncoderSetLabel;
		wgpu_exports_table.wgpu_command_encoder_write_timestamp = wgpuCommandEncoderWriteTimestamp;
		wgpu_exports_table.wgpu_command_encoder_reference = wgpuCommandEncoderReference;
		wgpu_exports_table.wgpu_command_encoder_release = wgpuCommandEncoderRelease;

		// ComputePassEncoder
		wgpu_exports_table.wgpu_compute_pass_encoder_dispatch_workgroups = wgpuComputePassEncoderDispatchWorkgroups;
		wgpu_exports_table.wgpu_compute_pass_encoder_dispatch_workgroups_indirect = wgpuComputePassEncoderDispatchWorkgroupsIndirect;
		wgpu_exports_table.wgpu_compute_pass_encoder_end = wgpuComputePassEncoderEnd;
		wgpu_exports_table.wgpu_compute_pass_encoder_insert_debug_marker = wgpuComputePassEncoderInsertDebugMarker;
		wgpu_exports_table.wgpu_compute_pass_encoder_pop_debug_group = wgpuComputePassEncoderPopDebugGroup;
		wgpu_exports_table.wgpu_compute_pass_encoder_push_debug_group = wgpuComputePassEncoderPushDebugGroup;
		wgpu_exports_table.wgpu_compute_pass_encoder_set_bind_group = wgpuComputePassEncoderSetBindGroup;
		wgpu_exports_table.wgpu_compute_pass_encoder_set_label = wgpuComputePassEncoderSetLabel;
		wgpu_exports_table.wgpu_compute_pass_encoder_set_pipeline = wgpuComputePassEncoderSetPipeline;
		wgpu_exports_table.wgpu_compute_pass_encoder_reference = wgpuComputePassEncoderReference;
		wgpu_exports_table.wgpu_compute_pass_encoder_release = wgpuComputePassEncoderRelease;

		// ComputePipeline
		wgpu_exports_table.wgpu_compute_pipeline_get_bind_group_layout = wgpuComputePipelineGetBindGroupLayout;
		wgpu_exports_table.wgpu_compute_pipeline_set_label = wgpuComputePipelineSetLabel;
		wgpu_exports_table.wgpu_compute_pipeline_reference = wgpuComputePipelineReference;
		wgpu_exports_table.wgpu_compute_pipeline_release = wgpuComputePipelineRelease;

		// Device
		wgpu_exports_table.wgpu_device_create_bind_group = wgpuDeviceCreateBindGroup;
		wgpu_exports_table.wgpu_device_create_bind_group_layout = wgpuDeviceCreateBindGroupLayout;
		wgpu_exports_table.wgpu_device_create_buffer = wgpuDeviceCreateBuffer;
		wgpu_exports_table.wgpu_device_create_command_encoder = wgpuDeviceCreateCommandEncoder;
		wgpu_exports_table.wgpu_device_create_compute_pipeline = wgpuDeviceCreateComputePipeline;
		wgpu_exports_table.wgpu_device_create_compute_pipeline_async = wgpuDeviceCreateComputePipelineAsync;
		wgpu_exports_table.wgpu_device_create_pipeline_layout = wgpuDeviceCreatePipelineLayout;
		wgpu_exports_table.wgpu_device_create_query_set = wgpuDeviceCreateQuerySet;
		wgpu_exports_table.wgpu_device_create_render_bundle_encoder = wgpuDeviceCreateRenderBundleEncoder;
		wgpu_exports_table.wgpu_device_create_render_pipeline = wgpuDeviceCreateRenderPipeline;
		wgpu_exports_table.wgpu_device_create_render_pipeline_async = wgpuDeviceCreateRenderPipelineAsync;
		wgpu_exports_table.wgpu_device_create_sampler = wgpuDeviceCreateSampler;
		wgpu_exports_table.wgpu_device_create_shader_module = wgpuDeviceCreateShaderModule;
		wgpu_exports_table.wgpu_device_create_texture = wgpuDeviceCreateTexture;
		wgpu_exports_table.wgpu_device_destroy = wgpuDeviceDestroy;
		wgpu_exports_table.wgpu_device_enumerate_features = wgpuDeviceEnumerateFeatures;
		wgpu_exports_table.wgpu_device_get_limits = wgpuDeviceGetLimits;
		wgpu_exports_table.wgpu_device_get_queue = wgpuDeviceGetQueue;
		wgpu_exports_table.wgpu_device_has_feature = wgpuDeviceHasFeature;
		wgpu_exports_table.wgpu_device_pop_error_scope = wgpuDevicePopErrorScope;
		wgpu_exports_table.wgpu_device_push_error_scope = wgpuDevicePushErrorScope;
		wgpu_exports_table.wgpu_device_set_label = wgpuDeviceSetLabel;
		wgpu_exports_table.wgpu_device_set_uncaptured_error_callback = wgpuDeviceSetUncapturedErrorCallback;
		wgpu_exports_table.wgpu_device_reference = wgpuDeviceReference;
		wgpu_exports_table.wgpu_device_release = wgpuDeviceRelease;

		// Instance
		wgpu_exports_table.wgpu_instance_create_surface = wgpuInstanceCreateSurface;
		wgpu_exports_table.wgpu_instance_process_events = wgpuInstanceProcessEvents;
		wgpu_exports_table.wgpu_instance_request_adapter = wgpuInstanceRequestAdapter;
		wgpu_exports_table.wgpu_instance_reference = wgpuInstanceReference;
		wgpu_exports_table.wgpu_instance_release = wgpuInstanceRelease;

		// PipelineLayout
		wgpu_exports_table.wgpu_pipeline_layout_set_label = wgpuPipelineLayoutSetLabel;
		wgpu_exports_table.wgpu_pipeline_layout_reference = wgpuPipelineLayoutReference;
		wgpu_exports_table.wgpu_pipeline_layout_release = wgpuPipelineLayoutRelease;

		// QuerySet
		wgpu_exports_table.wgpu_query_set_destroy = wgpuQuerySetDestroy;
		wgpu_exports_table.wgpu_query_set_get_count = wgpuQuerySetGetCount;
		wgpu_exports_table.wgpu_query_set_get_type = wgpuQuerySetGetType;
		wgpu_exports_table.wgpu_query_set_set_label = wgpuQuerySetSetLabel;
		wgpu_exports_table.wgpu_query_set_reference = wgpuQuerySetReference;
		wgpu_exports_table.wgpu_query_set_release = wgpuQuerySetRelease;

		// Queue
		wgpu_exports_table.wgpu_queue_on_submitted_work_done = wgpuQueueOnSubmittedWorkDone;
		wgpu_exports_table.wgpu_queue_set_label = wgpuQueueSetLabel;
		wgpu_exports_table.wgpu_queue_submit = wgpuQueueSubmit;
		wgpu_exports_table.wgpu_queue_write_buffer = wgpuQueueWriteBuffer;
		wgpu_exports_table.wgpu_queue_write_texture = wgpuQueueWriteTexture;
		wgpu_exports_table.wgpu_queue_reference = wgpuQueueReference;
		wgpu_exports_table.wgpu_queue_release = wgpuQueueRelease;

		// RenderBundle
		wgpu_exports_table.wgpu_render_bundle_set_label = wgpuRenderBundleSetLabel;
		wgpu_exports_table.wgpu_render_bundle_reference = wgpuRenderBundleReference;
		wgpu_exports_table.wgpu_render_bundle_release = wgpuRenderBundleRelease;

		// RenderBundleEncoder
		wgpu_exports_table.wgpu_render_bundle_encoder_draw = wgpuRenderBundleEncoderDraw;
		wgpu_exports_table.wgpu_render_bundle_encoder_draw_indexed = wgpuRenderBundleEncoderDrawIndexed;
		wgpu_exports_table.wgpu_render_bundle_encoder_draw_indexed_indirect = wgpuRenderBundleEncoderDrawIndexedIndirect;
		wgpu_exports_table.wgpu_render_bundle_encoder_draw_indirect = wgpuRenderBundleEncoderDrawIndirect;
		wgpu_exports_table.wgpu_render_bundle_encoder_finish = wgpuRenderBundleEncoderFinish;
		wgpu_exports_table.wgpu_render_bundle_encoder_insert_debug_marker = wgpuRenderBundleEncoderInsertDebugMarker;
		wgpu_exports_table.wgpu_render_bundle_encoder_pop_debug_group = wgpuRenderBundleEncoderPopDebugGroup;
		wgpu_exports_table.wgpu_render_bundle_encoder_push_debug_group = wgpuRenderBundleEncoderPushDebugGroup;
		wgpu_exports_table.wgpu_render_bundle_encoder_set_bind_group = wgpuRenderBundleEncoderSetBindGroup;
		wgpu_exports_table.wgpu_render_bundle_encoder_set_index_buffer = wgpuRenderBundleEncoderSetIndexBuffer;
		wgpu_exports_table.wgpu_render_bundle_encoder_set_label = wgpuRenderBundleEncoderSetLabel;
		wgpu_exports_table.wgpu_render_bundle_encoder_set_pipeline = wgpuRenderBundleEncoderSetPipeline;
		wgpu_exports_table.wgpu_render_bundle_encoder_set_vertex_buffer = wgpuRenderBundleEncoderSetVertexBuffer;
		wgpu_exports_table.wgpu_render_bundle_encoder_reference = wgpuRenderBundleEncoderReference;
		wgpu_exports_table.wgpu_render_bundle_encoder_release = wgpuRenderBundleEncoderRelease;

		// RenderPassEncoder
		wgpu_exports_table.wgpu_render_pass_encoder_begin_occlusion_query = wgpuRenderPassEncoderBeginOcclusionQuery;
		wgpu_exports_table.wgpu_render_pass_encoder_draw = wgpuRenderPassEncoderDraw;
		wgpu_exports_table.wgpu_render_pass_encoder_draw_indexed = wgpuRenderPassEncoderDrawIndexed;
		wgpu_exports_table.wgpu_render_pass_encoder_draw_indexed_indirect = wgpuRenderPassEncoderDrawIndexedIndirect;
		wgpu_exports_table.wgpu_render_pass_encoder_draw_indirect = wgpuRenderPassEncoderDrawIndirect;
		wgpu_exports_table.wgpu_render_pass_encoder_end = wgpuRenderPassEncoderEnd;
		wgpu_exports_table.wgpu_render_pass_encoder_end_occlusion_query = wgpuRenderPassEncoderEndOcclusionQuery;
		wgpu_exports_table.wgpu_render_pass_encoder_execute_bundles = wgpuRenderPassEncoderExecuteBundles;
		wgpu_exports_table.wgpu_render_pass_encoder_insert_debug_marker = wgpuRenderPassEncoderInsertDebugMarker;
		wgpu_exports_table.wgpu_render_pass_encoder_pop_debug_group = wgpuRenderPassEncoderPopDebugGroup;
		wgpu_exports_table.wgpu_render_pass_encoder_push_debug_group = wgpuRenderPassEncoderPushDebugGroup;
		wgpu_exports_table.wgpu_render_pass_encoder_set_bind_group = wgpuRenderPassEncoderSetBindGroup;
		wgpu_exports_table.wgpu_render_pass_encoder_set_blend_constant = wgpuRenderPassEncoderSetBlendConstant;
		wgpu_exports_table.wgpu_render_pass_encoder_set_index_buffer = wgpuRenderPassEncoderSetIndexBuffer;
		wgpu_exports_table.wgpu_render_pass_encoder_set_label = wgpuRenderPassEncoderSetLabel;
		wgpu_exports_table.wgpu_render_pass_encoder_set_pipeline = wgpuRenderPassEncoderSetPipeline;
		wgpu_exports_table.wgpu_render_pass_encoder_set_scissor_rect = wgpuRenderPassEncoderSetScissorRect;
		wgpu_exports_table.wgpu_render_pass_encoder_set_stencil_reference = wgpuRenderPassEncoderSetStencilReference;
		wgpu_exports_table.wgpu_render_pass_encoder_set_vertex_buffer = wgpuRenderPassEncoderSetVertexBuffer;
		wgpu_exports_table.wgpu_render_pass_encoder_set_viewport = wgpuRenderPassEncoderSetViewport;
		wgpu_exports_table.wgpu_render_pass_encoder_reference = wgpuRenderPassEncoderReference;
		wgpu_exports_table.wgpu_render_pass_encoder_release = wgpuRenderPassEncoderRelease;

		// RenderPipeline
		wgpu_exports_table.wgpu_render_pipeline_get_bind_group_layout = wgpuRenderPipelineGetBindGroupLayout;
		wgpu_exports_table.wgpu_render_pipeline_set_label = wgpuRenderPipelineSetLabel;
		wgpu_exports_table.wgpu_render_pipeline_reference = wgpuRenderPipelineReference;
		wgpu_exports_table.wgpu_render_pipeline_release = wgpuRenderPipelineRelease;

		// Sampler
		wgpu_exports_table.wgpu_sampler_set_label = wgpuSamplerSetLabel;
		wgpu_exports_table.wgpu_sampler_reference = wgpuSamplerReference;
		wgpu_exports_table.wgpu_sampler_release = wgpuSamplerRelease;

		// ShaderModule
		wgpu_exports_table.wgpu_shader_module_get_compilation_info = wgpuShaderModuleGetCompilationInfo;
		wgpu_exports_table.wgpu_shader_module_set_label = wgpuShaderModuleSetLabel;
		wgpu_exports_table.wgpu_shader_module_reference = wgpuShaderModuleReference;
		wgpu_exports_table.wgpu_shader_module_release = wgpuShaderModuleRelease;

		// Surface
		wgpu_exports_table.wgpu_surface_configure = wgpuSurfaceConfigure;
		wgpu_exports_table.wgpu_surface_get_capabilities = wgpuSurfaceGetCapabilities;
		wgpu_exports_table.wgpu_surface_get_current_texture = wgpuSurfaceGetCurrentTexture;
		wgpu_exports_table.wgpu_surface_get_preferred_format = wgpuSurfaceGetPreferredFormat;
		wgpu_exports_table.wgpu_surface_present = wgpuSurfacePresent;
		wgpu_exports_table.wgpu_surface_unconfigure = wgpuSurfaceUnconfigure;
		wgpu_exports_table.wgpu_surface_reference = wgpuSurfaceReference;
		wgpu_exports_table.wgpu_surface_release = wgpuSurfaceRelease;

		// SurfaceCapabilities
		wgpu_exports_table.wgpu_surface_capabilities_free_members = wgpuSurfaceCapabilitiesFreeMembers;

		// Texture
		wgpu_exports_table.wgpu_texture_create_view = wgpuTextureCreateView;
		wgpu_exports_table.wgpu_texture_destroy = wgpuTextureDestroy;
		wgpu_exports_table.wgpu_texture_get_depth_or_array_layers = wgpuTextureGetDepthOrArrayLayers;
		wgpu_exports_table.wgpu_texture_get_dimension = wgpuTextureGetDimension;
		wgpu_exports_table.wgpu_texture_get_format = wgpuTextureGetFormat;
		wgpu_exports_table.wgpu_texture_get_height = wgpuTextureGetHeight;
		wgpu_exports_table.wgpu_texture_get_mip_level_count = wgpuTextureGetMipLevelCount;
		wgpu_exports_table.wgpu_texture_get_sample_count = wgpuTextureGetSampleCount;
		wgpu_exports_table.wgpu_texture_get_usage = wgpuTextureGetUsage;
		wgpu_exports_table.wgpu_texture_get_width = wgpuTextureGetWidth;
		wgpu_exports_table.wgpu_texture_set_label = wgpuTextureSetLabel;
		wgpu_exports_table.wgpu_texture_reference = wgpuTextureReference;
		wgpu_exports_table.wgpu_texture_release = wgpuTextureRelease;

		// TextureView
		wgpu_exports_table.wgpu_texture_view_set_label = wgpuTextureViewSetLabel;
		wgpu_exports_table.wgpu_texture_view_reference = wgpuTextureViewReference;
		wgpu_exports_table.wgpu_texture_view_release = wgpuTextureViewRelease;

		// Native wgpu extensions (from wgpu.h)
		wgpu_exports_table.wgpu_generate_report = wgpuGenerateReport;
		wgpu_exports_table.wgpu_instance_enumerate_adapters = wgpuInstanceEnumerateAdapters;
		wgpu_exports_table.wgpu_queue_submit_for_index = wgpuQueueSubmitForIndex;
		wgpu_exports_table.wgpu_device_poll = wgpuDevicePoll;
		wgpu_exports_table.wgpu_set_log_callback = wgpuSetLogCallback;
		wgpu_exports_table.wgpu_set_log_level = wgpuSetLogLevel;
		wgpu_exports_table.wgpu_get_version = wgpuGetVersion;
		wgpu_exports_table.wgpu_render_pass_encoder_set_push_constants = wgpuRenderPassEncoderSetPushConstants;
		wgpu_exports_table.wgpu_render_pass_encoder_multi_draw_indirect = wgpuRenderPassEncoderMultiDrawIndirect;
		wgpu_exports_table.wgpu_render_pass_encoder_multi_draw_indexed_indirect = wgpuRenderPassEncoderMultiDrawIndexedIndirect;
		wgpu_exports_table.wgpu_render_pass_encoder_multi_draw_indirect_count = wgpuRenderPassEncoderMultiDrawIndirectCount;
		wgpu_exports_table.wgpu_render_pass_encoder_multi_draw_indexed_indirect_count = wgpuRenderPassEncoderMultiDrawIndexedIndirectCount;
		wgpu_exports_table.wgpu_compute_pass_encoder_begin_pipeline_statistics_query = wgpuComputePassEncoderBeginPipelineStatisticsQuery;
		wgpu_exports_table.wgpu_compute_pass_encoder_end_pipeline_statistics_query = wgpuComputePassEncoderEndPipelineStatisticsQuery;
		wgpu_exports_table.wgpu_render_pass_encoder_begin_pipeline_statistics_query = wgpuRenderPassEncoderBeginPipelineStatisticsQuery;
		wgpu_exports_table.wgpu_render_pass_encoder_end_pipeline_statistics_query = wgpuRenderPassEncoderEndPipelineStatisticsQuery;

		return &wgpu_exports_table;
	}
}