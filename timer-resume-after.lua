local C_Timer = require("Runtime.API.C_Timer")

print("Before")
C_Timer.ResumeAfter(3000)
print("After")
