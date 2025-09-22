local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local splashGui = Instance.new("ScreenGui", game.CoreGui)
splashGui.Name = "WaveSplash"
splashGui.ResetOnSpawn = false

local letters = {"W", "a", "v", "e", " ", "2", ".", "0"}
local colors = {
    Color3.fromRGB(0, 102, 204),
    Color3.fromRGB(70, 150, 230),
    Color3.fromRGB(173, 216, 230),
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(200, 200, 200),
    Color3.fromRGB(0, 102, 204),
    Color3.fromRGB(173, 216, 230),
    Color3.fromRGB(255, 255, 255)
}

local letterLabels = {}
local totalWidth = 500
local letterWidth = totalWidth / #letters
local height = 100

for i, letter in ipairs(letters) do
    local lbl = Instance.new("TextLabel", splashGui)
    lbl.Size = UDim2.new(0, letterWidth, 0, height)
    lbl.Position = UDim2.new(0.5, -totalWidth/2 + (i-1)*letterWidth, 0.5, -height/2)
    lbl.AnchorPoint = Vector2.new(0.5, 0.5)
    lbl.BackgroundTransparency = 1
    lbl.Text = letter
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextScaled = true
    lbl.TextColor3 = colors[i]
    lbl.TextStrokeTransparency = 0.5
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 70, 140)
    lbl.TextTransparency = 1
    letterLabels[i] = lbl
end

task.spawn(function()
    local fadeInTweens = {}
    local waveTweens = {}
    
    for i, lbl in ipairs(letterLabels) do
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(lbl, tweenInfo, {TextTransparency = 0})
        table.insert(fadeInTweens, tween)
        tween:Play()
        task.wait(0.1)
    end
    
    for i, lbl in ipairs(letterLabels) do
        local goal = {}
        goal.Position = UDim2.new(lbl.Position.X.Scale, lbl.Position.X.Offset, 0.5, -height/2 + 10)
        
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local tween = TweenService:Create(lbl, tweenInfo, goal)
        table.insert(waveTweens, tween)
        tween:Play()
        task.wait(0.05)
    end
    
    task.wait(0.5)
    
    for i, lbl in ipairs(letterLabels) do
        local goal = {}
        goal.Position = UDim2.new(lbl.Position.X.Scale, lbl.Position.X.Offset, 0.5, -height/2)
        
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local tween = TweenService:Create(lbl, tweenInfo, goal)
        tween:Play()
    end
    
    task.wait(1)
    
    for i, lbl in ipairs(letterLabels) do
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(lbl, tweenInfo, {TextTransparency = 1, TextStrokeTransparency = 1})
        tween:Play()
        task.wait(0.1)
    end
    
    task.wait(0.5)
    splashGui:Destroy()
end)

local settings = {
    espEnabled = true,
    aimEnabled = true,
    teamCheck = true,
    fovVisible = true,
    bhopEnabled = false,
    speedhackEnabled = false,
    speedValue = 55,
    fov = 100,
    aimPart = "Head",
    aimKey = Enum.UserInputType.MouseButton2,
    espColor = Color3.fromRGB(255, 0, 0),
    menuOpen = true,
    antiAimEnabled = false,
    espR = 255,
    espG = 0,
    espB = 0,
    smoothAim = false,
    smoothness = 0.2,
    espNames = true,
    espHealth = true,
    espDistance = false,
    aimPrediction = false,
    predictionAmount = 0.1,
    triggerBot = false,
    triggerDelay = 0.1,
    wallCheck = false,
    skeletonEsp = false,
    flyEnabled = false,
    noclipEnabled = false,
    flySpeed = 85,
}

local flying = false
local flyBV = nil
local flyBG = nil
local flySpeed = settings.flySpeed

local noclip = false
local connection = nil

local espBoxes = {}
local espNames = {}
local espHealth = {}
local espDistance = {}
local skeletonLines = {}
local drawings = {}

local fovCircle = Drawing.new("Circle")
fovCircle.Filled = false
fovCircle.Transparency = 0.6
fovCircle.Thickness = 1
fovCircle.Visible = settings.fovVisible
fovCircle.Color = Color3.new(1, 1, 1)
table.insert(drawings, fovCircle)

local aiming = false
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == settings.aimKey then 
        aiming = true 
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == settings.aimKey then 
        aiming = false 
    end
end)

local function toggleFly()
    if not LP.Character or not LP.Character:FindFirstChild("Humanoid") or not LP.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    flying = not flying
    
    if flying then
        flyBV = Instance.new("BodyVelocity")
        flyBV.Name = "FlyBV"
        flyBV.Parent = LP.Character.HumanoidRootPart
        flyBV.MaxForce = Vector3.new(0, 0, 0)
        flyBV.Velocity = Vector3.new(0, 0, 0)
        
        flyBG = Instance.new("BodyGyro")
        flyBG.Name = "FlyBG"
        flyBG.Parent = LP.Character.HumanoidRootPart
        flyBG.MaxTorque = Vector3.new(0, 0, 0)
        flyBG.P = 1000
        flyBG.D = 50
        
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        
        LP.Character.Humanoid.PlatformStand = true
    else
        if flyBV then
            flyBV:Destroy()
            flyBV = nil
        end
        if flyBG then
            flyBG:Destroy()
            flyBG = nil
        end
        
        LP.Character.Humanoid.PlatformStand = false
    end
end

local function toggleNoclip()
    noclip = not noclip
    
    if connection then
        connection:Disconnect()
        connection = nil
    end
    
    if noclip then
        connection = RunService.Stepped:Connect(function()
            if LP.Character then
                for _, part in pairs(LP.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if LP.Character then
            for _, part in pairs(LP.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function flyControls()
    if flying and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local root = LP.Character.HumanoidRootPart
        local cam = workspace.CurrentCamera
        local flyDirection = Vector3.new(0, 0, 0)
        
        if UIS:IsKeyDown(Enum.KeyCode.W) then
            flyDirection = flyDirection + (cam.CFrame.LookVector * flySpeed)
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            flyDirection = flyDirection - (cam.CFrame.LookVector * flySpeed)
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            flyDirection = flyDirection - (cam.CFrame.RightVector * flySpeed)
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            flyDirection = flyDirection + (cam.CFrame.RightVector * flySpeed)
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            flyDirection = flyDirection + Vector3.new(0, flySpeed, 0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            flyDirection = flyDirection - Vector3.new(0, flySpeed, 0)
        end
        
        flyBV.Velocity = flyDirection
        flyBG.CFrame = cam.CFrame
    end
end

RunService.RenderStepped:Connect(flyControls)

local function isEnemy(p)
    if not p or p == LP then return false end
    if not p.Character then return false end
    if not p.Character:FindFirstChild("HumanoidRootPart") then return false end
    if not p.Character:FindFirstChild("Humanoid") then return false end
    if settings.teamCheck and p.Team == LP.Team then return false end
    if settings.wallCheck then
        local character = LP.Character
        if not character then return false end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return false end
        
        local targetRoot = p.Character.HumanoidRootPart
        local direction = (targetRoot.Position - humanoidRootPart.Position).Unit
        local ray = Ray.new(humanoidRootPart.Position, direction * (targetRoot.Position - humanoidRootPart.Position).Magnitude)
        local part, position = workspace:FindPartOnRayWithIgnoreList(ray, {character, p.Character})
        
        if part and not part:IsDescendantOf(p.Character) then
            return false
        end
    end
    return true
end

local skeletonConnections = {
    {"HumanoidRootPart", "LowerTorso"},
    {"LowerTorso", "UpperTorso"},
    {"UpperTorso", "Head"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

local function createESP(player)
    if espBoxes[player] then return end
    
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Transparency = 1
    box.Visible = false
    box.Color = settings.espColor
    espBoxes[player] = box
    table.insert(drawings, box)
    
    local name = Drawing.new("Text")
    name.Text = player.Name
    name.Size = 16
    name.Center = true
    name.Outline = true
    name.OutlineColor = Color3.new(0, 0, 0)
    name.Visible = false
    name.Color = Color3.new(1, 1, 1)
    espNames[player] = name
    table.insert(drawings, name)
    
    local health = Drawing.new("Text")
    health.Size = 14
    name.Center = true
    health.Outline = true
    health.OutlineColor = Color3.new(0, 0, 0)
    health.Visible = false
    health.Color = Color3.new(1, 1, 1)
    espHealth[player] = health
    table.insert(drawings, health)
    
    local distance = Drawing.new("Text")
    distance.Size = 14
    distance.Center = true
    distance.Outline = true
    distance.OutlineColor = Color3.new(0, 0, 0)
    distance.Visible = false
    distance.Color = Color3.new(1, 1, 1)
    espDistance[player] = distance
    table.insert(drawings, distance)
    
    skeletonLines[player] = {}
    for i = 1, #skeletonConnections do
        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Visible = false
        line.Color = settings.espColor
        table.insert(skeletonLines[player], line)
        table.insert(drawings, line)
    end
end

local function removeESP(player)
    if espBoxes[player] then
        espBoxes[player]:Remove()
        espBoxes[player] = nil
    end
    if espNames[player] then
        espNames[player]:Remove()
        espNames[player] = nil
    end
    if espHealth[player] then
        espHealth[player]:Remove()
        espHealth[player] = nil
    end
    if espDistance[player] then
        espDistance[player]:Remove()
        espDistance[player] = nil
    end

    if skeletonLines[player] then
        for _, line in ipairs(skeletonLines[player]) do
            line:Remove()
        end
        skeletonLines[player] = nil
    end
end

local function updateSkeletonESP(player, character)
    if not settings.skeletonEsp or not skeletonLines[player] then return end
    
    for i, connection in ipairs(skeletonConnections) do
        local part1 = character:FindFirstChild(connection[1])
        local part2 = character:FindFirstChild(connection[2])
        
        if part1 and part2 then
            local pos1, vis1 = Camera:WorldToViewportPoint(part1.Position)
            local pos2, vis2 = Camera:WorldToViewportPoint(part2.Position)
            
            if vis1 and vis2 then
                skeletonLines[player][i].From = Vector2.new(pos1.X, pos1.Y)
                skeletonLines[player][i].To = Vector2.new(pos2.X, pos2.Y)
                skeletonLines[player][i].Visible = true
                skeletonLines[player][i].Color = settings.espColor
            else
                skeletonLines[player][i].Visible = false
            end
        else
            skeletonLines[player][i].Visible = false
        end
    end
end

local function getClosest()
    local closest, dist = nil, math.huge
    local mousePos = UIS:GetMouseLocation()
    
    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) and p.Character and p.Character:FindFirstChild(settings.aimPart) then
            local part = p.Character[settings.aimPart]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                if mag < settings.fov and mag < dist then
                    closest, dist = p, mag
                end
            end
        end
    end
    return closest
end

RunService.Heartbeat:Connect(function()
    if settings.bhopEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        local humanoid = LP.Character.Humanoid
        if UIS:IsKeyDown(Enum.KeyCode.Space) and humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Stepped:Connect(function()
    local char = LP.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if settings.speedhackEnabled then
            if hum.WalkSpeed ~= settings.speedValue then
                hum.WalkSpeed = settings.speedValue
            end
        else
            if hum.WalkSpeed ~= 16 then
                hum.WalkSpeed = 16
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if settings.antiAimEnabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        local pos = hrp.Position

        local randomYaw = math.rad(math.random(0, 360))
        hrp.CFrame = CFrame.new(pos) * CFrame.Angles(0, randomYaw, 0)
    end
end)

local lastTriggerTime = 0
RunService.Heartbeat:Connect(function()
    if settings.triggerBot and aiming and tick() - lastTriggerTime > settings.triggerDelay then
        local target = getClosest()
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            local humanoid = target.Character.Humanoid
            if humanoid.Health > 0 then
                mouse1click()
                lastTriggerTime = tick()
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    settings.espColor = Color3.fromRGB(settings.espR, settings.espG, settings.espB)
    fovCircle.Position = UIS:GetMouseLocation()
    fovCircle.Radius = settings.fov
    fovCircle.Visible = settings.fovVisible

    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) then
            if not espBoxes[p] then createESP(p) end
            
            local character = p.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")
            
            if root and humanoid then
                local pos, vis = Camera:WorldToViewportPoint(root.Position)
                
                if vis then
                    local scale = 1 / (Camera.CFrame.Position - root.Position).Magnitude * 100
                    local size = Vector2.new(40 * scale, 80 * scale)
                    local boxPos = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                    
                    if settings.espEnabled then
                        espBoxes[p].Position = boxPos
                        espBoxes[p].Size = size
                        espBoxes[p].Visible = true
                        espBoxes[p].Color = settings.espColor
                    else
                        espBoxes[p].Visible = false
                    end
                    
                    if settings.espNames then
                        espNames[p].Position = Vector2.new(pos.X, pos.Y - size.Y/2 - 20)
                        espNames[p].Visible = true
                    else
                        espNames[p].Visible = false
                    end
                    
                    if settings.espHealth then
                        espHealth[p].Text = "HP: " .. math.floor(humanoid.Health)
                        espHealth[p].Position = Vector2.new(pos.X, pos.Y + size.Y/2 + 5)
                        espHealth[p].Visible = true
                        
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        if healthPercent > 0.7 then
                            espHealth[p].Color = Color3.new(0, 1, 0)
                        elseif healthPercent > 0.3 then
                            espHealth[p].Color = Color3.new(1, 1, 0)
                        else
                            espHealth[p].Color = Color3.new(1, 0, 0)
                        end
                    else
                        espHealth[p].Visible = false
                    end
                    
                    if settings.espDistance then
                        local distance = (root.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                        espDistance[p].Text = math.floor(distance) .. " studs"
                        espDistance[p].Position = Vector2.new(pos.X, pos.Y + size.Y/2 + 25)
                        espDistance[p].Visible = true
                    else
                        espDistance[p].Visible = false
                    end
                    
                    updateSkeletonESP(p, character)
                else
                    espBoxes[p].Visible = false
                    espNames[p].Visible = false
                    espHealth[p].Visible = false
                    espDistance[p].Visible = false
                    
                    if skeletonLines[p] then
                        for _, line in ipairs(skeletonLines[p]) do
                            line.Visible = false
                        end
                    end
                end
            end
        elseif espBoxes[p] then
            removeESP(p)
        end
    end

    if settings.aimEnabled and aiming then
        local target = getClosest()
        if target and target.Character and target.Character:FindFirstChild(settings.aimPart) then
            local part = target.Character[settings.aimPart]
            
            local targetPosition = part.Position
            if settings.aimPrediction and target.Character:FindFirstChild("HumanoidRootPart") then
                local root = target.Character.HumanoidRootPart
                targetPosition = targetPosition + root.Velocity * settings.predictionAmount
            end
            
            if settings.smoothAim then
                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, settings.smoothness)
            else
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "WaveMenu"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 600, 0, 455)
Frame.Position = UDim2.new(0.5, -300, 0.5, -227.5)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Visible = settings.menuOpen
Frame.Active = true
Frame.Draggable = true

local uiCorner = Instance.new("UICorner", Frame)
uiCorner.CornerRadius = UDim.new(0, 8)

local titleBar = Instance.new("Frame", Frame)
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 102, 204)
titleBar.BorderSizePixel = 0

local titleBarCorner = Instance.new("UICorner", titleBar)
titleBarCorner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", titleBar)
title.Text = "Wave 2.0"
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.TextStrokeTransparency = 0.5
title.TextStrokeColor3 = Color3.fromRGB(0, 70, 140)

local tabContainer = Instance.new("Frame", Frame)
tabContainer.Size = UDim2.new(1, -20, 0, 40)
tabContainer.Position = UDim2.new(0, 10, 0, 50)
tabContainer.BackgroundTransparency = 1

local contentContainer = Instance.new("ScrollingFrame", Frame)
contentContainer.Size = UDim2.new(1, -20, 1, -160)
contentContainer.Position = UDim2.new(0, 10, 0, 100)
contentContainer.BackgroundTransparency = 1
contentContainer.ScrollBarThickness = 6
contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
contentContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

local userFrame = Instance.new("Frame", Frame)
userFrame.Size = UDim2.new(1, -20, 0, 60)
userFrame.Position = UDim2.new(0, 10, 1, -70)
userFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
userFrame.BorderSizePixel = 0

local userCorner = Instance.new("UICorner", userFrame)
userCorner.CornerRadius = UDim.new(0, 6)

local userImage = Instance.new("ImageLabel", userFrame)
userImage.Size = UDim2.new(0, 50, 0, 50)
userImage.Position = UDim2.new(0, 5, 0.5, -25)
userImage.BackgroundTransparency = 1
userImage.Image = LP.UserId and ("https://www.roblox.com/headshot-thumbnail/image?userId="..LP.UserId.."&width=48&height=48&format=png") or ""
userImage.ScaleType = Enum.ScaleType.Fit
ContentProvider:PreloadAsync({userImage.Image})

local userNameLabel = Instance.new("TextLabel", userFrame)
userNameLabel.Size = UDim2.new(0, 200, 0, 50)
userNameLabel.Position = UDim2.new(0, 65, 0, 0)
userNameLabel.BackgroundTransparency = 1
userNameLabel.Text = LP.Name
userNameLabel.Font = Enum.Font.SourceSansBold
userNameLabel.TextColor3 = Color3.new(1, 1, 1)
userNameLabel.TextSize = 20
userNameLabel.TextXAlignment = Enum.TextXAlignment.Left

local currentTab = "Aimbot"
local uiElements = {}

local function clearUI() 
    for _, v in ipairs(uiElements) do 
        if v:IsA("GuiObject") then
            v:Destroy() 
        end
    end 
    uiElements = {} 
end

local function createToggle(name, position, settingKey, parent)
    local toggleFrame = Instance.new("Frame", parent)
    toggleFrame.Size = UDim2.new(0, 280, 0, 35)
    toggleFrame.Position = position
    toggleFrame.BackgroundTransparency = 1
    table.insert(uiElements, toggleFrame)

    local label = Instance.new("TextLabel", toggleFrame)
    label.Size = UDim2.new(0, 200, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBackground = Instance.new("Frame", toggleFrame)
    toggleBackground.Size = UDim2.new(0, 50, 0, 25)
    toggleBackground.Position = UDim2.new(1, -50, 0.5, -12.5)
    toggleBackground.BackgroundColor3 = settings[settingKey] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
    toggleBackground.BorderSizePixel = 0
    
    local toggleCorner = Instance.new("UICorner", toggleBackground)
    toggleCorner.CornerRadius = UDim.new(0, 12)

    local toggleButton = Instance.new("TextButton", toggleBackground)
    toggleButton.Size = UDim2.new(0, 21, 0, 21)
    toggleButton.Position = settings[settingKey] and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
    toggleButton.BackgroundColor3 = Color3.new(1, 1, 1)
    toggleButton.Text = ""
    toggleButton.BorderSizePixel = 0
    
    local buttonCorner = Instance.new("UICorner", toggleButton)
    buttonCorner.CornerRadius = UDim.new(0, 10)

    local function updateToggle()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        if settings[settingKey] then
            local tween = TweenService:Create(toggleButton, tweenInfo, {Position = UDim2.new(1, -23, 0.5, -10.5)})
            local bgTween = TweenService:Create(toggleBackground, tweenInfo, {BackgroundColor3 = Color3.fromRGB(0, 170, 0)})
            tween:Play()
            bgTween:Play()
        else
            local tween = TweenService:Create(toggleButton, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -10.5)})
            local bgTween = TweenService:Create(toggleBackground, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)})
            tween:Play()
            bgTween:Play()
        end
    end

    toggleButton.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        updateToggle()
        
        if settingKey == "flyEnabled" then
            toggleFly()
        elseif settingKey == "noclipEnabled" then
            toggleNoclip()
        end
    end)

    updateToggle()
    return toggleFrame
end

local function createSlider(name, position, settingKey, min, max, step, parent)
    step = step or 1
    
    local sliderFrame = Instance.new("Frame", parent)
    sliderFrame.Size = UDim2.new(0, 280, 0, 50)
    sliderFrame.Position = position
    sliderFrame.BackgroundTransparency = 1
    table.insert(uiElements, sliderFrame)

    local label = Instance.new("TextLabel", sliderFrame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. tostring(settings[settingKey])
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left

    local sliderBackground = Instance.new("Frame", sliderFrame)
    sliderBackground.Size = UDim2.new(1, 0, 0, 15)
    sliderBackground.Position = UDim2.new(0, 0, 1, -20)
    sliderBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderBackground.BorderSizePixel = 0
    
    local bgCorner = Instance.new("UICorner", sliderBackground)
    bgCorner.CornerRadius = UDim.new(0, 7)

    local sliderFill = Instance.new("Frame", sliderBackground)
    sliderFill.Size = UDim2.new((settings[settingKey] - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    sliderFill.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner", sliderFill)
    fillCorner.CornerRadius = UDim.new(0, 7)

    local sliderButton = Instance.new("TextButton", sliderBackground)
    sliderButton.Size = UDim2.new(0, 20, 0, 20)
    sliderButton.Position = UDim2.new((settings[settingKey] - min) / (max - min), -10, 0.5, -10)
    sliderButton.BackgroundColor3 = Color3.new(1, 1, 1)
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.ZIndex = 2
    
    local buttonCorner = Instance.new("UICorner", sliderButton)
    buttonCorner.CornerRadius = UDim.new(0, 10)

    local dragging = false

    local function updateSlider(value)
        value = math.floor(value / step) * step
        settings[settingKey] = math.clamp(value, min, max)
        label.Text = name .. ": " .. tostring(settings[settingKey])
        
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local fillTween = TweenService:Create(sliderFill, tweenInfo, {Size = UDim2.new((settings[settingKey] - min) / (max - min), 0, 1, 0)})
        local buttonTween = TweenService:Create(sliderButton, tweenInfo, {Position = UDim2.new((settings[settingKey] - min) / (max - min), -10, 0.5, -10)})
        fillTween:Play()
        buttonTween:Play()
    end

    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = true 
        end 
    end)
    
    sliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = false 
        end 
    end)
    
    sliderBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = true
            local relativeX = (input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X
            local value = min + (max - min) * relativeX
            updateSlider(value)
        end 
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = (input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X
            local value = min + (max - min) * math.clamp(relativeX, 0, 1)
            updateSlider(value)
        end
    end)

    return sliderFrame
end

local function createDropdown(name, position, options, settingKey, parent)
    local dropdownFrame = Instance.new("Frame", parent)
    dropdownFrame.Size = UDim2.new(0, 280, 0, 50)
    dropdownFrame.Position = position
    dropdownFrame.BackgroundTransparency = 1
    table.insert(uiElements, dropdownFrame)

    local label = Instance.new("TextLabel", dropdownFrame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. tostring(settings[settingKey])
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left

    local dropdownButton = Instance.new("TextButton", dropdownFrame)
    dropdownButton.Size = UDim2.new(1, 0, 0, 25)
    dropdownButton.Position = UDim2.new(0, 0, 1, -25)
    dropdownButton.Text = "▼ " .. tostring(settings[settingKey])
    dropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    dropdownButton.TextColor3 = Color3.new(1, 1, 1)
    dropdownButton.Font = Enum.Font.SourceSans
    dropdownButton.TextSize = 14
    dropdownButton.BorderSizePixel = 0
    
    local buttonCorner = Instance.new("UICorner", dropdownButton)
    buttonCorner.CornerRadius = UDim.new(0, 4)

    dropdownButton.MouseButton1Click:Connect(function()
        local currentIndex = table.find(options, settings[settingKey]) or 1
        local nextIndex = (currentIndex % #options) + 1
        settings[settingKey] = options[nextIndex]
        label.Text = name .. ": " .. tostring(settings[settingKey])
        dropdownButton.Text = "▼ " .. tostring(settings[settingKey])
        
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        local scaleTween = TweenService:Create(dropdownButton, tweenInfo, {Size = UDim2.new(0.95, 0, 0, 23)})
        scaleTween:Play()
        task.wait(0.1)
        local scaleBack = TweenService:Create(dropdownButton, tweenInfo, {Size = UDim2.new(1, 0, 0, 25)})
        scaleBack:Play()
    end)

    return dropdownFrame
end

local function drawTabContent()
    clearUI()
    
    local yOffset = 0
    local spacing = 40
    
    if currentTab == "Aimbot" then
        createToggle("Aimbot", UDim2.new(0, 0, 0, yOffset), "aimEnabled", contentContainer)
        yOffset = yOffset + spacing
        createToggle("Team Check", UDim2.new(0, 0, 0, yOffset), "teamCheck", contentContainer)
        yOffset = yOffset + spacing
        createToggle("Wall Check", UDim2.new(0, 0, 0, yOffset), "wallCheck", contentContainer)
        yOffset = yOffset + spacing
        createToggle("Smooth Aim", UDim2.new(0, 0, 0, yOffset), "smoothAim", contentContainer)
        yOffset = yOffset + spacing
        createSlider("Smoothness", UDim2.new(0, 0, 0, yOffset), "smoothness", 0.1, 1, 0.1, contentContainer)
        yOffset = yOffset + spacing + 10
        createSlider("FOV", UDim2.new(0, 0, 0, yOffset), "fov", 50, 300, 1, contentContainer)
        yOffset = yOffset + spacing + 10
        createToggle("Show FOV", UDim2.new(0, 0, 0, yOffset), "fovVisible", contentContainer)
        yOffset = yOffset + spacing
        
        createDropdown("Aim Part", UDim2.new(0, 290, 0, 0), {"Head", "HumanoidRootPart", "UpperTorso"}, "aimPart", contentContainer)
        yOffset = 40
        createToggle("Prediction", UDim2.new(0, 290, 0, yOffset), "aimPrediction", contentContainer)
        yOffset = yOffset + spacing
        createSlider("Prediction Amt", UDim2.new(0, 290, 0, yOffset), "predictionAmount", 0.05, 0.3, 0.05, contentContainer)
        yOffset = yOffset + spacing + 10
        createToggle("Trigger Bot", UDim2.new(0, 290, 0, yOffset), "triggerBot", contentContainer)
        yOffset = yOffset + spacing
        createSlider("Trigger Delay", UDim2.new(0, 290, 0, yOffset), "triggerDelay", 0.05, 0.5, 0.05, contentContainer)
        
    elseif currentTab == "Visuals" then
        createToggle("ESP Boxes", UDim2.new(0, 0, 0, yOffset), "espEnabled", contentContainer)
        yOffset = yOffset + spacing
        createToggle("ESP Names", UDim2.new(0, 0, 0, yOffset), "espNames", contentContainer)
        yOffset = yOffset + spacing
        createToggle("ESP Health", UDim2.new(0, 0, 0, yOffset), "espHealth", contentContainer)
        yOffset = yOffset + spacing
        createToggle("ESP Distance", UDim2.new(0, 0, 0, yOffset), "espDistance", contentContainer)
        yOffset = yOffset + spacing
        createToggle("Skeleton ESP", UDim2.new(0, 0, 0, yOffset), "skeletonEsp", contentContainer)
        yOffset = yOffset + spacing
        createSlider("ESP R", UDim2.new(0, 0, 0, yOffset), "espR", 0, 255, 1, contentContainer)
        yOffset = yOffset + spacing + 10
        createSlider("ESP G", UDim2.new(0, 0, 0, yOffset), "espG", 0, 255, 1, contentContainer)
        yOffset = yOffset + spacing + 10
        createSlider("ESP B", UDim2.new(0, 0, 0, yOffset), "espB", 0, 255, 1, contentContainer)
        
    elseif currentTab == "Misc" then
        createToggle("Bunnyhop", UDim2.new(0, 0, 0, yOffset), "bhopEnabled", contentContainer)
        yOffset = yOffset + spacing
        createToggle("Speedhack", UDim2.new(0, 0, 0, yOffset), "speedhackEnabled", contentContainer)
        yOffset = yOffset + spacing
        if settings.speedhackEnabled then
            createSlider("Speed", UDim2.new(0, 0, 0, yOffset), "speedValue", 16, 50, 1, contentContainer)
            yOffset = yOffset + spacing + 10
        end
        createToggle("Anti-Aim", UDim2.new(0, 0, 0, yOffset), "antiAimEnabled", contentContainer)
        yOffset = yOffset + spacing
        createToggle("Fly", UDim2.new(0, 0, 0, yOffset), "flyEnabled", contentContainer)
        yOffset = yOffset + spacing
        if settings.flyEnabled then
            createSlider("Fly Speed", UDim2.new(0, 0, 0, yOffset), "flySpeed", 10, 100, 1, contentContainer)
            yOffset = yOffset + spacing + 10
        end
        createToggle("Noclip", UDim2.new(0, 0, 0, yOffset), "noclipEnabled", contentContainer)
        yOffset = yOffset + spacing
        createToggle("Menu Keybind", UDim2.new(0, 0, 0, yOffset), "menuOpen", contentContainer)
    end
end

local function createTabButton(name, xPosition)
    local tabButton = Instance.new("TextButton", tabContainer)
    tabButton.Size = UDim2.new(0, 120, 1, 0)
    tabButton.Position = UDim2.new(0, xPosition, 0, 0)
    tabButton.Text = name
    tabButton.BackgroundColor3 = currentTab == name and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(40, 40, 40)
    tabButton.TextColor3 = Color3.new(1, 1, 1)
    tabButton.Font = Enum.Font.SourceSansSemibold
    tabButton.TextSize = 16
    tabButton.BorderSizePixel = 0
    tabButton.AutoButtonColor = false
    
    local tabCorner = Instance.new("UICorner", tabButton)
    tabCorner.CornerRadius = UDim.new(0, 6)
    
    tabButton.MouseEnter:Connect(function()
        if currentTab ~= name then
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(tabButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)})
            tween:Play()
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if currentTab ~= name then
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(tabButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
            tween:Play()
        end
    end)
    
    tabButton.MouseButton1Click:Connect(function()
        currentTab = name
        
        for _, child in ipairs(tabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                if child == tabButton then
                    local tween = TweenService:Create(child, tweenInfo, {BackgroundColor3 = Color3.fromRGB(0, 120, 255)})
                    tween:Play()
                else
                    local tween = TweenService:Create(child, tweenInfo, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
                    tween:Play()
                end
            end
        end
        
        local scaleTween = TweenService:Create(tabButton, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 115, 1, -5)})
        scaleTween:Play()
        task.wait(0.1)
        local scaleBack = TweenService:Create(tabButton, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 120, 1, 0)})
        scaleBack:Play()
        
        drawTabContent()
    end)
    
    return tabButton
end

local aimbotTab = createTabButton("Aimbot", 0)
local visualsTab = createTabButton("Visuals", 125)
local miscTab = createTabButton("Misc", 250)
drawTabContent()

UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        settings.menuOpen = not settings.menuOpen
        
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        if settings.menuOpen then
            Frame.Visible = true
            local tween = TweenService:Create(Frame, tweenInfo, {Position = UDim2.new(0.5, -300, 0.5, -227.5), Size = UDim2.new(0, 600, 0, 455)})
            tween:Play()
        else
            local tween = TweenService:Create(Frame, tweenInfo, {Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 0, 0, 0)})
            tween:Play()
            tween.Completed:Connect(function()
                Frame.Visible = false
            end)
        end
    end
end)

local function cleanup()
    for _, drawing in ipairs(drawings) do
        drawing:Remove()
    end
    
    if connection then
        connection:Disconnect()
    end
    
    if flyBV then
        flyBV:Destroy()
    end
    
    if flyBG then
        flyBG:Destroy()
    end
    
    ScreenGui:Destroy()
end

game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child == ScreenGui then
        cleanup()
    end
end)

LP.CharacterRemoving:Connect(cleanup)

task.spawn(function()

    ContentProvider:PreloadAsync({userImage.Image})
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            createESP(player)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        createESP(player)
    end)
    
    flySpeed = settings.flySpeed
    
    while true do

        if flySpeed ~= settings.flySpeed then
            flySpeed = settings.flySpeed
        end
        
        fovCircle.Visible = settings.fovVisible
        fovCircle.Radius = settings.fov
        fovCircle.Color = Color3.new(1, 1, 1)
        
        settings.espColor = Color3.fromRGB(settings.espR, settings.espG, settings.espB)
        
        task.wait(0.1)
    end
end)

local function safeCall(func)
    local success, result = pcall(func)
    if not success then
        warn("Error in safeCall: " .. tostring(result))
    end
    return result
end

game:BindToClose(function()
    cleanup()
    
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.PlatformStand = false
        LP.Character.Humanoid.WalkSpeed = 16
    end
    
    for _, drawing in ipairs(drawings) do
        pcall(function()
            drawing:Remove()
        end)
    end
end)

local function updateUIScale()
    local viewportSize = Camera.ViewportSize
    local scale = math.min(viewportSize.X / 1920, viewportSize.Y / 1080)
    
    Frame.Size = UDim2.new(0, 600 * scale, 0, 455 * scale)
    Frame.Position = UDim2.new(0.5, -300 * scale, 0.5, -227.5 * scale)
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateUIScale)
updateUIScale()

return settings
