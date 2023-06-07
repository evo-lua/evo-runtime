#include "macros.hpp"
#include "stbi_ffi.hpp"

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

const char* stbi_version() {
	// There's no versioned releases or semver here, so this is as good as it gets
	return TOSTRING(STBI_VERSION) ".0.0";
}

bool stbi_image_info(stbi_readonly_file_contents_t buffer, const size_t file_size, stbi_image_t* image) {
	if(!buffer) return false;
	if(!image) return false;

	return stbi_info_from_memory(buffer, file_size, &image->width, &image->height, &image->channels);
}

bool stbi_load_image(stbi_readonly_file_contents_t buffer, const size_t file_size, stbi_image_t* image) {
	if(!buffer) return false;
	if(!image) return false;

	image->data = stbi_load_from_memory(buffer, file_size, &image->width, &image->height, &image->channels, NO_CONVERSION);
	return image->data != nullptr;
}

bool stbi_load_rgb(stbi_readonly_file_contents_t buffer, const size_t file_size, stbi_image_t* image) {
	if(!buffer) return false;
	if(!image) return false;

	image->data = stbi_load_from_memory(buffer, file_size, &image->width, &image->height, &image->channels, CONVERT_TO_RGB);
	return image->data != nullptr;
}

bool stbi_load_rgba(stbi_readonly_file_contents_t buffer, const size_t file_size, stbi_image_t* image) {
	if(!buffer) return false;
	if(!image) return false;

	image->data = stbi_load_from_memory(buffer, file_size, &image->width, &image->height, &image->channels, CONVERT_TO_RGB_WITH_ALPHA);
	return image->data != nullptr;
}

bool stbi_load_monochrome(stbi_readonly_file_contents_t buffer, const size_t file_size, stbi_image_t* image) {
	if(!buffer) return false;
	if(!image) return false;

	image->data = stbi_load_from_memory(buffer, file_size, &image->width, &image->height, &image->channels, CONVERT_TO_GREYSCALE);
	return image->data != nullptr;
}

bool stbi_load_monochrome_with_alpha(stbi_readonly_file_contents_t buffer, const size_t file_size, stbi_image_t* image) {
	if(!buffer) return false;
	if(!image) return false;

	image->data = stbi_load_from_memory(buffer, file_size, &image->width, &image->height, &image->channels, CONVERT_TO_GREYSCALE_WITH_ALPHA);
	return image->data != nullptr;
}

bool stbi_image_free(stbi_image_t* image) {
	if(!image) return false;
	if(!image->data) return false;

	stbi_image_free(image->data);
	return true;
}

static void append_to_buffer(void* context, void* chunk, int chunk_size) {
	luajit_stringbuffer_t* result = static_cast<luajit_stringbuffer_t*>(context);

	bool hasBufferEnoughSpace = result->num_bytes_used + chunk_size <= result->capacity;
	if(!hasBufferEnoughSpace) {
		// One day we'll have a proper error handling system... but today is not that day
		printf("[stbi_ffi] Cannot append_to_buffer: Reserved LuaJIT string buffer capacity exhausted\n");
		return;
	}

	memcpy(result->data + result->num_bytes_used, chunk, chunk_size);
	result->num_bytes_used += chunk_size;
}

size_t stbi_encode_bmp(stbi_image_t* image, uint8_t* buffer, const size_t buffer_size) {
	if(!buffer) return 0;
	if(!image) return 0;
	if(!image->data) return 0;

	luajit_stringbuffer_t result = { buffer, buffer_size, 0 };
	stbi_write_bmp_to_func(append_to_buffer, &result, image->width, image->height, image->channels, image->data);

	return result.num_bytes_used;
}

size_t stbi_encode_png(stbi_image_t* image, uint8_t* buffer, const size_t buffer_size, const int stride) {
	if(!buffer) return 0;
	if(!image) return 0;
	if(!image->data) return 0;

	luajit_stringbuffer_t result = { buffer, buffer_size, 0 };
	stbi_write_png_to_func(append_to_buffer, &result, image->width, image->height, image->channels, image->data, stride);

	return result.num_bytes_used;
}

size_t stbi_encode_jpg(stbi_image_t* image, uint8_t* buffer, const size_t buffer_size, int quality) {
	if(!buffer) return 0;
	if(!image) return 0;
	if(!image->data) return 0;

	if(quality < 0 || quality > 100) quality = 100;

	luajit_stringbuffer_t result = { buffer, buffer_size, 0 };
	stbi_write_jpg_to_func(append_to_buffer, &result, image->width, image->height, image->channels, image->data, quality);

	return result.num_bytes_used;
}

size_t stbi_encode_tga(stbi_image_t* image, uint8_t* buffer, const size_t buffer_size) {
	if(!buffer) return 0;
	if(!image) return 0;
	if(!image->data) return 0;

	luajit_stringbuffer_t result = { buffer, buffer_size, 0 };
	stbi_write_tga_to_func(append_to_buffer, &result, image->width, image->height, image->channels, image->data);

	return result.num_bytes_used;
}

namespace stbi_ffi {

	void* getExportsTable() {
		static struct static_stbi_exports_table stbi_exports_table;

		stbi_exports_table.stbi_version = stbi_version;

		stbi_exports_table.stbi_image_info = stbi_image_info;
		stbi_exports_table.stbi_load_image = stbi_load_image;
		stbi_exports_table.stbi_image_free = stbi_image_free;

		stbi_exports_table.stbi_encode_bmp = stbi_encode_bmp;
		stbi_exports_table.stbi_encode_jpg = stbi_encode_jpg;
		stbi_exports_table.stbi_encode_png = stbi_encode_png;
		stbi_exports_table.stbi_encode_tga = stbi_encode_tga;

		stbi_exports_table.stbi_load_rgb = stbi_load_rgb;
		stbi_exports_table.stbi_load_rgba = stbi_load_rgba;
		stbi_exports_table.stbi_load_monochrome = stbi_load_monochrome;
		stbi_exports_table.stbi_load_monochrome_with_alpha = stbi_load_monochrome_with_alpha;

		return &stbi_exports_table;
	}

}