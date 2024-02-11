#pragma once

#include "webview.h"
#include "webview_exports.h"

namespace webview_ffi {
	const char* getTypeDefinitions();
	void* getExportsTable();
}