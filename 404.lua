-- Упрощённый интерфейс (автономный, без внешних зависимостей)
local SimpleUI = {}
function SimpleUI:CreateWindow(title)
    local window = {Visible = false}
    print("Интерфейс " .. title .. " создан! Используйте Delete для переключения.")
    return {
        MakeTab = function(name)
            return {
                AddToggle = function(options)
                    local toggled = false
                    print("Переключатель '" .. options.Name .. "' добавлен (по умолчанию: " .. tostring(options.Default) .. ")")
                    return {
                        Set = function(value)
                            toggled = value
                            print(options.Name .. " установлен на: " .. tostring(toggled))
                            if options.Callback then
                                options.Callback(value)
                            end
                        end,
                        Get = function() return toggled end
                    }
                end
            }
        end,
        Toggle = function()
            window.Visible = not window.Visible
            print("Интерфейс видим: " .. tostring(window.Visible))
        end,
        Enable = function() window.Visible = true end,
        Disable = function() window.Visible = false end
    }
end
function SimpleUI:MakeNotification(title, content, time)
    print("Уведомление: " .. title .. " - " .. content .. " (длительность: " .. time .. " сек)")
end

-- Инициализация окна
local Window = SimpleUI:CreateWindow("RIVALS - v3")

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Переменные
local ESPEnabled = false
local AimbotEnabled = false
local IsAiming = false
local MenuVisible = false

-- Переключение меню клавишей Delete
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        MenuVisible = not MenuVisible
        Window:Toggle()
    end
end)

-- Уведомление при запуске
SimpleUI:MakeNotification("RIVALS v3", "Скрипт успешно загружен!\nНажмите Delete для открытия меню.", 5)

-- Вкладка ESP
local ESPTab = Window:MakeTab("ESP")
local ESPToggle = ESPTab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(value)
        ESPEnabled = value
        if ESPEnabled then
            for _, player in pairs(Players:GetPlayers()) do
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
            Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function()
                    if ESPEnabled and player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
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

-- Вкладка Aimbot
local AimbotTab = Window:MakeTab("Aimbot")
local AimbotToggle = AimbotTab:AddToggle({
    Name = "Enable Aimbot (RMB)",
    Default = false,
    Callback = function(value)
        AimbotEnabled = value
    end
})

-- Функция поиска ближайшего игрока
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

-- Логика Aimbot
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

-- Главный цикл
RunService.RenderStepped:Connect(function()
    if AimbotEnabled and IsAiming and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.Head.Position)
        end
    end
end)

-- Инициализация (скрыто)
Window:Disable()