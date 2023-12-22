local ffi = require("ffi")
local transform = require("transform")

local format = format
local ffi_copy =  ffi.copy
local ffi_gc = ffi.gc
local ffi_new = ffi.new
local math_sqrt = math.sqrt
local transform_bold = transform.bold

ffi.cdef([[
	typedef struct wtf_t {
		int width;
		int height;
		//stbi_pixelbuffer_t data;
		int channels;
	} wtf_t;
]])

local Image = {}

-- function Image.__tostring(self)
-- 	local formatted = {
-- 		x = format("%.3f", self.x),
-- 		y = format("%.3f", self.y),
-- 		z = format("%.3f", self.z),
-- 	}
-- 	local firstRow = format("%10s %10s %10s", formatted.x, formatted.y, formatted.z)
-- 	return format("%s\n%s", transform_bold("cdata<Image>:"), firstRow)
-- end

function Image.__call(_, width, height, pixelArray, pixelFormat)
	error("Called Construct")
	local image = ffi_new("stbi_image_t")
	image.width = width
	image.height = height
	image.channels = pixelFormat or 4


	if type(pixelArray) == "string" then

		error("WOOT?", 0)
		-- No way around this allocation?
			   local dataSize = width * height * pixelFormat
			   local buffer = ffi_new("stbi_unsigned_char_t[?]", dataSize)
	   
			   ffi_copy(buffer, pixelArray, #pixelArray)
	   
			   image.data = buffer
	   
			   ffi_gc(image, function(img)
				print("[Image] Finalizer called")
				   ffi.free(img.data) -- TBD stbi_image_free?
			   end)
		
		
		-- pixelArray = buffer.new(#pixelArray):put(pixelArray):ref()
		-- TODO GC anchor?

			else
				error("Unsupported pixel array type", 0)
				image.data = pixelArray

	end

	-- ffi_gc(image, stbi.bindings.stbi_image_free(image))
	return image
end

-- function Image:Add(anotherVector)
-- 	local result = ffi_new("Image")
-- 	result.x = self.x + anotherVector.x
-- 	result.y = self.y + anotherVector.y
-- 	result.z = self.z + anotherVector.z
-- 	return result
-- end

-- function Image:Subtract(anotherVector)
-- 	local result = ffi_new("Image")
-- 	result.x = self.x - anotherVector.x
-- 	result.y = self.y - anotherVector.y
-- 	result.z = self.z - anotherVector.z
-- 	return result
-- end

-- function Image:DotProduct(anotherVector)
-- 	return self.x * anotherVector.x + self.y * anotherVector.y + self.z * anotherVector.z
-- end

-- function Image:CrossProduct(anotherVector)
-- 	local result = ffi.new("Image")
-- 	result.x = self.y * anotherVector.z - self.z * anotherVector.y
-- 	result.y = self.z * anotherVector.x - self.x * anotherVector.z
-- 	result.z = self.x * anotherVector.y - self.y * anotherVector.x
-- 	return result
-- end

-- function Image:Normalize()
-- 	local length = math_sqrt(self:DotProduct(self))
-- 	self.x = self.x / length
-- 	self.y = self.y / length
-- 	self.z = self.z / length
-- end

-- function Image:Transform(transformationMatrix)
-- 	local transformedX = self.x * transformationMatrix.x1
-- 		+ self.y * transformationMatrix.y1
-- 		+ self.z * transformationMatrix.z1
-- 	local transformedY = self.x * transformationMatrix.x2
-- 		+ self.y * transformationMatrix.y2
-- 		+ self.z * transformationMatrix.z2
-- 	local transformedZ = self.x * transformationMatrix.x3
-- 		+ self.y * transformationMatrix.y3
-- 		+ self.z * transformationMatrix.z3

-- 	self.x = transformedX
-- 	self.y = transformedY
-- 	self.z = transformedZ
-- end

-- function Image:Scale(scaleFactorXYZ)
-- 	self.x = self.x * scaleFactorXYZ
-- 	self.y = self.y * scaleFactorXYZ
-- 	self.z = self.z * scaleFactorXYZ
-- end

-- function Image:GetMagnitude()
-- 	return math_sqrt(self:DotProduct(self))
-- end

Image.__index = Image
Image.__call = Image.Construct

-- local ct =  ffi.metatype(ffi.typeof("wtf_t"), {
-- 	__call = function()
-- 		error("???")
-- 	end
-- })
-- dump(getmetatable(ct))
-- print(ct, type(ct), ffi.typeof(ct))

-- return ct

return ffi.metatype("wtf_t", Image)
