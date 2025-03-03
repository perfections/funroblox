-- Load Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables
local ESPEnabled = false
local AimbotEnabled = false
local IsAiming = false
local MenuVisible = false

-- Create Window (hidden by default)
local Window = OrionLib:MakeWindow({
    Name = "RIVALS - Lite",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "RivalsLiteConfig",
    IntroEnabled = false
})

-- Toggle Menu with Delete
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        MenuVisible = not MenuVisible
        if MenuVisible then
            Window:Enable()
        else
            Window:Disable()
        end
    end
end)

-- Success Notification (Centered and Prominent)
OrionLib:MakeNotification({
    Name = "RIVALS Lite",
    Content = "Script Successfully Loaded!\nPress Delete to Toggle Menu",
    Time = 5,
    -- Note: Orion doesn't natively support "center screen" positioning,
    -- but this will be more prominent with \n for multi-line
})

-- Tab 1: ESP
local ESPTab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Simple ESP with Boxes
local function CreateESP(player)
    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local Box = Instance.new("BoxHandleAdornment")
        Box.Name = "ESPBox"
        Box.Parent = player.Character.HumanoidRootPart
        Box.Size = Vector3.new(5, 7, 5)
        Box.Color3 = Color3.fromRGB(255, 0, 0)
        Box.Transparency = 0.7
        Box.AlwaysOnTop = true
        Box.Adornee = player.Character.HumanoidRootPart
        Box.ZIndex = 10
    end
end

ESPTab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
        if ESPEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    CreateESP(player)
                end
            end
            Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function()
                    if ESPEnabled then
                        CreateESP(player)
                    end
                end)
            end)
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character.HumanoidRootPart:FindFirstChild("ESPBox") then
                    player.Character.HumanoidRootPart.ESPBox:Destroy()
                end
            end
        end
    end
})

-- Tab 2: Aimbot
local AimbotTab = Window:MakeTab({
    Name = "Aimbot",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Closest Player Function
local function GetClosestPlayer()
    local ClosestPlayer = nil
    local ShortestDistance = math.huge
    local MousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local HeadPos = Camera:WorldToViewportPoint(player.Character.Head.Position)
            local Distance = (Vector2.new(HeadPos.X, HeadPos.Y) - Vector2.new(MousePos.X, MousePos.Y)).Magnitude
            if Distance < ShortestDistance then
                ShortestDistance = Distance
                ClosestPlayer = player
            end
        end
    end
    return ClosestPlayer
end

AimbotTab:AddToggle({
    Name = "Enable Aimbot (RMB)",
    Default = false,
    Callback = function(Value)
        AimbotEnabled = Value
    end
})

-- RMB Aimbot Logic
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and AimbotEnabled then
        IsAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsAiming = false
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if AimbotEnabled and IsAiming and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.Head.Position)
        end
    end
end)

-- Initialize (hidden)
OrionLib:Init()
Window:Disable()