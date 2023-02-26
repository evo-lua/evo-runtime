local ffi = require("ffi")

local webview = require("webview")

describe("webview", function()
	describe("bindings", function()
		it("should export the entirety of the webview API", function()
			local exportedApiSurface = {
				"webview_bind",
				"webview_create",
				"webview_destroy",
				"webview_dispatch",
				"webview_eval",
				"webview_get_window",
				"webview_init",
				"webview_navigate",
				"webview_return",
				"webview_run",
				"webview_run_once",
				"webview_set_html",
				"webview_set_size",
				"webview_set_title",
				"webview_terminate",
				"webview_unbind",
				"webview_version",
			}

			for _, functionName in ipairs(exportedApiSurface) do
				assertEquals(type(webview.bindings[functionName]), "cdata")
			end
		end)

		describe("run_once", function()
			it("should not block the event loop", function()
				local view = webview.bindings.webview_create(true, nil)

				webview.bindings.webview_run_once(view)
				-- webview.bindings.webview_terminate(view)
				webview.bindings.webview_destroy(view)
			end)

			it("should update the state of the webview", function()
				local view = webview.bindings.webview_create(true, nil)

				webview.bindings.webview_run_once(view)
				-- webview.bindings.webview_terminate(view)
				webview.bindings.webview_destroy(view)

				-- local view = webview.bindings.webview_create(true, nil)

				-- webview.bindings.webview_set_title("TEST")
				-- webview.bindings.webview_run_once(view)

				-- webview.bindings.webview_terminate(view)
				-- webview.bindings.webview_destroy(view)
			end)
		end)
	end)

	-- This should be moved to the runtime library, once it is actually implemented...
	describe("version", function()
		it("should be a semantic version string", function()
			local versionString = webview.version()
			local major, minor, patch = string.match(versionString, "(%d+).(%d+).(%d+)")

			assertEquals(type(major), "string")
			assertEquals(type(minor), "string")
			assertEquals(type(patch), "string")
		end)

		it("should be the version number returned by webview_version()", function()
			local versionInfo = webview.bindings.webview_version()
			local expectedVersionString = ffi.string(versionInfo.version_number)

			assertEquals(webview.version(), expectedVersionString)
		end)
	end)
end)
