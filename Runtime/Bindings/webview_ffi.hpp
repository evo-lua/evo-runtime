#pragma once

#include "webview.h"

#include <string>

#include "webview_exports.h"

namespace webview_ffi {
	std::string getTypeDefinitions();
	void* getExportsTable();
}