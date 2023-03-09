describe("openssl", function()
	local openssl = require("openssl")
	local exportedFunctions = {
		"version",
		"hex",
		"base64",
		"list",
		"error",
		"rand_add",
		"rand_load",
		"rand_write",
		"rand_status",
		"random",
		"FIPS_mode",
		"FIPS_mode",
		"engine",
	}

	local exportedNamespaces = {
		"asn1",
		"bio",
		"cipher",
		"cms",
		"x509",
		"digest",
		"ec",
		"hmac",
		"bn",
		"ocsp",
		"ts",
		"pkcs12",
		"pkcs7",
		"pkey",
		"ssl",
	}

	it("should export all openssl functions", function()
		for _, functionName in ipairs(exportedFunctions) do
			local exportedFunction = openssl[functionName]
			assertEquals(type(exportedFunction), "function", "Should export function " .. functionName)
		end
	end)

	it("should export all openssl namespaces", function()
		for _, namespace in ipairs(exportedNamespaces) do
			local exportedNamespace = openssl[namespace]
			assertEquals(type(exportedNamespace), "table", "Should export namespace " .. namespace)
		end
	end)
end)
