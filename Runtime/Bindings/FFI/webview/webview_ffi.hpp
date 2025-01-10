#pragma once

namespace webview_ffi {
	void* getExportsTable();
	auto unwrapResult(auto result);
}