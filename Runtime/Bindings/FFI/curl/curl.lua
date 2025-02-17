local ffi = require("ffi")

local cast = ffi.cast

local curl = {
	MAX_CSTRING_LIST_SIZE = 256,
	metatypes = {},
}

curl.cdefs = [[
typedef enum CURLversion {
	CURLVERSION_FIRST, /* 7.10 */
	CURLVERSION_SECOND, /* 7.11.1 */
	CURLVERSION_THIRD, /* 7.12.0 */
	CURLVERSION_FOURTH, /* 7.16.1 */
	CURLVERSION_FIFTH, /* 7.57.0 */
	CURLVERSION_SIXTH, /* 7.66.0 */
	CURLVERSION_SEVENTH, /* 7.70.0 */
	CURLVERSION_EIGHTH, /* 7.72.0 */
	CURLVERSION_NINTH, /* 7.75.0 */
	CURLVERSION_TENTH, /* 7.77.0 */
	CURLVERSION_ELEVENTH, /* 7.87.0 */
	CURLVERSION_TWELFTH, /* 8.8.0 */
	CURLVERSION_LAST /* never actually use this */
} CURLversion;

struct curl_version_info_data {
	CURLversion age; /* age of the returned struct */
	const char* version; /* LIBCURL_VERSION */
	unsigned int version_num; /* LIBCURL_VERSION_NUM */
	const char* host; /* OS/host/cpu/machine when configured */
	int features; /* bitmask, see defines below */
	const char* ssl_version; /* human readable string */
	long ssl_version_num; /* not used anymore, always 0 */
	const char* libz_version; /* human readable string */
	/* protocols is terminated by an entry with a NULL protoname */
	const char* const* protocols;

	/* The fields below this were added in CURLVERSION_SECOND */
	const char* ares;
	int ares_num;

	/* This field was added in CURLVERSION_THIRD */
	const char* libidn;

	/* These field were added in CURLVERSION_FOURTH */

	/* Same as '_libiconv_version' if built with HAVE_ICONV */
	int iconv_ver_num;

	const char* libssh_version; /* human readable string */

	/* These fields were added in CURLVERSION_FIFTH */
	unsigned int brotli_ver_num; /* Numeric Brotli version
									(MAJOR << 24) | (MINOR << 12) | PATCH */
	const char* brotli_version; /* human readable string. */

	/* These fields were added in CURLVERSION_SIXTH */
	unsigned int nghttp2_ver_num; /* Numeric nghttp2 version
									 (MAJOR << 16) | (MINOR << 8) | PATCH */
	const char* nghttp2_version; /* human readable string. */
	const char* quic_version; /* human readable quic (+ HTTP/3) library +
								 version or NULL */

	/* These fields were added in CURLVERSION_SEVENTH */
	const char* cainfo; /* the built-in default CURLOPT_CAINFO, might
						   be NULL */
	const char* capath; /* the built-in default CURLOPT_CAPATH, might
						   be NULL */

	/* These fields were added in CURLVERSION_EIGHTH */
	unsigned int zstd_ver_num; /* Numeric Zstd version
									(MAJOR << 24) | (MINOR << 12) | PATCH */
	const char* zstd_version; /* human readable string. */

	/* These fields were added in CURLVERSION_NINTH */
	const char* hyper_version; /* human readable string. */

	/* These fields were added in CURLVERSION_TENTH */
	const char* gsasl_version; /* human readable string. */

	/* These fields were added in CURLVERSION_ELEVENTH */
	/* feature_names is terminated by an entry with a NULL feature name */
	const char* const* feature_names;

	/* These fields were added in CURLVERSION_TWELFTH */
	const char* rtmp_version; /* human readable string. */
};
typedef struct curl_version_info_data curl_version_info_data;

typedef enum {
	CURLUE_OK,
	CURLUE_BAD_HANDLE, /* 1 */
	CURLUE_BAD_PARTPOINTER, /* 2 */
	CURLUE_MALFORMED_INPUT, /* 3 */
	CURLUE_BAD_PORT_NUMBER, /* 4 */
	CURLUE_UNSUPPORTED_SCHEME, /* 5 */
	CURLUE_URLDECODE, /* 6 */
	CURLUE_OUT_OF_MEMORY, /* 7 */
	CURLUE_USER_NOT_ALLOWED, /* 8 */
	CURLUE_UNKNOWN_PART, /* 9 */
	CURLUE_NO_SCHEME, /* 10 */
	CURLUE_NO_USER, /* 11 */
	CURLUE_NO_PASSWORD, /* 12 */
	CURLUE_NO_OPTIONS, /* 13 */
	CURLUE_NO_HOST, /* 14 */
	CURLUE_NO_PORT, /* 15 */
	CURLUE_NO_QUERY, /* 16 */
	CURLUE_NO_FRAGMENT, /* 17 */
	CURLUE_NO_ZONEID, /* 18 */
	CURLUE_BAD_FILE_URL, /* 19 */
	CURLUE_BAD_FRAGMENT, /* 20 */
	CURLUE_BAD_HOSTNAME, /* 21 */
	CURLUE_BAD_IPV6, /* 22 */
	CURLUE_BAD_LOGIN, /* 23 */
	CURLUE_BAD_PASSWORD, /* 24 */
	CURLUE_BAD_PATH, /* 25 */
	CURLUE_BAD_QUERY, /* 26 */
	CURLUE_BAD_SCHEME, /* 27 */
	CURLUE_BAD_SLASHES, /* 28 */
	CURLUE_BAD_USER, /* 29 */
	CURLUE_LACKS_IDN, /* 30 */
	CURLUE_TOO_LARGE, /* 31 */
	CURLUE_LAST
} CURLUcode;

typedef enum {
	CURLUPART_URL,
	CURLUPART_SCHEME,
	CURLUPART_USER,
	CURLUPART_PASSWORD,
	CURLUPART_OPTIONS,
	CURLUPART_HOST,
	CURLUPART_PORT,
	CURLUPART_PATH,
	CURLUPART_QUERY,
	CURLUPART_FRAGMENT,
	CURLUPART_ZONEID /* added in 7.65.0 */
} CURLUPart;

typedef struct CURLU* url_ptr_t;
typedef struct const CURLU* url_cptr_t;

typedef enum {
	CURLU_DEFAULT_FEATURES = 0 << 0,
	CURLU_DEFAULT_PORT = (1 << 0),
	CURLU_NO_DEFAULT_PORT = (1 << 1),
	CURLU_DEFAULT_SCHEME = (1 << 2),
	CURLU_NON_SUPPORT_SCHEME = (1 << 3),
	CURLU_PATH_AS_IS = (1 << 4),
	CURLU_DISALLOW_USER = (1 << 5),
	CURLU_URLDECODE = (1 << 6),
	CURLU_URLENCODE = (1 << 7),
	CURLU_APPENDQUERY = (1 << 8),
	CURLU_GUESS_SCHEME = (1 << 9),
	CURLU_NO_AUTHORITY = (1 << 10),
	CURLU_ALLOW_SPACE = (1 << 11),
	CURLU_PUNYCODE = (1 << 12),
	CURLU_PUNY2IDN = (1 << 13),
	CURLU_GET_EMPTY = (1 << 14),
	CURLU_NO_GUESS_SCHEME = (1 << 15),
} CURLUFeatureFlags;

struct static_curl_exports_table {
	// Exports from curl.h
	CURLversion (*curl_version_now)(void);
	curl_version_info_data* (*curl_version_info)(CURLversion);
	void (*curl_free)(void*);

	// Exports from urlapi.h
	url_ptr_t (*curl_url)(void);
	void (*curl_url_cleanup)(url_ptr_t handle);
	url_ptr_t (*curl_url_dup)(url_cptr_t handle);
	CURLUcode (*curl_url_get)(url_cptr_t handle,
		CURLUPart what,
		char** part,
		unsigned int flags);
	CURLUcode (*curl_url_set)(url_ptr_t handle,
		CURLUPart what,
		const char* part,
		unsigned int flags);
	const char* (*curl_url_strerror)(CURLUcode status);
};

]]

function curl.initialize()
	ffi.cdef(curl.cdefs)

	curl.parts = {
		url = ffi.C.CURLUPART_URL,
		scheme = ffi.C.CURLUPART_SCHEME,
		user = ffi.C.CURLUPART_USER,
		password = ffi.C.CURLUPART_PASSWORD,
		options = ffi.C.CURLUPART_OPTIONS,
		host = ffi.C.CURLUPART_HOST,
		port = ffi.C.CURLUPART_PORT,
		path = ffi.C.CURLUPART_PATH,
		query = ffi.C.CURLUPART_QUERY,
		fragment = ffi.C.CURLUPART_FRAGMENT,
		zone = ffi.C.CURLUPART_ZONEID,
	}

	local url = {}

	function url:set(...)
		return curl.url_set(self, ...)
	end

	function url:get(...)
		return curl.url_get(self, ...)
	end

	function url:dup(...)
		return curl.url_dup(self, ...)
	end

	url.__index = url
	curl.metatypes.CURLU = ffi.metatype("struct CURLU", url)
end

function curl.unpack(cstrings)
	local entries = {}
	local index = 0
	while index < curl.MAX_CSTRING_LIST_SIZE do
		local cstring = cstrings[index]
		if cstring == ffi.NULL then
			break
		end

		local key = ffi.string(cstring)
		entries[key] = true

		index = index + 1
	end

	return entries
end

local function cstring_unwrap(cstring)
	if cstring == ffi.NULL then
		return tostring(ffi.NULL)
	end

	return ffi.string(cstring)
end

function curl.free(pointer)
	curl.bindings.curl_free(pointer)
end

function curl.url(href)
	local handle = curl.bindings.curl_url()
	ffi.gc(handle, curl.bindings.curl_url_cleanup)
	handle = cast("struct CURLU*", handle)

	if type(href) == "string" then
		handle:set("url", href)
	end

	return handle
end

function curl.url_dup(handle)
	local duplicatedHandle = curl.bindings.curl_url_dup(handle)
	ffi.gc(duplicatedHandle, curl.bindings.curl_url_cleanup)
	return cast("struct CURLU*", duplicatedHandle)
end

local where = ffi.new("char*[1]")
function curl.url_get(handle, what, how)
	what = what or "url"
	what = curl.parts[what] or curl.parts.url
	how = how or ffi.C.CURLU_DEFAULT_FEATURES

	local status = curl.bindings.curl_url_get(handle, what, where, how)
	if status ~= ffi.C.CURLUE_OK then
		return nil, curl.url_strerror(status)
	end

	local result = ffi.string(where[0])
	curl.free(where[0])
	return result
end

function curl.url_set(handle, what, part, how)
	what = what or "url"
	part = part and tostring(part) or ffi.NULL
	how = how or ffi.C.CURLU_DEFAULT_FEATURES

	local status = curl.bindings.curl_url_set(handle, curl.parts[what], part, how)
	if status ~= ffi.C.CURLUE_OK then
		return nil, curl.url_strerror(status)
	end

	return true
end

function curl.url_strerror(errorCode)
	return ffi.string(curl.bindings.curl_url_strerror(errorCode))
end

function curl.version_info(age)
	age = age or curl.bindings.curl_version_now()
	local versionInfo = curl.bindings.curl_version_info(age)

	local infoTable = {
		age = tonumber(versionInfo.age),
		version = cstring_unwrap(versionInfo.version),
		version_num = tonumber(versionInfo.version_num),
		host = cstring_unwrap(versionInfo.host),
		features = tonumber(versionInfo.features),
		ssl_version = cstring_unwrap(versionInfo.ssl_version),
		libz_version = cstring_unwrap(versionInfo.libz_version),
		protocols = curl.unpack(versionInfo.protocols),
		feature_names = curl.unpack(versionInfo.feature_names),
		-- These version-dependent fields are assumed to always be present with static libcurl
		ares = cstring_unwrap(versionInfo.ares),
		ares_num = tonumber(versionInfo.ares_num),
		libidn = cstring_unwrap(versionInfo.libidn),
		iconv_ver_num = tonumber(versionInfo.iconv_ver_num),
		libssh_version = cstring_unwrap(versionInfo.libssh_version),
		brotli_ver_num = tonumber(versionInfo.brotli_ver_num),
		brotli_version = cstring_unwrap(versionInfo.brotli_version),
		nghttp2_ver_num = tonumber(versionInfo.nghttp2_ver_num),
		nghttp2_version = cstring_unwrap(versionInfo.nghttp2_version),
		quic_version = cstring_unwrap(versionInfo.quic_version),
		cainfo = cstring_unwrap(versionInfo.cainfo),
		capath = cstring_unwrap(versionInfo.capath),
		zstd_ver_num = tonumber(versionInfo.zstd_ver_num),
		zstd_version = cstring_unwrap(versionInfo.zstd_version),
		hyper_version = cstring_unwrap(versionInfo.hyper_version),
		gsasl_version = cstring_unwrap(versionInfo.gsasl_version),
		rtmp_version = cstring_unwrap(versionInfo.rtmp_version),
	}

	infoTable.version = infoTable.version:gsub("%-DEV", "")

	return infoTable
end

function curl.version(age)
	age = age or curl.bindings.curl_version_now()
	local infoTable = curl.version_info(age)
	return infoTable.version, infoTable.version_num, tonumber(curl.bindings.curl_version_now())
end

return curl
