local ffi = require("ffi")
local transform = require("transform")

local format = format
local ffi_new = ffi.new
local math_sqrt = math.sqrt
local transform_bold = transform.bold

ffi.cdef([[
	typedef struct Image {
		float x;
		float y;
		float z;
	} Image;
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

Image.__call = function(_, pixelArray, width, height)
	local image = ffi_new("stbi_image_t")
	-- ffi_gc(image, stbi.bindings.stbi_image_free(image))
-- 	vector.x, vector.y, vector.z = x or 0, y or 0, z or 0
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

return ffi.metatype("Image", Image)
