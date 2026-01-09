--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

--// EXECUTOR DETECTION
local executor =
    identifyexecutor and identifyexecutor()
    or getexecutorname and getexecutorname()
    or "Xeno / Unknown"

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HypershootUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

--// MAIN FRAME
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 520, 0, 340)
Main.Position = UDim2.new(0.5, -260, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(0,0,0)
Main.BackgroundTransparency = 0.4
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

--// TOP BAR
local Top = Instance.new("Frame", Main)
Top.Size = UDim2.new(1,0,0,50)
Top.BackgroundTransparency = 1

--// PROFILE IMAGE
local Thumb = Instance.new("ImageLabel", Top)
Thumb.Size = UDim2.new(0,36,0,36)
Thumb.Position = UDim2.new(0,10,0,7)
Thumb.BackgroundTransparency = 1
Thumb.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1,0)

--// NAME
local NameLabel = Instance.new("TextLabel", Top)
NameLabel.Text = LocalPlayer.Name
NameLabel.Position = UDim2.new(0,55,0,6)
NameLabel.Size = UDim2.new(0,200,0,20)
NameLabel.TextColor3 = Color3.new(1,1,1)
NameLabel.BackgroundTransparency = 1
NameLabel.Font = Enum.Font.GothamBold
NameLabel.TextSize = 16
NameLabel.TextXAlignment = Left

--// EXECUTOR LABEL
local ExecLabel = Instance.new("TextLabel", Top)
ExecLabel.Text = "Executor: "..executor
ExecLabel.Position = UDim2.new(0,55,0,26)
ExecLabel.Size = UDim2.new(0,300,0,16)
ExecLabel.TextColor3 = Color3.fromRGB(180,180,180)
ExecLabel.BackgroundTransparency = 1
ExecLabel.Font = Enum.Font.Gotham
ExecLabel.TextSize = 13
ExecLabel.TextXAlignment = Left

--// TAB BAR
local Tabs = Instance.new("Frame", Main)
Tabs.Position = UDim2.new(0,0,0,55)
Tabs.Size = UDim2.new(0,120,1,-55)
Tabs.BackgroundTransparency = 1

--// CONTENT
local Pages = Instance.new("Frame", Main)
Pages.Position = UDim2.new(0,130,0,55)
Pages.Size = UDim2.new(1,-140,1,-65)
Pages.BackgroundTransparency = 1

--// TAB SYSTEM
local TabButtons = {}
local PagesList = {}

local function createTab(name)
    local btn = Instance.new("TextButton", Tabs)
    btn.Size = UDim2.new(1,-10,0,36)
    btn.Position = UDim2.new(0,5,0,#TabButtons*40)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(20,20,20)
    btn.BackgroundTransparency = 0.3
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local page = Instance.new("Frame", Pages)
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = false
    page.BackgroundTransparency = 1

    btn.MouseButton1Click:Connect(function()
        for _,p in pairs(PagesList) do p.Visible = false end
        page.Visible = true
    end)

    table.insert(TabButtons, btn)
    table.insert(PagesList, page)

    return page
end

--// CREATE TABS
local Combat = createTab("Combat")
local Visual = createTab("Visual")
local Player = createTab("Player")
local Misc = createTab("Misc")

PagesList[1].Visible = true

--// TOGGLE CREATOR
local function createToggle(parent, text, y, callback)
    local toggle = Instance.new("TextButton", parent)
    toggle.Size = UDim2.new(0,200,0,30)
    toggle.Position = UDim2.new(0,10,0,y)
    toggle.BackgroundColor3 = Color3.fromRGB(25,25,25)
    toggle.Text = "[ OFF ] "..text
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.Font = Enum.Font.Gotham
    toggle.TextSize = 14
    toggle.BorderSizePixel = 0
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,6)

    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = (state and "[ ON ] " or "[ OFF ] ")..text
        callback(state)
    end)
end

--// EXAMPLE TOGGLES
createToggle(Combat, "Aimbot", 10, function(v) print("Aimbot:",v) end)
createToggle(Combat, "AimSilent", 50, function(v) print("AimSilent:",v) end)

createToggle(Visual, "ESP", 10, functio
