-- All paths are relative to the project root, since that's where the CI run will start
local specFiles = {
	"Tests/BDD/globals.spec.lua",
	"Tests/BDD/console-library.spec.lua",
	"Tests/BDD/debug-library.spec.lua",
	"Tests/BDD/evo-library.spec.lua",
	"Tests/BDD/openssl-library.spec.lua",
	"Tests/BDD/path-library.spec.lua",
	"Tests/BDD/stduuid-library.spec.lua",
	"Tests/BDD/string-library.spec.lua",
	"Tests/BDD/table-library.spec.lua",
	"Tests/BDD/uuid-library.spec.lua",
	"Tests/BDD/uv-library.spec.lua",
	"Tests/BDD/v8-library.spec.lua",
	"Tests/BDD/webview-library.spec.lua",
	"Tests/BDD/zlib-library.spec.lua",
	"Tests/BDD/commandline-namespace.spec.lua",
	"Tests/BDD/filesystem-namespace.spec.lua",
	"Tests/BDD/runtime-namespace.spec.lua",
	"Tests/BDD/timer-namespace.spec.lua",
}

local numFailedSections = C_Runtime.RunDetailedTests(specFiles)

os.exit(numFailedSections)
