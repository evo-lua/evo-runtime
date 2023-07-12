-- All paths are relative to the project root, since that's where the CI run will start
local specFiles = {
	"Tests/BDD/globals.spec.lua",
	"Tests/BDD/console-library.spec.lua",
	"Tests/BDD/evo-library.spec.lua",
	"Tests/BDD/glfw-library.spec.lua",
	"Tests/BDD/interop-library.spec.lua",
	"Tests/BDD/json-library.spec.lua",
	"Tests/BDD/miniz-library.spec.lua",
	"Tests/BDD/openssl-library.spec.lua",
	"Tests/BDD/path-library.spec.lua",
	"Tests/BDD/regex-library.spec.lua",
	"Tests/BDD/stbi-library.spec.lua",
	"Tests/BDD/stduuid-library.spec.lua",
	"Tests/BDD/string-library.spec.lua",
	"Tests/BDD/table-library.spec.lua",
	"Tests/BDD/uuid-library.spec.lua",
	"Tests/BDD/uv-library.spec.lua",
	"Tests/BDD/v8-library.spec.lua",
	"Tests/BDD/vfs-library.spec.lua",
	"Tests/BDD/webview-library.spec.lua",
	"Tests/BDD/zlib-library.spec.lua",
	"Tests/BDD/commandline-namespace.spec.lua",
	"Tests/BDD/filesystem-namespace.spec.lua",
	"Tests/BDD/imageprocessing-namespace.spec.lua",
	"Tests/BDD/runtime-namespace.spec.lua",
	"Tests/BDD/timer-namespace.spec.lua",
}

local numFailedSections = C_Runtime.RunDetailedTests(#arg > 0 and arg or specFiles)

os.exit(numFailedSections)
