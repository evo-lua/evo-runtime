#pragma once

#include <webgpu.h>
#include <wgpu.h>

#include "wgpu_exports.h"

namespace wgpu_ffi {
	void* getExportsTable();
}