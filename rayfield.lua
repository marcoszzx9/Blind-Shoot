-- RAYFIELD
local Rayfield = loadstring(gameHttpGet(httpssirius.menurayfield))()

local Window = RayfieldCreateWindow({
	Name = Hypershoot  Private Test Panel,
	LoadingTitle = Hypershoot,
	LoadingSubtitle = AntiCheat Testing Build,
	Theme = Default,
})

-- TABS
local CombatTab = WindowCreateTab(Combat, 4483362458)
local VisualTab = WindowCreateTab(Visual, 4483362458)
local PlayerTab = WindowCreateTab(Player, 4483362458)
local KeybindTab = WindowCreateTab(Keybinds, 4483362458)
local MiscTab = WindowCreateTab(Misc, 4483362458)

-- SERVICES
local Players = gameGetService(Players)
local UIS = gameGetService(UserInputService)
local RunService = gameGetService(RunService)
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayerGetMouse()

-- STATES
local Flags = {
	Aimbot = false,
	AimSilent = false,
	Hitbox = false,
	ESP = false,
	KillAura = false,
	InfiniteAmmo = false,
	FastReload = false,
	SpeedShoot = false,
	NoRecoil = false,
	NoCooldown = false
}

--------------------------------------------------
-- UTILS
--------------------------------------------------
local function isEnemy(char)
	return char and charGetAttribute(Team) ~= LocalPlayer.CharacterGetAttribute(Team)
end

local function getClosestEnemy()
	local closest, dist = nil, math.huge
	for _, p in pairs(PlayersGetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.CharacterFindFirstChild(Head) then
			if isEnemy(p.Character) then
				local pos, onscreen = CameraWorldToViewportPoint(p.Character.Head.Position)
				if onscreen then
					local mag = (Vector2.new(pos.X, pos.Y) - UISGetMouseLocation()).Magnitude
					if mag  dist and mag  200 then
						dist = mag
						closest = p
					end
				end
			end
		end
	end
	return closest
end

--------------------------------------------------
-- AIMBOT
--------------------------------------------------
RunService.RenderSteppedConnect(function()
	if Flags.Aimbot and UISIsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local target = getClosestEnemy()
		if target and target.Character then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
		end
	end
end)

--------------------------------------------------
-- AIMSILENT
--------------------------------------------------
local oldIndex
oldIndex = hookmetamethod(game, __index, function(self, key)
	if self == Mouse and key == Hit and Flags.AimSilent then
		local target = getClosestEnemy()
		if target and target.Character then
			return target.Character.Head.CFrame
		end
	end
	return oldIndex(self, key)
end)

--------------------------------------------------
-- HITBOX
--------------------------------------------------
RunService.HeartbeatConnect(function()
	if not Flags.Hitbox then return end
	for _, p in pairs(PlayersGetPlayers()) do
		if p ~= LocalPlayer and p.Character and isEnemy(p.Character) then
			local hrp = p.CharacterFindFirstChild(HumanoidRootPart)
			if hrp then
				hrp.Size = Vector3.new(8,8,8)
				hrp.Transparency = 0.5
				hrp.Material = Enum.Material.Neon
				hrp.CanCollide = false
			end
		end
	end
end)

--------------------------------------------------
-- ESP (HIGHLIGHT)
--------------------------------------------------
local ESPCache = {}

local function applyESP(char)
	if ESPCache[char] then return end
	local hl = Instance.new(Highlight)
	hl.FillColor = Color3.fromRGB(255,0,0)
	hl.OutlineColor = Color3.fromRGB(255,255,255)
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = char
	ESPCache[char] = hl
end

local function clearESP()
	for _, v in pairs(ESPCache) do
		if v then vDestroy() end
	end
	ESPCache = {}
end

--------------------------------------------------
-- KILL AURA
--------------------------------------------------
RunService.HeartbeatConnect(function()
	if not Flags.KillAura then return end
	for _, p in pairs(PlayersGetPlayers()) do
		if p ~= LocalPlayer and p.Character and isEnemy(p.Character) then
			local hrp = p.CharacterFindFirstChild(HumanoidRootPart)
			local hum = p.CharacterFindFirstChild(Humanoid)
			local lhrp = LocalPlayer.Character and LocalPlayer.CharacterFindFirstChild(HumanoidRootPart)
			if hrp and hum and lhrp then
				if (hrp.Position - lhrp.Position).Magnitude  12 then
					hum.Health = 0
				end
			end
		end
	end
end)

--------------------------------------------------
-- AMMO  RELOAD
--------------------------------------------------
local function applyAmmo()
	for _, v in next, getgc(true) do
		if typeof(v) == table and rawget(v, Ammo) then
			if Flags.InfiniteAmmo then rawset(v, Ammo, math.huge) end
			if Flags.FastReload and rawget(v, ReloadTime) then
				rawset(v, ReloadTime, 0.05)
			end
		end
	end
end

--------------------------------------------------
-- SPEED ON SHOOT
--------------------------------------------------
local function hookTool(tool)
	if toolIsA(Tool) then
		tool.ActivatedConnect(function()
			if Flags.SpeedShoot then
				local hum = LocalPlayer.CharacterFindFirstChild(Humanoid)
				if hum then
					hum.WalkSpeed = 40
					task.delay(0.25, function()
						hum.WalkSpeed = 16
					end)
				end
			end
		end)
	end
end

LocalPlayer.CharacterAddedConnect(function(char)
	char.ChildAddedConnect(hookTool)
end)

--------------------------------------------------
-- NO RECOIL  NO COOLDOWN
--------------------------------------------------
local function applyGC()
	for _, v in next, getgc(true) do
		if typeof(v) == table then
			if Flags.NoRecoil and rawget(v,Spread) then
				rawset(v,Spread,0)
				rawset(v,BaseSpread,0)
			end
			if Flags.NoCooldown and rawget(v,CD) then
				rawset(v,CD,0)
			end
		end
	end
end

--------------------------------------------------
-- RENDER LOOP
--------------------------------------------------
RunService.RenderSteppedConnect(function()
	if Flags.ESP then
		for _, p in pairs(PlayersGetPlayers()) do
			if p ~= LocalPlayer and p.Character and isEnemy(p.Character) then
				applyESP(p.Character)
			end
		end
	else
		clearESP()
	end

	applyAmmo()
	applyGC()
end)

--------------------------------------------------
-- RAYFIELD TOGGLES
--------------------------------------------------
CombatTabCreateToggle({Name=Aimbot (RMB), Callback=function(v) Flags.Aimbot=v end})
CombatTabCreateToggle({Name=AimSilent, Callback=function(v) Flags.AimSilent=v end})
CombatTabCreateToggle({Name=Hitbox Expander, Callback=function(v) Flags.Hitbox=v end})
CombatTabCreateToggle({Name=Kill Aura, Callback=function(v) Flags.KillAura=v end})

VisualTabCreateToggle({Name=ESP, Callback=function(v) Flags.ESP=v end})

PlayerTabCreateToggle({Name=Infinite Ammo, Callback=function(v) Flags.InfiniteAmmo=v end})
PlayerTabCreateToggle({Name=Fast Reload, Callback=function(v) Flags.FastReload=v end})
PlayerTabCreateToggle({Name=Speed Buff on Shoot, Callback=function(v) Flags.SpeedShoot=v end})
PlayerTabCreateToggle({Name=No Recoil, Callback=function(v) Flags.NoRecoil=v end})
PlayerTabCreateToggle({Name=No Ability Cooldown, Callback=function(v) Flags.NoCooldown=v end})

--------------------------------------------------
-- KEYBINDS (OPCIONAL)
--------------------------------------------------
KeybindTabCreateKeybind({
	Name = Toggle Aimbot,
	CurrentKeybind = Enum.KeyCode.Z,
	HoldToInteract = false,
	Callback = function() Flags.Aimbot = not Flags.Aimbot end
})

KeybindTabCreateKeybind({
	Name = Toggle AimSilent,
	CurrentKeybind = Enum.KeyCode.X,
	HoldToInteract = false,
	Callback = function() Flags.AimSilent = not Flags.AimSilent end
})

--------------------------------------------------
-- MISC
--------------------------------------------------
MiscTabCreateButton({
	Name = Infinite Yield,
	Callback = function()
		loadstring(gameHttpGet(httpsraw.githubusercontent.comEdgeIYinfiniteyieldmastersource))()
	end
})

