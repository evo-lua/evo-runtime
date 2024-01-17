-- Adapted on Jan 18, 2024 from the lua-tf8 test suite, with minor alterations to fix Lua errors
-- Due to maintainability concerns, the modified lines have been tagged with [MOD: Reason]

-- MIT License

-- Copyright (c) 2018 Xavier Wang

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

---

local utf8 = require("utf8") -- [MOD: Package is preloaded as utf8 in Evo's environment]
local unpack = unpack or table.unpack
local E = utf8.escape

local function get_codes(s)
	return table.concat({ utf8.byte(s, 1, -1) }, " ")
end

local t = { 20985, 20984, 26364, 25171, 23567, 24618, 20861 }

describe("utf8", function()
	it("should pass the provided test suite without errors", function()
		-- test escape & len
		assert(get_codes(E("%123%xabc%x{ABC}%d%u{456}")) == "123 2748 2748 100 456")

		local s = E("%" .. table.concat(t, "%"))
		assert(utf8.len(s) == 7)
		assert(get_codes(s) == table.concat(t, " "))

		-- test offset

		local function assert_error(f, msg)
			local s, e = pcall(f)
			return assert(not s and e:match(msg))
		end

		assert(utf8.offset("中国", 0) == 1)
		assert(utf8.offset("中国", 0, 1) == 1)
		assert(utf8.offset("中国", 0, 2) == 1)
		assert(utf8.offset("中国", 0, 3) == 1)
		assert(utf8.offset("中国", 0, 4) == 4)
		assert(utf8.offset("中国", 0, 5) == 4)
		assert(utf8.offset("中国", 1) == 1)
		assert_error(function()
			utf8.offset("中国", 1, 2)
		end, "initial position is a continuation byte")
		assert(utf8.offset("中国", 2) == 4)
		assert(utf8.offset("中国", 3) == 7)
		assert(utf8.offset("中国", 4) == nil)
		assert(utf8.offset("中国", -1, -3) == 1)
		assert(utf8.offset("中国", -1, 1) == nil)

		-- test byte
		local function assert_table_equal(t1, t2, i, j)
			i = i or 1
			j = j or #t2
			local len = j - i + 1
			assert(#t1 == len)
			for cur = 1, len do
				assert(t1[cur] == t2[cur + i - 1])
			end
		end
		assert_table_equal({ utf8.byte(s, 2) }, t, 2, 2)
		assert_table_equal({ utf8.byte(s, 1, -1) }, t)
		assert_table_equal({ utf8.byte(s, -100) }, {})
		assert_table_equal({ utf8.byte(s, -100, -200) }, {})
		assert_table_equal({ utf8.byte(s, -200, -100) }, {})
		assert_table_equal({ utf8.byte(s, 100) }, {})
		assert_table_equal({ utf8.byte(s, 100, 200) }, {})
		assert_table_equal({ utf8.byte(s, 200, 100) }, {})

		-- test char
		assert(s == utf8.char(unpack(t)))

		-- test range
		for i = 1, #t do
			assert(utf8.byte(s, i) == t[i])
		end

		-- test sub
		assert(get_codes(utf8.sub(s, 2, -2)) == table.concat(t, " ", 2, #t - 1))
		assert(get_codes(utf8.sub(s, -100)) == table.concat(t, " "))
		assert(get_codes(utf8.sub(s, -100, -200)) == "")
		assert(get_codes(utf8.sub(s, -100, -100)) == "")
		assert(get_codes(utf8.sub(s, -100, 0)) == "")
		assert(get_codes(utf8.sub(s, -200, -100)) == "")
		assert(get_codes(utf8.sub(s, 100, 200)) == "")
		assert(get_codes(utf8.sub(s, 200, 100)) == "")

		-- test insert/remove
		assert(utf8.insert("abcdef", "...") == "abcdef...")
		assert(utf8.insert("abcdef", 0, "...") == "abcdef...")
		assert(utf8.insert("abcdef", 1, "...") == "...abcdef")
		assert(utf8.insert("abcdef", 6, "...") == "abcde...f")
		assert(utf8.insert("abcdef", 7, "...") == "abcdef...")
		assert(utf8.insert("abcdef", 3, "...") == "ab...cdef")
		assert(utf8.insert("abcdef", -3, "...") == "abc...def")
		assert(utf8.remove("abcdef", 3, 3) == "abdef")
		assert(utf8.remove("abcdef", 3, 4) == "abef")
		assert(utf8.remove("abcdef", 4, 3) == "abcdef")
		assert(utf8.remove("abcdef", -3, -3) == "abcef")
		assert(utf8.remove("abcdef", 100) == "abcdef")
		assert(utf8.remove("abcdef", -100) == "")
		assert(utf8.remove("abcdef", -100, 0) == "abcdef")
		assert(utf8.remove("abcdef", -100, -200) == "abcdef")
		assert(utf8.remove("abcdef", -200, -100) == "abcdef")
		assert(utf8.remove("abcdef", 100, 200) == "abcdef")
		assert(utf8.remove("abcdef", 200, 100) == "abcdef")

		do
			local s = E("a%255bc")
			assert(utf8.len(s, 4))
			assert(string.len(s, 6))
			assert(utf8.charpos(s) == 1)
			assert(utf8.charpos(s, 0) == 1)
			assert(utf8.charpos(s, 1) == 1)
			assert(utf8.charpos(s, 2) == 2)
			assert(utf8.charpos(s, 3) == 4)
			assert(utf8.charpos(s, 4) == 5)
			assert(utf8.charpos(s, 5) == nil)
			assert(utf8.charpos(s, 6) == nil)
			assert(utf8.charpos(s, -1) == 5)
			assert(utf8.charpos(s, -2) == 4)
			assert(utf8.charpos(s, -3) == 2)
			assert(utf8.charpos(s, -4) == 1)
			assert(utf8.charpos(s, -5) == nil)
			assert(utf8.charpos(s, -6) == nil)
			assert(utf8.charpos(s, 3, -1) == 2)
			assert(utf8.charpos(s, 3, 0) == 2)
			assert(utf8.charpos(s, 3, 1) == 4)
			assert(utf8.charpos(s, 6, -3) == 2)
			assert(utf8.charpos(s, 6, -4) == 1)
			assert(utf8.charpos(s, 6, -5) == nil)
		end

		local idx = 1
		for pos, code in utf8.next, s do
			assert(t[idx] == code)
			idx = idx + 1
		end

		assert(utf8.ncasecmp("abc", "AbC") == 0)
		assert(utf8.ncasecmp("abc", "AbE") == -1)
		assert(utf8.ncasecmp("abe", "AbC") == 1)
		assert(utf8.ncasecmp("abc", "abcdef") == -1)
		assert(utf8.ncasecmp("abcdef", "abc") == 1)
		assert(utf8.ncasecmp("abZdef", "abcZef") == 1)

		assert(utf8.gsub("x^[]+$", "%p", "%%%0") == "x%^%[%]%+%$")

		-- test invalid

		-- 1110-1010 10-000000 0110-0001
		do
			local s = "\234\128\97"
			assert(utf8.len(s, nil, nil, true) == 2)
			assert_table_equal({ utf8.len(s) }, { nil, 1 }, 1, 2)

			-- 1111-0000 10-000000 10-000000 ...
			s = "\240\128\128\128\128"
			assert_table_equal({ utf8.len(s) }, { nil, 1 }, 1, 2)
		end

		-- test compose
		local function assert_fail(f, patt)
			local ok, msg = pcall(f)
			assert(not ok)
			assert(msg:match(patt), msg)
		end
		do
			local s = "नमस्ते"
			assert(utf8.len(s) == 6)
			assert(utf8.reverse(s) == "तेस्मन")
			assert(utf8.reverse(s .. " ", true) == " ेत्समन")
			assert(utf8.match(s .. "\2", "%g+") == s)
			assert_fail(function()
				utf8.reverse(E("%xD800"))
			end, "invalid UTF%-8 code")
		end

		-- test match
		assert(utf8.match("%c", "") == nil) -- %c does not match U+F000

		-- test codepoint
		for i = 1, 1000 do
			assert(utf8.codepoint(E("%" .. i)) == i)
		end
		assert_fail(function()
			utf8.codepoint(E("%xD800"))
		end, "invalid UTF%-8 code")

		-- test escape
		assert_fail(function()
			E("%{1a1}")
		end, "invalid escape 'a'")

		-- test codes
		local result = { [1] = 20985, [4] = 20984, [7] = 26364, [10] = 25171, [13] = 23567, [16] = 24618, [19] = 20861 }
		for p, c in utf8.codes(s) do
			assert(result[p] == c)
		end
		for p, c in utf8.codes(s, true) do
			assert(result[p] == c)
		end
		assert_fail(function()
			for p, c in utf8.codes(E("%xD800")) do
				assert(result[p] == c)
			end
		end, "invalid UTF%-8 code")

		-- test width
		assert(utf8.width("नमस्ते\2") == 5)
		assert(utf8.width(E("%xA1")) == 1)
		assert(utf8.width(E("%xA1"), 2) == 2)
		assert(utf8.width(E("%x61C")) == 0)
		assert(utf8.width("A") == 1)
		assert(utf8.width("Ａ") == 2)
		assert(utf8.width(97) == 1)
		assert(utf8.width(65313) == 2)
		assert_fail(function()
			utf8.width(true)
		end, "number/string expected, got boolean")
		assert(utf8.widthindex("abcdef", 3) == 3)
		assert(utf8.widthindex("abcdef", 7) == 7)

		-- test patterns
		assert_fail(function()
			utf8.gsub("a", ".", function()
				return {}
			end)
		end, "invalid replacement value %(a table%)")
		assert_fail(function()
			utf8.gsub("a", ".", "%z")
		end, "invalid use of '%%' in replacement string")
		assert(utf8.find("abcabc", "ab", -10) == 1)

		-- test charpattern
		do
			local subj, n = "school=школа", 0
			for c in string.gmatch(subj, utf8.charpattern) do
				n = n + 1
			end
			assert(n == utf8.len(subj))
		end

		-- test isvalid
		local good_strings = {
			"",
			"A",
			"abcdefghijklmnopqrstuvwxyz",
			"``",
			"@",
			"नमस्ते",
			"中国",
			"日本語０１２３４５６７８９０。",
			"ひらがな",
			"Καλημέρα",
			"АБВГ",
			"⡌⠁⠧⠑ ⠼",
			"∑ f(i)",
			"Οὐχὶ ταὐτὰ παρίσταταί μοι γιγνώσκειν, ὦ ἄνδρες ᾿Αθηναῖοι, ὅταν τ᾿ εἰς τὰ πράγματα ἀποβλέψω καὶ ὅταν πρὸς τοὺς",
			"ABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789 abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿАБВГДабвгд∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣",
			"გთხოვთ ახლავე გაიაროთ რეგისტრაცია Unicode-ის მეათე საერთაშორისო კონფერენციაზე დასასწრებად, რომელიც გაიმართება 10-12 მარტს",
			"\000", -- NUL is valid in UTF-8
		}

		for _, good in ipairs(good_strings) do
			assert(utf8.isvalid(good))
		end

		assert(not utf8.isvalid("\255")) -- illegal byte 0xFF
		assert(not utf8.isvalid("abc\254def")) -- illegal byte 0xFE

		assert(not utf8.isvalid("123 \223")) -- truncated code unit 0xDF
		assert(not utf8.isvalid("123 \239\191")) -- truncated code unit 0xEF BF
		assert(not utf8.isvalid("123 \240\191")) -- truncated code unit 0xF0 BF
		assert(not utf8.isvalid("123 \240\191\191")) -- truncated code unit 0xF0 BF BF

		assert(not utf8.isvalid("\223ABC")) -- code unit 0xDF ended too soon and went to ASCII
		assert(not utf8.isvalid("\239\191ABC")) -- code unit 0xEF BF ended too soon and went to ASCII
		assert(not utf8.isvalid("\240\191ABC")) -- code unit 0xF0 BF ended too soon and went to ASCII
		assert(not utf8.isvalid("\240\191\191ABC")) -- code unit 0xF0 BF BF ended too soon and went to ASCII

		assert(not utf8.isvalid("\223中")) -- code unit 0xDF ended too soon and went to another multi-byte char
		assert(not utf8.isvalid("\239\191中")) -- code unit 0xEF BF ended too soon and went to another multi-byte char
		assert(not utf8.isvalid("\240\191中")) -- code unit 0xF0 BF ended too soon and went to another multi-byte char
		assert(not utf8.isvalid("\240\191\191中")) -- code unit 0xF0 BF BF ended too soon and went to another multi-byte char

		assert(utf8.isvalid("\237\159\191")) -- U+D7FF is valid
		assert(not utf8.isvalid("\237\160\128")) -- U+D800; reserved for UTF-16 surrogate
		assert(not utf8.isvalid("\237\175\191")) -- U+DBFF; reserved for UTF-16 surrogate
		assert(not utf8.isvalid("\237\191\191")) -- U+DFFF; reserved for UTF-16 surrogate
		assert(utf8.isvalid("\238\128\128")) -- U+E000 is valid

		assert(utf8.isvalid("\244\143\191\191")) -- U+10FFFF is valid
		assert(not utf8.isvalid("\244\144\128\128")) -- U+110000 is not valid
		assert(not utf8.isvalid("\247\191\191\191")) -- U+1FFFFF is not valid

		assert(not utf8.isvalid("\128")) -- continuation byte outside a multi-byte char
		assert(not utf8.isvalid("A\128A")) -- continuation byte outside a multi-byte char
		assert(not utf8.isvalid("中\128")) -- continuation byte outside a multi-byte char

		assert(not utf8.isvalid("\193\191")) -- overlong code unit
		assert(not utf8.isvalid("\224\159\191")) -- overlong code unit
		assert(not utf8.isvalid("\240\143\191\191")) -- overlong code unit

		-- test clean
		local cleaned, was_clean

		for _, good in ipairs(good_strings) do
			cleaned, was_clean = utf8.clean(good)
			assert(cleaned == good)
			assert(was_clean)
		end

		cleaned, was_clean = utf8.clean("A\128A")
		assert(cleaned == "A�A")
		assert(not was_clean)

		cleaned, was_clean = utf8.clean("\128")
		assert(cleaned == "�")
		assert(not was_clean)

		cleaned, was_clean = utf8.clean("1\193\1912\224\159\1913\240\143\191\191", "???")
		assert(cleaned == "1???2???3???")
		assert(not was_clean)

		cleaned, was_clean = utf8.clean("\237\160\128\237\175\191\237\191\191")
		assert(cleaned == "�") -- an entire sequence of bad bytes just gets replaced with one replacement char
		assert(not was_clean)

		cleaned, was_clean = utf8.clean("123 \223", "")
		assert(cleaned == "123 ")
		assert(not was_clean)

		cleaned, was_clean = utf8.clean("\239\191中", "")
		assert(cleaned == "中")
		assert(not was_clean)

		assert_error(function()
			utf8.clean("abc", "\255")
		end, "replacement string must be valid UTF%-8")

		-- test invalidoffset
		for _, good in ipairs(good_strings) do
			assert(utf8.invalidoffset(good) == nil)
		end

		assert(utf8.invalidoffset("\255") == 1)
		assert(utf8.invalidoffset("\255", 0) == 1)
		assert(utf8.invalidoffset("\255", 1) == 1)
		assert(utf8.invalidoffset("\255", 2) == nil)
		assert(utf8.invalidoffset("\255", -1) == 1)
		assert(utf8.invalidoffset("\255", -2) == 1)
		assert(utf8.invalidoffset("\255", -3) == 1)

		assert(utf8.invalidoffset("abc\254def") == 4)
		assert(utf8.invalidoffset("abc\254def", 0) == 4)
		assert(utf8.invalidoffset("abc\254def", 1) == 4)
		assert(utf8.invalidoffset("abc\254def", 2) == 4)
		assert(utf8.invalidoffset("abc\254def", 3) == 4)
		assert(utf8.invalidoffset("abc\254def", 4) == 4)
		assert(utf8.invalidoffset("abc\254def", 5) == nil)
		assert(utf8.invalidoffset("abc\254def", 6) == nil)
		assert(utf8.invalidoffset("abc\254def", -1) == nil)
		assert(utf8.invalidoffset("abc\254def", -2) == nil)
		assert(utf8.invalidoffset("abc\254def", -3) == nil)
		assert(utf8.invalidoffset("abc\254def", -4) == 4)
		assert(utf8.invalidoffset("abc\254def", -5) == 4)

		assert(utf8.invalidoffset("\237\160\128\237\175\191\237\191\191", 0) == 1)
		assert(utf8.invalidoffset("\237\160\128\237\175\191\237\191\191", 1) == 1)
		assert(utf8.invalidoffset("\237\160\128\237\175\191\237\191\191", 2) == 2)
		assert(utf8.invalidoffset("\237\160\128\237\175\191\237\191\191", 3) == 3)
		assert(utf8.invalidoffset("\237\160\128\237\175\191\237\191\191", 4) == 4)
		assert(utf8.invalidoffset("\237\160\128\237\175\191\237\191\191", 5) == 5)
		assert(utf8.invalidoffset("\237\160\128\237\175\191\237\191\191", 6) == 6)
		assert(utf8.invalidoffset("\237\160\128\237\175\191\237\191\191", -1) == 9)

		local function parse_codepoints(s)
			local list = {}
			for hex in s:gmatch("%w+") do
				list[#list + 1] = tonumber(hex, 16)
			end
			return utf8.char(unpack(list))
		end

		-- This is an official set of test cases for Unicode normalization
		-- Provided by the Unicode Consortium
		local normalization_test_cases = {}
		local f = io.open("deps/starwing/luautf8/NormalizationTest.txt", "r") -- [MOD: Updated file path]
		for line in f:lines() do
			if not line:match("^#") and not line:match("^@") then
				local src, nfc, nfd = line:match("([%w%s]+);([%w%s]+);([%w%s]+)")
				table.insert(
					normalization_test_cases,
					{ src = parse_codepoints(src), nfc = parse_codepoints(nfc), nfd = parse_codepoints(nfd) }
				)
			end
		end

		-- test isnfc
		for _, case in ipairs(normalization_test_cases) do
			assert(utf8.isnfc(case.nfc))
			if case.src ~= case.nfc then
				assert(not utf8.isnfc(case.src))
			end
			if case.nfd ~= case.nfc and case.nfd ~= case.src then
				assert(not utf8.isnfc(case.nfd))
			end
		end

		-- test normalize_nfc
		for _, case in ipairs(normalization_test_cases) do
			assert(utf8.normalize_nfc(case.src) == case.nfc)
			assert(utf8.normalize_nfc(case.nfc) == case.nfc)
			assert(utf8.normalize_nfc(case.nfd) == case.nfc)
		end

		-- Official set of test cases for grapheme cluster segmentation, provided by Unicode Consortium
		local grapheme_test_cases = {}
		f = io.open("deps/starwing/luautf8/GraphemeBreakTest.txt", "r") -- [MOD: Updated file path]
		for line in f:lines() do
			if not line:match("^#") and not line:match("^@") then
				line = line:gsub("#.*", "")
				line = line:gsub("^%s*÷%s*", "")
				line = line:gsub("%s*÷%s*$", "")
				local clusters = { "" }
				for str in line:gmatch("%S*") do
					if str == "×" then
					-- do nothing
					elseif str == "÷" then
						table.insert(clusters, "") -- start a new cluster
					else
						if str ~= "" then -- [MOD: Empty string fails in the line below]
							clusters[#clusters] = clusters[#clusters] .. utf8.char(tonumber(str, 16))
						end
					end
				end
				table.insert(grapheme_test_cases, { str = table.concat(clusters), clusters = clusters })
			end
		end

		-- test grapheme_indices
		for _, case in ipairs(grapheme_test_cases) do
			local actual_clusters = {}
			for start, stop in utf8.grapheme_indices(case.str) do
				table.insert(actual_clusters, case.str:sub(start, stop))
			end
			assert(#actual_clusters == #case.clusters)
			for i, cluster in ipairs(case.clusters) do
				assert(actual_clusters[i] == cluster)
			end
		end

		-- try iterating over grapheme clusters in a substring
		local clusters = {}
		for a, b in utf8.grapheme_indices("ひらがな", 4, 9) do
			table.insert(clusters, a)
			table.insert(clusters, b)
		end
		for idx, value in ipairs({ 4, 6, 7, 9 }) do
			assert(clusters[idx] == value)
		end

		-- try private use codepoint followed by a combining character
		clusters = {}
		for a, b in utf8.grapheme_indices("\239\128\128\204\154") do
			table.insert(clusters, a)
			table.insert(clusters, b)
		end
		for idx, value in ipairs({ 1, 5 }) do
			assert(clusters[idx] == value)
		end
	end)

	it("should pass the provided compatibility test suite without errors", function()
		assert(utf8.sub("123456789", 2, 4) == "234")
		assert(utf8.sub("123456789", 7) == "789")
		assert(utf8.sub("123456789", 7, 6) == "")
		assert(utf8.sub("123456789", 7, 7) == "7")
		assert(utf8.sub("123456789", 0, 0) == "")
		assert(utf8.sub("123456789", -10, 10) == "123456789")
		assert(utf8.sub("123456789", 1, 9) == "123456789")
		assert(utf8.sub("123456789", -10, -20) == "")
		assert(utf8.sub("123456789", -1) == "9")
		assert(utf8.sub("123456789", -4) == "6789")
		assert(utf8.sub("123456789", -6, -4) == "456")
		if not _no32 then
			assert(utf8.sub("123456789", -2 ^ 31, -4) == "123456")
			assert(utf8.sub("123456789", -2 ^ 31, 2 ^ 31 - 1) == "123456789")
			assert(utf8.sub("123456789", -2 ^ 31, -2 ^ 31) == "")
		end
		assert(utf8.sub("\000123456789", 3, 5) == "234")
		assert(utf8.sub("\000123456789", 8) == "789")

		assert(utf8.find("123456789", "345") == 3)
		a, b = utf8.find("123456789", "345")
		assert(utf8.sub("123456789", a, b) == "345")
		assert(utf8.find("1234567890123456789", "345", 3) == 3)
		assert(utf8.find("1234567890123456789", "345", 4) == 13)
		assert(utf8.find("1234567890123456789", "346", 4) == nil)
		assert(utf8.find("1234567890123456789", ".45", -9) == 13)
		assert(utf8.find("abcdefg", "\0", 5, 1) == nil)
		assert(utf8.find("", "") == 1)
		assert(utf8.find("", "", 1) == 1)
		assert(not utf8.find("", "", 2))
		assert(utf8.find("", "aaa", 1) == nil)
		assert(("alo(.)alo"):find("(.)", 1, 1) == 4)

		assert(utf8.len("") == 0)
		assert(utf8.len("\0\0\0") == 3)
		assert(utf8.len("1234567890") == 10)

		local E = utf8.escape
		assert(utf8.byte("a") == 97)
		assert(utf8.byte(E("%228")) > 127)
		assert(utf8.byte(utf8.char(255)) == 255)
		assert(utf8.byte(utf8.char(0)) == 0)
		assert(utf8.byte("\0") == 0)
		assert(utf8.byte("\0\0alo\0x", -1) == string.byte("x"))
		assert(utf8.byte("ba", 2) == 97)
		assert(utf8.byte("\n\n", 2, -1) == 10)
		assert(utf8.byte("\n\n", 2, 2) == 10)
		assert(utf8.byte("") == nil)
		assert(utf8.byte("hi", -3) == nil)
		assert(utf8.byte("hi", 3) == nil)
		assert(utf8.byte("hi", 9, 10) == nil)
		assert(utf8.byte("hi", 2, 1) == nil)
		assert(utf8.char() == "")
		assert(utf8.char(0, 255, 0) == utf8.escape("%0%255%0"))
		assert(utf8.char(0, utf8.byte(E("%228")), 0) == E("%0%xe4%0"))
		assert(utf8.char(utf8.byte(E("%228l\0髐"), 1, -1)) == E("%xe4l\0髐"))
		assert(utf8.char(utf8.byte(E("%228l\0髐"), 1, 0)) == "")
		assert(utf8.char(utf8.byte(E("%228l\0髐"), -10, 100)) == E("%xe4l\0髐"))

		assert(utf8.upper("ab\0c") == "AB\0C")
		assert(utf8.lower("\0ABCc%$") == "\0abcc%$")

		assert(utf8.reverse("") == "")
		assert(utf8.reverse("\0\1\2\3") == "\3\2\1\0")
		assert(utf8.reverse("\0001234") == "4321\0")

		for i = 0, 30 do
			assert(utf8.len(string.rep("a", i)) == i)
		end
	end)

	it("should pass the provided pattern matching test suite without errors", function()
		function f(s, p)
			local i, e = utf8.find(s, p)
			if i then
				return utf8.sub(s, i, e)
			end
		end

		function f1(s, p)
			p = utf8.gsub(p, "%%([0-9])", function(s)
				return "%" .. (tonumber(s) + 1)
			end)
			p = utf8.gsub(p, "^(^?)", "%1()", 1)
			p = utf8.gsub(p, "($?)$", "()%1", 1)
			local t = { utf8.match(s, p) }
			return utf8.sub(s, t[1], t[#t] - 1)
		end

		a, b = utf8.find("", "") -- empty patterns are tricky
		assert(a == 1 and b == 0)
		a, b = utf8.find("alo", "")
		assert(a == 1 and b == 0)
		a, b = utf8.find("a\0o a\0o a\0o", "a", 1) -- first position
		assert(a == 1 and b == 1)
		a, b = utf8.find("a\0o a\0o a\0o", "a\0o", 2) -- starts in the midle
		assert(a == 5 and b == 7)
		a, b = utf8.find("a\0o a\0o a\0o", "a\0o", 9) -- starts in the midle
		assert(a == 9 and b == 11)
		a, b = utf8.find("a\0a\0a\0a\0\0ab", "\0ab", 2) -- finds at the end
		assert(a == 9 and b == 11)
		a, b = utf8.find("a\0a\0a\0a\0\0ab", "b") -- last position
		assert(a == 11 and b == 11)
		assert(utf8.find("a\0a\0a\0a\0\0ab", "b\0") == nil) -- check ending
		assert(utf8.find("", "\0") == nil)
		assert(utf8.find("alo123alo", "12") == 4)
		assert(utf8.find("alo123alo", "^12") == nil)

		assert(utf8.match("aaab", ".*b") == "aaab")
		assert(utf8.match("aaa", ".*a") == "aaa")
		assert(utf8.match("b", ".*b") == "b")

		assert(utf8.match("aaab", ".+b") == "aaab")
		assert(utf8.match("aaa", ".+a") == "aaa")
		assert(not utf8.match("b", ".+b"))

		assert(utf8.match("aaab", ".?b") == "ab")
		assert(utf8.match("aaa", ".?a") == "aa")
		assert(utf8.match("b", ".?b") == "b")

		assert(f("aloALO", "%l*") == "alo")
		assert(f("aLo_ALO", "%a*") == "aLo")

		assert(f("  \n\r*&\n\r   xuxu  \n\n", "%g%g%g+") == "xuxu")

		assert(f("aaab", "a*") == "aaa")
		assert(f("aaa", "^.*$") == "aaa")
		assert(f("aaa", "b*") == "")
		assert(f("aaa", "ab*a") == "aa")
		assert(f("aba", "ab*a") == "aba")
		assert(f("aaab", "a+") == "aaa")
		assert(f("aaa", "^.+$") == "aaa")
		assert(f("aaa", "b+") == nil)
		assert(f("aaa", "ab+a") == nil)
		assert(f("aba", "ab+a") == "aba")
		assert(f("a$a", ".$") == "a")
		assert(f("a$a", ".%$") == "a$")
		assert(f("a$a", ".$.") == "a$a")
		assert(f("a$a", "$$") == nil)
		assert(f("a$b", "a$") == nil)
		assert(f("a$a", "$") == "")
		assert(f("", "b*") == "")
		assert(f("aaa", "bb*") == nil)
		assert(f("aaab", "a-") == "")
		assert(f("aaa", "^.-$") == "aaa")
		assert(f("aabaaabaaabaaaba", "b.*b") == "baaabaaabaaab")
		assert(f("aabaaabaaabaaaba", "b.-b") == "baaab")
		assert(f("alo xo", ".o$") == "xo")
		assert(f(" \n isto é assim", "%S%S*") == "isto")
		assert(f(" \n isto é assim", "%S*$") == "assim")
		assert(f(" \n isto é assim", "[a-z]*$") == "assim")
		assert(f("um caracter ? extra", "[^%sa-z]") == "?")
		assert(f("", "a?") == "")
		assert(f("á", "á?") == "á")
		assert(f("ábl", "á?b?l?") == "ábl")
		assert(f("  ábl", "á?b?l?") == "")
		assert(f("aa", "^aa?a?a") == "aa")
		assert(f("]]]áb", "[^]]") == "á")
		assert(f("0alo alo", "%x*") == "0a")
		assert(f("alo alo", "%C+") == "alo alo")

		assert(f1("alo alx 123 b\0o b\0o", "(..*) %1") == "b\0o b\0o")
		assert(f1("axz123= 4= 4 34", "(.+)=(.*)=%2 %1") == "3= 4= 4 3")
		assert(f1("=======", "^(=*)=%1$") == "=======")
		assert(utf8.match("==========", "^([=]*)=%1$") == nil)

		local function range(i, j)
			if i <= j then
				return i, range(i + 1, j)
			end
		end

		local abc = utf8.char(range(0, 255))

		assert(utf8.len(abc) == 256)
		assert(string.len(abc) == 384)

		function strset(p)
			local res = { s = "" }
			utf8.gsub(abc, p, function(c)
				res.s = res.s .. c
			end)
			return res.s
		end

		local E = utf8.escape
		assert(utf8.len(strset(E("[%200-%210]"))) == 11)

		assert(strset("[a-z]") == "abcdefghijklmnopqrstuvwxyz")
		assert(strset("[a-z%d]") == strset("[%da-uu-z]"))
		assert(strset("[a-]") == "-a")
		assert(strset("[^%W]") == strset("[%w]"))
		assert(strset("[]%%]") == "%]")
		assert(strset("[a%-z]") == "-az")
		assert(strset("[%^%[%-a%]%-b]") == "-[]^ab")
		assert(strset("%Z") == strset(E("[%1-%255]")))
		assert(strset(".") == strset(E("[%1-%255%%z]")))

		assert(utf8.match("alo xyzK", "(%w+)K") == "xyz")
		assert(utf8.match("254 K", "(%d*)K") == "")
		assert(utf8.match("alo ", "(%w*)$") == "")
		assert(utf8.match("alo ", "(%w+)$") == nil)
		assert(utf8.find("(álo)", "%(á") == 1)
		local a, b, c, d, e = utf8.match("âlo alo", "^(((.).).* (%w*))$")
		assert(a == "âlo alo" and b == "âl" and c == "â" and d == "alo" and e == nil)
		a, b, c, d = utf8.match("0123456789", "(.+(.?)())")
		assert(a == "0123456789" and b == "" and c == 11 and d == nil)

		assert(utf8.gsub("ülo ülo", "ü", "x") == "xlo xlo")
		assert(utf8.gsub("alo úlo  ", " +$", "") == "alo úlo") -- trim
		assert(utf8.gsub("  alo alo  ", "^%s*(.-)%s*$", "%1") == "alo alo") -- double trim
		assert(utf8.gsub("alo  alo  \n 123\n ", "%s+", " ") == "alo alo 123 ")
		t = "abç d"
		a, b = utf8.gsub(t, "(.)", "%1@")
		assert("@" .. a == utf8.gsub(t, "", "@") and b == 5)
		a, b = utf8.gsub("abçd", "(.)", "%0@", 2)
		assert(a == "a@b@çd" and b == 2)
		assert(utf8.gsub("alo alo", "()[al]", "%1") == "12o 56o")
		assert(utf8.gsub("abc=xyz", "(%w*)(%p)(%w+)", "%3%2%1-%0") == "xyz=abc-abc=xyz")
		assert(utf8.gsub("abc", "%w", "%1%0") == "aabbcc")
		assert(utf8.gsub("abc", "%w+", "%0%1") == "abcabc")
		assert(utf8.gsub("áéí", "$", "\0óú") == "áéí\0óú")
		assert(utf8.gsub("", "^", "r") == "r")
		assert(utf8.gsub("", "$", "r") == "r")

		assert(utf8.gsub("um (dois) tres (quatro)", "(%(%w+%))", utf8.upper) == "um (DOIS) tres (QUATRO)")

		do
			local function setglobal(n, v)
				rawset(_G, n, v)
			end
			utf8.gsub("a=roberto,roberto=a", "(%w+)=(%w%w*)", setglobal)
			assert(_G.a == "roberto" and _G.roberto == "a")
		end

		function f(a, b)
			return utf8.gsub(a, ".", b)
		end
		assert(
			utf8.gsub("trocar tudo em |teste|b| é |beleza|al|", "|([^|]*)|([^|]*)|", f)
				== "trocar tudo em bbbbb é alalalalalal"
		)

		local function dostring(s)
			return (loadstring or load)(s)() or ""
		end
		assert(utf8.gsub("alo $a=1$ novamente $return a$", "$([^$]*)%$", dostring) == "alo  novamente 1")

		x = utf8.gsub(
			"$local utf8=require'utf8' x=utf8.gsub('alo', '.', utf8.upper)$ assim vai para $return x$",
			"$([^$]*)%$",
			dostring
		)
		assert(x == " assim vai para ALO")

		t = {}
		s = "a alo jose  joao"
		r = utf8.gsub(s, "()(%w+)()", function(a, w, b)
			assert(utf8.len(w) == b - a)
			t[a] = b - a
		end)
		assert(s == r and t[1] == 1 and t[3] == 3 and t[7] == 4 and t[13] == 4)

		function isbalanced(s)
			return utf8.find(utf8.gsub(s, "%b()", ""), "[()]") == nil
		end

		assert(isbalanced("(9 ((8))(\0) 7) \0\0 a b ()(c)() a"))
		assert(not isbalanced("(9 ((8) 7) a b (\0 c) a"))
		assert(utf8.gsub("alo 'oi' alo", "%b''", '"') == 'alo " alo')

		local t = { "apple", "orange", "lime", n = 0 }
		assert(utf8.gsub("x and x and x", "x", function()
			t.n = t.n + 1
			return t[t.n]
		end) == "apple and orange and lime")

		t = { n = 0 }
		utf8.gsub("first second word", "%w%w*", function(w)
			t.n = t.n + 1
			t[t.n] = w
		end)
		assert(t[1] == "first" and t[2] == "second" and t[3] == "word" and t.n == 3)

		t = { n = 0 }
		assert(utf8.gsub("first second word", "%w+", function(w)
			t.n = t.n + 1
			t[t.n] = w
		end, 2) == "first second word")
		assert(t[1] == "first" and t[2] == "second" and t[3] == nil)

		assert(not pcall(utf8.gsub, "alo", "(.", print))
		assert(not pcall(utf8.gsub, "alo", ".)", print))
		assert(not pcall(utf8.gsub, "alo", "(.", {}))
		assert(not pcall(utf8.gsub, "alo", "(.)", "%2"))
		assert(not pcall(utf8.gsub, "alo", "(%1)", "a"))
		assert(not pcall(utf8.gsub, "alo", "(%0)", "a"))

		-- bug since 2.5 (C-stack overflow)
		do
			local function f(size)
				local s = string.rep("a", size)
				local p = string.rep(".?", size)
				return pcall(utf8.match, s, p)
			end
			local r, m = f(80)
			assert(r and #m == 80)
			r, m = f(200000)
			assert(not r and utf8.find(m, "too complex"))
		end

		if not _soft then
			-- big strings
			local a = string.rep("a", 300000)
			assert(utf8.find(a, "^a*.?$"))
			assert(not utf8.find(a, "^a*.?b$"))
			assert(utf8.find(a, "^a-.?$"))

			-- bug in 5.1.2
			a = string.rep("a", 10000) .. string.rep("b", 10000)
			assert(not pcall(utf8.gsub, a, "b"))
		end

		-- recursive nest of gsubs
		function rev(s)
			return utf8.gsub(s, "(.)(.+)", function(c, s1)
				return rev(s1) .. c
			end)
		end

		local x = "abcdef"
		assert(rev(rev(x)) == x)

		-- gsub with tables
		assert(utf8.gsub("alo alo", ".", {}) == "alo alo")
		assert(utf8.gsub("alo alo", "(.)", { a = "AA", l = "" }) == "AAo AAo")
		assert(utf8.gsub("alo alo", "(.).", { a = "AA", l = "K" }) == "AAo AAo")
		assert(utf8.gsub("alo alo", "((.)(.?))", { al = "AA", o = false }) == "AAo AAo")

		assert(utf8.gsub("alo alo", "().", { 2, 5, 6 }) == "256 alo")

		t = {}
		setmetatable(t, {
			__index = function(t, s)
				return utf8.upper(s)
			end,
		})
		assert(utf8.gsub("a alo b hi", "%w%w+", t) == "a ALO b HI")

		-- tests for gmatch
		local a = 0
		for i in utf8.gmatch("abcde", "()") do
			assert(i == a + 1)
			a = i
		end
		assert(a == 6)

		t = { n = 0 }
		for w in utf8.gmatch("first second word", "%w+") do
			t.n = t.n + 1
			t[t.n] = w
		end
		assert(t[1] == "first" and t[2] == "second" and t[3] == "word")

		t = { 3, 6, 9 }
		for i in utf8.gmatch("xuxx uu ppar r", "()(.)%2") do
			assert(i == table.remove(t, 1))
		end
		assert(#t == 0)

		t = {}
		for i, j in utf8.gmatch("13 14 10 = 11, 15= 16, 22=23", "(%d+)%s*=%s*(%d+)") do
			t[i] = j
		end
		a = 0
		for k, v in pairs(t) do
			assert(k + 1 == v + 0)
			a = a + 1
		end
		assert(a == 3)

		-- tests for `%f' (`frontiers')

		assert(utf8.gsub("aaa aa a aaa a", "%f[%w]a", "x") == "xaa xa x xaa x")
		assert(utf8.gsub("[[]] [][] [[[[", "%f[[].", "x") == "x[]] x]x] x[[[")
		assert(utf8.gsub("01abc45de3", "%f[%d]", ".") == ".01abc.45de.3")
		assert(utf8.gsub("01abc45 de3x", "%f[%D]%w", ".") == "01.bc45 de3.")
		local u = utf8.escape
		assert(utf8.gsub("function", u("%%f[%1-%255]%%w"), ".") == ".unction")
		assert(utf8.gsub("function", u("%%f[^%1-%255]"), ".") == "function.")

		assert(utf8.find("a", "%f[a]") == 1)
		assert(utf8.find("a", "%f[^%z]") == 1)
		assert(utf8.find("a", "%f[^%l]") == 2)
		assert(utf8.find("aba", "%f[a%z]") == 3)
		assert(utf8.find("aba", "%f[%z]") == 4)
		assert(not utf8.find("aba", "%f[%l%z]"))
		assert(not utf8.find("aba", "%f[^%l%z]"))

		local i, e = utf8.find(" alo aalo allo", "%f[%S].-%f[%s].-%f[%S]")
		assert(i == 2 and e == 5)
		local k = utf8.match(" alo aalo allo", "%f[%S](.-%f[%s].-%f[%S])")
		assert(k == "alo ")

		local a = { 1, 5, 9, 14, 17 }
		for k in utf8.gmatch("alo alo th02 is 1hat", "()%f[%w%d]") do
			assert(table.remove(a, 1) == k)
		end
		assert(#a == 0)

		-- malformed patterns
		local function malform(p, m)
			m = m or "malformed"
			local r, msg = pcall(utf8.find, "a", p)
			assert(not r and utf8.find(msg, m))
		end

		malform("[a")
		malform("[]")
		malform("[^]")
		malform("[a%]")
		malform("[a%")
		malform("%b")
		malform("%ba")
		malform("%")
		malform("%f", "missing")

		-- \0 in patterns
		assert(utf8.match("ab\0\1\2c", "[\0-\2]+") == "\0\1\2")
		assert(utf8.match("ab\0\1\2c", "[\0-\0]+") == "\0")
		assert(utf8.find("b$a", "$\0?") == 2)
		assert(utf8.find("abc\0efg", "%\0") == 4)
		assert(utf8.match("abc\0efg\0\1e\1g", "%b\0\1") == "\0efg\0\1e\1")
		assert(utf8.match("abc\0\0\0", "%\0+") == "\0\0\0")
		assert(utf8.match("abc\0\0\0", "%\0%\0?") == "\0\0")

		-- magic char after \0
		assert(utf8.find("abc\0\0", "\0.") == 4)
		assert(utf8.find("abcx\0\0abc\0abc", "x\0\0abc\0a.") == 4)
	end)
end)
