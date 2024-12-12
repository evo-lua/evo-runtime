set -e

echo "Building target curl"

SRC_DIR=deps/curl/curl
BUILD_DIR=$SRC_DIR/cmakebuild-unix
OUT_DIR=ninjabuild-unix

# TBD: ENABLE_UNICODE (Win32 only),-DWIN32_LEAN_AND_MEAN, CURL_LTO
# CURL_USE_OPENSSL
# OPENSSL_LIBRARIES 
# OPENSSL_INCLUDE_DIR

# HTTP/3 support:
# USE_OPENSSL_QUIC
# nghttp3 submodule

# HTTP/2 support:
# libnghttp2 as submodule
# NGHTTP2_INCLUDE_DIR
# NGHTTP2_LIBRARY

# C-ARES support:
# ENABLE_ARES
# Consider libuv dns
# Consider alternatives (what if all are disabled? Fallback = system or N/A?)

# Disable all the unwanted dependencies:
# CURL_DISABLE_LDAP
# Kerberos
# LIBIDN2_INCLUDE_DIR LIBIDN2_LIBRARY
# LIBPSL_INCLUDE_DIR LIBPSL_LIBRAR
# LIBSSH2_INCLUDE_DIR LIBSSH2_LIBRAR


# TBD: CA package from system dir - might be fine?
# Found CA bundle: /etc/ssl/certs/ca-certificates.crt
# Found CA path: /etc/ssl/certs

# ZLIB support:
# TBD

# TODO check macOS build log for unwanted deps
# -- Found Perl: /opt/homebrew/bin/perl (found version "5.40.0") - That's a no-no
# -- Found OpenSSL: /opt/homebrew/Cellar/openssl@3/3.3.2/lib/libcrypto.dylib (found version "3.3.2") - not the right one
# -- Found ZLIB: /Applications/Xcode_15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.5.sdk/usr/lib/libz.tbd (found version "1.2.12")
# -- Found NGHTTP2: /opt/homebrew/Cellar/libnghttp2/1.63.0/include (found version "1.63.0")
# -- Found Libidn2 (via pkg-config): /opt/homebrew/Cellar/libidn2/2.3.7/include (found version "2.3.7")
# -- Found Libssh2: /opt/homebrew/Cellar/libssh2/1.11.1/include (found version "1.11.1")

# TBD can test for this explicitly?
# -- Protocols: dict file ftp ftps gopher gophers http https imap imaps ipfs ipns ldap ldaps mqtt pop3 pop3s rtsp scp sftp smb smbs smtp smtps telnet tftp ws wss
# -- Features: alt-svc AsynchDNS HSTS HTTP2 HTTPS-proxy IDN IPv6 Largefile libz NTLM SSL threadsafe TLS-SRP UnixSockets

# TODO check Windows build log for unwanted deps
# -- Found Perl: D:/a/_temp/msys64/usr/bin/perl.exe (found version "5.38.2")
# Also required for OpenSSL, so begrudgingly accept it's needed?

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DBUILD_MODULE=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON -DCMAKE_C_COMPILER=gcc -DBUILD_CURL_EXE=OFF -DCURL_DISABLE_INSTALL=ON
cmake --build $BUILD_DIR --clean-first

cp $BUILD_DIR/lib/libcurl.a $OUT_DIR
# cp $BUILD_DIR/deps/libuv/libuv.a $OUT_DIR
