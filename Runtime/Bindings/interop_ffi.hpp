#pragma once

#include <webgpu.h>

#include <queue>
#include <cstddef>
#include <string>

typedef WGPUTexture wgpu_texture_t;
typedef WGPUBuffer wgpu_buffer_t;

// Opaque to LuaJIT (must use C API to access)
union deferred_event_t;
typedef std::queue<deferred_event_t>* deferred_event_queue_t;

#include "interop_exports.h"

namespace interop_ffi {
	std::string getTypeDefinitions();
	void* getExportsTable();
}