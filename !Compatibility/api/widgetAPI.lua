--Cache global variables
local assert = assert
local format = string.format
local tonumber = tonumber
local type = type

local function GetSize(frame)
	return frame:GetWidth(), frame:GetHeight()
end

local function SetSize(frame, width, height)
	width, height = tonumber(width), tonumber(height)

	assert(type(width) == "number" or type(width) == "string", format("Usage: %s:SetSize(width, height)", frame.GetName and frame:GetName() or tostring(frame)))

	frame:SetWidth(width)
	frame:SetHeight(type(height) == "number" and height or width)
end

local function HookScript2(frame, scriptType, handler)
	assert((type(scriptType) == "string" or type(scriptType) == "number") and type(handler) == "function", format("Usage: %s:HookScript2(\"type\", function)", frame.GetName and frame:GetName() or tostring(frame)))

	if frame:GetScript(scriptType) then
		frame:HookScript(scriptType, handler)
	else
		frame:SetScript(scriptType, handler)
	end
end

local function addapi(object)
	local mt = getmetatable(object).__index
	if not object.GetSize then mt.GetSize = GetSize end
	if not object.SetSize then mt.SetSize = SetSize end
	if not object.HookScript2 then mt.HookScript2 = HookScript2 end
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