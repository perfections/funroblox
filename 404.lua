-- Проверяем, что скрипт запускается в Roblox
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Получаем сервис игроков и локального игрока
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Ждем, пока загрузится персонаж и интерфейс игрока
if not player.Character then
    player.CharacterAdded:Wait()
end
local playerGui = player:WaitForChild("PlayerGui")

-- Создаем ScreenGui (основной контейнер для интерфейса)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Error404Gui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false -- Не сбрасывать GUI при респавне

-- Создаем затемняющий фон
local backdrop = Instance.new("Frame")
backdrop.Name = "Backdrop"
backdrop.Size = UDim2.new(1, 0, 1, 0) -- Полный экран
backdrop.Position = UDim2.new(0, 0, 0, 0)
backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Черный цвет
backdrop.BackgroundTransparency = 0.5 -- Полупрозрачный
backdrop.Parent = screenGui

-- Создаем текстовое сообщение "404 - Not Found"
local textLabel = Instance.new("TextLabel")
textLabel.Name = "ErrorMessage"
textLabel.Size = UDim2.new(0.5, 0, 0.2, 0)
textLabel.Position = UDim2.new(0.25, 0, 0.4, 0) -- Центр экрана
textLabel.BackgroundTransparency = 1 -- Прозрачный фон
textLabel.Text = "404 - Not Found"
textLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Красный текст
textLabel.TextScaled = true -- Автоматический размер текста
textLabel.Font = Enum.Font.SourceSansBold
textLabel.Parent = screenGui

-- Добавляем звуковой эффект
local sound = Instance.new("Sound")
sound.Name = "ErrorSound"
sound.SoundId = "rbxassetid://9120386436" -- ID звука ошибки (можно заменить)
sound.Volume = 0.5
sound.Parent = screenGui
sound:Play()

-- Анимация появления
for i = 1, 10 do
    backdrop.BackgroundTransparency = 0.5 - (i * 0.05) -- Плавное затемнение
    textLabel.TextTransparency = 1 - (i * 0.1) -- Плавное появление текста
    wait(0.05) -- Задержка для анимации
end

-- Держим сообщение 3 секунды, затем убираем
wait(3)

-- Анимация исчезновения
for i = 1, 10 do
    backdrop.BackgroundTransparency = backdrop.BackgroundTransparency + 0.05
    textLabel.TextTransparency = textLabel.TextTransparency + 0.1
    wait(0.05)
end

-- Удаляем GUI после завершения
screenGui:Destroy()
