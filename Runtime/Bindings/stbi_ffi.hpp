#pragma once

#include <cstdint>
#include <cstddef>

typedef unsigned char stbi_unsigned_char_t;
typedef unsigned char* stbi_pixelbuffer_t;
typedef unsigned char const* stbi_readonly_file_contents_t;

typedef enum {
	NO_CONVERSION = 0,
	CONVERT_TO_GREYSCALE = 1,
	CONVERT_TO_GREYSCALE_WITH_ALPHA = 2,
	CONVERT_TO_RGB = 3,
	CONVERT_TO_RGB_WITH_ALPHA = 4
} stbi_color_depth_t;

typedef struct {
	int width;
	int height;
	stbi_pixelbuffer_t data;
	int channels;
} stbi_image_t;

typedef struct {
	uint8_t* data;
	const size_t capacity;
	size_t num_bytes_used;
} luajit_stringbuffer_t;

struct static_stbi_exports_table {
	const char* (*stbi_version)(void);

	bool (*stbi_image_info)(stbi_readonly_file_contents_t buffer, const size_t file_size, stbi_image_t* image);
	bool (*stbi_load_image)(stbi_readonly_file_contents_t buffer, const size_t file_size, stbi_image_t* image);
	bool (*stbi_image_free)(stbi_image_t* image);

	bool (*stbi_load_rgb)(stbi_readonly_file_contents_t buffer, const size_t file_size, stbi_image_t* image);
	bool (*stbi_load_rgba)(stbi_readonly_file_contents_t buffer, const size_t file_size, stbi_image_t* image);
	bool (*stbi_load_monochrome)(stbi_readonly_file_contents_t buffer, const size_t file_size, stbi_image_t* image);
	bool (*stbi_load_monochrome_with_alpha)(stbi_readonly_file_contents_t buffer, const size_t file_size, stbi_image_t* image);

	size_t (*stbi_encode_bmp)(stbi_image_t* image, uint8_t* buffer, const size_t buffer_size);
	size_t (*stbi_encode_png)(stbi_image_t* image, uint8_t* buffer, const size_t buffer_size, const int stride);
	size_t (*stbi_encode_jpg)(stbi_image_t* image, uint8_t* buffer, const size_t buffer_size, int quality);
	size_t (*stbi_encode_tga)(stbi_image_t* image, uint8_t* buffer, const size_t buffer_size);

	void (*stbi_flip_vertically_on_write)(int flag);
};

namespace stbi_ffi {
	void* getExportsTable();
}