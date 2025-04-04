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

typedef struct stbi_color {
	uint8_t red;
	uint8_t green;
	uint8_t blue;
	uint8_t alpha;
} stbi_color_t;

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

typedef void (*stbi_write_callback_t)(void*, void*, int);

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

	size_t (*stbi_get_required_bmp_size)(stbi_image_t* image);
	size_t (*stbi_get_required_png_size)(stbi_image_t* image, const int stride);
	size_t (*stbi_get_required_jpg_size)(stbi_image_t* image, const int quality);
	size_t (*stbi_get_required_tga_size)(stbi_image_t* image);

	void (*stbi_abgr_to_rgba)(stbi_image_t* image);
	void (*stbi_replace_pixel_color_rgba)(stbi_image_t* image, const stbi_color_t* source_color, const stbi_color_t* replacement_color);
};