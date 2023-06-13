#pragma once

#include <lua.hpp>

extern "C" {

#include "luv.h"
#define MINIZ_NO_STDIO
#define MINIZ_NO_ZLIB_COMPATIBLE_NAMES
#include "miniz.h"

typedef struct {
	mz_zip_archive archive;
	uv_loop_t* loop;
	uv_fs_t req;
	uv_file fd;
} lmz_file_t;

typedef struct {
	int mode; // 0 = deflate, 1 = inflate
	mz_stream stream;
} lmz_stream_t;

// This is internal to miniz.c, but the bindings use it to implement nonblocking I/O
// Obviously this isn't ideal, but hopefully the struct won't change and if it does... tests should catch it
typedef struct
{
	void* m_p;
	size_t m_size, m_capacity;
	mz_uint m_element_size;
} mz_zip_array;

struct mz_zip_internal_state_tag {
	mz_zip_array m_central_dir;
	mz_zip_array m_central_dir_offsets;
	mz_zip_array m_sorted_central_dir_offsets;

	/* The flags passed in when the archive is initially opened. */
	mz_uint32 m_init_flags;

	/* MZ_TRUE if the archive has a zip64 end of central directory headers, etc. */
	mz_bool m_zip64;

	/* MZ_TRUE if we found zip64 extended info in the central directory (m_zip64 will also be slammed to true too, even if we didn't find a zip64 end of central dir header, etc.) */
	mz_bool m_zip64_has_extended_info_fields;

	/* These fields are used by the file, FILE, memory, and memory/heap read/write helpers. */
	MZ_FILE* m_pFile;
	mz_uint64 m_file_archive_start_ofs;

	void* m_pMem;
	size_t m_mem_size;
	size_t m_mem_capacity;
};

LUALIB_API int luaopen_miniz(lua_State* const L);
}