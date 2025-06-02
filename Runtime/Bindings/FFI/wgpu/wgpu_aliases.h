// WebGPU API (from webgpu.h)
typedef uint32_t WGPUFlags;
typedef uint32_t WGPUBool;

typedef struct WGPUAdapterImpl* WGPUAdapter;
typedef struct WGPUBindGroupImpl* WGPUBindGroup;
typedef struct WGPUBindGroupLayoutImpl* WGPUBindGroupLayout;
typedef struct WGPUBufferImpl* WGPUBuffer;
typedef struct WGPUCommandBufferImpl* WGPUCommandBuffer;
typedef struct WGPUCommandEncoderImpl* WGPUCommandEncoder;
typedef struct WGPUComputePassEncoderImpl* WGPUComputePassEncoder;
typedef struct WGPUComputePipelineImpl* WGPUComputePipeline;
typedef struct WGPUDeviceImpl* WGPUDevice;
typedef struct WGPUInstanceImpl* WGPUInstance;
typedef struct WGPUPipelineLayoutImpl* WGPUPipelineLayout;
typedef struct WGPUQuerySetImpl* WGPUQuerySet;
typedef struct WGPUQueueImpl* WGPUQueue;
typedef struct WGPURenderBundleImpl* WGPURenderBundle;
typedef struct WGPURenderBundleEncoderImpl* WGPURenderBundleEncoder;
typedef struct WGPURenderPassEncoderImpl* WGPURenderPassEncoder;
typedef struct WGPURenderPipelineImpl* WGPURenderPipeline;
typedef struct WGPUSamplerImpl* WGPUSampler;
typedef struct WGPUShaderModuleImpl* WGPUShaderModule;
typedef struct WGPUSurfaceImpl* WGPUSurface;
typedef struct WGPUTextureImpl* WGPUTexture;
typedef struct WGPUTextureViewImpl* WGPUTextureView;

typedef enum WGPUAdapterType {
	WGPUAdapterType_DiscreteGPU = 0x00000000,
	WGPUAdapterType_IntegratedGPU = 0x00000001,
	WGPUAdapterType_CPU = 0x00000002,
	WGPUAdapterType_Unknown = 0x00000003,
	WGPUAdapterType_Force32 = 0x7FFFFFFF
} WGPUAdapterType;

typedef enum WGPUAddressMode {
	WGPUAddressMode_Repeat = 0x00000000,
	WGPUAddressMode_MirrorRepeat = 0x00000001,
	WGPUAddressMode_ClampToEdge = 0x00000002,
	WGPUAddressMode_Force32 = 0x7FFFFFFF
} WGPUAddressMode;

typedef enum WGPUBackendType {
	WGPUBackendType_Undefined = 0x00000000,
	WGPUBackendType_Null = 0x00000001,
	WGPUBackendType_WebGPU = 0x00000002,
	WGPUBackendType_D3D11 = 0x00000003,
	WGPUBackendType_D3D12 = 0x00000004,
	WGPUBackendType_Metal = 0x00000005,
	WGPUBackendType_Vulkan = 0x00000006,
	WGPUBackendType_OpenGL = 0x00000007,
	WGPUBackendType_OpenGLES = 0x00000008,
	WGPUBackendType_Force32 = 0x7FFFFFFF
} WGPUBackendType;

typedef enum WGPUBlendFactor {
	WGPUBlendFactor_Zero = 0x00000000,
	WGPUBlendFactor_One = 0x00000001,
	WGPUBlendFactor_Src = 0x00000002,
	WGPUBlendFactor_OneMinusSrc = 0x00000003,
	WGPUBlendFactor_SrcAlpha = 0x00000004,
	WGPUBlendFactor_OneMinusSrcAlpha = 0x00000005,
	WGPUBlendFactor_Dst = 0x00000006,
	WGPUBlendFactor_OneMinusDst = 0x00000007,
	WGPUBlendFactor_DstAlpha = 0x00000008,
	WGPUBlendFactor_OneMinusDstAlpha = 0x00000009,
	WGPUBlendFactor_SrcAlphaSaturated = 0x0000000A,
	WGPUBlendFactor_Constant = 0x0000000B,
	WGPUBlendFactor_OneMinusConstant = 0x0000000C,
	WGPUBlendFactor_Force32 = 0x7FFFFFFF
} WGPUBlendFactor;

typedef enum WGPUBlendOperation {
	WGPUBlendOperation_Add = 0x00000000,
	WGPUBlendOperation_Subtract = 0x00000001,
	WGPUBlendOperation_ReverseSubtract = 0x00000002,
	WGPUBlendOperation_Min = 0x00000003,
	WGPUBlendOperation_Max = 0x00000004,
	WGPUBlendOperation_Force32 = 0x7FFFFFFF
} WGPUBlendOperation;

typedef enum WGPUBufferBindingType {
	WGPUBufferBindingType_Undefined = 0x00000000,
	WGPUBufferBindingType_Uniform = 0x00000001,
	WGPUBufferBindingType_Storage = 0x00000002,
	WGPUBufferBindingType_ReadOnlyStorage = 0x00000003,
	WGPUBufferBindingType_Force32 = 0x7FFFFFFF
} WGPUBufferBindingType;

typedef enum WGPUBufferMapAsyncStatus {
	WGPUBufferMapAsyncStatus_Success = 0x00000000,
	WGPUBufferMapAsyncStatus_ValidationError = 0x00000001,
	WGPUBufferMapAsyncStatus_Unknown = 0x00000002,
	WGPUBufferMapAsyncStatus_DeviceLost = 0x00000003,
	WGPUBufferMapAsyncStatus_DestroyedBeforeCallback = 0x00000004,
	WGPUBufferMapAsyncStatus_UnmappedBeforeCallback = 0x00000005,
	WGPUBufferMapAsyncStatus_MappingAlreadyPending = 0x00000006,
	WGPUBufferMapAsyncStatus_OffsetOutOfRange = 0x00000007,
	WGPUBufferMapAsyncStatus_SizeOutOfRange = 0x00000008,
	WGPUBufferMapAsyncStatus_Force32 = 0x7FFFFFFF
} WGPUBufferMapAsyncStatus;

typedef enum WGPUBufferMapState {
	WGPUBufferMapState_Unmapped = 0x00000000,
	WGPUBufferMapState_Pending = 0x00000001,
	WGPUBufferMapState_Mapped = 0x00000002,
	WGPUBufferMapState_Force32 = 0x7FFFFFFF
} WGPUBufferMapState;

typedef enum WGPUCompareFunction {
	WGPUCompareFunction_Undefined = 0x00000000,
	WGPUCompareFunction_Never = 0x00000001,
	WGPUCompareFunction_Less = 0x00000002,
	WGPUCompareFunction_LessEqual = 0x00000003,
	WGPUCompareFunction_Greater = 0x00000004,
	WGPUCompareFunction_GreaterEqual = 0x00000005,
	WGPUCompareFunction_Equal = 0x00000006,
	WGPUCompareFunction_NotEqual = 0x00000007,
	WGPUCompareFunction_Always = 0x00000008,
	WGPUCompareFunction_Force32 = 0x7FFFFFFF
} WGPUCompareFunction;

typedef enum WGPUCompilationInfoRequestStatus {
	WGPUCompilationInfoRequestStatus_Success = 0x00000000,
	WGPUCompilationInfoRequestStatus_Error = 0x00000001,
	WGPUCompilationInfoRequestStatus_DeviceLost = 0x00000002,
	WGPUCompilationInfoRequestStatus_Unknown = 0x00000003,
	WGPUCompilationInfoRequestStatus_Force32 = 0x7FFFFFFF
} WGPUCompilationInfoRequestStatus;

typedef enum WGPUCompilationMessageType {
	WGPUCompilationMessageType_Error = 0x00000000,
	WGPUCompilationMessageType_Warning = 0x00000001,
	WGPUCompilationMessageType_Info = 0x00000002,
	WGPUCompilationMessageType_Force32 = 0x7FFFFFFF
} WGPUCompilationMessageType;

typedef enum WGPUCompositeAlphaMode {
	WGPUCompositeAlphaMode_Auto = 0x00000000,
	WGPUCompositeAlphaMode_Opaque = 0x00000001,
	WGPUCompositeAlphaMode_Premultiplied = 0x00000002,
	WGPUCompositeAlphaMode_Unpremultiplied = 0x00000003,
	WGPUCompositeAlphaMode_Inherit = 0x00000004,
	WGPUCompositeAlphaMode_Force32 = 0x7FFFFFFF
} WGPUCompositeAlphaMode;

typedef enum WGPUCreatePipelineAsyncStatus {
	WGPUCreatePipelineAsyncStatus_Success = 0x00000000,
	WGPUCreatePipelineAsyncStatus_ValidationError = 0x00000001,
	WGPUCreatePipelineAsyncStatus_InternalError = 0x00000002,
	WGPUCreatePipelineAsyncStatus_DeviceLost = 0x00000003,
	WGPUCreatePipelineAsyncStatus_DeviceDestroyed = 0x00000004,
	WGPUCreatePipelineAsyncStatus_Unknown = 0x00000005,
	WGPUCreatePipelineAsyncStatus_Force32 = 0x7FFFFFFF
} WGPUCreatePipelineAsyncStatus;

typedef enum WGPUCullMode {
	WGPUCullMode_None = 0x00000000,
	WGPUCullMode_Front = 0x00000001,
	WGPUCullMode_Back = 0x00000002,
	WGPUCullMode_Force32 = 0x7FFFFFFF
} WGPUCullMode;

typedef enum WGPUDeviceLostReason {
	WGPUDeviceLostReason_Unknown = 0x00000001,
	WGPUDeviceLostReason_Destroyed = 0x00000002,
	WGPUDeviceLostReason_Force32 = 0x7FFFFFFF
} WGPUDeviceLostReason;

typedef enum WGPUErrorFilter {
	WGPUErrorFilter_Validation = 0x00000000,
	WGPUErrorFilter_OutOfMemory = 0x00000001,
	WGPUErrorFilter_Internal = 0x00000002,
	WGPUErrorFilter_Force32 = 0x7FFFFFFF
} WGPUErrorFilter;

typedef enum WGPUErrorType {
	WGPUErrorType_NoError = 0x00000000,
	WGPUErrorType_Validation = 0x00000001,
	WGPUErrorType_OutOfMemory = 0x00000002,
	WGPUErrorType_Internal = 0x00000003,
	WGPUErrorType_Unknown = 0x00000004,
	WGPUErrorType_DeviceLost = 0x00000005,
	WGPUErrorType_Force32 = 0x7FFFFFFF
} WGPUErrorType;

typedef enum WGPUFeatureName {
	WGPUFeatureName_Undefined = 0x00000000,
	WGPUFeatureName_DepthClipControl = 0x00000001,
	WGPUFeatureName_Depth32FloatStencil8 = 0x00000002,
	WGPUFeatureName_TimestampQuery = 0x00000003,
	WGPUFeatureName_TextureCompressionBC = 0x00000004,
	WGPUFeatureName_TextureCompressionETC2 = 0x00000005,
	WGPUFeatureName_TextureCompressionASTC = 0x00000006,
	WGPUFeatureName_IndirectFirstInstance = 0x00000007,
	WGPUFeatureName_ShaderF16 = 0x00000008,
	WGPUFeatureName_RG11B10UfloatRenderable = 0x00000009,
	WGPUFeatureName_BGRA8UnormStorage = 0x0000000A,
	WGPUFeatureName_Float32Filterable = 0x0000000B,
	WGPUFeatureName_Force32 = 0x7FFFFFFF
} WGPUFeatureName;

typedef enum WGPUFilterMode {
	WGPUFilterMode_Nearest = 0x00000000,
	WGPUFilterMode_Linear = 0x00000001,
	WGPUFilterMode_Force32 = 0x7FFFFFFF
} WGPUFilterMode;

typedef enum WGPUFrontFace {
	WGPUFrontFace_CCW = 0x00000000,
	WGPUFrontFace_CW = 0x00000001,
	WGPUFrontFace_Force32 = 0x7FFFFFFF
} WGPUFrontFace;

typedef enum WGPUIndexFormat {
	WGPUIndexFormat_Undefined = 0x00000000,
	WGPUIndexFormat_Uint16 = 0x00000001,
	WGPUIndexFormat_Uint32 = 0x00000002,
	WGPUIndexFormat_Force32 = 0x7FFFFFFF
} WGPUIndexFormat;

typedef enum WGPULoadOp {
	WGPULoadOp_Undefined = 0x00000000,
	WGPULoadOp_Clear = 0x00000001,
	WGPULoadOp_Load = 0x00000002,
	WGPULoadOp_Force32 = 0x7FFFFFFF
} WGPULoadOp;

typedef enum WGPUMipmapFilterMode {
	WGPUMipmapFilterMode_Nearest = 0x00000000,
	WGPUMipmapFilterMode_Linear = 0x00000001,
	WGPUMipmapFilterMode_Force32 = 0x7FFFFFFF
} WGPUMipmapFilterMode;

typedef enum WGPUPowerPreference {
	WGPUPowerPreference_Undefined = 0x00000000,
	WGPUPowerPreference_LowPower = 0x00000001,
	WGPUPowerPreference_HighPerformance = 0x00000002,
	WGPUPowerPreference_Force32 = 0x7FFFFFFF
} WGPUPowerPreference;

typedef enum WGPUPresentMode {
	WGPUPresentMode_Fifo = 0x00000000,
	WGPUPresentMode_FifoRelaxed = 0x00000001,
	WGPUPresentMode_Immediate = 0x00000002,
	WGPUPresentMode_Mailbox = 0x00000003,
	WGPUPresentMode_Force32 = 0x7FFFFFFF
} WGPUPresentMode;

typedef enum WGPUPrimitiveTopology {
	WGPUPrimitiveTopology_PointList = 0x00000000,
	WGPUPrimitiveTopology_LineList = 0x00000001,
	WGPUPrimitiveTopology_LineStrip = 0x00000002,
	WGPUPrimitiveTopology_TriangleList = 0x00000003,
	WGPUPrimitiveTopology_TriangleStrip = 0x00000004,
	WGPUPrimitiveTopology_Force32 = 0x7FFFFFFF
} WGPUPrimitiveTopology;

typedef enum WGPUQueryType {
	WGPUQueryType_Occlusion = 0x00000000,
	WGPUQueryType_Timestamp = 0x00000001,
	WGPUQueryType_Force32 = 0x7FFFFFFF
} WGPUQueryType;

typedef enum WGPUQueueWorkDoneStatus {
	WGPUQueueWorkDoneStatus_Success = 0x00000000,
	WGPUQueueWorkDoneStatus_Error = 0x00000001,
	WGPUQueueWorkDoneStatus_Unknown = 0x00000002,
	WGPUQueueWorkDoneStatus_DeviceLost = 0x00000003,
	WGPUQueueWorkDoneStatus_Force32 = 0x7FFFFFFF
} WGPUQueueWorkDoneStatus;

typedef enum WGPURequestAdapterStatus {
	WGPURequestAdapterStatus_Success = 0x00000000,
	WGPURequestAdapterStatus_Unavailable = 0x00000001,
	WGPURequestAdapterStatus_Error = 0x00000002,
	WGPURequestAdapterStatus_Unknown = 0x00000003,
	WGPURequestAdapterStatus_Force32 = 0x7FFFFFFF
} WGPURequestAdapterStatus;

typedef enum WGPURequestDeviceStatus {
	WGPURequestDeviceStatus_Success = 0x00000000,
	WGPURequestDeviceStatus_Error = 0x00000001,
	WGPURequestDeviceStatus_Unknown = 0x00000002,
	WGPURequestDeviceStatus_Force32 = 0x7FFFFFFF
} WGPURequestDeviceStatus;

typedef enum WGPUSType {
	WGPUSType_Invalid = 0x00000000,
	WGPUSType_SurfaceDescriptorFromMetalLayer = 0x00000001,
	WGPUSType_SurfaceDescriptorFromWindowsHWND = 0x00000002,
	WGPUSType_SurfaceDescriptorFromXlibWindow = 0x00000003,
	WGPUSType_SurfaceDescriptorFromCanvasHTMLSelector = 0x00000004,
	WGPUSType_ShaderModuleSPIRVDescriptor = 0x00000005,
	WGPUSType_ShaderModuleWGSLDescriptor = 0x00000006,
	WGPUSType_PrimitiveDepthClipControl = 0x00000007,
	WGPUSType_SurfaceDescriptorFromWaylandSurface = 0x00000008,
	WGPUSType_SurfaceDescriptorFromAndroidNativeWindow = 0x00000009,
	WGPUSType_SurfaceDescriptorFromXcbWindow = 0x0000000A,
	WGPUSType_RenderPassDescriptorMaxDrawCount = 0x0000000F,
	WGPUSType_Force32 = 0x7FFFFFFF
} WGPUSType;

typedef enum WGPUSamplerBindingType {
	WGPUSamplerBindingType_Undefined = 0x00000000,
	WGPUSamplerBindingType_Filtering = 0x00000001,
	WGPUSamplerBindingType_NonFiltering = 0x00000002,
	WGPUSamplerBindingType_Comparison = 0x00000003,
	WGPUSamplerBindingType_Force32 = 0x7FFFFFFF
} WGPUSamplerBindingType;

typedef enum WGPUStencilOperation {
	WGPUStencilOperation_Keep = 0x00000000,
	WGPUStencilOperation_Zero = 0x00000001,
	WGPUStencilOperation_Replace = 0x00000002,
	WGPUStencilOperation_Invert = 0x00000003,
	WGPUStencilOperation_IncrementClamp = 0x00000004,
	WGPUStencilOperation_DecrementClamp = 0x00000005,
	WGPUStencilOperation_IncrementWrap = 0x00000006,
	WGPUStencilOperation_DecrementWrap = 0x00000007,
	WGPUStencilOperation_Force32 = 0x7FFFFFFF
} WGPUStencilOperation;

typedef enum WGPUStorageTextureAccess {
	WGPUStorageTextureAccess_Undefined = 0x00000000,
	WGPUStorageTextureAccess_WriteOnly = 0x00000001,
	WGPUStorageTextureAccess_ReadOnly = 0x00000002,
	WGPUStorageTextureAccess_ReadWrite = 0x00000003,
	WGPUStorageTextureAccess_Force32 = 0x7FFFFFFF
} WGPUStorageTextureAccess;

typedef enum WGPUStoreOp {
	WGPUStoreOp_Undefined = 0x00000000,
	WGPUStoreOp_Store = 0x00000001,
	WGPUStoreOp_Discard = 0x00000002,
	WGPUStoreOp_Force32 = 0x7FFFFFFF
} WGPUStoreOp;

typedef enum WGPUSurfaceGetCurrentTextureStatus {
	WGPUSurfaceGetCurrentTextureStatus_Success = 0x00000000,
	WGPUSurfaceGetCurrentTextureStatus_Timeout = 0x00000001,
	WGPUSurfaceGetCurrentTextureStatus_Outdated = 0x00000002,
	WGPUSurfaceGetCurrentTextureStatus_Lost = 0x00000003,
	WGPUSurfaceGetCurrentTextureStatus_OutOfMemory = 0x00000004,
	WGPUSurfaceGetCurrentTextureStatus_DeviceLost = 0x00000005,
	WGPUSurfaceGetCurrentTextureStatus_Force32 = 0x7FFFFFFF
} WGPUSurfaceGetCurrentTextureStatus;

typedef enum WGPUTextureAspect {
	WGPUTextureAspect_All = 0x00000000,
	WGPUTextureAspect_StencilOnly = 0x00000001,
	WGPUTextureAspect_DepthOnly = 0x00000002,
	WGPUTextureAspect_Force32 = 0x7FFFFFFF
} WGPUTextureAspect;

typedef enum WGPUTextureDimension {
	WGPUTextureDimension_1D = 0x00000000,
	WGPUTextureDimension_2D = 0x00000001,
	WGPUTextureDimension_3D = 0x00000002,
	WGPUTextureDimension_Force32 = 0x7FFFFFFF
} WGPUTextureDimension;

typedef enum WGPUTextureFormat {
	WGPUTextureFormat_Undefined = 0x00000000,
	WGPUTextureFormat_R8Unorm = 0x00000001,
	WGPUTextureFormat_R8Snorm = 0x00000002,
	WGPUTextureFormat_R8Uint = 0x00000003,
	WGPUTextureFormat_R8Sint = 0x00000004,
	WGPUTextureFormat_R16Uint = 0x00000005,
	WGPUTextureFormat_R16Sint = 0x00000006,
	WGPUTextureFormat_R16Float = 0x00000007,
	WGPUTextureFormat_RG8Unorm = 0x00000008,
	WGPUTextureFormat_RG8Snorm = 0x00000009,
	WGPUTextureFormat_RG8Uint = 0x0000000A,
	WGPUTextureFormat_RG8Sint = 0x0000000B,
	WGPUTextureFormat_R32Float = 0x0000000C,
	WGPUTextureFormat_R32Uint = 0x0000000D,
	WGPUTextureFormat_R32Sint = 0x0000000E,
	WGPUTextureFormat_RG16Uint = 0x0000000F,
	WGPUTextureFormat_RG16Sint = 0x00000010,
	WGPUTextureFormat_RG16Float = 0x00000011,
	WGPUTextureFormat_RGBA8Unorm = 0x00000012,
	WGPUTextureFormat_RGBA8UnormSrgb = 0x00000013,
	WGPUTextureFormat_RGBA8Snorm = 0x00000014,
	WGPUTextureFormat_RGBA8Uint = 0x00000015,
	WGPUTextureFormat_RGBA8Sint = 0x00000016,
	WGPUTextureFormat_BGRA8Unorm = 0x00000017,
	WGPUTextureFormat_BGRA8UnormSrgb = 0x00000018,
	WGPUTextureFormat_RGB10A2Uint = 0x00000019,
	WGPUTextureFormat_RGB10A2Unorm = 0x0000001A,
	WGPUTextureFormat_RG11B10Ufloat = 0x0000001B,
	WGPUTextureFormat_RGB9E5Ufloat = 0x0000001C,
	WGPUTextureFormat_RG32Float = 0x0000001D,
	WGPUTextureFormat_RG32Uint = 0x0000001E,
	WGPUTextureFormat_RG32Sint = 0x0000001F,
	WGPUTextureFormat_RGBA16Uint = 0x00000020,
	WGPUTextureFormat_RGBA16Sint = 0x00000021,
	WGPUTextureFormat_RGBA16Float = 0x00000022,
	WGPUTextureFormat_RGBA32Float = 0x00000023,
	WGPUTextureFormat_RGBA32Uint = 0x00000024,
	WGPUTextureFormat_RGBA32Sint = 0x00000025,
	WGPUTextureFormat_Stencil8 = 0x00000026,
	WGPUTextureFormat_Depth16Unorm = 0x00000027,
	WGPUTextureFormat_Depth24Plus = 0x00000028,
	WGPUTextureFormat_Depth24PlusStencil8 = 0x00000029,
	WGPUTextureFormat_Depth32Float = 0x0000002A,
	WGPUTextureFormat_Depth32FloatStencil8 = 0x0000002B,
	WGPUTextureFormat_BC1RGBAUnorm = 0x0000002C,
	WGPUTextureFormat_BC1RGBAUnormSrgb = 0x0000002D,
	WGPUTextureFormat_BC2RGBAUnorm = 0x0000002E,
	WGPUTextureFormat_BC2RGBAUnormSrgb = 0x0000002F,
	WGPUTextureFormat_BC3RGBAUnorm = 0x00000030,
	WGPUTextureFormat_BC3RGBAUnormSrgb = 0x00000031,
	WGPUTextureFormat_BC4RUnorm = 0x00000032,
	WGPUTextureFormat_BC4RSnorm = 0x00000033,
	WGPUTextureFormat_BC5RGUnorm = 0x00000034,
	WGPUTextureFormat_BC5RGSnorm = 0x00000035,
	WGPUTextureFormat_BC6HRGBUfloat = 0x00000036,
	WGPUTextureFormat_BC6HRGBFloat = 0x00000037,
	WGPUTextureFormat_BC7RGBAUnorm = 0x00000038,
	WGPUTextureFormat_BC7RGBAUnormSrgb = 0x00000039,
	WGPUTextureFormat_ETC2RGB8Unorm = 0x0000003A,
	WGPUTextureFormat_ETC2RGB8UnormSrgb = 0x0000003B,
	WGPUTextureFormat_ETC2RGB8A1Unorm = 0x0000003C,
	WGPUTextureFormat_ETC2RGB8A1UnormSrgb = 0x0000003D,
	WGPUTextureFormat_ETC2RGBA8Unorm = 0x0000003E,
	WGPUTextureFormat_ETC2RGBA8UnormSrgb = 0x0000003F,
	WGPUTextureFormat_EACR11Unorm = 0x00000040,
	WGPUTextureFormat_EACR11Snorm = 0x00000041,
	WGPUTextureFormat_EACRG11Unorm = 0x00000042,
	WGPUTextureFormat_EACRG11Snorm = 0x00000043,
	WGPUTextureFormat_ASTC4x4Unorm = 0x00000044,
	WGPUTextureFormat_ASTC4x4UnormSrgb = 0x00000045,
	WGPUTextureFormat_ASTC5x4Unorm = 0x00000046,
	WGPUTextureFormat_ASTC5x4UnormSrgb = 0x00000047,
	WGPUTextureFormat_ASTC5x5Unorm = 0x00000048,
	WGPUTextureFormat_ASTC5x5UnormSrgb = 0x00000049,
	WGPUTextureFormat_ASTC6x5Unorm = 0x0000004A,
	WGPUTextureFormat_ASTC6x5UnormSrgb = 0x0000004B,
	WGPUTextureFormat_ASTC6x6Unorm = 0x0000004C,
	WGPUTextureFormat_ASTC6x6UnormSrgb = 0x0000004D,
	WGPUTextureFormat_ASTC8x5Unorm = 0x0000004E,
	WGPUTextureFormat_ASTC8x5UnormSrgb = 0x0000004F,
	WGPUTextureFormat_ASTC8x6Unorm = 0x00000050,
	WGPUTextureFormat_ASTC8x6UnormSrgb = 0x00000051,
	WGPUTextureFormat_ASTC8x8Unorm = 0x00000052,
	WGPUTextureFormat_ASTC8x8UnormSrgb = 0x00000053,
	WGPUTextureFormat_ASTC10x5Unorm = 0x00000054,
	WGPUTextureFormat_ASTC10x5UnormSrgb = 0x00000055,
	WGPUTextureFormat_ASTC10x6Unorm = 0x00000056,
	WGPUTextureFormat_ASTC10x6UnormSrgb = 0x00000057,
	WGPUTextureFormat_ASTC10x8Unorm = 0x00000058,
	WGPUTextureFormat_ASTC10x8UnormSrgb = 0x00000059,
	WGPUTextureFormat_ASTC10x10Unorm = 0x0000005A,
	WGPUTextureFormat_ASTC10x10UnormSrgb = 0x0000005B,
	WGPUTextureFormat_ASTC12x10Unorm = 0x0000005C,
	WGPUTextureFormat_ASTC12x10UnormSrgb = 0x0000005D,
	WGPUTextureFormat_ASTC12x12Unorm = 0x0000005E,
	WGPUTextureFormat_ASTC12x12UnormSrgb = 0x0000005F,
	WGPUTextureFormat_Force32 = 0x7FFFFFFF
} WGPUTextureFormat;

typedef enum WGPUTextureSampleType {
	WGPUTextureSampleType_Undefined = 0x00000000,
	WGPUTextureSampleType_Float = 0x00000001,
	WGPUTextureSampleType_UnfilterableFloat = 0x00000002,
	WGPUTextureSampleType_Depth = 0x00000003,
	WGPUTextureSampleType_Sint = 0x00000004,
	WGPUTextureSampleType_Uint = 0x00000005,
	WGPUTextureSampleType_Force32 = 0x7FFFFFFF
} WGPUTextureSampleType;

typedef enum WGPUTextureViewDimension {
	WGPUTextureViewDimension_Undefined = 0x00000000,
	WGPUTextureViewDimension_1D = 0x00000001,
	WGPUTextureViewDimension_2D = 0x00000002,
	WGPUTextureViewDimension_2DArray = 0x00000003,
	WGPUTextureViewDimension_Cube = 0x00000004,
	WGPUTextureViewDimension_CubeArray = 0x00000005,
	WGPUTextureViewDimension_3D = 0x00000006,
	WGPUTextureViewDimension_Force32 = 0x7FFFFFFF
} WGPUTextureViewDimension;

typedef enum WGPUVertexFormat {
	WGPUVertexFormat_Undefined = 0x00000000,
	WGPUVertexFormat_Uint8x2 = 0x00000001,
	WGPUVertexFormat_Uint8x4 = 0x00000002,
	WGPUVertexFormat_Sint8x2 = 0x00000003,
	WGPUVertexFormat_Sint8x4 = 0x00000004,
	WGPUVertexFormat_Unorm8x2 = 0x00000005,
	WGPUVertexFormat_Unorm8x4 = 0x00000006,
	WGPUVertexFormat_Snorm8x2 = 0x00000007,
	WGPUVertexFormat_Snorm8x4 = 0x00000008,
	WGPUVertexFormat_Uint16x2 = 0x00000009,
	WGPUVertexFormat_Uint16x4 = 0x0000000A,
	WGPUVertexFormat_Sint16x2 = 0x0000000B,
	WGPUVertexFormat_Sint16x4 = 0x0000000C,
	WGPUVertexFormat_Unorm16x2 = 0x0000000D,
	WGPUVertexFormat_Unorm16x4 = 0x0000000E,
	WGPUVertexFormat_Snorm16x2 = 0x0000000F,
	WGPUVertexFormat_Snorm16x4 = 0x00000010,
	WGPUVertexFormat_Float16x2 = 0x00000011,
	WGPUVertexFormat_Float16x4 = 0x00000012,
	WGPUVertexFormat_Float32 = 0x00000013,
	WGPUVertexFormat_Float32x2 = 0x00000014,
	WGPUVertexFormat_Float32x3 = 0x00000015,
	WGPUVertexFormat_Float32x4 = 0x00000016,
	WGPUVertexFormat_Uint32 = 0x00000017,
	WGPUVertexFormat_Uint32x2 = 0x00000018,
	WGPUVertexFormat_Uint32x3 = 0x00000019,
	WGPUVertexFormat_Uint32x4 = 0x0000001A,
	WGPUVertexFormat_Sint32 = 0x0000001B,
	WGPUVertexFormat_Sint32x2 = 0x0000001C,
	WGPUVertexFormat_Sint32x3 = 0x0000001D,
	WGPUVertexFormat_Sint32x4 = 0x0000001E,
	WGPUVertexFormat_Force32 = 0x7FFFFFFF
} WGPUVertexFormat;

typedef enum WGPUVertexStepMode {
	WGPUVertexStepMode_Vertex = 0x00000000,
	WGPUVertexStepMode_Instance = 0x00000001,
	WGPUVertexStepMode_VertexBufferNotUsed = 0x00000002,
	WGPUVertexStepMode_Force32 = 0x7FFFFFFF
} WGPUVertexStepMode;

typedef enum WGPUWGSLFeatureName {
	WGPUWGSLFeatureName_Undefined = 0x00000000,
	WGPUWGSLFeatureName_ReadonlyAndReadwriteStorageTextures = 0x00000001,
	WGPUWGSLFeatureName_Packed4x8IntegerDotProduct = 0x00000002,
	WGPUWGSLFeatureName_UnrestrictedPointerParameters = 0x00000003,
	WGPUWGSLFeatureName_PointerCompositeAccess = 0x00000004,
	WGPUWGSLFeatureName_Force32 = 0x7FFFFFFF
} WGPUWGSLFeatureName;

typedef enum WGPUBufferUsage {
	WGPUBufferUsage_None = 0x00000000,
	WGPUBufferUsage_MapRead = 0x00000001,
	WGPUBufferUsage_MapWrite = 0x00000002,
	WGPUBufferUsage_CopySrc = 0x00000004,
	WGPUBufferUsage_CopyDst = 0x00000008,
	WGPUBufferUsage_Index = 0x00000010,
	WGPUBufferUsage_Vertex = 0x00000020,
	WGPUBufferUsage_Uniform = 0x00000040,
	WGPUBufferUsage_Storage = 0x00000080,
	WGPUBufferUsage_Indirect = 0x00000100,
	WGPUBufferUsage_QueryResolve = 0x00000200,
	WGPUBufferUsage_Force32 = 0x7FFFFFFF
} WGPUBufferUsage;
typedef WGPUFlags WGPUBufferUsageFlags;

typedef enum WGPUColorWriteMask {
	WGPUColorWriteMask_None = 0x00000000,
	WGPUColorWriteMask_Red = 0x00000001,
	WGPUColorWriteMask_Green = 0x00000002,
	WGPUColorWriteMask_Blue = 0x00000004,
	WGPUColorWriteMask_Alpha = 0x00000008,
	WGPUColorWriteMask_All = 0x0000000F, // WGPUColorWriteMask_None | WGPUColorWriteMask_Red | WGPUColorWriteMask_Green | WGPUColorWriteMask_Blue | WGPUColorWriteMask_Alpha
	WGPUColorWriteMask_Force32 = 0x7FFFFFFF
} WGPUColorWriteMask;
typedef WGPUFlags WGPUColorWriteMaskFlags;

typedef enum WGPUMapMode {
	WGPUMapMode_None = 0x00000000,
	WGPUMapMode_Read = 0x00000001,
	WGPUMapMode_Write = 0x00000002,
	WGPUMapMode_Force32 = 0x7FFFFFFF
} WGPUMapMode;
typedef WGPUFlags WGPUMapModeFlags;

typedef enum WGPUShaderStage {
	WGPUShaderStage_None = 0x00000000,
	WGPUShaderStage_Vertex = 0x00000001,
	WGPUShaderStage_Fragment = 0x00000002,
	WGPUShaderStage_Compute = 0x00000004,
	WGPUShaderStage_Force32 = 0x7FFFFFFF
} WGPUShaderStage;
typedef WGPUFlags WGPUShaderStage;

typedef enum WGPUTextureUsage {
	WGPUTextureUsage_None = 0x00000000,
	WGPUTextureUsage_CopySrc = 0x00000001,
	WGPUTextureUsage_CopyDst = 0x00000002,
	WGPUTextureUsage_TextureBinding = 0x00000004,
	WGPUTextureUsage_StorageBinding = 0x00000008,
	WGPUTextureUsage_RenderAttachment = 0x00000010,
	WGPUTextureUsage_Force32 = 0x7FFFFFFF
} WGPUTextureUsage;
typedef WGPUFlags WGPUTextureUsageFlags;

typedef void (*WGPUProc)(void);
typedef void (*WGPUDeviceLostCallback)(WGPUDeviceLostReason reason, char const* message, void* userdata);
typedef void (*WGPUErrorCallback)(WGPUErrorType type, char const* message, void* userdata);
typedef void (*WGPUAdapterRequestDeviceCallback)(WGPURequestDeviceStatus status, WGPUDevice device, char const* message, void* userdata);
typedef void (*WGPUBufferMapAsyncCallback)(WGPUBufferMapAsyncStatus status, void* userdata);
typedef void (*WGPUDeviceCreateComputePipelineAsyncCallback)(WGPUCreatePipelineAsyncStatus status, WGPUComputePipeline pipeline, char const* message, void* userdata);
typedef void (*WGPUDeviceCreateRenderPipelineAsyncCallback)(WGPUCreatePipelineAsyncStatus status, WGPURenderPipeline pipeline, char const* message, void* userdata);
typedef void (*WGPUInstanceRequestAdapterCallback)(WGPURequestAdapterStatus status, WGPUAdapter adapter, char const* message, void* userdata);
typedef void (*WGPUQueueOnSubmittedWorkDoneCallback)(WGPUQueueWorkDoneStatus status, void* userdata);
typedef void (*WGPUShaderModuleGetCompilationInfoCallback)(WGPUCompilationInfoRequestStatus status, struct WGPUCompilationInfo const* compilationInfo, void* userdata);

typedef struct WGPUChainedStruct {
	struct WGPUChainedStruct const* next;
	WGPUSType sType;
} WGPUChainedStruct;

typedef struct WGPUChainedStructOut {
	struct WGPUChainedStructOut* next;
	WGPUSType sType;
} WGPUChainedStructOut;

typedef struct WGPUAdapterInfo {
	WGPUChainedStructOut* nextInChain;
	char const* vendor;
	char const* architecture;
	char const* device;
	char const* description;
	WGPUBackendType backendType;
	WGPUAdapterType adapterType;
	uint32_t vendorID;
	uint32_t deviceID;
} WGPUAdapterInfo;

typedef struct WGPUBindGroupEntry {
	WGPUChainedStruct const* nextInChain;
	uint32_t binding;
	WGPUBuffer buffer;
	uint64_t offset;
	uint64_t size;
	WGPUSampler sampler;
	WGPUTextureView textureView;
} WGPUBindGroupEntry;

typedef struct WGPUBlendComponent {
	WGPUBlendOperation operation;
	WGPUBlendFactor srcFactor;
	WGPUBlendFactor dstFactor;
} WGPUBlendComponent;

typedef struct WGPUBufferBindingLayout {
	WGPUChainedStruct const* nextInChain;
	WGPUBufferBindingType type;
	WGPUBool hasDynamicOffset;
	uint64_t minBindingSize;
} WGPUBufferBindingLayout;

typedef struct WGPUBufferDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
	WGPUBufferUsageFlags usage;
	uint64_t size;
	WGPUBool mappedAtCreation;
} WGPUBufferDescriptor;

typedef struct WGPUColor {
	double r;
	double g;
	double b;
	double a;
} WGPUColor;

typedef struct WGPUCommandBufferDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
} WGPUCommandBufferDescriptor;

typedef struct WGPUCommandEncoderDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
} WGPUCommandEncoderDescriptor;

typedef struct WGPUCompilationMessage {
	WGPUChainedStruct const* nextInChain;
	char const* message;
	WGPUCompilationMessageType type;
	uint64_t lineNum;
	uint64_t linePos;
	uint64_t offset;
	uint64_t length;
	uint64_t utf16LinePos;
	uint64_t utf16Offset;
	uint64_t utf16Length;
} WGPUCompilationMessage;

typedef struct WGPUComputePassTimestampWrites {
	WGPUQuerySet querySet;
	uint32_t beginningOfPassWriteIndex;
	uint32_t endOfPassWriteIndex;
} WGPUComputePassTimestampWrites;

typedef struct WGPUConstantEntry {
	WGPUChainedStruct const* nextInChain;
	char const* key;
	double value;
} WGPUConstantEntry;

typedef struct WGPUExtent3D {
	uint32_t width;
	uint32_t height;
	uint32_t depthOrArrayLayers;
} WGPUExtent3D;

typedef struct WGPUInstanceDescriptor {
	WGPUChainedStruct const* nextInChain;
} WGPUInstanceDescriptor;

typedef struct WGPULimits {
	uint32_t maxTextureDimension1D;
	uint32_t maxTextureDimension2D;
	uint32_t maxTextureDimension3D;
	uint32_t maxTextureArrayLayers;
	uint32_t maxBindGroups;
	uint32_t maxBindGroupsPlusVertexBuffers;
	uint32_t maxBindingsPerBindGroup;
	uint32_t maxDynamicUniformBuffersPerPipelineLayout;
	uint32_t maxDynamicStorageBuffersPerPipelineLayout;
	uint32_t maxSampledTexturesPerShaderStage;
	uint32_t maxSamplersPerShaderStage;
	uint32_t maxStorageBuffersPerShaderStage;
	uint32_t maxStorageTexturesPerShaderStage;
	uint32_t maxUniformBuffersPerShaderStage;
	uint64_t maxUniformBufferBindingSize;
	uint64_t maxStorageBufferBindingSize;
	uint32_t minUniformBufferOffsetAlignment;
	uint32_t minStorageBufferOffsetAlignment;
	uint32_t maxVertexBuffers;
	uint64_t maxBufferSize;
	uint32_t maxVertexAttributes;
	uint32_t maxVertexBufferArrayStride;
	uint32_t maxInterStageShaderComponents;
	uint32_t maxInterStageShaderVariables;
	uint32_t maxColorAttachments;
	uint32_t maxColorAttachmentBytesPerSample;
	uint32_t maxComputeWorkgroupStorageSize;
	uint32_t maxComputeInvocationsPerWorkgroup;
	uint32_t maxComputeWorkgroupSizeX;
	uint32_t maxComputeWorkgroupSizeY;
	uint32_t maxComputeWorkgroupSizeZ;
	uint32_t maxComputeWorkgroupsPerDimension;
} WGPULimits;

typedef struct WGPUMultisampleState {
	WGPUChainedStruct const* nextInChain;
	uint32_t count;
	uint32_t mask;
	WGPUBool alphaToCoverageEnabled;
} WGPUMultisampleState;

typedef struct WGPUOrigin3D {
	uint32_t x;
	uint32_t y;
	uint32_t z;
} WGPUOrigin3D;

typedef struct WGPUPipelineLayoutDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
	size_t bindGroupLayoutCount;
	WGPUBindGroupLayout const* bindGroupLayouts;
} WGPUPipelineLayoutDescriptor;

typedef struct WGPUPrimitiveDepthClipControl {
	WGPUChainedStruct chain;
	WGPUBool unclippedDepth;
} WGPUPrimitiveDepthClipControl;

typedef struct WGPUPrimitiveState {
	WGPUChainedStruct const* nextInChain;
	WGPUPrimitiveTopology topology;
	WGPUIndexFormat stripIndexFormat;
	WGPUFrontFace frontFace;
	WGPUCullMode cullMode;
} WGPUPrimitiveState;

typedef struct WGPUQuerySetDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
	WGPUQueryType type;
	uint32_t count;
} WGPUQuerySetDescriptor;

typedef struct WGPUQueueDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
} WGPUQueueDescriptor;

typedef struct WGPURenderBundleDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
} WGPURenderBundleDescriptor;

typedef struct WGPURenderBundleEncoderDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
	size_t colorFormatCount;
	WGPUTextureFormat const* colorFormats;
	WGPUTextureFormat depthStencilFormat;
	uint32_t sampleCount;
	WGPUBool depthReadOnly;
	WGPUBool stencilReadOnly;
} WGPURenderBundleEncoderDescriptor;

typedef struct WGPURenderPassDepthStencilAttachment {
	WGPUTextureView view;
	WGPULoadOp depthLoadOp;
	WGPUStoreOp depthStoreOp;
	float depthClearValue;
	WGPUBool depthReadOnly;
	WGPULoadOp stencilLoadOp;
	WGPUStoreOp stencilStoreOp;
	uint32_t stencilClearValue;
	WGPUBool stencilReadOnly;
} WGPURenderPassDepthStencilAttachment;

typedef struct WGPURenderPassDescriptorMaxDrawCount {
	WGPUChainedStruct chain;
	uint64_t maxDrawCount;
} WGPURenderPassDescriptorMaxDrawCount;

typedef struct WGPURenderPassTimestampWrites {
	WGPUQuerySet querySet;
	uint32_t beginningOfPassWriteIndex;
	uint32_t endOfPassWriteIndex;
} WGPURenderPassTimestampWrites;

typedef struct WGPURequestAdapterOptions {
	WGPUChainedStruct const* nextInChain;
	WGPUSurface compatibleSurface;
	WGPUPowerPreference powerPreference;
	WGPUBackendType backendType;
	WGPUBool forceFallbackAdapter;
} WGPURequestAdapterOptions;

typedef struct WGPUSamplerBindingLayout {
	WGPUChainedStruct const* nextInChain;
	WGPUSamplerBindingType type;
} WGPUSamplerBindingLayout;

typedef struct WGPUSamplerDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
	WGPUAddressMode addressModeU;
	WGPUAddressMode addressModeV;
	WGPUAddressMode addressModeW;
	WGPUFilterMode magFilter;
	WGPUFilterMode minFilter;
	WGPUMipmapFilterMode mipmapFilter;
	float lodMinClamp;
	float lodMaxClamp;
	WGPUCompareFunction compare;
	uint16_t maxAnisotropy;
} WGPUSamplerDescriptor;

typedef struct WGPUShaderModuleCompilationHint {
	WGPUChainedStruct const* nextInChain;
	char const* entryPoint;
	WGPUPipelineLayout layout;
} WGPUShaderModuleCompilationHint;

typedef struct WGPUShaderModuleSPIRVDescriptor {
	WGPUChainedStruct chain;
	uint32_t codeSize;
	uint32_t const* code;
} WGPUShaderModuleSPIRVDescriptor;

typedef struct WGPUShaderModuleWGSLDescriptor {
	WGPUChainedStruct chain;
	char const* code;
} WGPUShaderModuleWGSLDescriptor;

typedef struct WGPUStencilFaceState {
	WGPUCompareFunction compare;
	WGPUStencilOperation failOp;
	WGPUStencilOperation depthFailOp;
	WGPUStencilOperation passOp;
} WGPUStencilFaceState;

typedef struct WGPUStorageTextureBindingLayout {
	WGPUChainedStruct const* nextInChain;
	WGPUStorageTextureAccess access;
	WGPUTextureFormat format;
	WGPUTextureViewDimension viewDimension;
} WGPUStorageTextureBindingLayout;

typedef struct WGPUSurfaceCapabilities {
	WGPUChainedStructOut* nextInChain;
	WGPUTextureUsageFlags usages;
	size_t formatCount;
	WGPUTextureFormat const* formats;
	size_t presentModeCount;
	WGPUPresentMode const* presentModes;
	size_t alphaModeCount;
	WGPUCompositeAlphaMode const* alphaModes;
} WGPUSurfaceCapabilities;

typedef struct WGPUSurfaceConfiguration {
	WGPUChainedStruct const* nextInChain;
	WGPUDevice device;
	WGPUTextureFormat format;
	WGPUTextureUsageFlags usage;
	size_t viewFormatCount;
	WGPUTextureFormat const* viewFormats;
	WGPUCompositeAlphaMode alphaMode;
	uint32_t width;
	uint32_t height;
	WGPUPresentMode presentMode;
} WGPUSurfaceConfiguration;

typedef struct WGPUSurfaceDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
} WGPUSurfaceDescriptor;

typedef struct WGPUSurfaceDescriptorFromAndroidNativeWindow {
	WGPUChainedStruct chain;
	void* window;
} WGPUSurfaceDescriptorFromAndroidNativeWindow;

typedef struct WGPUSurfaceDescriptorFromCanvasHTMLSelector {
	WGPUChainedStruct chain;
	char const* selector;
} WGPUSurfaceDescriptorFromCanvasHTMLSelector;

typedef struct WGPUSurfaceDescriptorFromMetalLayer {
	WGPUChainedStruct chain;
	void* layer;
} WGPUSurfaceDescriptorFromMetalLayer;

typedef struct WGPUSurfaceDescriptorFromWaylandSurface {
	WGPUChainedStruct chain;
	void* display;
	void* surface;
} WGPUSurfaceDescriptorFromWaylandSurface;

typedef struct WGPUSurfaceDescriptorFromWindowsHWND {
	WGPUChainedStruct chain;
	void* hinstance;
	void* hwnd;
} WGPUSurfaceDescriptorFromWindowsHWND;

typedef struct WGPUSurfaceDescriptorFromXcbWindow {
	WGPUChainedStruct chain;
	void* connection;
	uint32_t window;
} WGPUSurfaceDescriptorFromXcbWindow;

typedef struct WGPUSurfaceDescriptorFromXlibWindow {
	WGPUChainedStruct chain;
	void* display;
	uint64_t window;
} WGPUSurfaceDescriptorFromXlibWindow;

typedef struct WGPUSurfaceTexture {
	WGPUTexture texture;
	WGPUBool suboptimal;
	WGPUSurfaceGetCurrentTextureStatus status;
} WGPUSurfaceTexture;

typedef struct WGPUTextureBindingLayout {
	WGPUChainedStruct const* nextInChain;
	WGPUTextureSampleType sampleType;
	WGPUTextureViewDimension viewDimension;
	WGPUBool multisampled;
} WGPUTextureBindingLayout;

typedef struct WGPUTextureDataLayout {
	WGPUChainedStruct const* nextInChain;
	uint64_t offset;
	uint32_t bytesPerRow;
	uint32_t rowsPerImage;
} WGPUTextureDataLayout;

typedef struct WGPUTextureViewDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
	WGPUTextureFormat format;
	WGPUTextureViewDimension dimension;
	uint32_t baseMipLevel;
	uint32_t mipLevelCount;
	uint32_t baseArrayLayer;
	uint32_t arrayLayerCount;
	WGPUTextureAspect aspect;
} WGPUTextureViewDescriptor;

typedef struct WGPUUncapturedErrorCallbackInfo {
	WGPUChainedStruct const* nextInChain;
	WGPUErrorCallback callback;
	void* userdata;
} WGPUUncapturedErrorCallbackInfo;

typedef struct WGPUVertexAttribute {
	WGPUVertexFormat format;
	uint64_t offset;
	uint32_t shaderLocation;
} WGPUVertexAttribute;

typedef struct WGPUBindGroupDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
	WGPUBindGroupLayout layout;
	size_t entryCount;
	WGPUBindGroupEntry const* entries;
} WGPUBindGroupDescriptor;

typedef struct WGPUBindGroupLayoutEntry {
	WGPUChainedStruct const* nextInChain;
	uint32_t binding;
	WGPUShaderStage visibility;
	WGPUBufferBindingLayout buffer;
	WGPUSamplerBindingLayout sampler;
	WGPUTextureBindingLayout texture;
	WGPUStorageTextureBindingLayout storageTexture;
} WGPUBindGroupLayoutEntry;

typedef struct WGPUBlendState {
	WGPUBlendComponent color;
	WGPUBlendComponent alpha;
} WGPUBlendState;

typedef struct WGPUCompilationInfo {
	WGPUChainedStruct const* nextInChain;
	size_t messageCount;
	WGPUCompilationMessage const* messages;
} WGPUCompilationInfo;

typedef struct WGPUComputePassDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
	WGPUComputePassTimestampWrites const* timestampWrites;
} WGPUComputePassDescriptor;

typedef struct WGPUDepthStencilState {
	WGPUChainedStruct const* nextInChain;
	WGPUTextureFormat format;
	WGPUBool depthWriteEnabled;
	WGPUCompareFunction depthCompare;
	WGPUStencilFaceState stencilFront;
	WGPUStencilFaceState stencilBack;
	uint32_t stencilReadMask;
	uint32_t stencilWriteMask;
	int32_t depthBias;
	float depthBiasSlopeScale;
	float depthBiasClamp;
} WGPUDepthStencilState;

typedef struct WGPUImageCopyBuffer {
	WGPUChainedStruct const* nextInChain;
	WGPUTextureDataLayout layout;
	WGPUBuffer buffer;
} WGPUImageCopyBuffer;

typedef struct WGPUImageCopyTexture {
	WGPUChainedStruct const* nextInChain;
	WGPUTexture texture;
	uint32_t mipLevel;
	WGPUOrigin3D origin;
	WGPUTextureAspect aspect;
} WGPUImageCopyTexture;

typedef struct WGPUProgrammableStageDescriptor {
	WGPUChainedStruct const* nextInChain;
	WGPUShaderModule module;
	char const* entryPoint;
	size_t constantCount;
	WGPUConstantEntry const* constants;
} WGPUProgrammableStageDescriptor;

typedef struct WGPURenderPassColorAttachment {
	WGPUChainedStruct const* nextInChain;
	WGPUTextureView view;
	uint32_t depthSlice;
	WGPUTextureView resolveTarget;
	WGPULoadOp loadOp;
	WGPUStoreOp storeOp;
	WGPUColor clearValue;
} WGPURenderPassColorAttachment;

typedef struct WGPURequiredLimits {
	WGPUChainedStruct const* nextInChain;
	WGPULimits limits;
} WGPURequiredLimits;

typedef struct WGPUShaderModuleDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
	size_t hintCount;
	WGPUShaderModuleCompilationHint const* hints;
} WGPUShaderModuleDescriptor;

typedef struct WGPUSupportedLimits {
	WGPUChainedStructOut* nextInChain;
	WGPULimits limits;
} WGPUSupportedLimits;

typedef struct WGPUTextureDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
	WGPUTextureUsageFlags usage;
	WGPUTextureDimension dimension;
	WGPUExtent3D size;
	WGPUTextureFormat format;
	uint32_t mipLevelCount;
	uint32_t sampleCount;
	size_t viewFormatCount;
	WGPUTextureFormat const* viewFormats;
} WGPUTextureDescriptor;

typedef struct WGPUVertexBufferLayout {
	uint64_t arrayStride;
	WGPUVertexStepMode stepMode;
	size_t attributeCount;
	WGPUVertexAttribute const* attributes;
} WGPUVertexBufferLayout;

typedef struct WGPUBindGroupLayoutDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
	size_t entryCount;
	WGPUBindGroupLayoutEntry const* entries;
} WGPUBindGroupLayoutDescriptor;

typedef struct WGPUColorTargetState {
	WGPUChainedStruct const* nextInChain;
	WGPUTextureFormat format;
	WGPUBlendState const* blend;
	WGPUColorWriteMaskFlags writeMask;
} WGPUColorTargetState;

typedef struct WGPUComputePipelineDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
	WGPUPipelineLayout layout;
	WGPUProgrammableStageDescriptor compute;
} WGPUComputePipelineDescriptor;

typedef struct WGPUDeviceDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
	size_t requiredFeatureCount;
	WGPUFeatureName const* requiredFeatures;
	WGPURequiredLimits const* requiredLimits;
	WGPUQueueDescriptor defaultQueue;
	WGPUDeviceLostCallback deviceLostCallback;
	void* deviceLostUserdata;
	WGPUUncapturedErrorCallbackInfo uncapturedErrorCallbackInfo;
} WGPUDeviceDescriptor;

typedef struct WGPURenderPassDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
	size_t colorAttachmentCount;
	WGPURenderPassColorAttachment const* colorAttachments;
	WGPURenderPassDepthStencilAttachment const* depthStencilAttachment;
	WGPUQuerySet occlusionQuerySet;
	WGPURenderPassTimestampWrites const* timestampWrites;
} WGPURenderPassDescriptor;

typedef struct WGPUVertexState {
	WGPUChainedStruct const* nextInChain;
	WGPUShaderModule module;
	char const* entryPoint;
	size_t constantCount;
	WGPUConstantEntry const* constants;
	size_t bufferCount;
	WGPUVertexBufferLayout const* buffers;
} WGPUVertexState;

typedef struct WGPUFragmentState {
	WGPUChainedStruct const* nextInChain;
	WGPUShaderModule module;
	char const* entryPoint;
	size_t constantCount;
	WGPUConstantEntry const* constants;
	size_t targetCount;
	WGPUColorTargetState const* targets;
} WGPUFragmentState;

typedef struct WGPURenderPipelineDescriptor {
	WGPUChainedStruct const* nextInChain;
	char const* label;
	WGPUPipelineLayout layout;
	WGPUVertexState vertex;
	WGPUPrimitiveState primitive;
	WGPUDepthStencilState const* depthStencil;
	WGPUMultisampleState multisample;
	WGPUFragmentState const* fragment;
} WGPURenderPipelineDescriptor;

typedef WGPUInstance (*WGPUProcCreateInstance)(WGPUInstanceDescriptor const* descriptor);
typedef WGPUProc (*WGPUProcGetProcAddress)(WGPUDevice device, char const* procName);

// Procs of Adapter
typedef size_t (*WGPUProcAdapterEnumerateFeatures)(WGPUAdapter adapter, WGPUFeatureName* features);
typedef void (*WGPUProcAdapterGetInfo)(WGPUAdapter adapter, WGPUAdapterInfo* info);
typedef WGPUBool (*WGPUProcAdapterGetLimits)(WGPUAdapter adapter, WGPUSupportedLimits* limits);
typedef WGPUBool (*WGPUProcAdapterHasFeature)(WGPUAdapter adapter, WGPUFeatureName feature);
typedef void (*WGPUProcAdapterRequestDevice)(WGPUAdapter adapter, WGPUDeviceDescriptor const* descriptor, WGPUAdapterRequestDeviceCallback callback, void* userdata);
typedef void (*WGPUProcAdapterReference)(WGPUAdapter adapter);
typedef void (*WGPUProcAdapterRelease)(WGPUAdapter adapter);

// Procs of AdapterInfo
typedef void (*WGPUProcAdapterInfoFreeMembers)(WGPUAdapterInfo adapterInfo);

// Procs of BindGroup
typedef void (*WGPUProcBindGroupSetLabel)(WGPUBindGroup bindGroup, char const* label);
typedef void (*WGPUProcBindGroupReference)(WGPUBindGroup bindGroup);
typedef void (*WGPUProcBindGroupRelease)(WGPUBindGroup bindGroup);

// Procs of BindGroupLayout
typedef void (*WGPUProcBindGroupLayoutSetLabel)(WGPUBindGroupLayout bindGroupLayout, char const* label);
typedef void (*WGPUProcBindGroupLayoutReference)(WGPUBindGroupLayout bindGroupLayout);
typedef void (*WGPUProcBindGroupLayoutRelease)(WGPUBindGroupLayout bindGroupLayout);

// Procs of Buffer
typedef void (*WGPUProcBufferDestroy)(WGPUBuffer buffer);
typedef void const* (*WGPUProcBufferGetConstMappedRange)(WGPUBuffer buffer, size_t offset, size_t size);
typedef WGPUBufferMapState (*WGPUProcBufferGetMapState)(WGPUBuffer buffer);
typedef void* (*WGPUProcBufferGetMappedRange)(WGPUBuffer buffer, size_t offset, size_t size);
typedef uint64_t (*WGPUProcBufferGetSize)(WGPUBuffer buffer);
typedef WGPUBufferUsageFlags (*WGPUProcBufferGetUsage)(WGPUBuffer buffer);
typedef void (*WGPUProcBufferMapAsync)(WGPUBuffer buffer, WGPUMapModeFlags mode, size_t offset, size_t size, WGPUBufferMapAsyncCallback callback, void* userdata);
typedef void (*WGPUProcBufferSetLabel)(WGPUBuffer buffer, char const* label);
typedef void (*WGPUProcBufferUnmap)(WGPUBuffer buffer);
typedef void (*WGPUProcBufferReference)(WGPUBuffer buffer);
typedef void (*WGPUProcBufferRelease)(WGPUBuffer buffer);

// Procs of CommandBuffer
typedef void (*WGPUProcCommandBufferSetLabel)(WGPUCommandBuffer commandBuffer, char const* label);
typedef void (*WGPUProcCommandBufferReference)(WGPUCommandBuffer commandBuffer);
typedef void (*WGPUProcCommandBufferRelease)(WGPUCommandBuffer commandBuffer);

// Procs of CommandEncoder
typedef WGPUComputePassEncoder (*WGPUProcCommandEncoderBeginComputePass)(WGPUCommandEncoder commandEncoder, WGPUComputePassDescriptor const* descriptor);
typedef WGPURenderPassEncoder (*WGPUProcCommandEncoderBeginRenderPass)(WGPUCommandEncoder commandEncoder, WGPURenderPassDescriptor const* descriptor);
typedef void (*WGPUProcCommandEncoderClearBuffer)(WGPUCommandEncoder commandEncoder, WGPUBuffer buffer, uint64_t offset, uint64_t size);
typedef void (*WGPUProcCommandEncoderCopyBufferToBuffer)(WGPUCommandEncoder commandEncoder, WGPUBuffer source, uint64_t sourceOffset, WGPUBuffer destination, uint64_t destinationOffset, uint64_t size);
typedef void (*WGPUProcCommandEncoderCopyBufferToTexture)(WGPUCommandEncoder commandEncoder, WGPUImageCopyBuffer const* source, WGPUImageCopyTexture const* destination, WGPUExtent3D const* copySize);
typedef void (*WGPUProcCommandEncoderCopyTextureToBuffer)(WGPUCommandEncoder commandEncoder, WGPUImageCopyTexture const* source, WGPUImageCopyBuffer const* destination, WGPUExtent3D const* copySize);
typedef void (*WGPUProcCommandEncoderCopyTextureToTexture)(WGPUCommandEncoder commandEncoder, WGPUImageCopyTexture const* source, WGPUImageCopyTexture const* destination, WGPUExtent3D const* copySize);
typedef WGPUCommandBuffer (*WGPUProcCommandEncoderFinish)(WGPUCommandEncoder commandEncoder, WGPUCommandBufferDescriptor const* descriptor);
typedef void (*WGPUProcCommandEncoderInsertDebugMarker)(WGPUCommandEncoder commandEncoder, char const* markerLabel);
typedef void (*WGPUProcCommandEncoderPopDebugGroup)(WGPUCommandEncoder commandEncoder);
typedef void (*WGPUProcCommandEncoderPushDebugGroup)(WGPUCommandEncoder commandEncoder, char const* groupLabel);
typedef void (*WGPUProcCommandEncoderResolveQuerySet)(WGPUCommandEncoder commandEncoder, WGPUQuerySet querySet, uint32_t firstQuery, uint32_t queryCount, WGPUBuffer destination, uint64_t destinationOffset);
typedef void (*WGPUProcCommandEncoderSetLabel)(WGPUCommandEncoder commandEncoder, char const* label);
typedef void (*WGPUProcCommandEncoderWriteTimestamp)(WGPUCommandEncoder commandEncoder, WGPUQuerySet querySet, uint32_t queryIndex);
typedef void (*WGPUProcCommandEncoderReference)(WGPUCommandEncoder commandEncoder);
typedef void (*WGPUProcCommandEncoderRelease)(WGPUCommandEncoder commandEncoder);

// Procs of ComputePassEncoder
typedef void (*WGPUProcComputePassEncoderDispatchWorkgroups)(WGPUComputePassEncoder computePassEncoder, uint32_t workgroupCountX, uint32_t workgroupCountY, uint32_t workgroupCountZ);
typedef void (*WGPUProcComputePassEncoderDispatchWorkgroupsIndirect)(WGPUComputePassEncoder computePassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset);
typedef void (*WGPUProcComputePassEncoderEnd)(WGPUComputePassEncoder computePassEncoder);
typedef void (*WGPUProcComputePassEncoderInsertDebugMarker)(WGPUComputePassEncoder computePassEncoder, char const* markerLabel);
typedef void (*WGPUProcComputePassEncoderPopDebugGroup)(WGPUComputePassEncoder computePassEncoder);
typedef void (*WGPUProcComputePassEncoderPushDebugGroup)(WGPUComputePassEncoder computePassEncoder, char const* groupLabel);
typedef void (*WGPUProcComputePassEncoderSetBindGroup)(WGPUComputePassEncoder computePassEncoder, uint32_t groupIndex, WGPUBindGroup group, size_t dynamicOffsetCount, uint32_t const* dynamicOffsets);
typedef void (*WGPUProcComputePassEncoderSetLabel)(WGPUComputePassEncoder computePassEncoder, char const* label);
typedef void (*WGPUProcComputePassEncoderSetPipeline)(WGPUComputePassEncoder computePassEncoder, WGPUComputePipeline pipeline);
typedef void (*WGPUProcComputePassEncoderReference)(WGPUComputePassEncoder computePassEncoder);
typedef void (*WGPUProcComputePassEncoderRelease)(WGPUComputePassEncoder computePassEncoder);

// Procs of ComputePipeline
typedef WGPUBindGroupLayout (*WGPUProcComputePipelineGetBindGroupLayout)(WGPUComputePipeline computePipeline, uint32_t groupIndex);
typedef void (*WGPUProcComputePipelineSetLabel)(WGPUComputePipeline computePipeline, char const* label);
typedef void (*WGPUProcComputePipelineReference)(WGPUComputePipeline computePipeline);
typedef void (*WGPUProcComputePipelineRelease)(WGPUComputePipeline computePipeline);

// Procs of Device
typedef WGPUBindGroup (*WGPUProcDeviceCreateBindGroup)(WGPUDevice device, WGPUBindGroupDescriptor const* descriptor);
typedef WGPUBindGroupLayout (*WGPUProcDeviceCreateBindGroupLayout)(WGPUDevice device, WGPUBindGroupLayoutDescriptor const* descriptor);
typedef WGPUBuffer (*WGPUProcDeviceCreateBuffer)(WGPUDevice device, WGPUBufferDescriptor const* descriptor);
typedef WGPUCommandEncoder (*WGPUProcDeviceCreateCommandEncoder)(WGPUDevice device, WGPUCommandEncoderDescriptor const* descriptor);
typedef WGPUComputePipeline (*WGPUProcDeviceCreateComputePipeline)(WGPUDevice device, WGPUComputePipelineDescriptor const* descriptor);
typedef void (*WGPUProcDeviceCreateComputePipelineAsync)(WGPUDevice device, WGPUComputePipelineDescriptor const* descriptor, WGPUDeviceCreateComputePipelineAsyncCallback callback, void* userdata);
typedef WGPUPipelineLayout (*WGPUProcDeviceCreatePipelineLayout)(WGPUDevice device, WGPUPipelineLayoutDescriptor const* descriptor);
typedef WGPUQuerySet (*WGPUProcDeviceCreateQuerySet)(WGPUDevice device, WGPUQuerySetDescriptor const* descriptor);
typedef WGPURenderBundleEncoder (*WGPUProcDeviceCreateRenderBundleEncoder)(WGPUDevice device, WGPURenderBundleEncoderDescriptor const* descriptor);
typedef WGPURenderPipeline (*WGPUProcDeviceCreateRenderPipeline)(WGPUDevice device, WGPURenderPipelineDescriptor const* descriptor);
typedef void (*WGPUProcDeviceCreateRenderPipelineAsync)(WGPUDevice device, WGPURenderPipelineDescriptor const* descriptor, WGPUDeviceCreateRenderPipelineAsyncCallback callback, void* userdata);
typedef WGPUSampler (*WGPUProcDeviceCreateSampler)(WGPUDevice device, WGPUSamplerDescriptor const* descriptor);
typedef WGPUShaderModule (*WGPUProcDeviceCreateShaderModule)(WGPUDevice device, WGPUShaderModuleDescriptor const* descriptor);
typedef WGPUTexture (*WGPUProcDeviceCreateTexture)(WGPUDevice device, WGPUTextureDescriptor const* descriptor);
typedef void (*WGPUProcDeviceDestroy)(WGPUDevice device);
typedef size_t (*WGPUProcDeviceEnumerateFeatures)(WGPUDevice device, WGPUFeatureName* features);
typedef WGPUBool (*WGPUProcDeviceGetLimits)(WGPUDevice device, WGPUSupportedLimits* limits);
typedef WGPUQueue (*WGPUProcDeviceGetQueue)(WGPUDevice device);
typedef WGPUBool (*WGPUProcDeviceHasFeature)(WGPUDevice device, WGPUFeatureName feature);
typedef void (*WGPUProcDevicePopErrorScope)(WGPUDevice device, WGPUErrorCallback callback, void* userdata);
typedef void (*WGPUProcDevicePushErrorScope)(WGPUDevice device, WGPUErrorFilter filter);
typedef void (*WGPUProcDeviceSetLabel)(WGPUDevice device, char const* label);
typedef void (*WGPUProcDeviceReference)(WGPUDevice device);
typedef void (*WGPUProcDeviceRelease)(WGPUDevice device);

// Procs of Instance
typedef WGPUSurface (*WGPUProcInstanceCreateSurface)(WGPUInstance instance, WGPUSurfaceDescriptor const* descriptor);
typedef WGPUBool (*WGPUProcInstanceHasWGSLLanguageFeature)(WGPUInstance instance, WGPUWGSLFeatureName feature);
typedef void (*WGPUProcInstanceProcessEvents)(WGPUInstance instance);
typedef void (*WGPUProcInstanceRequestAdapter)(WGPUInstance instance, WGPURequestAdapterOptions const* options, WGPUInstanceRequestAdapterCallback callback, void* userdata);
typedef void (*WGPUProcInstanceReference)(WGPUInstance instance);
typedef void (*WGPUProcInstanceRelease)(WGPUInstance instance);

// Procs of PipelineLayout
typedef void (*WGPUProcPipelineLayoutSetLabel)(WGPUPipelineLayout pipelineLayout, char const* label);
typedef void (*WGPUProcPipelineLayoutReference)(WGPUPipelineLayout pipelineLayout);
typedef void (*WGPUProcPipelineLayoutRelease)(WGPUPipelineLayout pipelineLayout);

// Procs of QuerySet
typedef void (*WGPUProcQuerySetDestroy)(WGPUQuerySet querySet);
typedef uint32_t (*WGPUProcQuerySetGetCount)(WGPUQuerySet querySet);
typedef WGPUQueryType (*WGPUProcQuerySetGetType)(WGPUQuerySet querySet);
typedef void (*WGPUProcQuerySetSetLabel)(WGPUQuerySet querySet, char const* label);
typedef void (*WGPUProcQuerySetReference)(WGPUQuerySet querySet);
typedef void (*WGPUProcQuerySetRelease)(WGPUQuerySet querySet);

// Procs of Queue
typedef void (*WGPUProcQueueOnSubmittedWorkDone)(WGPUQueue queue, WGPUQueueOnSubmittedWorkDoneCallback callback, void* userdata);
typedef void (*WGPUProcQueueSetLabel)(WGPUQueue queue, char const* label);
typedef void (*WGPUProcQueueSubmit)(WGPUQueue queue, size_t commandCount, WGPUCommandBuffer const* commands);
typedef void (*WGPUProcQueueWriteBuffer)(WGPUQueue queue, WGPUBuffer buffer, uint64_t bufferOffset, void const* data, size_t size);
typedef void (*WGPUProcQueueWriteTexture)(WGPUQueue queue, WGPUImageCopyTexture const* destination, void const* data, size_t dataSize, WGPUTextureDataLayout const* dataLayout, WGPUExtent3D const* writeSize);
typedef void (*WGPUProcQueueReference)(WGPUQueue queue);
typedef void (*WGPUProcQueueRelease)(WGPUQueue queue);

// Procs of RenderBundle
typedef void (*WGPUProcRenderBundleSetLabel)(WGPURenderBundle renderBundle, char const* label);
typedef void (*WGPUProcRenderBundleReference)(WGPURenderBundle renderBundle);
typedef void (*WGPUProcRenderBundleRelease)(WGPURenderBundle renderBundle);

// Procs of RenderBundleEncoder
typedef void (*WGPUProcRenderBundleEncoderDraw)(WGPURenderBundleEncoder renderBundleEncoder, uint32_t vertexCount, uint32_t instanceCount, uint32_t firstVertex, uint32_t firstInstance);
typedef void (*WGPUProcRenderBundleEncoderDrawIndexed)(WGPURenderBundleEncoder renderBundleEncoder, uint32_t indexCount, uint32_t instanceCount, uint32_t firstIndex, int32_t baseVertex, uint32_t firstInstance);
typedef void (*WGPUProcRenderBundleEncoderDrawIndexedIndirect)(WGPURenderBundleEncoder renderBundleEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset);
typedef void (*WGPUProcRenderBundleEncoderDrawIndirect)(WGPURenderBundleEncoder renderBundleEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset);
typedef WGPURenderBundle (*WGPUProcRenderBundleEncoderFinish)(WGPURenderBundleEncoder renderBundleEncoder, WGPURenderBundleDescriptor const* descriptor);
typedef void (*WGPUProcRenderBundleEncoderInsertDebugMarker)(WGPURenderBundleEncoder renderBundleEncoder, char const* markerLabel);
typedef void (*WGPUProcRenderBundleEncoderPopDebugGroup)(WGPURenderBundleEncoder renderBundleEncoder);
typedef void (*WGPUProcRenderBundleEncoderPushDebugGroup)(WGPURenderBundleEncoder renderBundleEncoder, char const* groupLabel);
typedef void (*WGPUProcRenderBundleEncoderSetBindGroup)(WGPURenderBundleEncoder renderBundleEncoder, uint32_t groupIndex, WGPUBindGroup group, size_t dynamicOffsetCount, uint32_t const* dynamicOffsets);
typedef void (*WGPUProcRenderBundleEncoderSetIndexBuffer)(WGPURenderBundleEncoder renderBundleEncoder, WGPUBuffer buffer, WGPUIndexFormat format, uint64_t offset, uint64_t size);
typedef void (*WGPUProcRenderBundleEncoderSetLabel)(WGPURenderBundleEncoder renderBundleEncoder, char const* label);
typedef void (*WGPUProcRenderBundleEncoderSetPipeline)(WGPURenderBundleEncoder renderBundleEncoder, WGPURenderPipeline pipeline);
typedef void (*WGPUProcRenderBundleEncoderSetVertexBuffer)(WGPURenderBundleEncoder renderBundleEncoder, uint32_t slot, WGPUBuffer buffer, uint64_t offset, uint64_t size);
typedef void (*WGPUProcRenderBundleEncoderReference)(WGPURenderBundleEncoder renderBundleEncoder);
typedef void (*WGPUProcRenderBundleEncoderRelease)(WGPURenderBundleEncoder renderBundleEncoder);

// Procs of RenderPassEncoder
typedef void (*WGPUProcRenderPassEncoderBeginOcclusionQuery)(WGPURenderPassEncoder renderPassEncoder, uint32_t queryIndex);
typedef void (*WGPUProcRenderPassEncoderDraw)(WGPURenderPassEncoder renderPassEncoder, uint32_t vertexCount, uint32_t instanceCount, uint32_t firstVertex, uint32_t firstInstance);
typedef void (*WGPUProcRenderPassEncoderDrawIndexed)(WGPURenderPassEncoder renderPassEncoder, uint32_t indexCount, uint32_t instanceCount, uint32_t firstIndex, int32_t baseVertex, uint32_t firstInstance);
typedef void (*WGPUProcRenderPassEncoderDrawIndexedIndirect)(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset);
typedef void (*WGPUProcRenderPassEncoderDrawIndirect)(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset);
typedef void (*WGPUProcRenderPassEncoderEnd)(WGPURenderPassEncoder renderPassEncoder);
typedef void (*WGPUProcRenderPassEncoderEndOcclusionQuery)(WGPURenderPassEncoder renderPassEncoder);
typedef void (*WGPUProcRenderPassEncoderExecuteBundles)(WGPURenderPassEncoder renderPassEncoder, size_t bundleCount, WGPURenderBundle const* bundles);
typedef void (*WGPUProcRenderPassEncoderInsertDebugMarker)(WGPURenderPassEncoder renderPassEncoder, char const* markerLabel);
typedef void (*WGPUProcRenderPassEncoderPopDebugGroup)(WGPURenderPassEncoder renderPassEncoder);
typedef void (*WGPUProcRenderPassEncoderPushDebugGroup)(WGPURenderPassEncoder renderPassEncoder, char const* groupLabel);
typedef void (*WGPUProcRenderPassEncoderSetBindGroup)(WGPURenderPassEncoder renderPassEncoder, uint32_t groupIndex, WGPUBindGroup group, size_t dynamicOffsetCount, uint32_t const* dynamicOffsets);
typedef void (*WGPUProcRenderPassEncoderSetBlendConstant)(WGPURenderPassEncoder renderPassEncoder, WGPUColor const* color);
typedef void (*WGPUProcRenderPassEncoderSetIndexBuffer)(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer buffer, WGPUIndexFormat format, uint64_t offset, uint64_t size);
typedef void (*WGPUProcRenderPassEncoderSetLabel)(WGPURenderPassEncoder renderPassEncoder, char const* label);
typedef void (*WGPUProcRenderPassEncoderSetPipeline)(WGPURenderPassEncoder renderPassEncoder, WGPURenderPipeline pipeline);
typedef void (*WGPUProcRenderPassEncoderSetScissorRect)(WGPURenderPassEncoder renderPassEncoder, uint32_t x, uint32_t y, uint32_t width, uint32_t height);
typedef void (*WGPUProcRenderPassEncoderSetStencilReference)(WGPURenderPassEncoder renderPassEncoder, uint32_t reference);
typedef void (*WGPUProcRenderPassEncoderSetVertexBuffer)(WGPURenderPassEncoder renderPassEncoder, uint32_t slot, WGPUBuffer buffer, uint64_t offset, uint64_t size);
typedef void (*WGPUProcRenderPassEncoderSetViewport)(WGPURenderPassEncoder renderPassEncoder, float x, float y, float width, float height, float minDepth, float maxDepth);
typedef void (*WGPUProcRenderPassEncoderReference)(WGPURenderPassEncoder renderPassEncoder);
typedef void (*WGPUProcRenderPassEncoderRelease)(WGPURenderPassEncoder renderPassEncoder);

// Procs of RenderPipeline
typedef WGPUBindGroupLayout (*WGPUProcRenderPipelineGetBindGroupLayout)(WGPURenderPipeline renderPipeline, uint32_t groupIndex);
typedef void (*WGPUProcRenderPipelineSetLabel)(WGPURenderPipeline renderPipeline, char const* label);
typedef void (*WGPUProcRenderPipelineReference)(WGPURenderPipeline renderPipeline);
typedef void (*WGPUProcRenderPipelineRelease)(WGPURenderPipeline renderPipeline);

// Procs of Sampler
typedef void (*WGPUProcSamplerSetLabel)(WGPUSampler sampler, char const* label);
typedef void (*WGPUProcSamplerReference)(WGPUSampler sampler);
typedef void (*WGPUProcSamplerRelease)(WGPUSampler sampler);

// Procs of ShaderModule
typedef void (*WGPUProcShaderModuleGetCompilationInfo)(WGPUShaderModule shaderModule, WGPUShaderModuleGetCompilationInfoCallback callback, void* userdata);
typedef void (*WGPUProcShaderModuleSetLabel)(WGPUShaderModule shaderModule, char const* label);
typedef void (*WGPUProcShaderModuleReference)(WGPUShaderModule shaderModule);
typedef void (*WGPUProcShaderModuleRelease)(WGPUShaderModule shaderModule);

// Procs of Surface
typedef void (*WGPUProcSurfaceConfigure)(WGPUSurface surface, WGPUSurfaceConfiguration const* config);
typedef void (*WGPUProcSurfaceGetCapabilities)(WGPUSurface surface, WGPUAdapter adapter, WGPUSurfaceCapabilities* surfaceCapabilities);
typedef void (*WGPUProcSurfaceGetCurrentTexture)(WGPUSurface surface, WGPUSurfaceTexture* surfaceTexture);
typedef void (*WGPUProcSurfacePresent)(WGPUSurface surface);
typedef void (*WGPUProcSurfaceSetLabel)(WGPUSurface surface, char const* label);
typedef void (*WGPUProcSurfaceUnconfigure)(WGPUSurface surface);
typedef void (*WGPUProcSurfaceReference)(WGPUSurface surface);
typedef void (*WGPUProcSurfaceRelease)(WGPUSurface surface);

// Procs of SurfaceCapabilities
typedef void (*WGPUProcSurfaceCapabilitiesFreeMembers)(WGPUSurfaceCapabilities surfaceCapabilities);

// Procs of Texture
typedef WGPUTextureView (*WGPUProcTextureCreateView)(WGPUTexture texture, WGPUTextureViewDescriptor const* descriptor);
typedef void (*WGPUProcTextureDestroy)(WGPUTexture texture);
typedef uint32_t (*WGPUProcTextureGetDepthOrArrayLayers)(WGPUTexture texture);
typedef WGPUTextureDimension (*WGPUProcTextureGetDimension)(WGPUTexture texture);
typedef WGPUTextureFormat (*WGPUProcTextureGetFormat)(WGPUTexture texture);
typedef uint32_t (*WGPUProcTextureGetHeight)(WGPUTexture texture);
typedef uint32_t (*WGPUProcTextureGetMipLevelCount)(WGPUTexture texture);
typedef uint32_t (*WGPUProcTextureGetSampleCount)(WGPUTexture texture);
typedef WGPUTextureUsageFlags (*WGPUProcTextureGetUsage)(WGPUTexture texture);
typedef uint32_t (*WGPUProcTextureGetWidth)(WGPUTexture texture);
typedef void (*WGPUProcTextureSetLabel)(WGPUTexture texture, char const* label);
typedef void (*WGPUProcTextureReference)(WGPUTexture texture);
typedef void (*WGPUProcTextureRelease)(WGPUTexture texture);

// Procs of TextureView
typedef void (*WGPUProcTextureViewSetLabel)(WGPUTextureView textureView, char const* label);
typedef void (*WGPUProcTextureViewReference)(WGPUTextureView textureView);
typedef void (*WGPUProcTextureViewRelease)(WGPUTextureView textureView);

// Native wgpu extension types (from wgpu.h)
typedef enum WGPUNativeSType {
	// Start at 0003 since that's allocated range for wgpu-native
	WGPUSType_DeviceExtras = 0x00030001,
	WGPUSType_NativeLimits = 0x00030002,
	WGPUSType_PipelineLayoutExtras = 0x00030003,
	WGPUSType_ShaderModuleGLSLDescriptor = 0x00030004,
	WGPUSType_InstanceExtras = 0x00030006,
	WGPUSType_BindGroupEntryExtras = 0x00030007,
	WGPUSType_BindGroupLayoutEntryExtras = 0x00030008,
	WGPUSType_QuerySetDescriptorExtras = 0x00030009,
	WGPUSType_SurfaceConfigurationExtras = 0x0003000A,
	WGPUNativeSType_Force32 = 0x7FFFFFFF
} WGPUNativeSType;

typedef enum WGPUNativeFeature {
	WGPUNativeFeature_PushConstants = 0x00030001,
	WGPUNativeFeature_TextureAdapterSpecificFormatFeatures = 0x00030002,
	WGPUNativeFeature_MultiDrawIndirect = 0x00030003,
	WGPUNativeFeature_MultiDrawIndirectCount = 0x00030004,
	WGPUNativeFeature_VertexWritableStorage = 0x00030005,
	WGPUNativeFeature_TextureBindingArray = 0x00030006,
	WGPUNativeFeature_SampledTextureAndStorageBufferArrayNonUniformIndexing = 0x00030007,
	WGPUNativeFeature_PipelineStatisticsQuery = 0x00030008,
	WGPUNativeFeature_StorageResourceBindingArray = 0x00030009,
	WGPUNativeFeature_PartiallyBoundBindingArray = 0x0003000A,
	WGPUNativeFeature_TextureFormat16bitNorm = 0x0003000B,
	WGPUNativeFeature_TextureCompressionAstcHdr = 0x0003000C,
	WGPUNativeFeature_MappablePrimaryBuffers = 0x0003000E,
	WGPUNativeFeature_BufferBindingArray = 0x0003000F,
	WGPUNativeFeature_UniformBufferAndStorageTextureArrayNonUniformIndexing = 0x00030010,
	// NYI (breaking API change required)
	// WGPUNativeFeature_AddressModeClampToZero = 0x00030011,
	// WGPUNativeFeature_AddressModeClampToBorder = 0x00030012,
	// WGPUNativeFeature_PolygonModeLine = 0x00030013,
	// WGPUNativeFeature_PolygonModePoint = 0x00030014,
	// WGPUNativeFeature_ConservativeRasterization = 0x00030015,
	// WGPUNativeFeature_ClearTexture = 0x00030016,
	WGPUNativeFeature_SpirvShaderPassthrough = 0x00030017,
	// WGPUNativeFeature_Multiview = 0x00030018,
	WGPUNativeFeature_VertexAttribute64bit = 0x00030019,
	WGPUNativeFeature_TextureFormatNv12 = 0x0003001A,
	WGPUNativeFeature_RayTracingAccelerationStructure = 0x0003001B,
	WGPUNativeFeature_RayQuery = 0x0003001C,
	WGPUNativeFeature_ShaderF64 = 0x0003001D,
	WGPUNativeFeature_ShaderI16 = 0x0003001E,
	WGPUNativeFeature_ShaderPrimitiveIndex = 0x0003001F,
	WGPUNativeFeature_ShaderEarlyDepthTest = 0x00030020,
	WGPUNativeFeature_Subgroup = 0x00030021,
	WGPUNativeFeature_SubgroupVertex = 0x00030022,
	WGPUNativeFeature_SubgroupBarrier = 0x00030023,
	WGPUNativeFeature_TimestampQueryInsideEncoders = 0x00030024,
	WGPUNativeFeature_TimestampQueryInsidePasses = 0x00030025,
	WGPUNativeFeature_Force32 = 0x7FFFFFFF
} WGPUNativeFeature;

typedef enum WGPULogLevel {
	WGPULogLevel_Off = 0x00000000,
	WGPULogLevel_Error = 0x00000001,
	WGPULogLevel_Warn = 0x00000002,
	WGPULogLevel_Info = 0x00000003,
	WGPULogLevel_Debug = 0x00000004,
	WGPULogLevel_Trace = 0x00000005,
	WGPULogLevel_Force32 = 0x7FFFFFFF
} WGPULogLevel;

typedef enum WGPUInstanceBackend {
	WGPUInstanceBackend_All = 0x00000000,
	WGPUInstanceBackend_Vulkan = 1 << 0,
	WGPUInstanceBackend_GL = 1 << 1,
	WGPUInstanceBackend_Metal = 1 << 2,
	WGPUInstanceBackend_DX12 = 1 << 3,
	WGPUInstanceBackend_DX11 = 1 << 4,
	WGPUInstanceBackend_BrowserWebGPU = 1 << 5,
	WGPUInstanceBackend_Primary = WGPUInstanceBackend_Vulkan | WGPUInstanceBackend_Metal | WGPUInstanceBackend_DX12 | WGPUInstanceBackend_BrowserWebGPU,
	WGPUInstanceBackend_Secondary = WGPUInstanceBackend_GL | WGPUInstanceBackend_DX11,
	WGPUInstanceBackend_Force32 = 0x7FFFFFFF
} WGPUInstanceBackend;

typedef enum WGPUInstanceFlag {
	WGPUInstanceFlag_Default = 0x00000000,
	WGPUInstanceFlag_Debug = 1 << 0,
	WGPUInstanceFlag_Validation = 1 << 1,
	WGPUInstanceFlag_DiscardHalLabels = 1 << 2,
	WGPUInstanceFlag_Force32 = 0x7FFFFFFF
} WGPUInstanceFlag;

typedef enum WGPUDx12Compiler {
	WGPUDx12Compiler_Undefined = 0x00000000,
	WGPUDx12Compiler_Fxc = 0x00000001,
	WGPUDx12Compiler_Dxc = 0x00000002,
	WGPUDx12Compiler_Force32 = 0x7FFFFFFF
} WGPUDx12Compiler;

typedef enum WGPUGles3MinorVersion {
	WGPUGles3MinorVersion_Automatic = 0x00000000,
	WGPUGles3MinorVersion_Version0 = 0x00000001,
	WGPUGles3MinorVersion_Version1 = 0x00000002,
	WGPUGles3MinorVersion_Version2 = 0x00000003,
	WGPUGles3MinorVersion_Force32 = 0x7FFFFFFF
} WGPUGles3MinorVersion;

typedef enum WGPUPipelineStatisticName {
	WGPUPipelineStatisticName_VertexShaderInvocations = 0x00000000,
	WGPUPipelineStatisticName_ClipperInvocations = 0x00000001,
	WGPUPipelineStatisticName_ClipperPrimitivesOut = 0x00000002,
	WGPUPipelineStatisticName_FragmentShaderInvocations = 0x00000003,
	WGPUPipelineStatisticName_ComputeShaderInvocations = 0x00000004,
	WGPUPipelineStatisticName_Force32 = 0x7FFFFFFF
} WGPUPipelineStatisticName;

typedef enum WGPUNativeQueryType {
	WGPUNativeQueryType_PipelineStatistics = 0x00030000,
	WGPUNativeQueryType_Force32 = 0x7FFFFFFF
} WGPUNativeQueryType;

typedef struct WGPUInstanceExtras {
	WGPUChainedStruct chain;
	WGPUInstanceBackend backends;
	WGPUInstanceFlag flags;
	WGPUDx12Compiler dx12ShaderCompiler;
	WGPUGles3MinorVersion gles3MinorVersion;
	WGPUStringView dxilPath;
	WGPUStringView dxcPath;
} WGPUInstanceExtras;

typedef struct WGPUDeviceExtras {
	WGPUChainedStruct chain;
	WGPUStringView tracePath;
} WGPUDeviceExtras;

typedef struct WGPUNativeLimits {
	WGPUChainedStructOut chain;
	uint32_t maxPushConstantSize;
	uint32_t maxNonSamplerBindings;
} WGPUNativeLimits;

typedef struct WGPUPushConstantRange {
	WGPUShaderStage stages;
	uint32_t start;
	uint32_t end;
} WGPUPushConstantRange;

typedef struct WGPUPipelineLayoutExtras {
	WGPUChainedStruct chain;
	size_t pushConstantRangeCount;
	WGPUPushConstantRange const* pushConstantRanges;
} WGPUPipelineLayoutExtras;

typedef uint64_t WGPUSubmissionIndex;

typedef struct WGPUWrappedSubmissionIndex {
	WGPUQueue queue;
	WGPUSubmissionIndex submissionIndex;
} WGPUWrappedSubmissionIndex;

typedef struct WGPUShaderDefine {
	char const* name;
	char const* value;
} WGPUShaderDefine;

typedef struct WGPUShaderModuleGLSLDescriptor {
	WGPUChainedStruct chain;
	WGPUShaderStage stage;
	char const* code;
	uint32_t defineCount;
	WGPUShaderDefine* defines;
} WGPUShaderModuleGLSLDescriptor;

typedef struct WGPUShaderModuleDescriptorSpirV {
	char const* label;
	uint32_t sourceSize;
	uint32_t const* source;
} WGPUShaderModuleDescriptorSpirV;

typedef struct WGPURegistryReport {
	size_t numAllocated;
	size_t numKeptFromUser;
	size_t numReleasedFromUser;
	size_t numError;
	size_t elementSize;
} WGPURegistryReport;

typedef struct WGPUHubReport {
	WGPURegistryReport adapters;
	WGPURegistryReport devices;
	WGPURegistryReport queues;
	WGPURegistryReport pipelineLayouts;
	WGPURegistryReport shaderModules;
	WGPURegistryReport bindGroupLayouts;
	WGPURegistryReport bindGroups;
	WGPURegistryReport commandBuffers;
	WGPURegistryReport renderBundles;
	WGPURegistryReport renderPipelines;
	WGPURegistryReport computePipelines;
	WGPURegistryReport querySets;
	WGPURegistryReport buffers;
	WGPURegistryReport textures;
	WGPURegistryReport textureViews;
	WGPURegistryReport samplers;
} WGPUHubReport;

typedef struct WGPUGlobalReport {
	WGPURegistryReport surfaces;
	WGPUBackendType backendType;
	WGPUHubReport vulkan;
	WGPUHubReport metal;
	WGPUHubReport dx12;
	WGPUHubReport gl;
} WGPUGlobalReport;

typedef struct WGPUInstanceEnumerateAdapterOptions {
	WGPUChainedStruct const* nextInChain;
	WGPUInstanceBackend backends;
} WGPUInstanceEnumerateAdapterOptions;

typedef struct WGPUBindGroupEntryExtras {
	WGPUChainedStruct chain;
	WGPUBuffer const* buffers;
	size_t bufferCount;
	WGPUSampler const* samplers;
	size_t samplerCount;
	WGPUTextureView const* textureViews;
	size_t textureViewCount;
} WGPUBindGroupEntryExtras;

typedef struct WGPUBindGroupLayoutEntryExtras {
	WGPUChainedStruct chain;
	uint32_t count;
} WGPUBindGroupLayoutEntryExtras;

typedef struct WGPUQuerySetDescriptorExtras {
	WGPUChainedStruct chain;
	WGPUPipelineStatisticName const* pipelineStatistics;
	size_t pipelineStatisticCount;
} WGPUQuerySetDescriptorExtras;

typedef struct WGPUSurfaceConfigurationExtras {
	WGPUChainedStruct chain;
	uint32_t desiredMaximumFrameLatency;
} WGPUSurfaceConfigurationExtras;

typedef void (*WGPULogCallback)(WGPULogLevel level, char const* message, void* userdata);

typedef enum WGPUNativeTextureFormat {
	// From Features::TEXTURE_FORMAT_16BIT_NORM
	WGPUNativeTextureFormat_R16Unorm = 0x00030001,
	WGPUNativeTextureFormat_R16Snorm = 0x00030002,
	WGPUNativeTextureFormat_Rg16Unorm = 0x00030003,
	WGPUNativeTextureFormat_Rg16Snorm = 0x00030004,
	WGPUNativeTextureFormat_Rgba16Unorm = 0x00030005,
	WGPUNativeTextureFormat_Rgba16Snorm = 0x00030006,
	// From Features::TEXTURE_FORMAT_NV12
	WGPUNativeTextureFormat_NV12 = 0x00030007,
} WGPUNativeTextureFormat;