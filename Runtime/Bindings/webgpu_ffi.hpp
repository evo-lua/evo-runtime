#pragma once

#include <webgpu.h>
#include <wgpu.h>

#include <string>

#include "webgpu_exports.h"

namespace webgpu_ffi {
	void* getExportsTable();
}