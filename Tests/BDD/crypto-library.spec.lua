local crypto = require("crypto")
local openssl = require("openssl")

local tinsert = table.insert

describe("crypto", function()
	it("should export all shared Argon2 KDF constants", function()
		assertEquals(crypto.KDF_ARGON2D, "ARGON2D")
		assertEquals(crypto.KDF_ARGON2I, "ARGON2I")
		assertEquals(crypto.KDF_ARGON2ID, "ARGON2ID")

		-- Based on https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html#argon2id
		assertEquals(crypto.DEFAULT_KDF_PARAMETERS.kdf, crypto.KDF_ARGON2ID)
		assertEquals(crypto.DEFAULT_KDF_PARAMETERS.version, 0x13)
		assertEquals(crypto.DEFAULT_KDF_PARAMETERS.kilobytes, 47104)
		assertEquals(crypto.DEFAULT_KDF_PARAMETERS.threads, 1)
		assertEquals(crypto.DEFAULT_KDF_PARAMETERS.lanes, 1)

		assertEquals(crypto.DEFAULT_KDF_PARAMETERS.size, 32)
		assertEquals(crypto.DEFAULT_KDF_PARAMETERS.iterations, 3)
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
	end)

	describe("getSizeOfCompactBase64", function()
		it(
			"should return a number that is large enough to contain the Base64 representation in OpenSSL EVP format",
			function()
				assertTrue(crypto.getSizeOfCompactBase64("A") >= #crypto.toCompactBase64("A"))
				assertTrue(crypto.getSizeOfCompactBase64("Hello") >= #crypto.toCompactBase64("Hello"))
				assertTrue(
					crypto.getSizeOfCompactBase64(string.rep("A", 48)) >= #crypto.toCompactBase64(string.rep("A", 48))
				)
				assertTrue(
					crypto.getSizeOfCompactBase64(string.rep("A", 49)) >= #crypto.toCompactBase64(string.rep("A", 49))
				)
				assertTrue(
					crypto.getSizeOfCompactBase64(string.rep("A", 64)) >= #crypto.toCompactBase64(string.rep("A", 64))
				)
				assertTrue(
					crypto.getSizeOfCompactBase64(string.rep("A", 65)) >= #crypto.toCompactBase64(string.rep("A", 65))
				)
				assertTrue(
					crypto.getSizeOfCompactBase64(string.rep("A", 66)) >= #crypto.toCompactBase64(string.rep("A", 66))
				)
				assertTrue(
					crypto.getSizeOfCompactBase64(string.rep("A", 666)) >= #crypto.toCompactBase64(string.rep("A", 666))
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

		it("should use the default KDF parameters if none were passed", function()
			local hash = openssl.hex(
				"38b341ed50ce995b20baba760bf8f9e9fc650c37bb321359f95da57b6535861151aff373a5f005c8f7b0cf6a91a139113367b1ffd8c789f2c78ec211fc93eab1",
				false
			)
			local salt = "saltsalt"
			local expectedMCF =
				"$argon2id$v=19$m=47104,t=1,p=1$c2FsdHNhbHQ$OLNB7VDOmVsgurp2C/j56fxlDDe7MhNZ+V2le2U1hhFRr/NzpfAFyPewz2qRoTkRM2ex/9jHifLHjsIR/JPqsQ"
			assertEquals(crypto.mcf(hash, salt), expectedMCF)
		end)
	end)

	describe("hash", function()
		it("should return a failure with the OpenSSL error message if the provided salt is too short", function()
			-- Minimum length is 8, so this will always fail to derive a key
			local result, errorMessage = crypto.hash("password", "salt")
			assertEquals(result, nil)
			assertEquals(errorMessage, "OpenSSL error:1C800070:Provider routines::invalid salt length")
		end)

		it("should return the derived key if valid Argon2I parameters were passed", function()
			local parameters = {
				kdf = crypto.KDF_ARGON2I,
			}
			local expectedResult = "82615d6e6ce041b231a94b86054106c87996097f7db2e534802694b25f3fffd6"
			assertEquals(openssl.hex(crypto.hash("password", "saltsalt", parameters)), expectedResult)
		end)

		it("should return the derived key if valid Argon2D parameters were passed", function()
			local parameters = {
				kdf = crypto.KDF_ARGON2D,
			}
			local expectedResult = "34b5ed95db7e4dd2c7140abb2b53834c8ce6bb303f7ad862c6ba5a5ace37146f"
			assertEquals(openssl.hex(crypto.hash("password", "saltsalt", parameters)), expectedResult)
		end)

		it("should return the derived key if valid Argon2ID parameters were passed", function()
			local parameters = {
				kdf = crypto.KDF_ARGON2ID,
			}
			local expectedResult = "f2886c40de48b303c6441cb62e1bf8a0423d74bf7bd34027cc87f560c76054f1"
			assertEquals(openssl.hex(crypto.hash("password", "saltsalt", parameters)), expectedResult)
		end)

		it("should be able to derive variable-length keys longer than the usual password lengths", function()
			local expectedResult =
				"8ee0698f0fec907169324128a6b43e9266226d020ef313e5bfd49d425bca8c7db87fc13e810aef32c8fb4696c39151e57ce083704df03db9aab8356873246c105a757e6dd8eb37f0df0629c2fde5f30ef1196cf49f80bcf9e81b39279e34898c676c4c96e1bb52133fe0349a7de557e920933fd53364687d0561fa66591f60852b5ffcc8f2429f7f257d3095063c898c30e536fc53fcef6ddd4c55feb72f3519025a2b82e75111f5917f57646baf1e22942f640edd716312d466acf81781ab85c2b3f5d56358c4b4b8cf18100ba14b76092ad727fb7e5fadb16ae0b85acc9401782e3f11558c5d6eb8ae6390fe0fbab30e41c764756db104c67ae3d17ad64b30"

			local parameters = {
				size = 256,
			}
			assertEquals(openssl.hex(crypto.hash("password", "saltsalt", parameters)), expectedResult)
		end)

		it("should use the default KDF parameters if none were passed", function()
			local parameters = crypto.DEFAULT_KDF_PARAMETERS
			local actual = openssl.hex(crypto.hash("password", "saltsalt"))
			local expected = openssl.hex(crypto.hash("password", "saltsalt", parameters))
			assertEquals(actual, expected)
		end)
	end)

	describe("verify", function()
		it(
			"should return false if the given hash cannot be derived from the plaintext password, salt, and kdf parameters",
			function()
				local parameters = {
					kdf = crypto.KDF_ARGON2I,
				}
				local hash = "82615d6e6ce041b231a94b86054106c87996097f7db2e534802694b25f3fffd?"
				assertFalse(crypto.verify("password", "saltsalt", openssl.hex(hash, false), parameters))
			end
		)

		it(
			"should return true if the given hash can be derived from the plaintext password, salt, and kdf parameters",
			function()
				local parameters = {
					kdf = crypto.KDF_ARGON2I,
				}
				local hash = "82615d6e6ce041b231a94b86054106c87996097f7db2e534802694b25f3fffd6"
				assertTrue(crypto.verify("password", "saltsalt", openssl.hex(hash, false), parameters))
			end
		)

		it("should use the default KDF parameters if none were passed", function()
			local hash = "f2886c40de48b303c6441cb62e1bf8a0423d74bf7bd34027cc87f560c76054f1"
			assertTrue(crypto.verify("password", "saltsalt", openssl.hex(hash, false), nil))
		end)
	end)
end)
