--// Load Fluent safely
local Fluent
do
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet(
            "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
        ))()
    end)

    if not ok or not lib then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Erro",
            Text = "Falha ao carregar Fluent UI",
            Duration = 5
        })
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

--// CACHES
local ESPCache = {}

--// Window
local Window = Fluent:CreateWindow({
    Title = "Hypershoot | Private",
    SubTitle = "Executor: " .. executor,
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 420),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

--// Tabs
local Tabs = {
    Combat = Window:AddTab({ Title = "Combat" }),
    Visual = Window:AddTab({ Title = "Visual" }),
    Misc = Window:AddTab({ Title = "Misc" }),
    Settings = Window:AddTab({ Title = "Settings" })
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
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then 
        return false 
    end
    
    local myTeam = LP.Character:GetAttribute("Team") or LP.Team and LP.Team.Name
    local theirTeam = char:GetAttribute("Team") or (char.Parent and char.Parent:FindFirstChildOfClass("Player") and char.Parent:FindFirstChildOfClass("Player").Team and char.Parent:FindFirstChildOfClass("Player").Team.Name)
    
    return char
        and char:FindFirstChild("Humanoid")
        and char.Humanoid.Health > 0
        and myTeam ~= theirTeam
end

local function getClosestEnemy()
    local closest, dist = nil, math.huge
    local mousePos = UIS:GetMouseLocation()
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 and isEnemy(p.Character) then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if mag < dist and mag < 300 then
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
-- FUNÇÕES DO CHEAT
------------------------------------------------

-- AIMBOT
local aimbotConnection
Tabs.Combat:AddToggle("Aimbot", {
    Title = "Aimbot (RMB)",
    Default = false,
    Callback = function(v)
        Flags.Aimbot = v
        
        if aimbotConnection then
            aimbotConnection:Disconnect()
            aimbotConnection = nil
        end
        
        if v then
            aimbotConnection = RunService.RenderStepped:Connect(function()
                if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                    local t = getClosestEnemy()
                    if t and t.Character and t.Character:FindFirstChild("Head") then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position)
                    end
                end
            end)
        end
    end
})

-- AIMSILENT
local originalIndex
Tabs.Combat:AddToggle("AimSilent", {
    Title = "Silent Aim",
    Default = false,
    Callback = function(v)
        Flags.AimSilent = v
        
        if v and not originalIndex then
            originalIndex = hookmetamethod(game, "__index", function(self, key)
                if self == Mouse and key == "Hit" and Flags.AimSilent then
                    local t = getClosestEnemy()
                    if t and t.Character and t.Character:FindFirstChild("Head") then
                        return t.Character.Head.CFrame
                    end
                end
                return originalIndex(self, key)
            end)
        end
    end
})

-- KILL AURA
local killAuraConnection
Tabs.Combat:AddToggle("KillAura", {
    Title = "Kill Aura (12 studs)",
    Default = false,
    Callback = function(v)
        Flags.KillAura = v
        
        if killAuraConnection then
            killAuraConnection:Disconnect()
            killAuraConnection = nil
        end
        
        if v then
            killAuraConnection = RunService.Heartbeat:Connect(function()
                if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
                
                local lhrp = LP.Character.HumanoidRootPart
                
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
                        if isEnemy(p.Character) then
                            local hrp = p.Character.HumanoidRootPart
                            local hum = p.Character.Humanoid
                            
                            if (hrp.Position - lhrp.Position).Magnitude < 12 and hum.Health > 0 then
                                hum.Health = 0
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- ESP
local espConnection
Tabs.Visual:AddToggle("ESP", {
    Title = "ESP Highlight",
    Default = false,
    Callback = function(v)
        Flags.ESP = v
        
        -- Limpar cache
        for _, hl in pairs(ESPCache) do
            if hl then
                hl:Destroy()
            end
        end
        ESPCache = {}
        
        if espConnection then
            espConnection:Disconnect()
            espConnection = nil
        end
        
        if v then
            espConnection = RunService.RenderStepped:Connect(function()
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") then
                        if isEnemy(p.Character) then
                            if not ESPCache[p.Character] then
                                local hl = Instance.new("Highlight")
                                hl.FillColor = Color3.fromRGB(255, 50, 50)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.3
                                hl.OutlineTransparency = 0
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.Parent = p.Character
                                ESPCache[p.Character] = hl
                            end
                        else
                            -- Remover highlight se não for inimigo
                            if ESPCache[p.Character] then
                                ESPCache[p.Character]:Destroy()
                                ESPCache[p.Character] = nil
                            end
                        end
                    end
                end
                
                -- Limpar highlights de personagens que não existem mais
                for char, hl in pairs(ESPCache) do
                    if not char or not char.Parent then
                        hl:Destroy()
                        ESPCache[char] = nil
                    end
                end
            end)
        else
            -- Desativar: remover todos os highlights
            for _, hl in pairs(ESPCache) do
                if hl then
                    hl:Destroy()
                end
            end
            ESPCache = {}
        end
    end
})

-- HITBOX
local hitboxConnection
Tabs.Visual:AddToggle("Hitbox", {
    Title = "Hitbox Expander",
    Default = false,
    Callback = function(v)
        Flags.Hitbox = v
        
        if hitboxConnection then
            hitboxConnection:Disconnect()
            hitboxConnection = nil
        end
        
        if v then
            hitboxConnection = RunService.Heartbeat:Connect(function()
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and isEnemy(p.Character) then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.Size = Vector3.new(6, 6, 6)
                            hrp.CanCollide = false
                            hrp.Transparency = 0.7
                        end
                    end
                end
            end)
        else
            -- Resetar hitboxes quando desativado
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(2, 2, 1)
                        hrp.CanCollide = true
                        hrp.Transparency = 0
                    end
                end
            end
        end
    end
})

------------------------------------------------
-- MISC TAB
------------------------------------------------

-- TELEPORT TO PLAYER
local teleportDropdown = Tabs.Misc:AddDropdown("TeleportPlayer", {
    Title = "Teleport to Player",
    Values = {},
    Default = 1,
    Callback = function(value)
        local player = Players:FindFirstChild(value)
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
            Fluent:Notify({
                Title = "Teleport",
                Content = "Teleported to " .. value,
                Duration = 3
            })
        end
    end
})

-- Atualizar lista de jogadores
local function updatePlayerList()
    local playerNames = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            table.insert(playerNames, player.Name)
        end
    end
    teleportDropdown:SetValues(playerNames)
end

-- Atualizar quando jogadores entram/saem
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

-- NO FLY (Simples)
local flyConnection
Tabs.Misc:AddToggle("NoFly", {
    Title = "Simple Fly (N)",
    Default = false,
    Callback = function(v)
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        
        if v then
            local speed = 50
            local flying = false
            local bodyVelocity
            
            flyConnection = UIS.InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.N then
                    flying = not flying
                    
                    if flying and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                        bodyVelocity = Instance.new("BodyVelocity")
                        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                        bodyVelocity.Parent = LP.Character.HumanoidRootPart
                        
                        Fluent:Notify({
                            Title = "Fly",
                            Content = "Fly Enabled (WASD + Space/Shift)",
                            Duration = 3
                        })
                    elseif bodyVelocity then
                        bodyVelocity:Destroy()
                        bodyVelocity = nil
                    end
                end
                
                if flying and bodyVelocity then
                    local moveDirection = Vector3.new(0, 0, 0)
                    
                    if input.KeyCode == Enum.KeyCode.W then
                        moveDirection = moveDirection + Camera.CFrame.LookVector
                    elseif input.KeyCode == Enum.KeyCode.S then
                        moveDirection = moveDirection - Camera.CFrame.LookVector
                    elseif input.KeyCode == Enum.KeyCode.A then
                        moveDirection = moveDirection - Camera.CFrame.RightVector
                    elseif input.KeyCode == Enum.KeyCode.D then
                        moveDirection = moveDirection + Camera.CFrame.RightVector
                    elseif input.KeyCode == Enum.KeyCode.Space then
                        moveDirection = moveDirection + Vector3.new(0, 1, 0)
                    elseif input.KeyCode == Enum.KeyCode.LeftShift then
                        moveDirection = moveDirection - Vector3.new(0, 1, 0)
                    end
                    
                    if moveDirection.Magnitude > 0 then
                        bodyVelocity.Velocity = moveDirection.Unit * speed
                    end
                end
            end)
        end
    end
})

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

-- Forçar seleção da primeira tab
task.spawn(function()
    task.wait(0.1)
    Window:SelectTab(1)
end)

-- Notificação de carregamento
task.wait(0.5)
Fluent:Notify({
    Title = "Hypershoot Loaded",
    Content = "Menu opened with LeftControl",
    Duration = 4
})

-- Função para desativar tudo quando o script for desligado
local function cleanup()
    -- Desativar todas as conexões
    if aimbotConnection then aimbotConnection:Disconnect() end
    if killAuraConnection then killAuraConnection:Disconnect() end
    if espConnection then espConnection:Disconnect() end
    if hitboxConnection then hitboxConnection:Disconnect() end
    if flyConnection then flyConnection:Disconnect() end
    
    -- Limpar ESP
    for _, hl in pairs(ESPCache) do
        if hl then hl:Destroy() end
    end
    
    -- Resetar hitboxes
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.CanCollide = true
                hrp.Transparency = 0
            end
        end
    end
end

-- Limpar quando o jogador sai
game:GetService("UserInputService").WindowFocused:Connect(function()
    cleanup()
end)

-- Manter apenas uma instância do menu
if _G.HypershootWindow then
    _G.HypershootWindow:Destroy()
end
_G.HypershootWindow = Window

print("🎮 Hypershoot Loaded Successfully")
