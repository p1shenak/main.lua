--[[
    FONDI MM2 V4.2
    ESP + OUTLINE + TRACERS
    PLAYER LIST + SPECTATOR
    FLY + NOCLIP
    SETTINGS
    L = Toggle Menu
    TOGGLE SOUND = 133095302935970
]]

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

--// SETTINGS
local Settings = {
    ESP = true,
    Outline = true,
    Tracers = false,
    ShowNames = true,
    ShowRoles = true,

    Fly = false,
    Noclip = false,
    FlySpeed = 50,

    Spectating = false,
    SpectatedPlayer = nil
}

local KEY = "FONDI-MM2-FOREVER"

--//==================================================
--// TOGGLE SOUND
--//==================================================

local ToggleSound = Instance.new("Sound")
ToggleSound.Name = "FondiToggleSound"
ToggleSound.SoundId = "rbxassetid://133095302935970"
ToggleSound.Volume = 1
ToggleSound.Parent = SoundService

local function PlayToggleSound()
    ToggleSound:Stop()
    ToggleSound.TimePosition = 0
    ToggleSound:Play()
end

--//==================================================
--// NOTIFICATION
--//==================================================

local function Notify(text)
    local old = PG:FindFirstChild("FondiNotification")

    if old then
        old:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "FondiNotification"
    gui.ResetOnSpawn = false
    gui.Parent = PG

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 45)
    frame.Position = UDim2.new(1, -275, 1, -65)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 1, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 15
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.Parent = frame

    task.delay(2, function()
        if gui then
            gui:Destroy()
        end
    end)
end

--//==================================================
--// ROLE DETECTION
--//==================================================

local function GetRole(player)
    if not player then
        return "Innocent"
    end

    local backpack = player:FindFirstChildOfClass("Backpack")

    if backpack then
        if backpack:FindFirstChild("Knife")
            or backpack:FindFirstChild("Revolver")
            or backpack:FindFirstChild("Gun") then

            if backpack:FindFirstChild("Knife") then
                return "Murderer"
            end

            if backpack:FindFirstChild("Gun")
                or backpack:FindFirstChild("Revolver") then
                return "Sheriff"
            end
        end
    end

    local character = player.Character

    if character then
        if character:FindFirstChild("Knife") then
            return "Murderer"
        end

        if character:FindFirstChild("Gun")
            or character:FindFirstChild("Revolver") then
            return "Sheriff"
        end
    end

    return "Innocent"
end

local function GetRoleColor(role)
    if role == "Murderer" then
        return Color3.fromRGB(255, 50, 50)
    elseif role == "Sheriff" then
        return Color3.fromRGB(50, 120, 255)
    else
        return Color3.fromRGB(80, 255, 100)
    end
end

--//==================================================
--// ESP
--//==================================================

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "FondiESP"
ESPFolder.Parent = PG

local ESPObjects = {}

local UpdateESP

local function RemoveESP(player)
    local data = ESPObjects[player]

    if data then
        if data.Highlight then
            data.Highlight:Destroy()
        end

        if data.Billboard then
            data.Billboard:Destroy()
        end

        if data.Tracer then
            data.Tracer:Destroy()
        end

        ESPObjects[player] = nil
    end
end

local function CreateESP(player)
    if player == LP then
        return
    end

    RemoveESP(player)

    local character = player.Character

    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root then
        return
    end

    local data = {}

    --// HIGHLIGHT
    local highlight = Instance.new("Highlight")
    highlight.Name = "FondiHighlight"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.75
    highlight.OutlineTransparency = 0
    highlight.Parent = ESPFolder

    data.Highlight = highlight

    --// NAME / ROLE
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "FondiName"
    billboard.Adornee = root
    billboard.Size = UDim2.new(0, 200, 0, 55)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = ESPFolder

    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0.2
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Parent = billboard

    data.Billboard = billboard
    data.Label = label

    ESPObjects[player] = data

    UpdateESP(player)
end

UpdateESP = function(player)
    local data = ESPObjects[player]

    if not data then
        return
    end

    local character = player.Character

    if not character then
        RemoveESP(player)
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")

    if not root then
        return
    end

    local role = GetRole(player)
    local roleColor = GetRoleColor(role)

    --// HIGHLIGHT
    if data.Highlight then
        data.Highlight.Adornee = character
        data.Highlight.Enabled = Settings.ESP
        data.Highlight.OutlineTransparency = Settings.Outline and 0 or 1
        data.Highlight.FillTransparency = 0.75
        data.Highlight.FillColor = roleColor
        data.Highlight.OutlineColor = roleColor
    end

    --// NAME
    if data.Billboard and data.Label then
        data.Billboard.Enabled = Settings.ESP and Settings.ShowNames

        if Settings.ShowRoles then
            data.Label.Text =
                player.DisplayName
                .. "\n"
                .. role
        else
            data.Label.Text = player.DisplayName
        end

        data.Label.TextColor3 = roleColor
    end
end

local function SetupPlayerESP(player)
    if player == LP then
        return
    end

    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart", 5)
        task.wait(0.2)

        if Settings.ESP then
            CreateESP(player)
        end
    end)

    player.CharacterRemoving:Connect(function()
        RemoveESP(player)
    end)

    if player.Character then
        task.spawn(function()
            task.wait(0.2)
            if Settings.ESP then
                CreateESP(player)
            end
        end)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    SetupPlayerESP(player)
end

Players.PlayerAdded:Connect(function(player)
    SetupPlayerESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

--// Refresh ESP
task.spawn(function()
    while task.wait(0.5) do
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP then
                if Settings.ESP then
                    if not ESPObjects[player] then
                        CreateESP(player)
                    else
                        UpdateESP(player)
                    end
                end
            end
        end
    end
end)

--//==================================================
--// FLY
--//==================================================

local FlyBV
local FlyBG
local FlyConnection

local function StopFly()
    Settings.Fly = false

    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end

    if FlyBV then
        FlyBV:Destroy()
        FlyBV = nil
    end

    if FlyBG then
        FlyBG:Destroy()
        FlyBG = nil
    end

    local character = LP.Character

    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

local function StartFly()
    StopFly()

    Settings.Fly = true

    local character = LP.Character

    if not character then
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then
        return
    end

    FlyBV = Instance.new("BodyVelocity")
    FlyBV.Name = "FondiFlyVelocity"
    FlyBV.MaxForce = Vector3.new(100000, 100000, 100000)
    FlyBV.Velocity = Vector3.zero
    FlyBV.Parent = root

    FlyBG = Instance.new("BodyGyro")
    FlyBG.Name = "FondiFlyGyro"
    FlyBG.MaxTorque = Vector3.new(100000, 100000, 100000)
    FlyBG.P = 10000
    FlyBG.Parent = root

    humanoid.PlatformStand = true

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not Settings.Fly then
            return
        end

        if not root.Parent then
            return
        end

        local camera = workspace.CurrentCamera
        local direction = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            direction += camera.CFrame.LookVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.S) then
            direction -= camera.CFrame.LookVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.A) then
            direction -= camera.CFrame.RightVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.D) then
            direction += camera.CFrame.RightVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            direction += Vector3.new(0, 1, 0)
        end

        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            direction -= Vector3.new(0, 1, 0)
        end

        if direction.Magnitude > 0 then
            direction = direction.Unit
        end

        FlyBV.Velocity = direction * Settings.FlySpeed
        FlyBG.CFrame = camera.CFrame
    end)
end

--//==================================================
--// NOCLIP
--//==================================================

local NoclipConnection

local function StartNoclip()
    if NoclipConnection then
        NoclipConnection:Disconnect()
    end

    Settings.Noclip = true

    NoclipConnection = RunService.Stepped:Connect(function()
        if not Settings.Noclip then
            return
        end

        local character = LP.Character

        if not character then
            return
        end

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function StopNoclip()
    Settings.Noclip = false

    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
end

--//==================================================
--// PLAYER LIST / SPECTATOR
--//==================================================

local PlayerListFrame
local SpectateLabel

local function StopSpectating()
    Settings.Spectating = false
    Settings.SpectatedPlayer = nil

    local camera = workspace.CurrentCamera

    if LP.Character then
        local humanoid = LP.Character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            camera.CameraSubject = humanoid
        end
    end

    if SpectateLabel then
        SpectateLabel.Text = "Spectating: Nobody"
    end
end

local function SpectatePlayer(player)
    if not player then
        return
    end

    if player == LP then
        StopSpectating()
        return
    end

    local character = player.Character

    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return
    end

    Settings.Spectating = true
    Settings.SpectatedPlayer = player

    workspace.CurrentCamera.CameraSubject = humanoid

    if SpectateLabel then
        SpectateLabel.Text = "Spectating: " .. player.DisplayName
    end
end

--//==================================================
--// MAIN UI
--//==================================================

local MainGui
local MainFrame

local function MakeToggle(parent, text, y, settingName, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 35)
    button.Position = UDim2.new(0, 10, 0, y)
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.GothamMedium
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    local function Refresh()
        local state = Settings[settingName]

        if state then
            button.Text = text .. "  [ON]"
            button.BackgroundColor3 = Color3.fromRGB(45, 90, 55)
        else
            button.Text = text .. "  [OFF]"
            button.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        end
    end

    button.MouseButton1Click:Connect(function()
        Settings[settingName] = not Settings[settingName]

        PlayToggleSound()

        if callback then
            callback(Settings[settingName])
        end

        Refresh()
    end)

    Refresh()

    return button
end

local function BuildUI()
    if PG:FindFirstChild("Fondi_V4") then
        PG.Fondi_V4:Destroy()
    end

    MainGui = Instance.new("ScreenGui")
    MainGui.Name = "Fondi_V4"
    MainGui.ResetOnSpawn = false
    MainGui.Enabled = true
    MainGui.Parent = PG

    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 520)
    MainFrame.Position = UDim2.new(0, 30, 0.5, -260)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = MainGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = MainFrame

    --// TITLE
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "FONDI MM2 V4.2"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = MainFrame

    --// STATUS
    SpectateLabel = Instance.new("TextLabel")
    SpectateLabel.Size = UDim2.new(1, -20, 0, 25)
    SpectateLabel.Position = UDim2.new(0, 10, 0, 43)
    SpectateLabel.BackgroundTransparency = 1
    SpectateLabel.Text = "Spectating: Nobody"
    SpectateLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    SpectateLabel.TextSize = 12
    SpectateLabel.Font = Enum.Font.Gotham
    SpectateLabel.Parent = MainFrame

    --// ESP
    MakeToggle(
        MainFrame,
        "ESP",
        75,
        "ESP",
        function()
            if not Settings.ESP then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LP then
                        RemoveESP(player)
                    end
                end
            else
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LP then
                        CreateESP(player)
                    end
                end
            end
        end
    )

    --// OUTLINE
    MakeToggle(
        MainFrame,
        "Outline",
        115,
        "Outline",
        function()
            for _, player in ipairs(Players:GetPlayers()) do
                UpdateESP(player)
            end
        end
    )

    --// TRACERS
    MakeToggle(
        MainFrame,
        "Tracers",
        155,
        "Tracers",
        function()
            -- Reserved for tracer system
        end
    )

    --// NAMES
    MakeToggle(
        MainFrame,
        "Names",
        195,
        "ShowNames",
        function()
            for _, player in ipairs(Players:GetPlayers()) do
                UpdateESP(player)
            end
        end
    )

    --// ROLES
    MakeToggle(
        MainFrame,
        "Roles",
        235,
        "ShowRoles",
        function()
            for _, player in ipairs(Players:GetPlayers()) do
                UpdateESP(player)
            end
        end
    )

    --// FLY
    MakeToggle(
        MainFrame,
        "Fly",
        275,
        "Fly",
        function(state)
            if state then
                StartFly()
            else
                StopFly()
            end
        end
    )

    --// NOCLIP
    MakeToggle(
        MainFrame,
        "Noclip",
        315,
        "Noclip",
        function(state)
            if state then
                StartNoclip()
            else
                StopNoclip()
            end
        end
    )

    --// SPEED LABEL
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, -20, 0, 25)
    speedLabel.Position = UDim2.new(0, 10, 0, 355)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Fly Speed: " .. tostring(Settings.FlySpeed)
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedLabel.TextSize = 13
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.Parent = MainFrame

    --// SPEED - BUTTONS
    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0.45, -5, 0, 30)
    minus.Position = UDim2.new(0, 10, 0, 385)
    minus.Text = "-"
    minus.TextSize = 18
    minus.Font = Enum.Font.GothamBold
    minus.TextColor3 = Color3.new(1, 1, 1)
    minus.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    minus.Parent = MainFrame

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0.45, -5, 0, 30)
    plus.Position = UDim2.new(0.55, 0, 0, 385)
    plus.Text = "+"
    plus.TextSize = 18
    plus.Font = Enum.Font.GothamBold
    plus.TextColor3 = Color3.new(1, 1, 1)
    plus.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    plus.Parent = MainFrame

    for _, button in ipairs({minus, plus}) do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = button
    end

    minus.MouseButton1Click:Connect(function()
        Settings.FlySpeed = math.max(10, Settings.FlySpeed - 10)
        speedLabel.Text = "Fly Speed: " .. tostring(Settings.FlySpeed)
        PlayToggleSound()
    end)

    plus.MouseButton1Click:Connect(function()
        Settings.FlySpeed = math.min(300, Settings.FlySpeed + 10)
        speedLabel.Text = "Fly Speed: " .. tostring(Settings.FlySpeed)
        PlayToggleSound()
    end)

    --// SPECTATE
    local spectateTitle = Instance.new("TextLabel")
    spectateTitle.Size = UDim2.new(1, -20, 0, 25)
    spectateTitle.Position = UDim2.new(0, 10, 0, 425)
    spectateTitle.BackgroundTransparency = 1
    spectateTitle.Text = "PLAYER LIST"
    spectateTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    spectateTitle.TextSize = 13
    spectateTitle.Font = Enum.Font.GothamBold
    spectateTitle.Parent = MainFrame

    local playerList = Instance.new("ScrollingFrame")
    playerList.Name = "PlayerList"
    playerList.Size = UDim2.new(1, -20, 0, 80)
    playerList.Position = UDim2.new(0, 10, 0, 450)
    playerList.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    playerList.BorderSizePixel = 0
    playerList.ScrollBarThickness = 3
    playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
    playerList.Parent = MainFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 3)
    listLayout.Parent = playerList

    PlayerListFrame = playerList

    local function RefreshPlayerList()
        for _, child in ipairs(playerList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP then
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, -5, 0, 25)
                button.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
                button.BorderSizePixel = 0
                button.Text = player.DisplayName
                button.TextColor3 = GetRoleColor(GetRole(player))
                button.TextSize = 12
                button.Font = Enum.Font.Gotham
                button.Parent = playerList

                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 5)
                corner.Parent = button

                button.MouseButton1Click:Connect(function()
                    SpectatePlayer(player)
                end)
            end
        end

        local count = #Players:GetPlayers() - 1
        playerList.CanvasSize = UDim2.new(0, 0, 0, math.max(0, count * 28))
    end

    RefreshPlayerList()

    Players.PlayerAdded:Connect(function()
        task.wait(0.2)
        RefreshPlayerList()
    end)

    Players.PlayerRemoving:Connect(function(player)
        if Settings.SpectatedPlayer == player then
            StopSpectating()
        end

        task.wait(0.1)
        RefreshPlayerList()
    end)

    --// STOP SPECTATE
    local stopButton = Instance.new("TextButton")
    stopButton.Size = UDim2.new(1, -20, 0, 30)
    stopButton.Position = UDim2.new(0, 10, 1, -40)
    stopButton.Text = "STOP SPECTATING"
    stopButton.TextColor3 = Color3.new(1, 1, 1)
    stopButton.TextSize = 12
    stopButton.Font = Enum.Font.GothamBold
    stopButton.BackgroundColor3 = Color3.fromRGB(70, 35, 35)
    stopButton.Parent = MainFrame

    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 6)
    stopCorner.Parent = stopButton

    stopButton.MouseButton1Click:Connect(function()
        StopSpectating()
        PlayToggleSound()
    end)
end

--//==================================================
--// L = TOGGLE MENU
--//==================================================

local function ToggleMenu()
    local menu = PG:FindFirstChild("Fondi_V4")

    if menu then
        menu.Enabled = not menu.Enabled
    end
end

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.L then
        ToggleMenu()
    end
end)

--//==================================================
--// RESPAWN HANDLING
--//==================================================

LP.CharacterAdded:Connect(function(character)
    StopFly()

    if Settings.Noclip then
        task.wait(0.5)
        StartNoclip()
    end

    task.wait(1)

    if Settings.Spectating then
        StopSpectating()
    end
end)

--//==================================================
--// KEY SYSTEM
--//==================================================

local function BuildKeyUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "FondiKey"
    gui.ResetOnSpawn = false
    gui.Parent = PG

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 190)
    frame.Position = UDim2.new(0.5, -175, 0.5, -95)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "FONDI MM2"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -40, 0, 40)
    box.Position = UDim2.new(0, 20, 0, 60)
    box.PlaceholderText = "Enter key..."
    box.Text = ""
    box.TextColor3 = Color3.new(1, 1, 1)
    box.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    box.BorderSizePixel = 0
    box.TextSize = 14
    box.Font = Enum.Font.Gotham
    box.Parent = frame

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = box

    local enter = Instance.new("TextButton")
    enter.Size = UDim2.new(1, -40, 0, 40)
    enter.Position = UDim2.new(0, 20, 0, 115)
    enter.Text = "ACTIVATE"
    enter.TextColor3 = Color3.new(1, 1, 1)
    enter.TextSize = 14
    enter.Font = Enum.Font.GothamBold
    enter.BackgroundColor3 = Color3.fromRGB(45, 80, 120)
    enter.BorderSizePixel = 0
    enter.Parent = frame

    local enterCorner = Instance.new("UICorner")
    enterCorner.CornerRadius = UDim.new(0, 6)
    enterCorner.Parent = enter

    local function CheckKey()
        if box.Text == KEY then
            gui:Destroy()
            BuildUI()
            Notify("FONDI MM2 activated")
        else
            box.Text = ""
            box.PlaceholderText = "Wrong key!"
        end
    end

    enter.MouseButton1Click:Connect(CheckKey)

    box.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            CheckKey()
        end
    end)
end

BuildKeyUI()
