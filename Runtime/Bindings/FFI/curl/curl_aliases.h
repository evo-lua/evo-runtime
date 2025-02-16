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
