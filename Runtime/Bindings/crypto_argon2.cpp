// This code was mostly taken from the PHC-Argon2 reference implemention (with some basic optimizations added)
// Source: https://github.com/P-H-C/phc-winner-argon2/blob/master/src/encoding.c
// See the original licensing terms below:
/*
 * Argon2 reference source code package - reference C implementations
 *
 * Copyright 2015
 * Daniel Dinu, Dmitry Khovratovich, Jean-Philippe Aumasson, and Samuel Neves
 *
 * You may use this work under the terms of a Creative Commons CC0 1.0
 * License/Waiver or the Apache Public License 2.0, at your option. The terms of
 * these licenses can be found at:
 *
 * - CC0 1.0 Universal : https://creativecommons.org/publicdomain/zero/1.0
 * - Apache 2.0        : https://www.apache.org/licenses/LICENSE-2.0
 *
 * You should have received a copy of both of these licenses along with this
 * software. If not, they may be obtained at the above URLs.
 */

#include "crypto_argon2.hpp"

#include <cstddef>

const char base64_chars[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
							"abcdefghijklmnopqrstuvwxyz"
							"0123456789+/";

inline char b64_byte_to_char(unsigned x) {
	return base64_chars[x];
}

inline unsigned b64_char_to_byte(int c) {
	unsigned x;

	x = (GE(c, 'A') & LE(c, 'Z') & (c - 'A')) | (GE(c, 'a') & LE(c, 'z') & (c - ('a' - 26))) | (GE(c, '0') & LE(c, '9') & (c - ('0' - 52))) | (EQ(c, '+') & 62) | (EQ(c, '/') & 63);
	return x | (EQ(x, 0) & (EQ(c, 'A') ^ 0xFF));
}

size_t argon2_to_base64(unsigned char* dst, size_t dst_len, const unsigned char* src, size_t src_len) {
	size_t olen;
	const unsigned char* buf;
	unsigned acc, acc_len;

	olen = (src_len / 3) << 2;
	switch(src_len % 3) {
	case 2:
		olen++;
	/* fall through */
	case 1:
		olen += 2;
		break;
	}
	if(dst_len <= olen) {
		return static_cast<size_t>(-1);
	}

	acc = 0;
	acc_len = 0;
	buf = src;

	// Loop unrolling: Process 3 bytes at a time
	while(src_len >= 3) {
		acc = (acc << 24) + (buf[0] << 16) + (buf[1] << 8) + buf[2];
		buf += 3;
		src_len -= 3;
		acc_len = 24;

		while(acc_len >= 6) {
			acc_len -= 6;
			*dst++ = b64_byte_to_char((acc >> acc_len) & 0x3F);
		}
	}

	// Handle remaining bytes
	while(src_len-- > 0) {
		acc = (acc << 8) + (*buf++);
		acc_len += 8;
		while(acc_len >= 6) {
			acc_len -= 6;
			*dst++ = b64_byte_to_char((acc >> acc_len) & 0x3F);
		}
	}

	if(acc_len > 0) {
		*dst++ = b64_byte_to_char((acc << (6 - acc_len)) & 0x3F);
	}
	*dst++ = 0;
	return olen;
}

size_t argon2_from_base64(unsigned char* dst, size_t dst_len, const char* src) {
	size_t len;
	unsigned char* buf;
	unsigned acc, acc_len;

	buf = dst;
	len = 0;
	acc = 0;
	acc_len = 0;
	for(;;) {
		unsigned d;

		d = b64_char_to_byte(*src);
		if(d > 63) { // Invalid character
			break;
		}
		src++;
		acc = (acc << 6) + d;
		acc_len += 6;
		if(acc_len >= 8) {
			acc_len -= 8;
			if(len >= dst_len) {
				return static_cast<size_t>(-1); // Error: buffer overflow
			}
			*buf++ = (acc >> acc_len) & 0xFF;
			len++;
		}
	}

	// Check for invalid input
	if(acc_len > 4 || (acc & ((static_cast<unsigned>(1) << acc_len) - 1)) != 0) {
		return static_cast<size_t>(-1);
	}
	return len;
}
