#pragma once

#include <cstddef>

struct static_iconv_exports_table {
	size_t (*iconv_convert)(char* input, size_t input_size, const char* input_encoding, const char* output_encoding, char* output, size_t output_size);
};

namespace iconv_ffi {
	void* getExportsTable();
}