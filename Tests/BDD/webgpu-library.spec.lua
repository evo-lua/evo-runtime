local ffi = require("ffi")
local new = ffi.new

local function assertNumber(value)
	assertEquals(type(value), "number")
end

local function assertStruct(cdata)
	assertEquals(type(cdata), "cdata")
end

describe("webgpu", function()
	describe("bindings", function()
		it("should export native wgpu extension enums", function()
			-- WGPUNativeSType
			assertNumber(ffi.C.WGPUSType_DeviceExtras)
			assertNumber(ffi.C.WGPUSType_RequiredLimitsExtras)
			assertNumber(ffi.C.WGPUSType_PipelineLayoutExtras)
			assertNumber(ffi.C.WGPUSType_ShaderModuleGLSLDescriptor)
			assertNumber(ffi.C.WGPUSType_SupportedLimitsExtras)
			assertNumber(ffi.C.WGPUSType_InstanceExtras)
			assertNumber(ffi.C.WGPUSType_BindGroupEntryExtras)
			assertNumber(ffi.C.WGPUSType_BindGroupLayoutEntryExtras)
			assertNumber(ffi.C.WGPUSType_QuerySetDescriptorExtras)
			assertNumber(ffi.C.WGPUSType_SurfaceConfigurationExtras)
			assertNumber(ffi.C.WGPUNativeSType_Force32)

			-- WGPUNativeFeature
			assertNumber(ffi.C.WGPUNativeFeature_PushConstants)
			assertNumber(ffi.C.WGPUNativeFeature_TextureAdapterSpecificFormatFeatures)
			assertNumber(ffi.C.WGPUNativeFeature_MultiDrawIndirect)
			assertNumber(ffi.C.WGPUNativeFeature_MultiDrawIndirectCount)
			assertNumber(ffi.C.WGPUNativeFeature_VertexWritableStorage)
			assertNumber(ffi.C.WGPUNativeFeature_TextureBindingArray)
			assertNumber(ffi.C.WGPUNativeFeature_SampledTextureAndStorageBufferArrayNonUniformIndexing)
			assertNumber(ffi.C.WGPUNativeFeature_PipelineStatisticsQuery)
			assertNumber(ffi.C.WGPUNativeFeature_Force32)
			assertNumber(ffi.C.WGPUNativeFeature_SampledTextureAndStorageBufferArrayNonUniformIndexing)
			assertNumber(ffi.C.WGPUNativeFeature_TextureBindingArray)

			-- WGPULogLevel
			assertNumber(ffi.C.WGPULogLevel_Off)
			assertNumber(ffi.C.WGPULogLevel_Error)
			assertNumber(ffi.C.WGPULogLevel_Warn)
			assertNumber(ffi.C.WGPULogLevel_Info)
			assertNumber(ffi.C.WGPULogLevel_Debug)
			assertNumber(ffi.C.WGPULogLevel_Trace)
			assertNumber(ffi.C.WGPULogLevel_Force32)

			-- WGPUInstanceBackend
			assertNumber(ffi.C.WGPUInstanceBackend_All)
			assertNumber(ffi.C.WGPUInstanceBackend_Vulkan)
			assertNumber(ffi.C.WGPUInstanceBackend_GL)
			assertNumber(ffi.C.WGPUInstanceBackend_Metal)
			assertNumber(ffi.C.WGPUInstanceBackend_DX12)
			assertNumber(ffi.C.WGPUInstanceBackend_DX11)
			assertNumber(ffi.C.WGPUInstanceBackend_BrowserWebGPU)
			assertNumber(ffi.C.WGPUInstanceBackend_Primary)
			assertNumber(ffi.C.WGPUInstanceBackend_BrowserWebGPU)
			assertNumber(ffi.C.WGPUInstanceBackend_Secondary)
			assertNumber(ffi.C.WGPUInstanceBackend_Force32)

			-- WGPUInstanceFlag
			assertNumber(ffi.C.WGPUInstanceFlag_Default)
			assertNumber(ffi.C.WGPUInstanceFlag_Debug)
			assertNumber(ffi.C.WGPUInstanceFlag_Validation)
			assertNumber(ffi.C.WGPUInstanceFlag_DiscardHalLabels)
			assertNumber(ffi.C.WGPUInstanceFlag_Force32)

			-- WGPUDx12Compiler
			assertNumber(ffi.C.WGPUDx12Compiler_Undefined)
			assertNumber(ffi.C.WGPUDx12Compiler_Fxc)
			assertNumber(ffi.C.WGPUDx12Compiler_Dxc)
			assertNumber(ffi.C.WGPUDx12Compiler_Force32)

			-- WGPUGles3MinorVersion
			assertNumber(ffi.C.WGPUGles3MinorVersion_Automatic)
			assertNumber(ffi.C.WGPUGles3MinorVersion_Version0)
			assertNumber(ffi.C.WGPUGles3MinorVersion_Version1)
			assertNumber(ffi.C.WGPUGles3MinorVersion_Version2)
			assertNumber(ffi.C.WGPUGles3MinorVersion_Force32)

			-- WGPUPipelineStatisticName
			assertNumber(ffi.C.WGPUPipelineStatisticName_VertexShaderInvocations)
			assertNumber(ffi.C.WGPUPipelineStatisticName_ClipperInvocations)
			assertNumber(ffi.C.WGPUPipelineStatisticName_ClipperPrimitivesOut)
			assertNumber(ffi.C.WGPUPipelineStatisticName_FragmentShaderInvocations)
			assertNumber(ffi.C.WGPUPipelineStatisticName_ComputeShaderInvocations)
			assertNumber(ffi.C.WGPUPipelineStatisticName_Force32)

			-- WGPUNativeQueryType
			assertNumber(ffi.C.WGPUNativeQueryType_PipelineStatistics)
			assertNumber(ffi.C.WGPUNativeQueryType_Force32)
		end)

		it("should export native wgpu extension types", function()
			assertStruct(new("WGPUInstanceExtras"))
			assertStruct(new("WGPUDeviceExtras"))
			assertStruct(new("WGPUNativeLimits"))
			assertStruct(new("WGPURequiredLimitsExtras"))
			assertStruct(new("WGPUSupportedLimitsExtras"))
			assertStruct(new("WGPUPushConstantRange"))
			assertStruct(new("WGPUPipelineLayoutExtras"))
			assertStruct(new("WGPUSubmissionIndex"))
			assertStruct(new("WGPUWrappedSubmissionIndex"))
			assertStruct(new("WGPUShaderDefine"))
			assertStruct(new("WGPUShaderModuleGLSLDescriptor"))
			assertStruct(new("WGPURegistryReport"))
			assertStruct(new("WGPUHubReport"))
			assertStruct(new("WGPUGlobalReport"))
			assertStruct(new("WGPUInstanceEnumerateAdapterOptions"))
			assertStruct(new("WGPUBindGroupEntryExtras"))
			assertStruct(new("WGPUBindGroupLayoutEntryExtras"))
			assertStruct(new("WGPUQuerySetDescriptorExtras"))
			assertStruct(new("WGPUSurfaceConfigurationExtras"))
		end)
	end)
end)
