-- All paths are relative to the project root, since that's where the CI run will start
local specFiles = {
	"Tests/BDD/globals.spec.lua",
	"Tests/BDD/uv-library.spec.lua",
	"Tests/BDD/webview-library.spec.lua",
	"Tests/BDD/runtime-namespace.spec.lua",
}

local numFailedSections = C_Runtime.RunDetailedTests(specFiles)

os.exit(numFailedSections)
