---
--- check for an already loaded old WhoLib
---

if WhoLibByALeX or WhoLib then
	-- the WhoLib-1.0 (WhoLibByALeX) or WhoLib (by Malex) is loaded -> fail!
	error("an other WhoLib is already running - disable them first!\n")
	return
end -- if

---
--- check version
---

assert(LibStub, "LibWho-2.0 requires LibStub")


local major_version = 'LibWho-2.0'
local minor_version = tonumber("154") or 99999

local lib = LibStub:NewLibrary(major_version, minor_version)


if not lib then
	return	-- already loaded and no upgrade necessary
end

lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
local callbacks = lib.callbacks

local am = {}
local om = getmetatable(lib)
if om then
	for k, v in pairs(om) do am[k] = v end
end
am.__tostring = function() return major_version end
setmetatable(lib, am)

local function dbgfunc(...) if lib.Debug then print(...) end end
local function NOP() return end
local dbg = NOP

---
--- initalize base
---

if type(lib['hooked']) ~= 'table' then
	lib['hooked'] = {}
end -- if

if type(lib['hook']) ~= 'table' then
	lib['hook'] = {}
end -- if

if type(lib['events']) ~= 'table' then
	lib['events'] = {}
end -- if

if type(lib['embeds']) ~= 'table' then
	lib['embeds'] = {}
end -- if

if type(lib['frame']) ~= 'table' then
	lib['frame'] = CreateFrame('Frame', major_version);
end -- if
lib['frame']:Hide()

lib.Queue = {[1]={}, [2]={}, [3]={}}
lib.WhoInProgress = false
lib.Result = nil
lib.Args = nil
lib.Total = nil
lib.Quiet = nil
lib.Debug = false
lib.Cache = {}
lib.CacheQueue = {}
lib.SetWhoToUIState = false


lib.MinInterval = 2.5
lib.MaxInterval = 10

---
--- locale
---

if (GetLocale() == "ruRU") then
	lib.L = {
		['console_queued'] = 'Добавлено в очередь "/who %s"',
		['console_query'] = 'Результат "/who %s"',
		['gui_wait'] = '- Пожалуйста подождите -',
	}
else
	-- enUS is the default
	lib.L = {
		['console_queued'] = 'Added "/who %s" to queue',
		['console_query'] = 'Result of "/who %s"',
		['gui_wait'] = '- Please Wait -',
	}
end -- if


---
--- external functions/constants
---

lib['external'] = {
	'WHOLIB_QUEUE_USER',
	'WHOLIB_QUEUE_QUIET',
	'WHOLIB_QUEUE_SCANNING',
	'WHOLIB_FLAG_ALWAYS_CALLBACK',
	'Who',
	'UserInfo',
	'CachedUserInfo',
	'GetWhoLibDebug',
	'SetWhoLibDebug',
--	'RegisterWhoLibEvent',
}

-- queues
lib['WHOLIB_QUEUE_USER'] = 1
lib['WHOLIB_QUEUE_QUIET'] = 2
lib['WHOLIB_QUEUE_SCANNING'] = 3



local queue_all = {
	[1] = 'WHOLIB_QUEUE_USER',
	[2] = 'WHOLIB_QUEUE_QUIET',
	[3] = 'WHOLIB_QUEUE_SCANNING',
}

local queue_quiet = {
	[2] = 'WHOLIB_QUEUE_QUIET',
	[3] = 'WHOLIB_QUEUE_SCANNING',
}

-- bit masks!
lib['WHOLIB_FLAG_ALWAYS_CALLBACK'] = 1

function lib:Reset()
    self.Queue = {[1]={}, [2]={}, [3]={}}
    self.Cache = {}
    self.CacheQueue = {}
end

function lib.Who(defhandler, query, opts)
	local self, args, usage = lib, {}, 'Who(query, [opts])'

	args.query = self:CheckArgument(usage, 'query', 'string', query)
	opts = self:CheckArgument(usage, 'opts', 'table', opts, {})
	args.queue = self:CheckPreset(usage, 'opts.queue', queue_all, opts.queue, self.WHOLIB_QUEUE_SCANNING)
	args.flags = self:CheckArgument(usage, 'opts.flags', 'number', opts.flags, 0)
	args.callback, args.handler = self:CheckCallback(usage, 'opts.', opts.callback, opts.handler, defhandler)
	-- now args - copied and verified from opts

	if args.queue == self.WHOLIB_QUEUE_USER then
		if WhoFrame:IsShown() then
			self:GuiWho(args.query)
		else
			self:ConsoleWho(args.query)
		end
	else
		self:AskWho(args)
	end
end

function lib.UserInfo(defhandler, name, opts)
	local self, args, usage = lib, {}, 'UserInfo(name, [opts])'
	local now = time()

    name = self:CheckArgument(usage, 'name', 'string', name)
    if name:len() == 0 then return end

    if name:find("%-") then --[[dbg("ignoring xrealm: "..name)]] return end

	args.name = self:CapitalizeInitial(name)
	opts = self:CheckArgument(usage, 'opts', 'table', opts, {})
	args.queue = self:CheckPreset(usage, 'opts.queue', queue_quiet, opts.queue, self.WHOLIB_QUEUE_SCANNING)
	args.flags = self:CheckArgument(usage, 'opts.flags', 'number', opts.flags, 0)
	args.timeout = self:CheckArgument(usage, 'opts.timeout', 'number', opts.timeout, 5)
	args.callback, args.handler = self:CheckCallback(usage, 'opts.', opts.callback,  opts.handler, defhandler)

	-- now args - copied and verified from opts
	local cachedName = self.Cache[args.name]

	if(cachedName ~= nil)then
		-- user is in cache
		if(cachedName.valid == true and (args.timeout < 0 or cachedName.last + args.timeout*60 > now))then
			-- cache is valid and timeout is in range
			--dbg('Info(' .. args.name ..') returned immedeatly')
			if(bit.band(args.flags, self.WHOLIB_FLAG_ALWAYS_CALLBACK) ~= 0)then
				self:RaiseCallback(args, cachedName.data)
				return false
			else
				return self:DupAll(self:ReturnUserInfo(args.name))
			end
		elseif(cachedName.valid == false)then
			-- query is already running (first try)
			if(args.callback ~= nil)then
				tinsert(cachedName.callback, args)
			end
			--dbg('Info(' .. args.name ..') returned cause it\'s already searching')
			return nil
		end
	else
		self.Cache[args.name] = {valid=false, inqueue=false, callback={}, data={Name = args.name}, last=now }
	end

	local cachedName = self.Cache[args.name]

	if(cachedName.inqueue)then
		-- query is running!
		if(args.callback ~= nil)then
			tinsert(cachedName.callback, args)
		end
		dbg('Info(' .. args.name ..') returned cause it\'s already searching')
		return nil
	end
	if (GetLocale() == "ruRU") then -- in ruRU with n- not show information about player in WIM addon
    if args.name and args.name:len() > 0 then
    	local query = 'и-"' .. args.name .. '"'
    	cachedName.inqueue = true
    	if(args.callback ~= nil)then
    		tinsert(cachedName.callback, args)
    	end
    	self.CacheQueue[query] = args.name
    	dbg('Info(' .. args.name ..') added to queue')
    	self:AskWho( { query = query, queue = args.queue, flags = 0, info = args.name } )
    end
	else
	    if args.name and args.name:len() > 0 then
    	local query = 'n-"' .. args.name .. '"'
    	cachedName.inqueue = true
    	if(args.callback ~= nil)then
    		tinsert(cachedName.callback, args)
    	end
    	self.CacheQueue[query] = args.name
    	dbg('Info(' .. args.name ..') added to queue')
    	self:AskWho( { query = query, queue = args.queue, flags = 0, info = args.name } )
    end
	end
	return nil
end

function lib.CachedUserInfo(_, name)
	local self, usage = lib, 'CachedUserInfo(name)'

	name = self:CapitalizeInitial(self:CheckArgument(usage, 'name', 'string', name))

	if self.Cache[name] == nil then
		return nil
	else
		return self:DupAll(self:ReturnUserInfo(name))
	end
end

function lib.GetWhoLibDebug(_, mode)
    return lib.Debug
end

function lib.SetWhoLibDebug(_, mode)
    lib.Debug = mode
	dbg = mode and dbgfunc or NOP
end

--function lib.RegisterWhoLibEvent(defhandler, event, callback, handler)
--	local self, usage = lib, 'RegisterWhoLibEvent(event, callback, [handler])'
--
--	self:CheckPreset(usage, 'event', self.events, event)
--	local callback, handler = self:CheckCallback(usage, '', callback, handler, defhandler, true)
--	table.insert(self.events[event], {callback=callback, handler=handler})
--end

-- non-embedded externals

function lib.Embed(_, handler)
	local self, usage = lib, 'Embed(handler)'

	self:CheckArgument(usage, 'handler', 'table', handler)

	for _,name in pairs(self.external) do
		handler[name] = self[name]
	end -- do
	 self['embeds'][handler] = true

	return handler
end

function lib.Library(_)
	local self = lib

	return self:Embed({})
end

---
--- internal functions
---

function lib:AllQueuesEmpty()
    local queueCount = #self.Queue[1] + #self.Queue[2] + #self.Queue[3] + #self.CacheQueue

    -- Be sure that we have cleared the in-progress status
    if self.WhoInProgress then
        queueCount = queueCount + 1
    end

	return queueCount == 0
end

local queryInterval = 5

function lib:GetQueryInterval() return queryInterval end

function lib:AskWhoNextIn5sec()
	if self.frame:IsShown() then return end

	dbg("Waiting to send next who")
	self.Timeout_time = queryInterval
	self['frame']:Show()
end

function lib:CancelPendingWhoNext()
	lib['frame']:Hide()
end

lib['frame']:SetScript("OnUpdate", function(frame, elapsed)
	lib.Timeout_time = lib.Timeout_time - elapsed
	if lib.Timeout_time <= 0 then
		lib['frame']:Hide()
		lib:AskWhoNext()
	end -- if
end);


-- queue scheduler
local queue_weights = { [1] = 0.6, [2] = 0.2, [3] = 0.2 }
local queue_bounds = { [1] = 0.6, [2] = 0.2, [3] = 0.2 }

-- allow for single queries from the user to get processed faster
local lastInstantQuery = time()
local INSTANT_QUERY_MIN_INTERVAL = 60 -- only once every 1 min

function lib:UpdateWeights()
   local weightsum, sum, count = 0, 0, 0
   for k,v in pairs(queue_weights) do
        sum = sum + v
        weightsum = weightsum + v * #self.Queue[k]
   end

   if weightsum == 0 then
        for k,v in pairs(queue_weights) do queue_bounds[k] = v end
        return
   end

   local adjust = sum / weightsum

   for k,v in pairs(queue_bounds) do
        queue_bounds[k] = queue_weights[k] * adjust * #self.Queue[k]
   end
end

function lib:GetNextFromScheduler()
   self:UpdateWeights()

   -- Since an addon could just fill up the user q for instant processing
   -- we have to limit instants to 1 per INSTANT_QUERY_MIN_INTERVAL
   -- and only try instant fulfilment if it will empty the user queue
   if #self.Queue[1] == 1 then
		if time() - lastInstantQuery > INSTANT_QUERY_MIN_INTERVAL then
			dbg("INSTANT")
			lastInstantQuery = time()
			return 1, self.Queue[1]
		end
   end

   local n,i = math.random(),0
   repeat
        i=i+1
        n = n - queue_bounds[i]
   until i>=#self.Queue or n <= 0

   dbg(("Q=%d, bound=%d"):format(i, queue_bounds[i]))

   if #self.Queue[i] > 0 then
        dbg(("Q=%d, bound=%d"):format(i, queue_bounds[i]))
       return i, self.Queue[i]
   else
        dbg("Queues empty, waiting")
   end
end

lib.queue_bounds = queue_bounds

function lib:AskWhoNext()
	if lib.frame:IsShown() then
		dbg("Already waiting")
		return
	end

	self:CancelPendingWhoNext()

	if self.WhoInProgress then
		-- if we had a who going, it didnt complete
		dbg("TIMEOUT: "..self.Args.query)
		local args = self.Args
		self.Args = nil
--		if args.info and self.CacheQueue[args.query] ~= nil then
			dbg("Requeing "..args.query)
			tinsert(self.Queue[args.queue], args)
			if args.console_show ~= nil then
				DEFAULT_CHAT_FRAME:AddMessage(("Timeout on result of '%s' - retrying..."):format(args.query),1,1,0)
				args.console_show = true
			end
--		end

		if queryInterval < lib.MaxInterval then
			queryInterval = queryInterval + 0.5
			dbg("--Throttling down to 1 who per " .. queryInterval .. "s")
		end
	end


	self.WhoInProgress = false

	local v,k,args = nil
    local kludge = 10
	repeat
        k,v = self:GetNextFromScheduler()
        if not k then break end
		if(WhoFrame:IsShown() and k > self.WHOLIB_QUEUE_QUIET)then
			break
		end
		if(#v > 0)then
			args = tremove(v, 1)
			break
		end
        kludge = kludge - 1
	until kludge <= 0

	if args then
		self.WhoInProgress = true
		self.Result = {}
		self.Args = args
		self.Total = -1
		if(args.console_show == true)then
			DEFAULT_CHAT_FRAME:AddMessage(string.format(self.L['console_query'], args.query), 1, 1, 0)

		end

		if args.queue == self.WHOLIB_QUEUE_USER then
			WhoFrameEditBox:SetText(args.query)
			self.Quiet = false

			if args.whotoui then
    			self.hooked.SetWhoToUI(args.whotoui)
    		else
    			self.hooked.SetWhoToUI(args.gui and true or false)
			end
		else
			self.hooked.SetWhoToUI(true)
			self.Quiet = true
		end

		dbg("QUERY: "..args.query)
		self.hooked.SendWho(args.query)
	else
		self.Args = nil
		self.WhoInProgress = false
	end

    -- Keep processing the who queue if there is more work
	if not self:AllQueuesEmpty() then
		self:AskWhoNextIn5sec()
    else
        dbg("*** Done processing requests ***")
	end
end

function lib:AskWho(args)
	tinsert(self.Queue[args.queue], args)
	dbg('[' .. args.queue .. '] added "' .. args.query .. '", queues=' .. #self.Queue[1] .. '/'.. #self.Queue[2] .. '/'.. #self.Queue[3])
	self:TriggerEvent('WHOLIB_QUERY_ADDED')

	self:AskWhoNext()
end

function lib:ReturnWho()
    if not self.Args then
        self.Quiet = nil
        return
    end

	if(self.Args.queue == self.WHOLIB_QUEUE_QUIET or self.Args.queue == self.WHOLIB_QUEUE_SCANNING)then
		self.Quiet = nil
	end

	if queryInterval > self.MinInterval then
		queryInterval = queryInterval - 0.5
		dbg("--Throttling up to 1 who per " .. queryInterval .. "s")
	end

	self.WhoInProgress = false
	dbg("RESULT: "..self.Args.query)
	dbg('[' .. self.Args.queue .. '] returned "' .. self.Args.query .. '", total=' .. self.Total ..' , queues=' .. #self.Queue[1] .. '/'.. #self.Queue[2] .. '/'.. #self.Queue[3])
	local now = time()
	local complete = (self.Total == #self.Result) and (self.Total < MAX_WHOS_FROM_SERVER)
	for _,v in pairs(self.Result)do
		if v.Name then
			if(self.Cache[v.Name] == nil)then
				self.Cache[v.Name] = { inqueue = false, callback = {} }
			end

			local cachedName = self.Cache[v.Name]

			cachedName.valid = true -- is now valid
			cachedName.data = v -- update data
			cachedName.data.Online = true -- player is online
			cachedName.last = now -- update timestamp
			if(cachedName.inqueue)then
				if(self.Args.info and self.CacheQueue[self.Args.query] == v.Name)then
					-- found by the query which was created to -> remove us from query
					self.CacheQueue[self.Args.query] = nil
				else
					-- found by another query
					for k2,v2 in pairs(self.CacheQueue) do
						if(v2 == v.Name)then
							for i=self.WHOLIB_QUEUE_QUIET, self.WHOLIB_QUEUE_SCANNING do
								for k3,v3 in pairs(self.Queue[i]) do
									if(v3.query == k2 and v3.info)then
										-- remove the query which was generated for this user, cause another query was faster...
										dbg("Found '"..v.Name.."' early via query '"..self.Args.query.."'")
										table.remove(self.Queue[i], k3)
										self.CacheQueue[k2] = nil
									end
								end
							end
						end
					end
				end
				dbg('Info(' .. v.Name ..') returned: on')
				for _,v2 in pairs(cachedName.callback) do
					self:RaiseCallback(v2, self:ReturnUserInfo(v.Name))
				end
				cachedName.callback = {}
			end
			cachedName.inqueue = false -- query is done
		end
	end
	if(self.Args.info and self.CacheQueue[self.Args.query])then
		-- the query did not deliver the result => not online!
		local name = self.CacheQueue[self.Args.query]
		local cachedName = self.Cache[name]
		if (cachedName.inqueue)then
			-- nothing found (yet)
			cachedName.valid = true -- is now valid
			cachedName.inqueue = false -- query is done?
			cachedName.last = now -- update timestamp
			if(complete)then
				cachedName.data.Online = false -- player is offline
			else
				cachedName.data.Online = nil -- player is unknown (more results from who than can be displayed)
			end
		end
		dbg('Info(' .. name ..') returned: ' .. (cachedName.data.Online == false and 'off' or 'unkn'))
		for _,v in pairs(cachedName.callback) do
			self:RaiseCallback(v, self:ReturnUserInfo(name))
		end
		cachedName.callback = {}
		self.CacheQueue[self.Args.query] = nil
	end
	self:RaiseCallback(self.Args, self.Args.query, self.Result, complete, self.Args.info)
	self:TriggerEvent('WHOLIB_QUERY_RESULT', self.Args.query, self.Result, complete, self.Args.info)

	if not self:AllQueuesEmpty() then
		self:AskWhoNextIn5sec()
	end
end

function lib:GuiWho(msg)
	if(msg == self.L['gui_wait'])then
		return
	end

	for _,v in pairs(self.Queue[self.WHOLIB_QUEUE_USER]) do
		if(v.gui == true)then
			return
		end
	end
	if(self.WhoInProgress)then
		WhoFrameEditBox:SetText(self.L['gui_wait'])
	end
	self.savedText = msg
	self:AskWho({query = msg, queue = self.WHOLIB_QUEUE_USER, flags = 0, gui = true})
	WhoFrameEditBox:ClearFocus();
end

function lib:ConsoleWho(msg)
	--WhoFrameEditBox:SetText(msg)
	local console_show = false
	local q1 = self.Queue[self.WHOLIB_QUEUE_USER]
	local q1count = #q1

	if(q1count > 0 and q1[q1count].query == msg)then -- last query is itdenical: drop
		return
	end

	if(q1count > 0 and q1[q1count].console_show == false)then -- display 'queued' if console and not yet shown
		DEFAULT_CHAT_FRAME:AddMessage(string.format(self.L['console_queued'], q1[q1count].query), 1, 1, 0)
		q1[q1count].console_show = true
	end
	if(q1count > 0 or self.WhoInProgress)then
		DEFAULT_CHAT_FRAME:AddMessage(string.format(self.L['console_queued'], msg), 1, 1, 0)
		console_show = true
	end
	self:AskWho({query = msg, queue = self.WHOLIB_QUEUE_USER, flags = 0, console_show = console_show})
end

function lib:ReturnUserInfo(name)
	if(name ~= nil and self ~= nil and self.Cache ~= nil and self.Cache[name] ~= nil) then
		return self.Cache[name].data, (time() - self.Cache[name].last) / 60
	end
end

function lib:RaiseCallback(args, ...)
	if type(args.callback) == 'function' then
		args.callback(self:DupAll(...))
	elseif args.callback then -- must be a string
		args.handler[args.callback](args.handler, self:DupAll(...))
	end -- if
end

-- Argument checking

function lib:CheckArgument(func, name, argtype, arg, defarg)
	if arg == nil and defarg ~= nil then
		return defarg
	elseif type(arg) == argtype then
		return arg
	else
		error(string.format("%s: '%s' - %s%s expected got %s", func, name, (defarg ~= nil) and 'nil or ' or '', argtype, type(arg)), 3)
	end -- if
end

function lib:CheckPreset(func, name, preset, arg, defarg)
	if arg == nil and defarg ~= nil then
		return defarg
	elseif arg ~= nil and preset[arg] ~= nil then
		return arg
	else
		local p = {}
		for k,v in pairs(preset) do
			if type(v) ~= 'string' then
				table.insert(p, k)
			else
				table.insert(p, v)
			end -- if
		end -- for
		error(string.format("%s: '%s' - one of %s%s expected got %s", func, name, (defarg ~= nil) and 'nil, ' or '', table.concat(p, ', '), self:simple_dump(arg)), 3)
	end -- if
end

function lib:CheckCallback(func, prefix, callback, handler, defhandler, nonil)
	if not nonil and callback == nil then
		-- no callback: ignore handler
		return nil, nil
	elseif type(callback) == 'function' then
		-- simple function
		if handler ~= nil then
			error(string.format("%s: '%shandler' - nil expected got %s", func, prefix, type(arg)), 3)
		end -- if
	elseif type(callback) == 'string' then
		-- method
		if handler == nil then
			handler = defhandler
		end -- if
		if type(handler) ~= 'table' or type(handler[callback]) ~= 'function' or handler == self then
			error(string.format("%s: '%shandler' - nil or function expected got %s", func, prefix, type(arg)), 3)
		end -- if
	else
		error(string.format("%s: '%scallback' - %sfunction or string expected got %s", func, prefix, nonil and 'nil or ' or '', type(arg)), 3)
	end -- if

	return callback, handler
end

-- helpers

function lib:simple_dump(x)
	if type(x) == 'string' then
		return 'string \''..x..'\''
	elseif type(x) == 'number' then
		return 'number '..x
	else
		return type(x)
	end
end

function lib:Dup(from)
	local to = {}

	for k,v in pairs(from) do
		if type(v) == 'table' then
			to[k] = self:Dup(v)
		else
			to[k] = v
		end -- if
	end -- for

	return to
end

function lib:DupAll(x, ...)
	if type(x) == 'table' then
		return self:Dup(x), self:DupAll(...)
	elseif x ~= nil then
		return x, self:DupAll(...)
	else
		return nil
	end -- if
end

local MULTIBYTE_FIRST_CHAR = "^([\192-\255]?%a?[\128-\191]*)"

function lib:CapitalizeInitial(name)
    return name:gsub(MULTIBYTE_FIRST_CHAR, string.upper, 1)
end

---
--- user events (Using CallbackHandler)
---

lib.PossibleEvents = {
	'WHOLIB_QUERY_RESULT',
	'WHOLIB_QUERY_ADDED',
}

function lib:TriggerEvent(event, ...)
    callbacks:Fire(event, ...)
end

---
--- slash commands
---

SlashCmdList['WHO'] = function(msg)
	dbg("console /who: "..msg)
	-- new /who function
	--local self = lib

	if(msg == '')then
		lib:GuiWho(WhoFrame_GetDefaultWhoCommand())
	elseif(WhoFrame:IsVisible())then
		lib:GuiWho(msg)
	else
		lib:ConsoleWho(msg)
	end
end

SlashCmdList['WHOLIB_DEBUG'] = function()
	-- /wholibdebug: toggle debug on/off
	local self = lib

    self:SetWhoLibDebug(not self.Debug)
end

SLASH_WHOLIB_DEBUG1 = '/wholibdebug'


---
--- hook activation
---

-- functions to hook
local hooks = {
	'SendWho',
	'WhoFrameEditBox_OnEnterPressed',
--	'FriendsFrame_OnEvent',
	'SetWhoToUI',
}

-- hook all functions (which are not yet hooked)
for _, name in pairs(hooks) do
	if not lib['hooked'][name] then
		lib['hooked'][name] = _G[name]
		_G[name] = function(...)
			lib.hook[name](lib, ...)
		end -- function
	end -- if
end -- for

-- fake 'WhoFrame:Hide' as hooked
table.insert(hooks, 'WhoFrame_Hide')

-- check for unused hooks -> remove function
for name, _ in pairs(lib['hook']) do
	if not hooks[name] then
		lib['hook'][name] = function() end
	end -- if
end -- for

-- secure hook 'WhoFrame:Hide'
if not lib['hooked']['WhoFrame_Hide'] then
	lib['hooked']['WhoFrame_Hide'] = true
	hooksecurefunc(WhoFrame, 'Hide', function(...)
			lib['hook']['WhoFrame_Hide'](lib, ...)
		end -- function
	)
end -- if



----- Coroutine based implementation (future)
--function lib:sendWhoResult(val)
--    coroutine.yield(val)
--end
--
--function lib:sendWaitState(val)
--    coroutine.yield(val)
--end
--
--function lib:producer()
--    return coroutine.create(
--    function()
--        lib:AskWhoNext()
--        lib:sendWaitState(true)
--
--        -- Resumed look for data
--
--    end)
--end





---
--- hook replacements
---

function lib.hook.SendWho(self, msg)
	dbg("SendWho: "..msg)
	lib.AskWho(self, {query = msg, queue = lib.WHOLIB_QUEUE_USER, whotoui = lib.SetWhoToUIState, flags = 0})
end

function lib.hook.WhoFrameEditBox_OnEnterPressed(self)
	lib:GuiWho(WhoFrameEditBox:GetText())
end

--[[
function lib.hook.FriendsFrame_OnEvent(self, ...)
	if event ~= 'WHO_LIST_UPDATE' or not lib.Quiet then
		lib.hooked.FriendsFrame_OnEvent(...)
	end
end
]]

hooksecurefunc(FriendsFrame, 'RegisterEvent', function(self, event)
		if(event == "WHO_LIST_UPDATE") then
			self:UnregisterEvent("WHO_LIST_UPDATE");
		end
	end);


function lib.hook.SetWhoToUI(self, state)
	lib.SetWhoToUIState = state
end

function lib.hook.WhoFrame_Hide(self)
	if(not lib.WhoInProgress)then
		lib:AskWhoNextIn5sec()
	end
end


---
--- WoW events
---

local who_pattern = string.gsub(WHO_NUM_RESULTS, '%%d', '%%d%+')


function lib:CHAT_MSG_SYSTEM(arg1)
	if arg1 and arg1:find(who_pattern) then
		lib:ProcessWhoResults()
	end
end

FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")

function lib:WHO_LIST_UPDATE()
    if not lib.Quiet then
		WhoList_Update()
        FriendsFrame_Update()
    end

    lib:ProcessWhoResults()
end

function lib:ProcessWhoResults()
	self.Result = self.Result and table.wipe(self.Result) or {}

	local num
	self.Total, num = GetNumWhoResults()
	for i=1, num do
		local charname, guildname, level, race, class, zone, nonlocalclass, sex = GetWhoInfo(i)
		self.Result[i] = {Name=charname, Guild=guildname, Level=level, Race=race, Class=class, Zone=zone, NoLocaleClass=nonlocalclass, Sex=sex }
	end

	self:ReturnWho()
end

---
--- event activation
---

lib['frame']:UnregisterAllEvents();

lib['frame']:SetScript("OnEvent", function(frame, event, ...)
	lib[event](lib, ...)
end);

for _,name in pairs({
	'CHAT_MSG_SYSTEM',
	'WHO_LIST_UPDATE',
}) do
	lib['frame']:RegisterEvent(name);
end -- for


---
--- re-embed
---

for target,_ in pairs(lib['embeds']) do
	if type(target) == 'table' then
		lib:Embed(target)
	end -- if
end -- for
