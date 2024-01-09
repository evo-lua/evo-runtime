local ffi = require("ffi")
local labsound = require("labsound")

describe("labsound", function()
	describe("version", function()
		it("should return the embedded LabSound version in semver format", function()
			local embeddedLibraryVersion = labsound.version()
			local firstMatchedCharacterIndex, lastMatchedCharacterIndex =
				string.find(embeddedLibraryVersion, "%d+.%d+.%d+")

			assertEquals(firstMatchedCharacterIndex, 1)
			assertEquals(lastMatchedCharacterIndex, string.len(embeddedLibraryVersion))
			assertEquals(type(string.match(embeddedLibraryVersion, "%d+.%d+.%d+")), "string")
		end)
	end)

	describe("bindings", function()
		describe("labsound_get_default_device_config", function()
			it("should return false if nullptr values are passed", function()
				local config = ffi.new("labsound_audio_stream_config_t")
				assertFalse(labsound.bindings.labsound_get_default_device_config(config, nil, false))
				assertFalse(labsound.bindings.labsound_get_default_device_config(nil, config, false))
				assertFalse(labsound.bindings.labsound_get_default_device_config(nil, nil, false))
			end)
		end)

		describe("labsound_get_device_info", function()
			it("should return false if nullptr values are passed", function()
				assertFalse(labsound.bindings.labsound_get_device_info(0, nil))
			end)
		end)

		describe("labsound_device_create", function()
			it("should return nullptr if nullptr values are passed", function()
				local config = ffi.new("labsound_audio_stream_config_t")
				assert(labsound.bindings.labsound_device_create(config, nil) == ffi.NULL)
				assert(labsound.bindings.labsound_device_create(nil, config) == ffi.NULL)
				assert(labsound.bindings.labsound_device_create(nil, nil) == ffi.NULL)
			end)
		end)

		describe("labsound_device_destroy", function()
			it("should not crash if nullptr values were passed", function()
				labsound.bindings.labsound_device_destroy(nil)
			end)
		end)

		describe("labsound_context_destroy", function()
			it("should not crash if nullptr values were passed", function()
				labsound.bindings.labsound_context_destroy(nil)
			end)
		end)

		describe("labsound_context_connect", function()
			it("should return false if nullptr values were passed", function()
				local context = ffi.new("labsound_audio_context_t")
				local node = ffi.new("labsound_audio_node_t")

				assertFalse(labsound.bindings.labsound_context_connect(context, node, nil, 0, 0))
				assertFalse(labsound.bindings.labsound_context_connect(context, nil, node, 0, 0))
				assertFalse(labsound.bindings.labsound_context_connect(context, nil, nil, 0, 0))
				assertFalse(labsound.bindings.labsound_context_connect(nil, node, node, 0, 0))
				assertFalse(labsound.bindings.labsound_context_connect(nil, node, nil, 0, 0))
				assertFalse(labsound.bindings.labsound_context_connect(nil, nil, node, 0, 0))
				assertFalse(labsound.bindings.labsound_context_connect(nil, nil, nil, 0, 0))
			end)
		end)

		describe("labsound_context_disconnect", function()
			it("should return false if nullptr values were passed", function()
				local context = ffi.new("labsound_audio_context_t")
				local node = ffi.new("labsound_audio_node_t")

				assertFalse(labsound.bindings.labsound_context_disconnect(context, node, nil, 0, 0))
				assertFalse(labsound.bindings.labsound_context_disconnect(context, nil, node, 0, 0))
				assertFalse(labsound.bindings.labsound_context_disconnect(context, nil, nil, 0, 0))
				assertFalse(labsound.bindings.labsound_context_disconnect(nil, node, node, 0, 0))
				assertFalse(labsound.bindings.labsound_context_disconnect(nil, node, nil, 0, 0))
				assertFalse(labsound.bindings.labsound_context_disconnect(nil, nil, node, 0, 0))
				assertFalse(labsound.bindings.labsound_context_disconnect(nil, nil, nil, 0, 0))
			end)
		end)

		describe("labsound_destination_node_create", function()
			it("should return nullptr if nullptr values are passed", function()
				local context = ffi.new("labsound_audio_context_t")
				local device = ffi.new("labsound_audio_device_t")
				assert(labsound.bindings.labsound_destination_node_create(context, nil) == ffi.NULL)
				assert(labsound.bindings.labsound_destination_node_create(nil, device) == ffi.NULL)
				assert(labsound.bindings.labsound_destination_node_create(nil, nil) == ffi.NULL)
			end)
		end)

		describe("labsound_destination_node_destroy", function()
			it("should not crash if nullptr values were passed", function()
				labsound.bindings.labsound_destination_node_destroy(nil)
			end)
		end)

		describe("labsound_gain_node_create", function()
			it("should return nullptr if nullptr values are passed", function()
				assert(labsound.bindings.labsound_gain_node_create(nil) == ffi.NULL)
			end)
		end)

		describe("labsound_gain_node_destroy", function()
			it("should not crash if nullptr values were passed", function()
				labsound.bindings.labsound_gain_node_destroy(nil)
			end)
		end)

		describe("labsound_gain_node_set_value", function()
			it("should return false if nullptr values are passed", function()
				assertFalse(labsound.bindings.labsound_gain_node_set_value(nil, 0.5))
			end)

			it("should return false if invalid nodes are passed", function()
				local node = ffi.new("labsound_gain_node_t") -- Uninitialized
				assertFalse(labsound.bindings.labsound_gain_node_set_value(node, 0.5))
			end)
		end)

		describe("labsound_sampled_audio_node_from_file", function()
			it("should return nullptr if nullptr values are passed", function()
				local context = ffi.new("labsound_audio_context_t")
				local WAV_FILE = path.join("deps", "LabSound", "LabSound", "assets", "samples", "stereo-music-clip.wav")
				assert(labsound.bindings.labsound_sampled_audio_node_from_file(context, nil, false) == ffi.NULL)
				assert(labsound.bindings.labsound_sampled_audio_node_from_file(nil, WAV_FILE, false) == ffi.NULL)
				assert(labsound.bindings.labsound_sampled_audio_node_from_file(nil, nil, false) == ffi.NULL)
			end)

			it("should return nullptr if an invalid file path was passed", function()
				local context = ffi.new("labsound_audio_context_t")
				local path = "invalid.xyz"
				assert(labsound.bindings.labsound_sampled_audio_node_from_file(context, path, false) == ffi.NULL)
				assert(labsound.bindings.labsound_sampled_audio_node_from_file(context, path, false) == ffi.NULL)
			end)
		end)

		describe("labsound_sampled_audio_node_from_memory", function()
			it("should return nullptr if nullptr values are passed", function()
				local context = ffi.new("labsound_audio_context_t")
				local WAV_FILE = path.join("deps", "LabSound", "LabSound", "assets", "samples", "stereo-music-clip.wav")
				local WAV_FILE_CONTENTS = C_FileSystem.ReadFile(WAV_FILE)
				assert(labsound.bindings.labsound_sampled_audio_node_from_memory(context, nil, 0, false) == ffi.NULL)
				assert(
					labsound.bindings.labsound_sampled_audio_node_from_memory(
						nil,
						WAV_FILE_CONTENTS,
						#WAV_FILE_CONTENTS,
						false
					) == ffi.NULL
				)
				assert(labsound.bindings.labsound_sampled_audio_node_from_memory(nil, nil, 0, false) == ffi.NULL)
			end)

			it("should return nullptr if an invalid file contents were passed", function()
				local context = ffi.new("labsound_audio_context_t")
				local fileContents = "invalid"
				assert(
					labsound.bindings.labsound_sampled_audio_node_from_memory(
						context,
						fileContents,
						#fileContents,
						false
					) == ffi.NULL
				)
				assert(
					labsound.bindings.labsound_sampled_audio_node_from_memory(
						context,
						fileContents,
						#fileContents,
						false
					) == ffi.NULL
				)
			end)
		end)

		describe("labsound_sampled_audio_node_destroy", function()
			it("should not crash if nullptr values were passed", function()
				labsound.bindings.labsound_sampled_audio_node_destroy(nil)
			end)
		end)

		describe("labsound_sampled_audio_node_start", function()
			it("should return false if nullptr values were passed", function()
				assertFalse(labsound.bindings.labsound_sampled_audio_node_start(nil, 0, 0))
			end)
		end)

		describe("labsound_sampled_audio_node_stop", function()
			it("should return false if nullptr values were passed", function()
				assertFalse(labsound.bindings.labsound_sampled_audio_node_stop(nil, 0))
			end)
		end)
	end)
end)
