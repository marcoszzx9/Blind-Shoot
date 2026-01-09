-- RAYFIELD
local Rayfield = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua"
))()

local Window = Rayfield:CreateWindow({
    Name = "Hypershoot | Private Test Panel",
    LoadingTitle = "Hypershoot",
    LoadingSubtitle = "AntiCheat Testing Build",
    Theme = "Default"
})

-- TABS
local CombatTab = Window:CreateTab("Combat", 4483362458 /* icon */)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local MiscTab   = Window:CreateTab("Misc", 4483362458)

-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

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
    if not char or not LocalPlayer.Character then return false end
    return char:GetAttribute("Team") ~= LocalPlayer.Character:GetAttribute("Team")
end

local function getClosestEnemy()
    local closest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            if isEnemy(p.Character) then
                local pos, onscreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onscreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if mag < dist and mag < 200 then
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
RunService.RenderStepped:Connect(function()
    if Flags.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
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
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if self == Mouse and key == "Hit" and Flags.AimSilent then
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
RunService.Heartbeat:Connect(function()
    if not Flags.Hitbox then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and isEnemy(p.Character) then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
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
-- ESP
--------------------------------------------------
local ESPCache = {}

local function applyESP(char)
    if ESPCache[char] then return end
    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(255,0,0)
    hl.OutlineColor = Color3.fromRGB(255,255,255)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char
    ESPCache[char] = hl
end

local function clearESP()
    for _, v in pairs(ESPCache) do
        if v then v:Destroy() end
    end
    ESPCache = {}
end

--------------------------------------------------
-- KILL AURA
--------------------------------------------------
RunService.Heartbeat:Connect(function()
    if not Flags.KillAura then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and isEnemy(p.Character) then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            local lhrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hum and lhrp then
                if (hrp.Position - lhrp.Position).Magnitude < 12 then
                    hum.Health = 0
                end
            end
        end
    end
end)

--------------------------------------------------
-- RAYFIELD TOGGLES
--------------------------------------------------
CombatTab:CreateToggle({
    Name = "Aimbot (RMB)",
    Callback = function(v) Flags.Aimbot = v end
})

CombatTab:CreateToggle({
    Name = "AimSilent",
    Callback = function(v) Flags.AimSilent = v end
})

CombatTab:CreateToggle({
    Name = "Hitbox Expander",
    Callback = function(v) Flags.Hitbox = v end
})

CombatTab:CreateToggle({
    Name = "Kill Aura",
    Callback = function(v) Flags.KillAura = v end
})

VisualTab:CreateToggle({
    Name = "ESP",
    Callback = function(v) Flags.ESP = v end
})

--------------------------------------------------
-- MISC
--------------------------------------------------
MiscTab:CreateButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

