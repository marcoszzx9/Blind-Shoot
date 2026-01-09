--// Load Fluent safely
local Fluent
do
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet(
            "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
        ))()
    end)

    if not ok or not lib then
        warn("Failed to load Fluent UI")
        return
    end

    Fluent = lib
end

--// Addons
local SaveManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"
))()

local InterfaceManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
))()

--// EXECUTOR
local executor = "Unknown"
if identifyexecutor then
    executor = identifyexecutor() or "Unknown"
elseif getexecutorname then
    executor = getexecutorname() or "Unknown"
end

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

--// FLAGS
local Flags = {
    Aimbot = false,
    AimSilent = false,
    ESP = false,
    Hitbox = false,
    KillAura = false
}

--// Window
local Window = Fluent:CreateWindow({
    Title = "Hypershoot | Private",
    SubTitle = "Executor: " .. executor,
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 480),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

--// Tabs
local Tabs = {
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "eye" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "box" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

------------------------------------------------
-- INFO
------------------------------------------------
Tabs.Combat:AddParagraph({
    Title = "Account Info",
    Content = "User: " .. LP.Name .. "\nUserId: " .. LP.UserId .. "\nExecutor: " .. executor
})

------------------------------------------------
-- UTILS
------------------------------------------------
local function isEnemy(char)
    if not LP.Character then return false end
    return char
        and char:FindFirstChild("Humanoid")
        and char:GetAttribute("Team") ~= LP.Character:GetAttribute("Team")
end

local function getClosestEnemy()
    local closest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
            if isEnemy(p.Character) then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
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

------------------------------------------------
-- AIMBOT
------------------------------------------------
RunService.RenderStepped:Connect(function()
    if Flags.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = getClosestEnemy()
        if t and t.Character then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position)
        end
    end
end)

------------------------------------------------
-- AIMSILENT
------------------------------------------------
local old
old = hookmetamethod(game, "__index", function(self, key)
    if Flags.AimSilent and self == Mouse and key == "Hit" then
        local t = getClosestEnemy()
        if t and t.Character then
            return t.Character.Head.CFrame
        end
    end
    return old(self, key)
end)

------------------------------------------------
-- HITBOX
------------------------------------------------
RunService.Heartbeat:Connect(function()
    if not Flags.Hitbox then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and isEnemy(p.Character) then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(8,8,8)
                hrp.CanCollide = false
                hrp.Transparency = 0.5
            end
        end
    end
end)

------------------------------------------------
-- ESP
------------------------------------------------
local ESPCache = {}

local function clearESP()
    for _, v in pairs(ESPCache) do
        if v then v:Destroy() end
    end
    ESPCache = {}
end

RunService.RenderStepped:Connect(function()
    if not Flags.ESP then
        clearESP()
        return
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and isEnemy(p.Character) then
            if not ESPCache[p.Character] then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(255,0,0)
                hl.OutlineColor = Color3.fromRGB(255,255,255)
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = p.Character
                ESPCache[p.Character] = hl
            end
        end
    end
end)

------------------------------------------------
-- KILL AURA
------------------------------------------------
RunService.Heartbeat:Connect(function()
    if not Flags.KillAura then return end
    local lhrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not lhrp then return end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and isEnemy(p.Character) then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if hrp and hum and (hrp.Position - lhrp.Position).Magnitude < 12 then
                hum.Health = 0
            end
        end
    end
end)

------------------------------------------------
-- UI TOGGLES
------------------------------------------------
Tabs.Combat:AddToggle("Aimbot", {
    Title = "Aimbot (RMB)",
    Default = false,
    Callback = function(v) Flags.Aimbot = v end
})

Tabs.Combat:AddToggle("AimSilent", {
    Title = "Aim Silent",
    Default = false,
    Callback = function(v) Flags.AimSilent = v end
})

Tabs.Combat:AddToggle("KillAura", {
    Title = "Kill Aura",
    Default = false,
    Callback = function(v) Flags.KillAura = v end
})

Tabs.Visual:AddToggle("ESP", {
    Title = "ESP",
    Default = false,
    Callback = function(v) Flags.ESP = v end
})

Tabs.Visual:AddToggle("Hitbox", {
    Title = "Hitbox Expander",
    Default = false,
    Callback = function(v) Flags.Hitbox = v end
})

-- Adicione mais elementos de exemplo se a UI não aparecer
Tabs.Misc:AddButton({
    Title = "Test Button",
    Description = "Clique para testar",
    Callback = function()
        Fluent:Notify({
            Title = "Teste",
            Content = "Botão funcionando!",
            Duration = 3
        })
    end
})

Tabs.Misc:AddSlider("TestSlider", {
    Title = "Test Slider",
    Description = "Apenas para teste",
    Min = 0,
    Max = 100,
    Default = 50,
    Rounding = 0,
    Callback = function(Value)
        print("Slider value:", Value)
    end
})

------------------------------------------------
-- OPTIONS
------------------------------------------------
local Options = Fluent.Options

------------------------------------------------
-- SETTINGS / SAVE
------------------------------------------------
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("HypershootFluent")
SaveManager:SetFolder("HypershootFluent/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Loaded",
    Content = "Hypershoot carregado com sucesso!",
    Duration = 5
})

print("Script carregado completamente")
warn("Hypershoot UI deve aparecer agora")

-- Verificação final
if Window then
    print("✓ Janela criada com sucesso")
else
    warn("✗ Falha ao criar janela")
end

if Tabs.Combat then
    print("✓ Tab Combat criada")
else
    warn("✗ Falha ao criar tab Combat")
end
