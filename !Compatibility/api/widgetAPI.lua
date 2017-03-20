local function SetSize(frame, width, height)
	assert(width)
	frame:SetWidth(width)
	frame:SetHeight(height or width)
end

local function addapi(object)
	local mt = getmetatable(object).__index
	if not object.SetSize then mt.SetSize = SetSize end
end

local handled = {["Frame"] = true}
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())

object = EnumerateFrames()
while object do
	if not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end

	object = EnumerateFrames(object)
end