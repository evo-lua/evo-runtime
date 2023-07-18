#include "macros.hpp"
#include "stbi_ffi.hpp"

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_RESIZE_IMPLEMENTATION
#include "stb_image_resize.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#include <utility>

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

// There's no more reliable way to get the required buffer size AFAICT
static void count_bytes(void* context, void* data, int size) {
	size_t* byte_counter = static_cast<size_t*>(context);
	*byte_counter += size;
}

size_t stbi_get_required_bmp_size(stbi_image_t* image) {
	if(!image) return 0;
	if(!image->data) return 0;

	size_t byte_counter = 0;

	int success = stbi_write_bmp_to_func(count_bytes, &byte_counter, image->width, image->height, image->channels, image->data);
	if(!success) return 0;

	return byte_counter;
}

size_t stbi_get_required_png_size(stbi_image_t* image, const int stride) {
	if(!image) return 0;
	if(!image->data) return 0;

	size_t byte_counter = 0;

	int success = stbi_write_png_to_func(count_bytes, &byte_counter, image->width, image->height, image->channels, image->data, stride);
	if(!success) return 0;

	return byte_counter;
}

size_t stbi_get_required_jpg_size(stbi_image_t* image, int quality) {
	if(!image) return 0;
	if(!image->data) return 0;

	size_t byte_counter = 0;

	int success = stbi_write_jpg_to_func(count_bytes, &byte_counter, image->width, image->height, image->channels, image->data, quality);
	if(!success) return 0;

	return byte_counter;
}

size_t stbi_get_required_tga_size(stbi_image_t* image) {
	if(!image) return 0;
	if(!image->data) return 0;

	size_t byte_counter = 0;

	int success = stbi_write_tga_to_func(count_bytes, &byte_counter, image->width, image->height, image->channels, image->data);
	if(!success) return 0;

	return byte_counter;
}

const size_t ABGR_RED_INDEX = 3;
const size_t ABGR_GREEN_INDEX = 2;
const size_t ABGR_BLUE_INDEX = 1;
const size_t ABGR_ALPHA_INDEX = 0;

void stbi_abgr_to_rgba(stbi_image_t* image) {
	if(!image) return;
	if(!image->data) return;

	const size_t num_pixels = image->width * image->height;
	for(size_t i = 0; i < num_pixels; i++) {
		uint8_t* pixel = image->data + i * 4;
		std::swap(pixel[ABGR_ALPHA_INDEX], pixel[ABGR_RED_INDEX]);
		std::swap(pixel[ABGR_BLUE_INDEX], pixel[ABGR_GREEN_INDEX]);
	}
}

void stbi_resize_filtered(stbi_image_t* original_image, stbi_image_t* resized_image) {
	if(!original_image) return;
	if(!resized_image) return;
	if(!original_image->data) return;
	if(!resized_image->data) return;

	constexpr int stride = 0;
	stbir_resize_uint8(original_image->data, original_image->width, original_image->height, stride, resized_image->data, resized_image->width, resized_image->height, stride, original_image->channels);
}

#include <iostream>

// void stbi_resize_unfiltered(stbi_image_t* original_image, stbi_image_t* resized_image) {
// 	if(!original_image || !resized_image) return;
// 	if(!original_image->data || !resized_image->data) return;

// 	int scale_factor_x = resized_image->width / original_image->width;
// 	int scale_factor_y = resized_image->height / original_image->height;

// 	for(int y = 0; y < original_image->height; y++) {
// 		for(int x = 0; x < original_image->width; x++) {
// 			// Copy each pixel of the original image to a block of the new image
// 			for(int sy = 0; sy < scale_factor_y; sy++) {
// 				for(int sx = 0; sx < scale_factor_x; sx++) {
// 					// The address of the pixel in the original image
// 					uint8_t* source_pixel = original_image->data + (y * original_image->width + x) * original_image->channels;

// 					// The address of the pixel in the new image
// 					uint8_t* dest_pixel = resized_image->data + ((y * scale_factor_y + sy) * resized_image->width + (x * scale_factor_x + sx)) * resized_image->channels;

// 					// Copy the pixel
// 					for(int c = 0; c < original_image->channels; c++) {
// 						std::cout << "Filling channel " << c << " with " << (int)source_pixel[c] << " for pixel " << x << ", " << y << "\n";
// 						dest_pixel[c] = source_pixel[c];
// 					}
// 				}
// 			}
// 		}
// 	}
// }

const size_t RGBA_RED_INDEX = 0;
const size_t RGBA_GREEN_INDEX = 1;
const size_t RGBA_BLUE_INDEX = 2;
const size_t RGBA_ALPHA_INDEX = 3;

void stbi_resize_unfiltered(stbi_image_t* original_image, stbi_image_t* resized_image) {
	if(!original_image || !resized_image) return;
	if(!original_image->data || !resized_image->data) return;

	int scale_factor_x = resized_image->width / original_image->width;
	int scale_factor_y = resized_image->height / original_image->height;

	for(int y = 0; y < resized_image->height; y++) {
		for(int x = 0; x < resized_image->width; x++) {

			const size_t source_index = floor(y / scale_factor_y * original_image->width + x / scale_factor_x) * original_image->channels;
			stbi_unsigned_char_t* source_pixel = &original_image->data[source_index];
			const uint8_t source_red = *(source_pixel + RGBA_RED_INDEX);
			const uint8_t source_green = *(source_pixel + RGBA_GREEN_INDEX);
			const uint8_t source_blue = *(source_pixel + RGBA_BLUE_INDEX);
			const uint8_t source_alpha = *(source_pixel + RGBA_ALPHA_INDEX);

			const size_t dest_index = (y * resized_image->width + x) * original_image->channels;
			stbi_unsigned_char_t* dest_pixel = &resized_image->data[dest_index];
			*(dest_pixel + RGBA_RED_INDEX) = source_red;
			*(dest_pixel + RGBA_GREEN_INDEX) = source_green;
			*(dest_pixel + RGBA_BLUE_INDEX) = source_blue;
			*(dest_pixel + RGBA_ALPHA_INDEX) = source_alpha;

			std::cout << "Filling pixel " << dest_index << " -> " << x << ", " << y << " with "
					  << "(RGBA: " << (int)source_red << ", " << (int)source_green << ", " << (int)source_blue << ", " << (int)source_alpha << ")\n";
		}
	}
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

		stbi_exports_table.stbi_flip_vertically_on_write = stbi_flip_vertically_on_write;

		stbi_exports_table.stbi_get_required_bmp_size = stbi_get_required_bmp_size;
		stbi_exports_table.stbi_get_required_png_size = stbi_get_required_png_size;
		stbi_exports_table.stbi_get_required_jpg_size = stbi_get_required_jpg_size;
		stbi_exports_table.stbi_get_required_tga_size = stbi_get_required_tga_size;

		stbi_exports_table.stbi_abgr_to_rgba = stbi_abgr_to_rgba;

		stbi_exports_table.stbi_resize_filtered = stbi_resize_filtered;
		stbi_exports_table.stbi_resize_unfiltered = stbi_resize_unfiltered;

		return &stbi_exports_table;
	}

}