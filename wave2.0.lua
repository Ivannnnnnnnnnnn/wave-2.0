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
}

local espBoxes = {}
local espNames = {}
local espHealth = {}
local espDistance = {}
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
                else
                    espBoxes[p].Visible = false
                    espNames[p].Visible = false
                    espHealth[p].Visible = false
                    espDistance[p].Visible = false
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
Frame.Position = UDim2.new(0.2, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Visible = settings.menuOpen
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame)

local title = Instance.new("TextLabel", Frame)
title.Text = "Wave 2.0"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local currentTab = "Aimbot"
local uiElements = {}
local function clearUI() 
    for _, v in ipairs(uiElements) do 
        v:Destroy() 
    end 
    uiElements = {} 
end

local baseY = 70
local spacing = 45

local function makeSlider(name, y, settingKey, min, max, step)
    step = step or 1
    
    local label = Instance.new("TextLabel", Frame)
    label.Position = UDim2.new(0, 10, 0, y)
    label.Size = UDim2.new(0, 280, 0, 20)
    label.Text = name .. ": " .. tostring(settings[settingKey])
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    table.insert(uiElements, label)

    local slider = Instance.new("TextButton", Frame)
    slider.Position = UDim2.new(0, 10, 0, y + 28)
    slider.Size = UDim2.new(0, 280, 0, 15)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    slider.Text = ""
    table.insert(uiElements, slider)
    
    local fill = Instance.new("Frame", slider)
    fill.Size = UDim2.new((settings[settingKey] - min) / (max - min), 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    fill.BorderSizePixel = 0
    table.insert(uiElements, fill)

    local dragging = false
    slider.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = true 
        end 
    end)
    
    slider.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = false 
        end 
    end)
    
    slider.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = input.Position.X
            local relativeX = math.clamp(mouseX - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
            local value = min + (max - min) * (relativeX / slider.AbsoluteSize.X)
            value = math.floor(value / step) * step
            settings[settingKey] = math.clamp(value, min, max)
            label.Text = name .. ": " .. tostring(settings[settingKey])
            fill.Size = UDim2.new((settings[settingKey] - min) / (max - min), 0, 1, 0)
        end
    end)
end

local function makeToggle(name, y, settingKey)
    local toggle = Instance.new("TextButton", Frame)
    toggle.Position = UDim2.new(0, 10, 0, y)
    toggle.Size = UDim2.new(0, 130, 0, 25)
    toggle.Text = name .. ": " .. (settings[settingKey] and "ON" or "OFF")
    toggle.BackgroundColor3 = settings[settingKey] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(40, 40, 40)
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.Font = Enum.Font.SourceSans
    toggle.TextSize = 18
    toggle.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        toggle.Text = name .. ": " .. (settings[settingKey] and "ON" or "OFF")
        toggle.BackgroundColor3 = settings[settingKey] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(40, 40, 40)
    end)
    table.insert(uiElements, toggle)
end

local function makeDropdown(name, y, options, settingKey)
    local label = Instance.new("TextLabel", Frame)
    label.Position = UDim2.new(0, 10, 0, y)
    label.Size = UDim2.new(0, 280, 0, 25)
    label.Text = name .. ": " .. tostring(settings[settingKey])
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    table.insert(uiElements, label)

    local dropdown = Instance.new("TextButton", Frame)
    dropdown.Position = UDim2.new(0, 10, 0, y + 25)
    dropdown.Size = UDim2.new(0, 280, 0, 25)
    dropdown.Text = "Change"
    dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    dropdown.TextColor3 = Color3.new(1,1,1)
    dropdown.Font = Enum.Font.SourceSans
    dropdown.TextSize = 16
    table.insert(uiElements, dropdown)

    dropdown.MouseButton1Click:Connect(function()
        local currentIndex = table.find(options, settings[settingKey]) or 1
        local nextIndex = (currentIndex % #options) + 1
        settings[settingKey] = options[nextIndex]
        label.Text = name .. ": " .. tostring(settings[settingKey])
    end)
end

local function drawTabContent()
    clearUI()
    if currentTab == "Aimbot" then
        local leftX = 10
        local rightX = 310
        local y = baseY

        makeToggle("Aimbot", y, "aimEnabled")
        makeToggle("Team Check", y + spacing, "teamCheck")
        makeToggle("Wall Check", y + spacing*2, "wallCheck")
        makeToggle("Smooth Aim", y + spacing*3, "smoothAim")
        makeSlider("Smoothness", y + spacing*4, "smoothness", 0.1, 1, 0.1)
        makeSlider("FOV", y + spacing*5, "fov", 50, 300)
        makeToggle("Show FOV", y + spacing*6, "fovVisible")

        makeDropdown("Aim Part", y, {"Head", "HumanoidRootPart", "UpperTorso"}, "aimPart")
        makeToggle("Prediction", y + spacing, "aimPrediction")
        makeSlider("Prediction Amt", y + spacing*2, "predictionAmount", 0.05, 0.3, 0.05)
        makeToggle("Trigger Bot", y + spacing*3, "triggerBot")
        makeSlider("Trigger Delay", y + spacing*4, "triggerDelay", 0.05, 0.5, 0.05)

        for _, v in ipairs(uiElements) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                if v.Position.X.Offset == 10 and v.Position.Y.Offset >= baseY then
                    if v.Text == "Aim Part: "..settings.aimPart or v.Text == "Change"
                        or v.Text:find("Prediction") or v.Text:find("Trigger") then
                        v.Position = v.Position + UDim2.new(0, rightX - leftX, 0, 0)
                    end
                end
            end
        end
    elseif currentTab == "Visuals" then
        makeToggle("ESP Boxes", baseY, "espEnabled")
        makeToggle("ESP Names", baseY + spacing, "espNames")
        makeToggle("ESP Health", baseY + spacing*2, "espHealth")
        makeToggle("ESP Distance", baseY + spacing*3, "espDistance")
        makeSlider("ESP R", baseY + spacing*4, "espR", 0, 255)
        makeSlider("ESP G", baseY + spacing*5, "espG", 0, 255)
        makeSlider("ESP B", baseY + spacing*6, "espB", 0, 255)
    elseif currentTab == "Misc" then
        makeToggle("Bunnyhop", baseY, "bhopEnabled")
        makeToggle("Speedhack", baseY + spacing, "speedhackEnabled")
        if settings.speedhackEnabled then
            makeSlider("Speed", baseY + spacing*2, "speedValue", 16, 50)
        end
        makeToggle("Anti-Aim", baseY + spacing*4, "antiAimEnabled")
    end
end

local function makeTabButton(name, x)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(0, 80, 0, 25)
    btn.Position = UDim2.new(0, x, 0, 35)
    btn.Text = name
    btn.BackgroundColor3 = currentTab == name and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.AutoButtonColor = false
    
    btn.MouseEnter:Connect(function() 
        if currentTab ~= name then
            btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70) 
        end
    end)
    
    btn.MouseLeave:Connect(function() 
        if currentTab ~= name then
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) 
        end
    end)
    
    btn.MouseButton1Click:Connect(function()
        currentTab = name
        drawTabContent()
        
        for _, child in ipairs(Frame:GetChildren()) do
            if child:IsA("TextButton") and child ~= btn and child.Text ~= "Change" then
                child.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end
        end
        
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    end)
    
    return btn
end

local aimbotTab = makeTabButton("Aimbot", 10)
local visualsTab = makeTabButton("Visuals", 100)
local miscTab = makeTabButton("Misc", 190)
drawTabContent()

local userFrame = Instance.new("Frame", Frame)
userFrame.Size = UDim2.new(1, -20, 0, 60)
userFrame.Position = UDim2.new(0, 10, 1, -65)
userFrame.BackgroundTransparency = 0.5
userFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", userFrame)

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
userNameLabel.TextSize = 24
userNameLabel.TextXAlignment = Enum.TextXAlignment.Left

UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        settings.menuOpen = not settings.menuOpen
        Frame.Visible = settings.menuOpen
    end
end)

game:GetService("UserInputService").WindowFocusReleased:Connect(function()
    for _, drawing in ipairs(drawings) do
        pcall(function()
            drawing:Remove()
        end)
    end
end)