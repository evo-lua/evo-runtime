local console = require("console")

describe("console", function()
	describe("capture", function()
		it("should start capturing regular console output when called once", function()
			console.capture()
			print("42")
			print("43")
			print("44")
			local capturedConsoleOutput = console.release()
			assertEquals(capturedConsoleOutput, "42\n43\n44\n")
		end)

		it("should clear the internal buffer when called", function()
			console.capture()
			print("42")
			console.capture()
			local capturedConsoleOutput = console.release()
			console.release()
			assertEquals(capturedConsoleOutput, "")
		end)
	end)

	describe("release", function()
		it("should return nil if no capture has been started before", function()
			assertNil(console.release())
		end)

		it("should return an empty string if no output was captured", function()
			console.capture()
			local capturedOutput = console.release()
			assertEquals(capturedOutput, "")
		end)

		it("should return the buffer contents if some output was captured", function()
			console.capture()
			print("Hello! Hello!")
			local capturedOutput = console.release()

			assertEquals(capturedOutput, "Hello! Hello!\n")
		end)

		it("should return only the output for the most recent capture if multiple captures were started", function()
			console.capture()
			print("Whatever")
			console.release()

			console.capture()
			print("Good... bye!")
			local capturedOutput = console.release()

			assertEquals(capturedOutput, "Good... bye!\n")
		end)
	end)
end)