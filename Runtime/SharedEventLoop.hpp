#pragma once

#include "LuaVirtualMachine.hpp"
#include "curl_ffi.hpp"
#include "uws_ffi.hpp"

#include <cassert>
#include <format>
#include <memory>
#include <stdexcept>

using namespace std;
using uws_loop_t = uWS::Loop*;

extern "C" {
#include "luv.h"
#include "uv.h"
}

class SharedEventLoop {
private:
	shared_ptr<LuaVirtualMachine> m_mainThreadVM;

	uv_loop_t m_uvMainLoop;
	uws_loop_t m_uwsMainLoop;

public:
	explicit SharedEventLoop(auto L) {
		assert(L != nullptr);
		m_mainThreadVM = L;

		int errorCode = uv_loop_init(&m_uvMainLoop);
		if(errorCode != 0) {
			auto message = format("Failed to initialize shared event loop ({}: {})",
				uv_err_name(errorCode), uv_strerror(errorCode));
			throw runtime_error(message);
		}

		luv_set_loop(m_mainThreadVM->GetState(), &m_uvMainLoop);

		auto uwsEventLoop = uws_ffi::assignEventLoop(&m_uvMainLoop);
		assert(uwsEventLoop != nullptr);
		m_uwsMainLoop = uwsEventLoop;

		CURLcode status = curl_global_init(CURL_GLOBAL_ALL);
		if(status != CURLE_OK) {
			auto message = format("Failed to initialize libcurl environment ({})", curl_easy_strerror(status));
			throw runtime_error(message);
		}
	}

	~SharedEventLoop() {
		luv_set_loop(m_mainThreadVM->GetState(), nullptr);
		uws_ffi::unassignEventLoop(m_uwsMainLoop);
		curl_global_cleanup();
	}

	void RunMainLoopUntilDone() {
		// There's just a single main loop right now, but that'll probably need to change
		int refCount = uv_run(&m_uvMainLoop, UV_RUN_DEFAULT);
		if(refCount != 0) {
			auto message = format("Main loop finished running, but there's {} active references", refCount);
			throw runtime_error(message);
		}
	}
};