-- luarocks install lua-cjson 
-- file /usr/local/lib/lua/5.1/cjson.so

-- curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh
-- lit install luvit/json

local assertions = require("assertions")
local json = require("json")

local cjson = require("cjson")
assert(type(cjson) == "table")

local someTable = {hi = 42}
local cjsonEncodedString = dump(cjson.encode(someTable))
local rapidjsonEncodedString = dump(json.encode(someTable))

assertions.assertEquals(cjsonEncodedString, rapidjsonEncodedString)