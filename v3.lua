local Library = {} -- 簡易的なUI構築
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Frame = Instance.new("Frame", ScreenGui)
local ToggleBtn = Instance.new("TextButton", Frame)
local SetPosBtn = Instance.new("TextButton", Frame)
local StatusLabel = Instance.new("TextLabel", Frame)

-- UIの見た目設定
Frame.Size = UDim2.new(0, 200, 0, 120)
Frame.Position = UDim2.new(0.5, -100, 0.5, -60)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Active = true
Frame.Draggable = true

local function styleBtn(btn, pos, text)
    btn.Size = UDim2.new(0, 180, 0, 30)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
end

styleBtn(ToggleBtn, UDim2.new(0, 10, 0, 10), "ON / OFF")
styleBtn(SetPosBtn, UDim2.new(0, 10, 0, 45), "座標を設定 (Click)")
StatusLabel.Size = UDim2.new(0, 180, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 85)
StatusLabel.Text = "停止中"
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.BackgroundTransparency = 1

-- 変数
local targetX, targetY = 0, 0
local clicking = false
local settingPos = false
local vim = game:GetService("VirtualInputManager")
local mouse = game:GetService("Players").LocalPlayer:GetMouse()

-- 座標設定ロジック
SetPosBtn.MouseButton1Click:Connect(function()
    settingPos = true
    StatusLabel.Text = "画面をクリックして座標を指定..."
end)

mouse.Button1Down:Connect(function()
    if settingPos then
        targetX, targetY = mouse.X, mouse.Y
        settingPos = false
        StatusLabel.Text = "固定座標: " .. targetX .. ", " .. targetY
    end
end)

-- ループ処理
ToggleBtn.MouseButton1Click:Connect(function()
    clicking = not clicking
    if clicking then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        spawn(function()
            while clicking do
                -- 指定した座標にクリック信号を送信
                vim:SendMouseButtonEvent(targetX, targetY, 0, true, game, 0)
                task.wait(0.05)
                vim:SendMouseButtonEvent(targetX, targetY, 0, false, game, 0)
                task.wait(0.05)
            end
        end)
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)
