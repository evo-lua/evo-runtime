local ffi = require("ffi")
local ffi_string = ffi.string

local curl = {
	MAX_CSTRING_LIST_SIZE = 256,
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

struct static_curl_exports_table {
	// curl.h
	CURLversion CURLVERSION_NOW;
	curl_version_info_data* (*curl_version_info)(CURLversion);
};

]]

function curl.initialize()
	ffi.cdef(curl.cdefs)
end

function curl.unpack(cstrings)
	local entries = {}
	local index = 0
	while index < curl.MAX_CSTRING_LIST_SIZE do
		local cstring = cstrings[index]
		if cstring == ffi.NULL then
			break
		end

		local key = ffi_string(cstring)
		entries[key] = true

		index = index + 1
	end

	return entries
end

local function cstring_unwrap(cstring)
	if cstring == ffi.NULL then
		return tostring(ffi.NULL)
	end

	return ffi_string(cstring)
end

function curl.version_info(age)
	age = age or curl.bindings.CURLVERSION_NOW
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
	age = age or curl.bindings.CURLVERSION_NOW
	local infoTable = curl.version_info(age)
	return infoTable.version, infoTable.version_num, tonumber(curl.bindings.CURLVERSION_NOW)
end

return curl
