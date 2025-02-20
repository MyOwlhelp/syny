--[[ Synapse Y
     Date:      2/17/2025
     Desc: 		Open Sourced.
     File:      Init.lua
]]

local getgenv = getgenv or function() return _G end
local getrenv = getrenv or function() return _G end
local getgc = getgc or function() return {} end
local getreg = getreg or function() return {} end
local gethui = gethui or function() return game:GetService("CoreGui") end
local setmetatable = setmetatable
local getrawmetatable = getrawmetatable
local setreadonly = setreadonly or function(mt, bool) if bool then error("setreadonly not available") end end
local isreadonly = isreadonly or function(mt) return false end
local checkcaller = checkcaller or function() return false end
local clonefunction = clonefunction or function(func) return func end
local HtType = true
local HtGet
local GetNDM = getndm
local GameMeta = GameMeta
local TableRemove = table.remove
local FindString = string.find
local ReverseString = string.reverse
local SetNDM = setndm
local StrFind = string.find
local StrGSub = string.gsub
local HookFunc = hookfunction
local httpService = cloneref(game:GetService('HttpService'))
local RepKick = reportkick
local HtPost

local GetInstanceList = getinstancelist
local NewCC = newcclosure

local GetLoadedModules = getloadedmodules
-- event API
local GetCons = getconnections
local DisableCon = disableconnection
local EnableCon = enableconnection
local GetConFunc = getconnectionfunc
local GetConnectState = getconnectionstate

-- Define MarketplaceService and related functions
local MarketplaceService = game:GetService("MarketplaceService")
local PCall = pcall
local GService = game.GetService
local GetObjects = game.GetObjects
local noscript = ""
local MarketBlacklist = {} -- Define this
getgenv().checkrbxlocked = nil
local CheckRL = checkrbxlocked
local GetLoadedModules = getloadedmodules

local syn = {}

-- Improved newcclosure implementation
getgenv().newcclosure = function(f)
	if type(f) ~= "function" then error("expected function as argument #1") end
	if not islclosure(f) then error("expected Lua function as argument #1") end
	return NewCC(f)
end

-- Hook function
getgenv().hookfunction = newcclosure(function(old, new)
	if type(old) ~= "function" then error("expected function as argument #1") end
	if type(new) ~= "function" then error("expected function as argument #2") end

	if islclosure(old) and not islclosure(new) then error("expected C function or Lua function as both argument #1 and #2") end

	local hook
	if not islclosure(old) and islclosure(new) then
		hook = newcclosure(new)
	else
		hook = new
	end

	return HookFunc(old, hook)
end)

getgenv().hookfunc = hookfunction

-- Identify executor
getgenv().identifyexecutor = newcclosure(function()
	return "Synapse Y - v1.0.0b"
end)

-- Define HtType and related functions
if HtType then
	HtGet = game.HttpGetAsync
	HtPost = game.HttpPostAsync
else
	HtGet = httpget
	HtPost = httppost
end

local mbox = getgenv().messageboxasync
local mcomplete = getgenv().mbcomplete
local mres = getgenv().mbres
getgenv().messageboxasync = function(message, title, code)
	mbox(message, title, code)
	while wait() do
		if mcomplete() then
			return mres()
		end
	end
end

local casync = getgenv().rconsoleinputasync
local ccomplete = getgenv().rconsolecomplete
local cres = getgenv().rconsoleres
getgenv().rconsoleinputasync = function()
	casync()
	while wait() do
		if ccomplete() then
			return cres()
		end
	end
end

getgenv().rconsoleinput = newcclosure(function()
	local input = ""
	local waiting = true

	-- Function to handle user input
	local function onInput(key)
		if key == "\n" then -- Enter key
			waiting = false
		elseif key == "\b" then -- Backspace key
			if #input > 0 then
				input = string.sub(input, 1, #input - 1)
			end
		else
			input = input .. key
		end
	end

	-- Bind input events (using UserInputService)
	local UIS = game:GetService("UserInputService")
	local connection
	connection = UIS.InputBegan:Connect(function(inputObject, gameProcessedEvent)
		if inputObject.UserInputType == Enum.UserInputType.Keyboard or inputObject.UserInputType == Enum.UserInputType.Gamepad1 or inputObject.UserInputType == Enum.UserInputType.Touch then
			local key = inputObject.KeyCode == Enum.KeyCode.Unknown and inputObject.UserInputState == Enum.UserInputState.Begin and inputObject.TextInput or inputObject.KeyCode.Name
			if key then
				onInput(key)
			end
			if not waiting then
				connection:Disconnect()
			end
		end
	end)


	-- Wait for input
	while waiting do
		wait()
	end

	return input
end)

getgenv().getscripts = newcclosure(function()
	local inst = GetInstanceList()
	local r = {}

	for i, v in pairs(inst) do
		if typeof(v) == "Instance" and (v:IsA("LocalScript") or v:IsA("ModuleScript")) and not v.RobloxLocked then
			r[#r + 1] = v
		end
	end

	return r
end)

getgenv().get_scripts = getscripts

getgenv().syn_get_thread_identity = newcclosure(function(input)
	local success, get = pcall(function()
		return getthreadidentity(input)
	end)
	return get
end)
getgenv().syn_set_thread_identity = newcclosure(function(input)
	local success, set = pcall(function()
		return setthreadidentity(input)
	end)
	return set
end)
syn.set_thread_identity = syn_set_thread_identity
syn.get_thread_identity = syn_get_thread_identity

getgenv().require = function(scr, Req)
	if typeof(scr) ~= 'Instance' or scr.ClassName ~= 'ModuleScript' then error'attempt to require a non-ModuleScript' end
	if CheckRL(scr) then error'attempt to require a core ModuleScript' end
	local oIdentity = syn.get_thread_identity()

	syn.set_thread_identity(2)
	local g, res = pcall(Req, scr)
	syn.set_thread_identity(oIdentity)

	if not g then
		error(res)
	end

	return res
end

local function decompile(script_instance)
	local bytecode = getscriptbytecode(script_instance)
	local encoded = crypt.base64.encode(bytecode)
	local header = "-- Decompiled with the Synapse Y Luau decompiler."

	local httpResult = request({
		Url = "https://medal.hates.us/decompile",
		Method = "POST",
		Body = encoded
	})

	if httpResult.StatusCode ~= 200 then
		return "-- Error occurred while requesting the API, Bytecode:\n\n--[[\n" .. httpResult.Body .. "\n--]]"
	else
		return header .. "\n\n" .. httpResult.Body
	end
end

getgenv().decompile = decompile
getgenv().syn_decompile = decompile

getgenv().saveinstance = newcclosure(function()
	decompile()
	local Params = {
		RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/",
		SSI = "saveinstance",
	}
	local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
	local Options = { NilInstances = true, RemovePlayerCharacters = false }
	synsaveinstance(Options)
end)

--getloadedmodules fix
getgenv().getloadedmodules = newcclosure(function()
	local Unfiltered = GetLoadedModules()
	local Filtered = {}

	for I,V in pairs(Unfiltered) do
		if not CheckRL(V) then table.insert(Filtered, V) end
	end

	return Filtered
end)

getgenv().get_loaded_modules = getloadedmodules

getgenv().htgetf = newcclosure(function(url)
	local GND = GetNDM(game)
	SetNDM(game, 3)
	spawn(function() SetNDM(game, GND) end)
	return HtForceGet(game, url)
end)

getgenv().syn_crypt_b64_encode = newcclosure(function(input)
	-- Check if the input is valid
	if not input or type(input) ~= "string" then
		return nil, "Invalid input"
	end

	-- Attempt to encode the input
	local success, encoded = pcall(function()
		return crypt.base64.encode(input)
	end)

	-- Check if encoding was successful
	if not success then
		return nil, "Encoding failed"
	end

	-- Return the encoded string
	return encoded
end)

getgenv().syn_crypt_b64_decode = newcclosure(function(input)
	-- Attempt to decode the input
	local success, decoded = pcall(function()
		return crypt.base64.decode(input)
	end)

	-- Check if decoding was successful
	if not success then
		return nil, "Decoding failed"
	end

	-- Return the encoded string
	return decoded
end)

getgenv().is_synapse_function = newcclosure(function(func)
	if type(func) ~= "function" then
		return false, "Invalid function"
	end
	return (iscclosure and iscclosure(func)) or false
end)

getgenv().Drawing = Draw

print("Synapse Y is initialized.")
