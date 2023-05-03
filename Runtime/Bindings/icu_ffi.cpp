#include <iostream>
#include <string>
#include <vector>
#include <unicode/ucnv.h>
#include <unicode/ustring.h>

std::string convert_euckr_to_utf8_icu(const std::string& euckr_str) {
	UErrorCode err = U_ZERO_ERROR;
	UConverter* conv_euckr = ucnv_open("EUC-KR", &err);

	if(U_FAILURE(err)) {
		std::cerr << "Error opening EUC-KR converter" << std::endl;
		exit(1);
	}

	std::vector<UChar> ustr(euckr_str.length() + 1);
	int32_t ustr_len = ucnv_toUChars(conv_euckr, ustr.data(), ustr.size(),
		euckr_str.c_str(), euckr_str.length(), &err);

	if(U_FAILURE(err)) {
		std::cerr << "Error converting EUC-KR to UTF-16" << std::endl;
		exit(1);
	}

	ucnv_close(conv_euckr);

	std::string utf8_str;
	utf8_str.resize(ustr_len * 3);
	u_strToUTF8(&utf8_str[0], utf8_str.size(), nullptr, ustr.data(), ustr_len, &err);

	if(U_FAILURE(err)) {
		std::cerr << "Error converting UTF-16 to UTF-8" << std::endl;
		exit(1);
	}

	return utf8_str;
}

int icu_test() {
	std::string euckr_str = "\xBC\xAD\xBA\xF1\xBD\xBA"; // EUC-KR encoded string: "서울시"
	std::string utf8_str = convert_euckr_to_utf8_icu(euckr_str);

	std::cout << "EUC-KR string: " << euckr_str << std::endl;
	std::cout << "UTF-8 string: " << utf8_str << std::endl;

	return 0;
}
