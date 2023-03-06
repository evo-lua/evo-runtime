-- local ffi = require("ffi")
-- local uv = require("uv")
local uws = require("uws")

-- local webview_create = webview.bindings.webview_create
-- local webview_run_once = webview.bindings.webview_run_once

describe("uws", function()
	describe("bindings", function()
		it("should export the entirety of the uws C API", function()
			local exportedApiSurface = {
				"uws_create_app",
				"uws_app_destroy",
				"uws_app_get",
				"uws_app_post",
				"uws_app_options",
				"uws_app_delete",
				"uws_app_patch",
				"uws_app_put",
				"uws_app_head",
				"uws_app_connect",
				"uws_app_trace",
				"uws_app_any",
				"uws_app_run",
				"uws_app_listen",
				"uws_app_listen_with_config",
				"uws_app_listen_domain",
				"uws_app_listen_domain_with_options",
				"uws_app_domain",
				"uws_constructor_failed",
				"uws_num_subscribers",
				"uws_publish",
				"uws_get_native_handle",
				"uws_remove_server_name",
				"uws_add_server_name",
				"uws_add_server_name_with_options",
				"uws_missing_server_name",
				"uws_filter",
				"uws_ws",
				"uws_ws_get_user_data",
				"uws_ws_close",
				"uws_ws_send",
				"uws_ws_send_with_options",
				"uws_ws_send_fragment",
				"uws_ws_send_first_fragment",
				"uws_ws_send_first_fragment_with_opcode",
				"uws_ws_send_last_fragment",
				"uws_ws_end",
				"uws_ws_cork",
				"uws_ws_subscribe",
				"uws_ws_unsubscribe",
				"uws_ws_is_subscribed",
				"uws_ws_iterate_topics",
				"uws_ws_publish",
				"uws_ws_publish_with_options",
				"uws_ws_get_buffered_amount",
				"uws_ws_get_remote_address",
				"uws_ws_get_remote_address_as_text",
				"uws_res_end",
				"uws_res_try_end",
				"uws_res_cork",
				"uws_res_pause",
				"uws_res_resume",
				"uws_res_write_continue",
				"uws_res_write_status",
				"uws_res_write_header",
				"uws_res_write_header_int",
				"uws_res_end_without_body",
				"uws_res_write",
				"uws_res_get_write_offset",
				"uws_res_override_write_offset",
				"uws_res_has_responded",
				"uws_res_on_writable",
				"uws_res_on_aborted",
				"uws_res_on_data",
				"uws_res_upgrade",
				"uws_res_get_remote_address",
				"uws_res_get_remote_address_as_text",
				-- "uws_res_get_proxied_remote_address",
				-- "uws_res_get_proxied_remote_address_as_text",
				"uws_res_get_native_handle",
				"uws_req_is_ancient",
				"uws_req_get_yield",
				"uws_req_set_yield",
				"uws_req_get_url",
				"uws_req_get_full_url",
				"uws_req_get_method",
				"uws_req_get_case_sensitive_method",
				"uws_req_get_header",
				"uws_req_for_each_header",
				"uws_req_get_query",
				"uws_req_get_parameter",
				"uws_get_loop",
				"uws_get_loop_with_native",
			}

			for _, functionName in ipairs(exportedApiSurface) do
				assertEquals(type(uws.bindings[functionName]), "cdata")
			end
		end)

		-- 		describe("run_once", function()
		-- 			it("should not block the event loop", function()
		-- 				local view = webview_create(true, nil)

		-- 				local WEBVIEW_HINT_NONE = 0
		-- 				webview.bindings.webview_set_size(view, 640, 480, WEBVIEW_HINT_NONE)
		-- 				webview.bindings.webview_set_title(view, "Le window")

		-- 				local numUpdates = 0

		-- 				local TARGET_FPS = 60 -- Since timers are inherently at least a little inaccurate, might have to be increased ?
		-- 				local GUI_UPDATE_INTERVAL_IN_MS = 1000 / TARGET_FPS
		-- 				local guiUpdateTimer = uv.new_timer()

		-- 				guiUpdateTimer:start(GUI_UPDATE_INTERVAL_IN_MS, GUI_UPDATE_INTERVAL_IN_MS, function()
		-- 					numUpdates = numUpdates + 1
		-- 					webview_run_once(view, false)

		-- 					if numUpdates == 6 then
		-- 						uv.stop()
		-- 						webview.bindings.webview_destroy(view)
		-- 					end
		-- 				end)

		-- 				uv.run()
		-- 			end)
		-- 		end)
		-- 	end)

		-- 	-- This should be moved to the runtime library, once it is actually implemented...
		-- 	describe("version", function()
		-- 		it("should be a semantic version string", function()
		-- 			local versionString = webview.version()
		-- 			local major, minor, patch = string.match(versionString, "(%d+).(%d+).(%d+)")

		-- 			assertEquals(type(major), "string")
		-- 			assertEquals(type(minor), "string")
		-- 			assertEquals(type(patch), "string")
		-- 		end)

		-- 		it("should be the version number returned by webview_version()", function()
		-- 			local versionInfo = webview.bindings.webview_version()
		-- 			local expectedVersionString = ffi.string(versionInfo.version_number)

		-- 			assertEquals(webview.version(), expectedVersionString)
		-- 		end)
	end)
end)
