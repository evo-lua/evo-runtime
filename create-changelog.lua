local versionFrom, versionTo = ...

local C_BuildTools = require("BuildTools.NinjaBuildTools")

C_BuildTools.GenerateChangeLog(versionFrom, versionTo)
