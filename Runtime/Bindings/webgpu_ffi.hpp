#pragma once

#include <webgpu.h>
#include <wgpu.h>

#include "webgpu_exports.h"

namespace webgpu_ffi {
	const char* getTypeDefinitions();
	void* getExportsTable();
}