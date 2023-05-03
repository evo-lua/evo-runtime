#include <iostream>
#include <string>
#include <vector>
#include <unicode/ucnv.h>
#include <unicode/ustring.h>

// TODO use icu namespace

std::string convert_encoding_icu(const std::string& src_str, const std::string& src_encoding, const std::string& target_encoding) {
	UErrorCode err = U_ZERO_ERROR;
	UConverter* conv_src = ucnv_open(src_encoding.c_str(), &err);

	if(U_FAILURE(err)) {
		std::cerr << "Error opening source converter" << std::endl;
		exit(1);
	}

	std::vector<UChar> ustr(src_str.length() + 1);
	int32_t ustr_len = ucnv_toUChars(conv_src, ustr.data(), ustr.size(),
		src_str.c_str(), src_str.length(), &err);

	if(U_FAILURE(err)) {
		std::cerr << "Error converting source encoding to UTF-16" << std::endl;
		exit(1);
	}

	ucnv_close(conv_src);

	UConverter* conv_target = ucnv_open(target_encoding.c_str(), &err);

	if(U_FAILURE(err)) {
		std::cerr << "Error opening target converter" << std::endl;
		exit(1);
	}

	std::string target_str;
	target_str.resize(ustr_len * 3);
	ucnv_fromUChars(conv_target, &target_str[0], target_str.size(), ustr.data(), ustr_len, &err);

	if(U_FAILURE(err)) {
		std::cerr << "Error converting UTF-16 to target encoding" << std::endl;
		exit(1);
	}

	ucnv_close(conv_target);

	return target_str;
}

int main() {
	std::string euckr_str = "\xBC\xAD\xBA\xF1\xBD\xBA"; // EUC-KR encoded string: "서울시"
	std::string utf8_str = convert_encoding_icu(euckr_str, "EUC-KR", "UTF-8");

	std::cout << "EUC-KR string: " << euckr_str << std::endl;
	std::cout << "UTF-8 string: " << utf8_str << std::endl;

	return 0;
}
