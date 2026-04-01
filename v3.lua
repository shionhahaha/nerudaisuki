local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local vim = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local mouse = Players.LocalPlayer:GetMouse()

-- メインGUI
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "NerudaisukiClickerV2_5s"

-- キー認証用パネル
local KeyFrame = Instance.new("Frame", ScreenGui)
KeyFrame.Size = UDim2.new(0, 250, 0, 100)
KeyFrame.Position = UDim2.new(0.5, -125, 0.5, -50)
KeyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
KeyFrame.Active = true
KeyFrame.Draggable = true

local KeyInput = Instance.new("TextBox", KeyFrame)
KeyInput.Size = UDim2.new(0, 200, 0, 30)
KeyInput.Position = UDim2.new(0, 25, 0, 20)
KeyInput.PlaceholderText = "Enter Key Here..."
KeyInput.Text = ""
KeyInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
KeyInput.TextColor3 = Color3.new(1, 1, 1)

local KeySubmit = Instance.new("TextButton", KeyFrame)
KeySubmit.Size = UDim2.new(0, 100, 0, 30)
KeySubmit.Position = UDim2.new(0, 75, 0, 60)
KeySubmit.Text = "Check Key"
KeySubmit.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
KeySubmit.TextColor3 = Color3.new(1, 1, 1)

-- 操作パネル
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 200)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true

local function styleBtn(btn, pos, text)
    btn.Size = UDim2.new(0, 200, 0, 30)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
end

local ToggleBtn = Instance.new("TextButton", MainFrame)
local SetPosBtn = Instance.new("TextButton", MainFrame)
local StatusLabel = Instance.new("TextLabel", MainFrame)

styleBtn(ToggleBtn, UDim2.new(0, 10, 0, 10), "ON / OFF")
styleBtn(SetPosBtn, UDim2.new(0, 10, 0, 45), "座標を設定 (Click)")

-- スライダー部分
local SliderFrame = Instance.new("Frame", MainFrame)
SliderFrame.Size = UDim2.new(0, 200, 0, 20)
SliderFrame.Position = UDim2.new(0, 10, 0, 95)
SliderFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

local SliderButton = Instance.new("TextButton", SliderFrame)
SliderButton.Size = UDim2.new(0, 20, 0, 20)
SliderButton.Position = UDim2.new(0, 0, 0, 0) -- 初期位置
SliderButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
SliderButton.Text = ""

local SpeedLabel = Instance.new("TextLabel", MainFrame)
SpeedLabel.Size = UDim2.new(0, 200, 0, 20)
SpeedLabel.Position = UDim2.new(0, 10, 0, 120)
SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "間隔: 0.10秒"

StatusLabel.Size = UDim2.new(0, 200, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 160)
StatusLabel.Text = "停止中"
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.BackgroundTransparency = 1

-- 変数
local targetX, targetY = 0, 0
local clicking = false
local settingPos = false
local clickWait = 0.1
local maxWait = 5.0 -- ★ 最大値を5秒に変更
local correctKey = "nerudaisuki"

-- スライダーのロジック
local dragging = false
SliderButton.MouseButton1Down:Connect(function() dragging = true end)
UserInputService.InputEnded:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end 
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = math.clamp((input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
        SliderButton.Position = UDim2.new(pos, -10, 0, 0)
        
        -- ★ 0.01秒 ～ 5.0秒 の間で調整
        clickWait = math.max(0.01, pos * maxWait)
        SpeedLabel.Text = string.format("間隔: %.2f秒", clickWait)
    end
end)

-- キー認証
KeySubmit.MouseButton1Click:Connect(function()
    if KeyInput.Text == correctKey then
        KeyFrame.Visible = false
        MainFrame.Visible = true
    else
        KeyInput.Text = "Wrong Key!"
        task.wait(1)
        KeyInput.Text = ""
    end
end)

-- 座標設定
SetPosBtn.MouseButton1Click:Connect(function()
    settingPos = true
    StatusLabel.Text = "画面をクリックして指定..."
end)

mouse.Button1Down:Connect(function()
    if settingPos then
        targetX, targetY = mouse.X, mouse.Y
        settingPos = false
        StatusLabel.Text = "座標固定: " .. targetX .. ", " .. targetY
    end
end)

-- オートクリック
ToggleBtn.MouseButton1Click:Connect(function()
    clicking = not clicking
    ToggleBtn.BackgroundColor3 = clicking and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    StatusLabel.Text = clicking and "実行中" or "停止中"
    
    if clicking then
        task.spawn(function()
            while clicking do
                vim:SendMouseButtonEvent(targetX, targetY, 0, true, game, 0)
                task.wait(0.01) -- クリックの押し込み時間
                vim:SendMouseButtonEvent(targetX, targetY, 0, false, game, 0)
                task.wait(clickWait)
            end
        end)
    end
end)
