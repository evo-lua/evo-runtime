local versionFrom, versionTo = arg[1], arg[2]

local C_BuildTools = require("BuildTools.NinjaBuildTools")

C_BuildTools.GenerateChangeLog(versionFrom, versionTo)
