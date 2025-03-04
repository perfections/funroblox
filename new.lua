-- Защита от преждевременного выполнения
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Сервисы Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Переменные состояния
local ESPActive = false
local AimbotAutoActive = false -- Автоматический аимбот по X
local AimbotHoldEnabled = false -- Включение режима зажима по V
local AimbotHoldActive = false -- Активность зажима правой кнопки
local AutoFireActive = false
local AimbotSmoothness = 0.8
local ScriptActive = true

-- Бинды по умолчанию
local Keybinds = {
    ESP = Enum.KeyCode.F1,
    AimbotAuto = Enum.KeyCode.X, -- Автоматический аимбот
    AimbotHold = Enum.KeyCode.V, -- Включение режима зажима
    AutoFire = Enum.KeyCode.Z,
    Menu = Enum.KeyCode.RightShift,
    Chat = Enum.KeyCode.T -- Клавиша для отправки сообщения с обходом
}

-- Анимация логотипа при запуске
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Error404Gui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local bgFrame = Instance.new("Frame")
bgFrame.Name = "GlitchBG"
bgFrame.Size = UDim2.new(1, 0, 1, 0)
bgFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bgFrame.BackgroundTransparency = 0.8
bgFrame.Parent = screenGui

local text404 = Instance.new("TextLabel")
text404.Name = "Text404"
text404.Size = UDim2.new(0.3, 0, 0.15, 0)
text404.Position = UDim2.new(0.35, 0, 0.4, 0)
text404.BackgroundTransparency = 1
text404.Text = "404"
text404.TextColor3 = Color3.fromRGB(255, 0, 0)
text404.TextScaled = true
text404.Font = Enum.Font.Code
text404.TextTransparency = 1
text404.Parent = screenGui

local textActivate = Instance.new("TextLabel")
textActivate.Name = "TextActivate"
textActivate.Size = UDim2.new(0.3, 0, 0.1, 0)
textActivate.Position = UDim2.new(0.35, 0, 0.55, 0)
textActivate.BackgroundTransparency = 1
textActivate.Text = "Activate"
textActivate.TextColor3 = Color3.fromRGB(0, 191, 255)
textActivate.TextScaled = true
textActivate.Font = Enum.Font.Code
textActivate.TextTransparency = 1
textActivate.Parent = screenGui

local glitchSound = Instance.new("Sound")
glitchSound.Name = "GlitchSound"
glitchSound.SoundId = "rbxassetid://1843529371"
glitchSound.Volume = 0.5
glitchSound.Parent = screenGui
glitchSound:Play()

for i = 1, 10 do
    text404.TextTransparency = 1 - (i / 10)
    text404.TextColor3 = (i % 2 == 0) and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 100, 100)
    text404.Position = UDim2.new(0.35 + (math.random(-5, 5) / 1000), 0, 0.4 + (math.random(-5, 5) / 1000), 0)
    wait(0.05)
end

for i = 1, 15 do
    textActivate.TextTransparency = 1 - (i / 15)
    textActivate.Position = UDim2.new(0.35 + (math.random(-10, 10) / 1000), 0, 0.55 + (math.random(-10, 10) / 1000), 0)
    if i % 3 == 0 then
        textActivate.TextTransparency = 0.3
    end
    wait(0.04)
end

for i = 1, 10 do
    text404.TextTransparency = i / 10
    textActivate.TextTransparency = i / 10
    text404.Size = UDim2.new(0.3 + (i / 100), 0, 0.15 + (i / 100), 0)
    textActivate.Size = UDim2.new(0.3 + (i / 100), 0, 0.1 + (i / 100), 0)
    bgFrame.BackgroundTransparency = 0.8 + (i / 50)
    wait(0.05)
end

screenGui:Destroy()

-- GUI меню
local MenuGui = Instance.new("ScreenGui")
MenuGui.Name = "404Menu"
MenuGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
MenuGui.ResetOnSpawn = false
MenuGui.Enabled = false

local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0.3, 0, 0.5, 0)
MenuFrame.Position = UDim2.new(0.35, 0, 0.25, 0)
MenuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MenuFrame.BorderSizePixel = 0
MenuFrame.Parent = MenuGui

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Parent = MenuFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.1, 0)
Title.BackgroundTransparency = 1
Title.Text = "404 Rivals Cheat"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.TextScaled = true
Title.Font = Enum.Font.Code
Title.Parent = MenuFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 0.9, 0)
ContentFrame.Position = UDim2.new(0, 0, 0.1, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MenuFrame

local function CreateSlider(name, minVal, maxVal, defaultVal, yPos, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0.15, 0)
    frame.Position = UDim2.new(0.05, 0, yPos, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = ContentFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. string.format("%.1f", defaultVal)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSans
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0.3, 0, 0.2, 0)
    bar.Position = UDim2.new(0.65, 0, 0.4, 0)
    bar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    bar.Parent = frame

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0.1, 0, 1.5, 0)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, -0.25, 0)
    knob.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
    knob.Text = ""
    knob.Parent = bar

    local dragging = false
    knob.MouseButton1Down:Connect(function()
        dragging = true
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation()
            local framePos = bar.AbsolutePosition
            local frameSize = bar.AbsoluteSize.X
            local relativeX = math.clamp((mousePos.X - framePos.X) / frameSize, 0, 1)
            knob.Position = UDim2.new(relativeX, 0, -0.25, 0)
            local value = minVal + (relativeX * (maxVal - minVal))
            label.Text = name .. ": " .. string.format("%.1f", value)
            if name == "Aimbot Smoothness" then
                AimbotSmoothness = value
            elseif name == "ESP Transparency" then
                ESPActive = value > 0
                UpdateESP()
            end
            callback(value)
        end
    end)
end

local function CreateToggle(name, yPos, state, toggleFunc)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0.15, 0)
    frame.Position = UDim2.new(0.05, 0, yPos, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = ContentFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSans
    label.Parent = frame

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0.2, 0, 0.8, 0)
    switch.Position = UDim2.new(0.75, 0, 0.1, 0)
    switch.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    switch.Text = state and "ON" or "OFF"
    switch.TextColor3 = Color3.fromRGB(255, 255, 255)
    switch.TextScaled = true
    switch.Font = Enum.Font.SourceSans
    switch.Parent = frame

    switch.MouseButton1Click:Connect(function()
        state = not state
        switch.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        switch.Text = state and "ON" or "OFF"
        toggleFunc(state)
    end)
end

-- Настройка интерфейса
CreateToggle("AutoFire", 0, AutoFireActive, function(state) AutoFireActive = state end)
CreateSlider("ESP Transparency", 0, 1, ESPActive and 0.5 or 0, 0.15, function(value) ESPActive = value > 0; UpdateESP() end)
CreateSlider("Aimbot Smoothness", 0.1, 1, AimbotSmoothness, 0.3, function(value) AimbotSmoothness = value end)

local Contacts = Instance.new("TextLabel")
Contacts.Size = UDim2.new(1, 0, 0.1, 0)
Contacts.Position = UDim2.new(0, 0, 0.9, 0)
Contacts.BackgroundTransparency = 1
Contacts.Text = "TG: <font color=\"rgb(0,191,255)\"><u>t.me/psycheqow</u></font> | DS: <font color=\"rgb(0,191,255)\"><u>psycheqow</u></font>"
Contacts.TextColor3 = Color3.fromRGB(255, 255, 255)
Contacts.TextScaled = true
Contacts.Font = Enum.Font.SourceSans
Contacts.RichText = true
Contacts.Parent = MenuFrame

-- Функции
local function AddESP(player)
    if player == LocalPlayer or not player.Character or not ESPActive then return end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart or humanoid.Health <= 0 then return end

    if rootPart:FindFirstChild("ESPBox") then rootPart.ESPBox:Destroy() end
    if rootPart:FindFirstChild("HealthBar") then rootPart.HealthBar:Destroy() end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESPBox"
    box.Parent = rootPart
    box.Size = Vector3.new(4, 6, 4)
    box.Color3 = Color3.fromRGB(0, 255, 0)
    box.Transparency = 0.5
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = rootPart

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HealthBar"
    billboard.Parent = rootPart
    billboard.Size = UDim2.new(2, 0, 0.5, 0)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true

    local healthFrame = Instance.new("Frame")
    healthFrame.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
    healthFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthFrame.Parent = billboard

    humanoid.HealthChanged:Connect(function(newHealth)
        healthFrame.Size = UDim2.new(newHealth / humanoid.MaxHealth, 0, 1, 0)
        if newHealth <= 0 then
            box:Destroy()
            billboard:Destroy()
        end
    end)
end

local function RemoveESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if player.Character.HumanoidRootPart:FindFirstChild("ESPBox") then
                player.Character.HumanoidRootPart.ESPBox:Destroy()
            end
            if player.Character.HumanoidRootPart:FindFirstChild("HealthBar") then
                player.Character.HumanoidRootPart.HealthBar:Destroy()
            end
        end
    end
end

local function UpdateESP()
    RemoveESP()
    if ESPActive then
        for _, player in pairs(Players:GetPlayers()) do
            spawn(function() AddESP(player) end)
        end
    end
end

local function FindClosestPlayer()
    local closest, minDistance = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local playerPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not playerPos then
        print("No player position found")
        return nil
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health > 0 then
                local headPos = player.Character.Head.Position
                local distance = (headPos - playerPos).Magnitude
                -- Ограничение радиуса для большой карты (1000 студий)
                if distance < 1000 then
                    local screenPos = Camera:WorldToViewportPoint(headPos)
                    if screenPos.Z > 0 then
                        local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if screenDistance < minDistance and screenDistance < 300 then
                            minDistance = screenDistance
                            closest = player
                            print("Target found: " .. player.Name .. " at distance " .. screenDistance)
                        end
                    end
                end
            end
        end
    end
    if not closest then
        print("No valid target found within radius")
    end
    return closest
end

-- Чтение уведомлений о скинах (оставлено для мониторинга)
spawn(function()
    while ScriptActive do
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, child in pairs(gui:GetDescendants()) do
                    if child:IsA("TextLabel") and (child.Text:lower():find("skin") or child.Text:lower():find("reward")) then
                        print("Новое уведомление:", child.Text)
                    end
                end
            end
        end
        wait(5)
    end
end)

-- Обход фильтра чата
local function SendChatMessage(message)
    local badWords = {"fuck", "shit", "bitch", "ass", "damn", "hell"} -- Пример списка
    local replacements = {"xKqP", "zXy7", "pLmN", "aBcD", "jKlM", "hIjK"} -- Случайные замены
    local newMessage = message
    for i, word in pairs(badWords) do
        newMessage = newMessage:gsub(word, replacements[i] or "xXx")
    end
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(newMessage, "All")
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not ScriptActive or gameProcessed then return end
    if input.KeyCode == Keybinds.Chat and UserInputService:GetFocusedTextBox() == nil then
        local msg = game:GetService("Chat"):Chat(LocalPlayer, "Type your message (T to send)", Enum.ChatColor.Blue)
        local userInputService = game:GetService("UserInputService")
        local textBox = Instance.new("TextBox")
        textBox.Size = UDim2.new(0, 200, 0, 50)
        textBox.Position = UDim2.new(0.5, -100, 0.5, -25)
        textBox.Text = ""
        textBox.Parent = playerGui
        textBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                SendChatMessage(textBox.Text)
                textBox:Destroy()
            end
        end)
        userInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.T then
                SendChatMessage(textBox.Text)
                textBox:Destroy()
            end
        end)
    elseif input.KeyCode == Keybinds.Menu then
        MenuGui.Enabled = not MenuGui.Enabled
    elseif input.KeyCode == Keybinds.ESP then
        ESPActive = not ESPActive
        UpdateESP()
    elseif input.KeyCode == Keybinds.AimbotAuto then
        AimbotAutoActive = not AimbotAutoActive
        print("AimbotAutoActive set to: " .. tostring(AimbotAutoActive))
    elseif input.KeyCode == Keybinds.AimbotHold then
        AimbotHoldEnabled = not AimbotHoldEnabled
        if not AimbotHoldEnabled then AimbotHoldActive = false end
        print("AimbotHoldEnabled set to: " .. tostring(AimbotHoldEnabled))
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 and AimbotHoldEnabled then
        AimbotHoldActive = true
        print("AimbotHoldActive set to: true")
    elseif input.KeyCode == Keybinds.AutoFire then
        AutoFireActive = not AutoFireActive
        print("AutoFireActive set to: " .. tostring(AutoFireActive))
    elseif input.KeyCode == Enum.KeyCode.Delete then
        ScriptActive = false
        RemoveESP()
        MenuGui:Destroy()
        print("404 Script Unloaded")
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotHoldActive = false
        print("AimbotHoldActive set to: false")
    end
end)

-- Перезапуск чита при смене раунда/лобби
LocalPlayer.CharacterAdded:Connect(function()
    if ScriptActive then
        RemoveESP()
        AimbotAutoActive = false
        AimbotHoldEnabled = false
        AimbotHoldActive = false
        AutoFireActive = false
        wait(2)
        UpdateESP()
        print("Скрипт перезапущен в новом раунде/лобби")
    end
end)

-- Логика чита
RunService.RenderStepped:Connect(function()
    if not ScriptActive or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        print("Script paused: No character or HumanoidRootPart")
        return
    end
    
    if ESPActive then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not player.Character:FindFirstChild("ESPBox") then
                AddESP(player)
            end
        end
    end
    
    if AimbotAutoActive or (AimbotHoldEnabled and AimbotHoldActive) then
        local target = FindClosestPlayer()
        if target then
            local headPos = Camera:WorldToViewportPoint(target.Character.Head.Position)
            local mousePos = UserInputService:GetMouseLocation()
            local delta = Vector2.new(headPos.X, headPos.Y) - mousePos
            mousemoverel(delta.X * AimbotSmoothness, delta.Y * AimbotSmoothness)
            print("Aiming at: " .. target.Name)
        else
            print("No target found")
        end
    end
    
    if AutoFireActive then
        local target = FindClosestPlayer()
        if target then
            mouse1press()
            wait(0.05)
            mouse1release()
            print("Firing at: " .. target.Name)
        else
            print("No target for AutoFire")
        end
    end
end)

-- Обновление после спавна
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESPActive then
            wait(0.5)
            AddESP(player)
        end
    end)
end)
