local crypto = require("crypto")
local ffi = require("ffi")
local openssl = require("openssl")

local tinsert = table.insert

describe("crypto", function()
	it("should export all shared Argon2 constants", function()
		assertEquals(crypto.KDF_ARGON2D, ffi.C.KDF_ARGON2D)
		assertEquals(crypto.KDF_ARGON2I, ffi.C.KDF_ARGON2I)
		assertEquals(crypto.KDF_ARGON2ID, ffi.C.KDF_ARGON2ID)

		assertEquals(crypto.DEFAULT_ARGON2_VERSION, 0x13)

		assertEquals(crypto.kdfs[crypto.KDF_ARGON2D], "argon2d")
		assertEquals(crypto.kdfs[crypto.KDF_ARGON2I], "argon2i")
		assertEquals(crypto.kdfs[crypto.KDF_ARGON2ID], "argon2id")
	end)

	describe("version", function()
		it("should return the embedded OpenSSL version in semver format", function()
			local embeddedLibraryVersion, versionNumber = crypto.version()
			assertTrue(type(versionNumber) == "number")
			local firstMatchedCharacterIndex, lastMatchedCharacterIndex =
				string.find(embeddedLibraryVersion, "%d+.%d+.%d+")

			assertEquals(firstMatchedCharacterIndex, 1)
			assertEquals(lastMatchedCharacterIndex, string.len(embeddedLibraryVersion))
			assertEquals(type(string.match(embeddedLibraryVersion, "%d+.%d+.%d+")), "string")
		end)
	end)

	describe("getMaxSizeOfBase64", function()
		it(
			"should return a number that is large enough to contain the Base64 representation in OpenSSL EVP format",
			function()
				assertTrue(crypto.getMaxSizeOfBase64("A") >= #crypto.toBase64("A"))
				assertTrue(crypto.getMaxSizeOfBase64("Hello") >= #crypto.toBase64("Hello"))
				assertTrue(crypto.getMaxSizeOfBase64(string.rep("A", 48)) >= #crypto.toBase64(string.rep("A", 48)))
				assertTrue(crypto.getMaxSizeOfBase64(string.rep("A", 49)) >= #crypto.toBase64(string.rep("A", 49)))
				assertTrue(crypto.getMaxSizeOfBase64(string.rep("A", 64)) >= #crypto.toBase64(string.rep("A", 64)))
				assertTrue(crypto.getMaxSizeOfBase64(string.rep("A", 65)) >= #crypto.toBase64(string.rep("A", 65)))
				assertTrue(crypto.getMaxSizeOfBase64(string.rep("A", 66)) >= #crypto.toBase64(string.rep("A", 66)))
				assertTrue(crypto.getMaxSizeOfBase64(string.rep("A", 666)) >= #crypto.toBase64(string.rep("A", 666)))
				assertTrue(crypto.getMaxSizeOfBase64(string.rep("A", 6666)) >= #crypto.toBase64(string.rep("A", 6666)))
			end
		)

		describe("getSizeOfCompactBase64", function()
			-- The Argon2 format is shorter, so if it returns enough space for EVP then Argon2 will also fit
			it(
				"should return a number that is large enough to contain the Base64 representation in OpenSSL EVP format",
				function()
					assertTrue(crypto.getSizeOfCompactBase64("A") >= #crypto.toCompactBase64("A"))
					assertTrue(crypto.getSizeOfCompactBase64("Hello") >= #crypto.toCompactBase64("Hello"))
					assertTrue(
						crypto.getSizeOfCompactBase64(string.rep("A", 48))
							>= #crypto.toCompactBase64(string.rep("A", 48))
					)
					assertTrue(
						crypto.getSizeOfCompactBase64(string.rep("A", 49))
							>= #crypto.toCompactBase64(string.rep("A", 49))
					)
					assertTrue(
						crypto.getSizeOfCompactBase64(string.rep("A", 64))
							>= #crypto.toCompactBase64(string.rep("A", 64))
					)
					assertTrue(
						crypto.getSizeOfCompactBase64(string.rep("A", 65))
							>= #crypto.toCompactBase64(string.rep("A", 65))
					)
					assertTrue(
						crypto.getSizeOfCompactBase64(string.rep("A", 66))
							>= #crypto.toCompactBase64(string.rep("A", 66))
					)
					assertTrue(
						crypto.getSizeOfCompactBase64(string.rep("A", 666))
							>= #crypto.toCompactBase64(string.rep("A", 666))
					)
					assertTrue(
						crypto.getSizeOfCompactBase64(string.rep("A", 6666))
							>= #crypto.toCompactBase64(string.rep("A", 6666))
					)
				end
			)

			it("should return the space required to store the Base64 representation in OpenSSL EVP format", function()
				local inputs = {}
				tinsert(inputs, openssl.random(4))
				tinsert(inputs, openssl.random(8))
				tinsert(inputs, openssl.random(16))
				tinsert(inputs, openssl.random(32))
				tinsert(inputs, openssl.random(64))
				tinsert(inputs, openssl.random(128))
				tinsert(inputs, openssl.random(256))
				tinsert(inputs, openssl.random(512))
				tinsert(inputs, openssl.random(1250))
				tinsert(inputs, openssl.random(2500))
				tinsert(inputs, openssl.random(5000))
				tinsert(inputs, openssl.random(10000))
				tinsert(inputs, openssl.random(100000))

				for index, input in ipairs(inputs) do
					local expectedMaxSize = #crypto.toBase64(input)
					if crypto.getMaxSizeOfBase64(input) < expectedMaxSize then
						error("Output buffer would overflow", 0)
					end
				end
			end)
		end)

		describe("getSizeOfCompactBase64", function()
			it("should return the space required to store the Base64 representation in Argon2 MCF format", function()
				local inputs = {}
				tinsert(inputs, openssl.random(4))
				tinsert(inputs, openssl.random(8))
				tinsert(inputs, openssl.random(16))
				tinsert(inputs, openssl.random(32))
				tinsert(inputs, openssl.random(64))
				tinsert(inputs, openssl.random(128))
				tinsert(inputs, openssl.random(256))
				tinsert(inputs, openssl.random(512))
				tinsert(inputs, openssl.random(1250))
				tinsert(inputs, openssl.random(2500))
				tinsert(inputs, openssl.random(5000))
				tinsert(inputs, openssl.random(10000))
				tinsert(inputs, openssl.random(100000))

				for index, input in ipairs(inputs) do
					local expectedMaxSize = #crypto.toCompactBase64(input)
					if crypto.getSizeOfCompactBase64(input) < expectedMaxSize then
						error("Output buffer would overflow", 0)
					end
				end
			end)
		end)
	end)

	describe("toBase64", function()
		it("should return the Base64 encoded input string in OpenSSL EVP format", function()
			local input = openssl.hex(
				"38b341ed50ce995b20baba760bf8f9e9fc650c37bb321359f95da57b6535861151aff373a5f005c8f7b0cf6a91a139113367b1ffd8c789f2c78ec211fc93eab1",
				false
			)
			local expectedOutput =
				"OLNB7VDOmVsgurp2C/j56fxlDDe7MhNZ+V2le2U1hhFRr/NzpfAFyPewz2qRoTkR\nM2ex/9jHifLHjsIR/JPqsQ==\n"
			assertEquals(crypto.toBase64(input), expectedOutput)
		end)
	end)

	describe("toCompactBase64", function()
		it("should return the Base64 encoded input string in Argon2 MCF format", function()
			local input = openssl.hex(
				"38b341ed50ce995b20baba760bf8f9e9fc650c37bb321359f95da57b6535861151aff373a5f005c8f7b0cf6a91a139113367b1ffd8c789f2c78ec211fc93eab1",
				false
			)
			local expectedOutput =
				"OLNB7VDOmVsgurp2C/j56fxlDDe7MhNZ+V2le2U1hhFRr/NzpfAFyPewz2qRoTkRM2ex/9jHifLHjsIR/JPqsQ"
			assertEquals(crypto.toCompactBase64(input), expectedOutput)
		end)
	end)

	describe("fromBase64", function()
		it("should return the original input if a Base64-encoded string in OpenSSL EVP form was passed", function()
			local encodedInput =
				"OLNB7VDOmVsgurp2C/j56fxlDDe7MhNZ+V2le2U1hhFRr/NzpfAFyPewz2qRoTkR\nM2ex/9jHifLHjsIR/JPqsQ==\n"
			local expectedOutput = openssl.hex(
				"38b341ed50ce995b20baba760bf8f9e9fc650c37bb321359f95da57b6535861151aff373a5f005c8f7b0cf6a91a139113367b1ffd8c789f2c78ec211fc93eab1",
				false
			)
			assertEquals(#crypto.fromBase64(encodedInput), #expectedOutput)
			assertEquals(crypto.fromBase64(encodedInput), expectedOutput)
			assertEquals(openssl.hex(crypto.fromBase64(encodedInput), false), openssl.hex(expectedOutput, false))
		end)
	end)

	describe("fromCompactBase64", function()
		it("should return the original input if a Base64-encoded string in Argon2 MCF form was passed", function()
			local encodedInput =
				"OLNB7VDOmVsgurp2C/j56fxlDDe7MhNZ+V2le2U1hhFRr/NzpfAFyPewz2qRoTkRM2ex/9jHifLHjsIR/JPqsQ"
			local expectedOutput = openssl.hex(
				"38b341ed50ce995b20baba760bf8f9e9fc650c37bb321359f95da57b6535861151aff373a5f005c8f7b0cf6a91a139113367b1ffd8c789f2c78ec211fc93eab1",
				false
			)
			assertEquals(#crypto.fromCompactBase64(encodedInput), #expectedOutput)
			assertEquals(crypto.fromCompactBase64(encodedInput), expectedOutput)
			assertEquals(openssl.hex(crypto.fromCompactBase64(encodedInput), false), openssl.hex(expectedOutput, false))
		end)
	end)

	describe("mcf", function()
		it(
			"should return the modular crypt formatted representation of the hash for a given set of Argon2 parameters",
			function()
				local hash = openssl.hex(
					"38b341ed50ce995b20baba760bf8f9e9fc650c37bb321359f95da57b6535861151aff373a5f005c8f7b0cf6a91a139113367b1ffd8c789f2c78ec211fc93eab1",
					false
				)
				local salt = "saltsalt"
				local params = {
					kdf = crypto.KDF_ARGON2D,
					version = 0x13,
					iterations = 3,
					threads = 3,
					lanes = 1,
					kilobytes = 47104,
					-- length is implicitly defind by the hash itself
				}

				local expectedMCF =
					"$argon2d$v=19$m=47104,t=3,p=1$c2FsdHNhbHQ$OLNB7VDOmVsgurp2C/j56fxlDDe7MhNZ+V2le2U1hhFRr/NzpfAFyPewz2qRoTkRM2ex/9jHifLHjsIR/JPqsQ"
				assertEquals(crypto.mcf(hash, salt, params), expectedMCF)
			end
		)
	end)
end)
