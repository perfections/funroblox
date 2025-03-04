-- Защита от преждевременного выполнения
if not game:IsLoaded() then
    local success, err = pcall(function()
        game.Loaded:Wait()
    end)
    if not success then
        warn("Ошибка загрузки игры: " .. err)
        return
    end
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
local AimbotActive = false
local AutoFireActive = false
local ScriptActive = true

-- Ждем PlayerGui
local playerGui
local success, err = pcall(function()
    playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
end)
if not success or not playerGui then
    warn("Не удалось получить PlayerGui: " .. (err or "время ожидания истекло"))
    return
end

-- Анимация "404 Activate"
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

-- Функция проверки, является ли игрок врагом
local function IsEnemy(player)
    if player == LocalPlayer then
        print(player.Name, "это я, не враг")
        return false
    end
    -- В Rivals команды могут не использовать Team явно, поэтому считаем всех врагами по умолчанию
    -- До уточнения точной системы команд в игре
    print(player.Name, "Считаем врагом (Rivals: нет точных данных о командах)")
    return true
end

-- Улучшенный ESP (в стиле CS:GO + здоровье)
local function AddESP(player)
    if not player.Character then
        print(player.Name, "Нет персонажа")
        return
    end
    if not player.Character:FindFirstChild("HumanoidRootPart") then
        print(player.Name, "Нет HumanoidRootPart")
        return
    end
    if not player.Character:FindFirstChild("Humanoid") then
        print(player.Name, "Нет Humanoid")
        return
    end

    local humanoid = player.Character.Humanoid
    local rootPart = player.Character.HumanoidRootPart

    if humanoid.Health <= 0 then
        print(player.Name, "Мёртв, пропускаем")
        return
    end

    if not IsEnemy(player) then
        print(player.Name, "Союзник, пропускаем")
        return
    end

    -- Удаляем старый ESP
    if rootPart:FindFirstChild("ESPBox") then
        rootPart.ESPBox:Destroy()
    end
    if rootPart:FindFirstChild("HealthBar") then
        rootPart.HealthBar:Destroy()
    end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESPBox"
    box.Parent = rootPart
    box.Size = Vector3.new(4, 6, 4)
    box.Color3 = Color3.fromRGB(0, 255, 0) -- Только живые
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
            print(player.Name, "Умер, ESP удалён")
        end
    end)
    print("ESP добавлен для", player.Name)
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
    print("ESP удалён для всех")
end

local function ToggleESP(state)
    ESPActive = state
    print("ESP:", ESPActive and "ВКЛ" or "ВЫКЛ")
    if ESPActive then
        RemoveESP()
        for _, player in pairs(Players:GetPlayers()) do
            spawn(function() AddESP(player) end)
        end
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                if ESPActive then
                    wait(0.5) -- Задержка для загрузки
                    AddESP(player)
                end
            end)
        end)
    else
        RemoveESP()
    end
end

-- Проверка активной катаны
local function HasActiveKatana(player)
    if player and player.Character then
        for _, child in pairs(player.Character:GetChildren()) do
            if child:IsA("Tool") and child:FindFirstChild("StarEffect") then
                return true
            end
        end
    end
    return false
end

-- Проверка линии видимости
local function CanHitTarget(target)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or not target or not target.Character or not target.Character:FindFirstChild("Head") then
        return false
    end
    local origin = LocalPlayer.Character.HumanoidRootPart.Position
    local targetPos = target.Character.Head.Position
    local ray = Ray.new(origin, (targetPos - origin).Unit * 300)
    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, target.Character})
    return hit == nil or hit:IsDescendantOf(target.Character)
end

-- Поиск ближайшего живого противника
local function FindClosestPlayer()
    local closest = nil
    local minDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    for _, player in pairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health > 0 and not HasActiveKatana(player) then
                local headPos = Camera:WorldToViewportPoint(player.Character.Head.Position)
                if headPos.Z > 0 then
                    local distance = (Vector2.new(headPos.X, headPos.Y) - mousePos).Magnitude
                    if distance < minDistance and distance < 300 then
                        minDistance = distance
                        closest = player
                        print("Найден живой враг:", player.Name)
                    end
                end
            else
                print(player.Name, "Мёртв или с катаной, пропускаем")
            end
        end
    end
    if not closest then print("Живой враг не найден") end
    return closest
end

local function ToggleAimbot(state)
    AimbotActive = state
    print("Silent Aimbot:", AimbotActive and "ВКЛ" or "ВЫКЛ")
end

local function ToggleAutoFire(state)
    AutoFireActive = state
    print("AutoFire:", AutoFireActive and "ВКЛ" or "ВЫКЛ")
end

-- Обработка ввода
UserInputService.InputBegan:Connect(function(input)
    if not ScriptActive then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        ToggleESP(not ESPActive)
    elseif input.KeyCode == Enum.KeyCode.X then
        ToggleAimbot(not AimbotActive)
    elseif input.KeyCode == Enum.KeyCode.Z then
        ToggleAutoFire(not AutoFireActive)
    elseif input.KeyCode == Enum.KeyCode.Delete then
        ScriptActive = false
        ToggleESP(false)
        ToggleAimbot(false)
        ToggleAutoFire(false)
        RemoveESP()
        print("404 Script Unloaded")
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        local target = FindClosestPlayer()
        if AimbotActive and target and HasActiveKatana(target) then
            return -- Блокировка стрельбы
        end
    end
end)

-- Silent Aimbot и AutoFire
RunService.RenderStepped:Connect(function()
    if not ScriptActive or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    if AimbotActive then
        local target = FindClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPos = Camera:WorldToViewportPoint(target.Character.Head.Position)
            local mousePos = UserInputService:GetMouseLocation()
            local delta = Vector2.new(headPos.X, headPos.Y) - mousePos
            local smoothFactor = 0.8
            mousemoverel(delta.X * smoothFactor, delta.Y * smoothFactor)
        end
    end
    
    if AutoFireActive then
        local target = FindClosestPlayer()
        if target and not HasActiveKatana(target) and CanHitTarget(target) then
            mouse1press()
            wait(0.05)
            mouse1release()
        end
    end
end)

-- Обновление ESP после каждого раунда
LocalPlayer.CharacterAdded:Connect(function()
    if ESPActive then
        RemoveESP()
        wait(2) -- Увеличенная задержка для полной загрузки
        for _, player in pairs(Players:GetPlayers()) do
            spawn(function() AddESP(player) end)
        end
    end
end)

-- Дополнительное обновление ESP для новых игроков
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESPActive then
            wait(0.5)
            AddESP(player)
        end
    end)
end)
