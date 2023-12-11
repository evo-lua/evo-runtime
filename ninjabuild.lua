-- The default path settings may not be sufficient to find the build tools
package.path = package.path .. ";./?.lua"

-- CAUTION: This script MUST run as-is in stock LuaJIT, so that the runtime can be bootstrapped from source
-- That means you can only use standard LuaJIT functionality here, or the few dedicated modules designed to be portable
local EvoBuildTarget = require("BuildTools.Targets.EvoBuildTarget")
local NinjaFile = require("BuildTools.NinjaFile")

print("Generating build configuration ...")
local ninjaFile = EvoBuildTarget:GenerateNinjaFile()

print(EvoBuildTarget)

print("Saving Ninja file: " .. NinjaFile.DEFAULT_BUILD_FILE_NAME)
ninjaFile:Save()
