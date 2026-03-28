local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LoopTP_System"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 200)
mainFrame.Position = UDim2.new(0.5, -110, 0.7, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "LOOP TELEPORT MENU"
title.TextColor3 = Color3.fromRGB(200, 200, 200)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.Parent = mainFrame

local recordBtn = Instance.new("TextButton")
recordBtn.Size = UDim2.new(0, 190, 0, 35)
recordBtn.Position = UDim2.new(0.5, -95, 0, 35)
recordBtn.Text = "地点を記録"
recordBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 120)
recordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
recordBtn.Font = Enum.Font.GothamBold
recordBtn.TextSize = 14
recordBtn.Parent = mainFrame
Instance.new("UICorner", recordBtn).CornerRadius = UDim.new(0, 8)

local loopBtn = Instance.new("TextButton")
loopBtn.Size = UDim2.new(0, 190, 0, 35)
loopBtn.Position = UDim2.new(0.5, -95, 0, 75)
loopBtn.Text = "ループTP: OFF"
loopBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
loopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loopBtn.Font = Enum.Font.GothamBold
loopBtn.TextSize = 14
loopBtn.Parent = mainFrame
Instance.new("UICorner", loopBtn).CornerRadius = UDim.new(0, 8)

local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(0, 180, 0, 4)
sliderFrame.Position = UDim2.new(0.5, -90, 0, 155)
sliderFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
sliderFrame.BorderSizePixel = 0
sliderFrame.Parent = mainFrame

local sliderDot = Instance.new("TextButton")
sliderDot.Size = UDim2.new(0, 16, 0, 16)
sliderDot.Position = UDim2.new(0, 0, 0.5, -8) 
sliderDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderDot.Text = ""
sliderDot.Parent = sliderFrame
Instance.new("UICorner", sliderDot).CornerRadius = UDim.new(1, 0)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 20)
speedLabel.Position = UDim2.new(0, 0, 0, -25)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "ループ間隔: 0.1 秒"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 12
speedLabel.Parent = sliderFrame

local savedPos = nil
local loopEnabled = false
local loopInterval = 0.1 

recordBtn.MouseButton1Click:Connect(function()
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		savedPos = char.HumanoidRootPart.Position
		recordBtn.Text = "✔ 記録完了"
		task.wait(0.5)
		recordBtn.Text = "地点を記録"
	end
end)

loopBtn.MouseButton1Click:Connect(function()
	if not savedPos then
		loopBtn.Text = "先に記録してください"
		task.wait(1)
		loopBtn.Text = "ループTP: OFF"
		return
	end

	loopEnabled = not loopEnabled
	if loopEnabled then
		loopBtn.Text = "ループTP: ON (実行中)"
		loopBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
	else
		loopBtn.Text = "ループTP: OFF"
		loopBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	end
end)

task.spawn(function()
	while true do
		if loopEnabled and savedPos then
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char.HumanoidRootPart.CFrame = CFrame.new(savedPos + Vector3.new(0, 3, 0))
			end
		end
		task.wait(loopInterval) 
	end
end)

local draggingSlider = false
sliderDot.MouseButton1Down:Connect(function() draggingSlider = true end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
		local mousePos = input.Position.X
		local framePos = sliderFrame.AbsolutePosition.X
		local frameWidth = sliderFrame.AbsoluteSize.X
		
		local percentage = math.clamp((mousePos - framePos) / frameWidth, 0, 1)
		sliderDot.Position = UDim2.new(percentage, -8, 0.5, -8)
		
		-- 0.1秒から10秒の間で調整可能に設定
		loopInterval = math.max(0.1, math.round(percentage * 10 * 10) / 10)
		speedLabel.Text = "ループ間隔: " .. tostring(loopInterval) .. " 秒"
	end
end)

local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
