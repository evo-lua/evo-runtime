
// Aliased types (opaque to LuaJIT)
typedef struct CURL CURL;
typedef struct CURLU* url_ptr_t;
typedef struct const CURLU* url_cptr_t;

// Exported from system.h
typedef int64_t curl_off_t;

// Exported from curl.h
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
	CURLE_OK = 0,
	CURLE_UNSUPPORTED_PROTOCOL, /* 1 */
	CURLE_FAILED_INIT, /* 2 */
	CURLE_URL_MALFORMAT, /* 3 */
	CURLE_NOT_BUILT_IN, /* 4 - [was obsoleted in August 2007 for
						   7.17.0, reused in April 2011 for 7.21.5] */
	CURLE_COULDNT_RESOLVE_PROXY, /* 5 */
	CURLE_COULDNT_RESOLVE_HOST, /* 6 */
	CURLE_COULDNT_CONNECT, /* 7 */
	CURLE_WEIRD_SERVER_REPLY, /* 8 */
	CURLE_REMOTE_ACCESS_DENIED, /* 9 a service was denied by the server
								   due to lack of access - when login fails
								   this is not returned. */
	CURLE_FTP_ACCEPT_FAILED, /* 10 - [was obsoleted in April 2006 for
								7.15.4, reused in Dec 2011 for 7.24.0]*/
	CURLE_FTP_WEIRD_PASS_REPLY, /* 11 */
	CURLE_FTP_ACCEPT_TIMEOUT, /* 12 - timeout occurred accepting server
								 [was obsoleted in August 2007 for 7.17.0,
								 reused in Dec 2011 for 7.24.0]*/
	CURLE_FTP_WEIRD_PASV_REPLY, /* 13 */
	CURLE_FTP_WEIRD_227_FORMAT, /* 14 */
	CURLE_FTP_CANT_GET_HOST, /* 15 */
	CURLE_HTTP2, /* 16 - A problem in the http2 framing layer.
					[was obsoleted in August 2007 for 7.17.0,
					reused in July 2014 for 7.38.0] */
	CURLE_FTP_COULDNT_SET_TYPE, /* 17 */
	CURLE_PARTIAL_FILE, /* 18 */
	CURLE_FTP_COULDNT_RETR_FILE, /* 19 */
	CURLE_OBSOLETE20, /* 20 - NOT USED */
	CURLE_QUOTE_ERROR, /* 21 - quote command failure */
	CURLE_HTTP_RETURNED_ERROR, /* 22 */
	CURLE_WRITE_ERROR, /* 23 */
	CURLE_OBSOLETE24, /* 24 - NOT USED */
	CURLE_UPLOAD_FAILED, /* 25 - failed upload "command" */
	CURLE_READ_ERROR, /* 26 - could not open/read from file */
	CURLE_OUT_OF_MEMORY, /* 27 */
	CURLE_OPERATION_TIMEDOUT, /* 28 - the timeout time was reached */
	CURLE_OBSOLETE29, /* 29 - NOT USED */
	CURLE_FTP_PORT_FAILED, /* 30 - FTP PORT operation failed */
	CURLE_FTP_COULDNT_USE_REST, /* 31 - the REST command failed */
	CURLE_OBSOLETE32, /* 32 - NOT USED */
	CURLE_RANGE_ERROR, /* 33 - RANGE "command" did not work */
	CURLE_OBSOLETE34, /* 34 */
	CURLE_SSL_CONNECT_ERROR, /* 35 - wrong when connecting with SSL */
	CURLE_BAD_DOWNLOAD_RESUME, /* 36 - could not resume download */
	CURLE_FILE_COULDNT_READ_FILE, /* 37 */
	CURLE_LDAP_CANNOT_BIND, /* 38 */
	CURLE_LDAP_SEARCH_FAILED, /* 39 */
	CURLE_OBSOLETE40, /* 40 - NOT USED */
	CURLE_OBSOLETE41, /* 41 - NOT USED starting with 7.53.0 */
	CURLE_ABORTED_BY_CALLBACK, /* 42 */
	CURLE_BAD_FUNCTION_ARGUMENT, /* 43 */
	CURLE_OBSOLETE44, /* 44 - NOT USED */
	CURLE_INTERFACE_FAILED, /* 45 - CURLOPT_INTERFACE failed */
	CURLE_OBSOLETE46, /* 46 - NOT USED */
	CURLE_TOO_MANY_REDIRECTS, /* 47 - catch endless re-direct loops */
	CURLE_UNKNOWN_OPTION, /* 48 - User specified an unknown option */
	CURLE_SETOPT_OPTION_SYNTAX, /* 49 - Malformed setopt option */
	CURLE_OBSOLETE50, /* 50 - NOT USED */
	CURLE_OBSOLETE51, /* 51 - NOT USED */
	CURLE_GOT_NOTHING, /* 52 - when this is a specific error */
	CURLE_SSL_ENGINE_NOTFOUND, /* 53 - SSL crypto engine not found */
	CURLE_SSL_ENGINE_SETFAILED, /* 54 - can not set SSL crypto engine as
								   default */
	CURLE_SEND_ERROR, /* 55 - failed sending network data */
	CURLE_RECV_ERROR, /* 56 - failure in receiving network data */
	CURLE_OBSOLETE57, /* 57 - NOT IN USE */
	CURLE_SSL_CERTPROBLEM, /* 58 - problem with the local certificate */
	CURLE_SSL_CIPHER, /* 59 - could not use specified cipher */
	CURLE_PEER_FAILED_VERIFICATION, /* 60 - peer's certificate or fingerprint
									   was not verified fine */
	CURLE_BAD_CONTENT_ENCODING, /* 61 - Unrecognized/bad encoding */
	CURLE_OBSOLETE62, /* 62 - NOT IN USE since 7.82.0 */
	CURLE_FILESIZE_EXCEEDED, /* 63 - Maximum file size exceeded */
	CURLE_USE_SSL_FAILED, /* 64 - Requested FTP SSL level failed */
	CURLE_SEND_FAIL_REWIND, /* 65 - Sending the data requires a rewind
							   that failed */
	CURLE_SSL_ENGINE_INITFAILED, /* 66 - failed to initialise ENGINE */
	CURLE_LOGIN_DENIED, /* 67 - user, password or similar was not
						   accepted and we failed to login */
	CURLE_TFTP_NOTFOUND, /* 68 - file not found on server */
	CURLE_TFTP_PERM, /* 69 - permission problem on server */
	CURLE_REMOTE_DISK_FULL, /* 70 - out of disk space on server */
	CURLE_TFTP_ILLEGAL, /* 71 - Illegal TFTP operation */
	CURLE_TFTP_UNKNOWNID, /* 72 - Unknown transfer ID */
	CURLE_REMOTE_FILE_EXISTS, /* 73 - File already exists */
	CURLE_TFTP_NOSUCHUSER, /* 74 - No such user */
	CURLE_OBSOLETE75, /* 75 - NOT IN USE since 7.82.0 */
	CURLE_OBSOLETE76, /* 76 - NOT IN USE since 7.82.0 */
	CURLE_SSL_CACERT_BADFILE, /* 77 - could not load CACERT file, missing
								 or wrong format */
	CURLE_REMOTE_FILE_NOT_FOUND, /* 78 - remote file not found */
	CURLE_SSH, /* 79 - error from the SSH layer, somewhat
				  generic so the error message will be of
				  interest when this has happened */

	CURLE_SSL_SHUTDOWN_FAILED, /* 80 - Failed to shut down the SSL
								  connection */
	CURLE_AGAIN, /* 81 - socket is not ready for send/recv,
					wait till it is ready and try again (Added
					in 7.18.2) */
	CURLE_SSL_CRL_BADFILE, /* 82 - could not load CRL file, missing or
							  wrong format (Added in 7.19.0) */
	CURLE_SSL_ISSUER_ERROR, /* 83 - Issuer check failed.  (Added in
							   7.19.0) */
	CURLE_FTP_PRET_FAILED, /* 84 - a PRET command failed */
	CURLE_RTSP_CSEQ_ERROR, /* 85 - mismatch of RTSP CSeq numbers */
	CURLE_RTSP_SESSION_ERROR, /* 86 - mismatch of RTSP Session Ids */
	CURLE_FTP_BAD_FILE_LIST, /* 87 - unable to parse FTP file list */
	CURLE_CHUNK_FAILED, /* 88 - chunk callback reported error */
	CURLE_NO_CONNECTION_AVAILABLE, /* 89 - No connection available, the
									  session will be queued */
	CURLE_SSL_PINNEDPUBKEYNOTMATCH, /* 90 - specified pinned public key did not
									   match */
	CURLE_SSL_INVALIDCERTSTATUS, /* 91 - invalid certificate status */
	CURLE_HTTP2_STREAM, /* 92 - stream error in HTTP/2 framing layer
						 */
	CURLE_RECURSIVE_API_CALL, /* 93 - an api function was called from
								 inside a callback */
	CURLE_AUTH_ERROR, /* 94 - an authentication function returned an
						 error */
	CURLE_HTTP3, /* 95 - An HTTP/3 layer problem */
	CURLE_QUIC_CONNECT_ERROR, /* 96 - QUIC connection error */
	CURLE_PROXY, /* 97 - proxy handshake error */
	CURLE_SSL_CLIENTCERT, /* 98 - client-side certificate required */
	CURLE_UNRECOVERABLE_POLL, /* 99 - poll/select returned fatal error */
	CURLE_TOO_LARGE, /* 100 - a value/data met its maximum */
	CURLE_ECH_REQUIRED, /* 101 - ECH tried but failed */
	CURL_LAST /* never use! */
} CURLcode;

// Exported from urlapi.h
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

// Exported from easy.h
typedef CURLcode curl_ssls_export_cb(CURL* handle,
	void* userptr,
	const char* session_key,
	const unsigned char* shmac,
	size_t shmac_len,
	const unsigned char* sdata,
	size_t sdata_len,
	curl_off_t valid_until,
	int ietf_tls_id,
	const char* alpn,
	size_t earlydata_max);

// Exported from header.h
typedef enum {
	CURLHE_OK,
	CURLHE_BADINDEX, /* header exists but not with this index */
	CURLHE_MISSING, /* no such header exists */
	CURLHE_NOHEADERS, /* no headers at all exist (yet) */
	CURLHE_NOREQUEST, /* no request with this number was used */
	CURLHE_OUT_OF_MEMORY, /* out of memory while processing */
	CURLHE_BAD_ARGUMENT, /* a function argument was not okay */
	CURLHE_NOT_BUILT_IN /* if API was disabled in the build */
} CURLHcode;