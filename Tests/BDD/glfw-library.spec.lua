local glfw = require("glfw")

describe("glfw", function()
	describe("bindings", function()
		it("should export the entirety of the glfw API", function()
			local exportedApiSurface = {
				"glfw_version",
				"glfw_find_constant",
				"glfw_get_wgpu_surface",
				"glfw_init",
				"glfw_terminate",
				"glfw_poll_events",
				"glfw_create_window",
				"glfw_destroy_window",
				"glfw_window_should_close",
				"glfw_window_hint",
				"glfw_set_window_pos",
				"glfw_get_framebuffer_size",
				"glfw_get_window_size",
				"glfw_register_events",
				"glfw_get_primary_monitor",
				"glfw_get_monitors",
				"glfw_get_window_monitor",
				"glfw_set_window_monitor",
				"glfw_get_video_mode",
			}

			for _, functionName in ipairs(exportedApiSurface) do
				assertEquals(type(glfw.bindings[functionName]), "cdata")
			end
		end)
	end)

	describe("glfw_find_constant", function()
		it("should return the defined value if the constant exists", function()
			local value = glfw.bindings.glfw_find_constant("GLFW_KEY_0")
			assertEquals(value, 48)
		end)

		it("should return a special sentinel value if the constant does not exist", function()
			local value = glfw.bindings.glfw_find_constant("DOES_NOT_EXIST")
			assertEquals(value, 0xdead)
		end)
	end)

	describe("version", function()
		it("should return the embedded glfw version in semver format", function()
			local versionString = glfw.version()
			local firstMatchedCharacterIndex, lastMatchedCharacterIndex = string.find(versionString, "%d+.%d+.%d+")

			assertEquals(firstMatchedCharacterIndex, 1)
			assertEquals(lastMatchedCharacterIndex, string.len(versionString))
			assertEquals(type(string.match(versionString, "%d+.%d+.%d+")), "string")
		end)
	end)
end)
