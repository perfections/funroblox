-- Сервисы Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera

-- Переменные состояния
local ESPActive = false
local AimbotActive = false
local Aiming = false

-- Функция для создания ESP
local function AddESP(player)
    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESPBox"
        box.Parent = player.Character.HumanoidRootPart
        box.Size = Vector3.new(4, 6, 4)
        box.Color3 = Color3.new(1, 0, 0)
        box.Transparency = 0.6
        box.AlwaysOnTop = true
        box.Adornee = player.Character.HumanoidRootPart
    end
end

-- Функция для удаления ESP
local function RemoveESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character.HumanoidRootPart:FindFirstChild("ESPBox") then
            player.Character.HumanoidRootPart.ESPBox:Destroy()
        end
    end
end

-- Переключение ESP
local function ToggleESP(state)
    ESPActive = state
    if ESPActive then
        for _, player in pairs(Players:GetPlayers()) do
            spawn(function() AddESP(player) end)
        end
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                if ESPActive then AddESP(player) end
            end)
        end)
    else
        RemoveESP()
    end
    print("ESP: " .. (ESPActive and "ВКЛ" or "ВЫКЛ"))
end

-- Функция поиска ближайшего игрока
local function FindClosestPlayer()
    local closest = nil
    local minDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local headPos = Camera:WorldToViewportPoint(player.Character.Head.Position)
            local distance = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
            if distance < minDistance then
                minDistance = distance
                closest = player
            end
        end
    end
    return closest
end

-- Переключение Aimbot
local function ToggleAimbot(state)
    AimbotActive = state
    print("Aimbot: " .. (AimbotActive and "ВКЛ" or "ВЫКЛ"))
end

-- Обработка ввода
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and AimbotActive then
        Aiming = true
    elseif input.KeyCode == Enum.KeyCode.F1 then
        ToggleESP(not ESPActive)
    elseif input.KeyCode == Enum.KeyCode.F2 then
        ToggleAimbot(not AimbotActive)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aiming = false
    end
end)

-- Проверка готовности игры
local function WaitForGameReady()
    local maxWait = 15 -- Увеличено до 15 секунд для учёта очереди
    local elapsed = 0
    print("Ожидание загрузки игры (максимум " .. maxWait .. " сек)...")
    repeat
        wait(1)
        elapsed = elapsed + 1
    until game:IsLoaded() or elapsed >= maxWait
    if game:IsLoaded() then
        print("Игра загружена, скрипт активен!")
        RunService.RenderStepped:Connect(function()
            if AimbotActive and Aiming and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local target = FindClosestPlayer()
                if target and target.Character and target.Character:FindFirstChild("Head") then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
                end
            end
        end)
    else
        print("Игра не загрузилась в течение " .. maxWait .. " секунд. Перезапустите и попробуйте снова.")
    end
end

-- Запуск
WaitForGameReady()