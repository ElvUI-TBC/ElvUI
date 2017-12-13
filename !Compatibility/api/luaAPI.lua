--Cache global variables
local error = error
local geterrorhandler = geterrorhandler
local pairs = pairs
local pcall = pcall
local securecall = securecall
local select = select
local tostring = tostring
local type = type
local unpack = unpack

function table.wipe(t)
	assert(type(t) == "table", format("bad argument #1 to 'wipe' (table expected, got %s)", t and type(t) or "no value"))

	for k in pairs(t) do
		t[k] = nil
	end

	return t
end
wipe = table.wipe

local LOCAL_ToStringAllTemp = {}
function tostringall(...)
	local n = select('#', ...)
	-- Simple versions for common argument counts
	if (n == 1) then
		return tostring(...)
	elseif (n == 2) then
		local a, b = ...
		return tostring(a), tostring(b)
	elseif (n == 3) then
		local a, b, c = ...
		return tostring(a), tostring(b), tostring(c)
	elseif (n == 0) then
		return
	end

	local needfix
	for i = 1, n do
		local v = select(i, ...)
		if (type(v) ~= "string") then
			needfix = i
			break
		end
	end
	if (not needfix) then return ... end

	wipe(LOCAL_ToStringAllTemp)
	for i = 1, needfix - 1 do
		LOCAL_ToStringAllTemp[i] = select(i, ...)
	end
	for i = needfix, n do
		LOCAL_ToStringAllTemp[i] = tostring(select(i, ...))
	end
	return unpack(LOCAL_ToStringAllTemp)
end

local LOCAL_PrintHandler = function(...)
	DEFAULT_CHAT_FRAME:AddMessage(strjoin(" ", tostringall(...)))
end

function setprinthandler(func)
	if (type(func) ~= "function") then
		error("Invalid print handler")
	else
		LOCAL_PrintHandler = func
	end
end

function getprinthandler() return LOCAL_PrintHandler end

local function print_inner(...)
	local ok, err = pcall(LOCAL_PrintHandler, ...)
	if (not ok) then
		local func = geterrorhandler()
		func(err)
	end
end

function print(...)
	securecall(pcall, print_inner, ...)
end

SLASH_PRINT1 = "/print"
SlashCmdList["PRINT"] = print