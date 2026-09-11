--[[
    FONDI MM2 V4.1
    PLAYER LIST + SPECTATOR + FLY + SETTINGS + HIGHLIGHT ESP

    HOTKEYS:
    L = открыть/скрыть меню
    V = Fly
    B = Noclip
    P = Player List
    O = Spectator
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer
local pg = LP:WaitForChild("PlayerGui")

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local Settings = {
    ESP = true,
    Tracers = true,
    Fly = false,
    Noclip = false,

    FlySpeed = 50,

    Outline = true,
    ShowNames = true,
    ShowRoles = true,

    Spectating = false,
    SpectatedPlayer = nil,

    MenuKey = Enum.KeyCode.L,
    FlyKey = Enum.KeyCode.V,
    NoclipKey = Enum.KeyCode.B,
    PlayerListKey = Enum.KeyCode.P,
    SpectatorKey = Enum.KeyCode.O
}

local KEY = "FONDI-MM2-FOREVER"
local IsAuthenticated = false

local ESPObjects = {}
local PlayerButtons = {}

--------------------------------------------------
-- NOTIFY
--------------------------------------------------

local function Notify(text, color)
    print("[FONDI_NOTIFY]: " .. tostring(text))

    local old = pg:FindFirstChild("Fondi_Notify")

    if not old then
        old = Instance.new("ScreenGui")
        old.Name = "Fondi_Notify"
        old.ResetOnSpawn = false
        old.Parent = pg
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 45)
    frame.Position = UDim2.new(1, 20, 0.8, 0)
    frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    frame.Parent = old

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(120, 50, 255)
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = tostring(text)
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Parent = frame

    TweenService:Create(
        frame,
        TweenInfo.new(0.35, Enum.EasingStyle.Back),
        {Position = UDim2.new(1, -270, 0.8, 0)}
    ):Play()

    task.delay(2.2, function()
        if frame then
            TweenService:Create(
                frame,
                TweenInfo.new(0.3),
                {Position = UDim2.new(1, 20, 0.8, 0)}
            ):Play()

            task.wait(0.35)

            if frame then
                frame:Destroy()
            end
        end
    end)
end

--------------------------------------------------
-- ROLE DETECTION
--------------------------------------------------

local function HasTool(player, toolNames)
    if not player then
        return false
    end

    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character

    for _, name in ipairs(toolNames) do
        if backpack and backpack:FindFirstChild(name) then
            return true
        end

        if character and character:FindFirstChild(name) then
            return true
        end
    end

    return false
end

local function GetRole(player)

    if not player then
        return "Innocent"
    end

    -- Murderer
    if HasTool(player, {
        "Knife",
        "DefaultKnife",
        "KnifeServer"
    }) then
        return "Murderer"
    end

    -- Sheriff
    if HasTool(player, {
        "Gun",
        "Revolver",
        "DefaultGun",
        "SheriffGun"
    }) then
        return "Sheriff"
    end

    return "Innocent"
end

local function GetRoleColor(role)

    if role == "Murderer" then
        return Color3.fromRGB(255, 35, 35)
    end

    if role == "Sheriff" then
        return Color3.fromRGB(45, 120, 255)
    end

    return Color3.fromRGB(60, 255, 100)
end

--------------------------------------------------
-- ESP
--------------------------------------------------

local function RemoveESP(player)

    if ESPObjects[player] then

        for _, object in pairs(ESPObjects[player]) do
            if object and object.Parent then
                object:Destroy()
            end
        end

        ESPObjects[player] = nil
    end
end

local function CreateESP(player)

    if player == LP then
        return
    end

    RemoveESP(player)

    local data = {}

    --------------------------------------------------
    -- HIGHLIGHT
    --------------------------------------------------

    local highlight = Instance.new("Highlight")
    highlight.Name = "Fondi_Outline"
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.85
    highlight.OutlineTransparency = 0
    highlight.Parent = pg

    --------------------------------------------------
    -- NAME
    --------------------------------------------------

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Fondi_Name"
    billboard.Size = UDim2.new(0, 180, 0, 45)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = pg

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextStrokeTransparency = 0.2
    label.Parent = billboard

    data.Highlight = highlight
    data.Billboard = billboard
    data.Label = label

    ESPObjects[player] = data
end

local function UpdateESP(player)

    if player == LP then
        return
    end

    if not ESPObjects[player] then
        CreateESP(player)
    end

    local data = ESPObjects[player]

    if not data then
        return
    end

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not Settings.ESP or not IsAuthenticated or not character or not root then

        data.Highlight.Enabled = false
        data.Billboard.Enabled = false

        return
    end

    local role = GetRole(player)
    local color = GetRoleColor(role)

    --------------------------------------------------
    -- OUTLINE
    --------------------------------------------------

    data.Highlight.Enabled = Settings.Outline
    data.Highlight.Adornee = character

    data.Highlight.FillColor = color
    data.Highlight.OutlineColor = color

    --------------------------------------------------
    -- NAME
    --------------------------------------------------

    data.Billboard.Enabled = Settings.ShowNames
    data.Billboard.Adornee = root

    if Settings.ShowRoles then
        data.Label.Text = player.DisplayName .. "\n[" .. role .. "]"
    else
        data.Label.Text = player.DisplayName
    end

    data.Label.TextColor3 = color
end

local function RefreshAllESP()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            UpdateESP(player)
        end
    end
end

Players.PlayerAdded:Connect(function(player)

    if player ~= LP then
        CreateESP(player)

        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            UpdateESP(player)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)

    RemoveESP(player)

    if Settings.SpectatedPlayer == player then
        Settings.SpectatedPlayer = nil
        Settings.Spectating = false

        workspace.CurrentCamera.CameraSubject =
            LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LP then
        CreateESP(player)
    end
end

task.spawn(function()

    while task.wait(0.25) do

        if IsAuthenticated then
            RefreshAllESP()
        end

    end

end)

--------------------------------------------------
-- FLY
--------------------------------------------------

local flyBV
local flyBG

local function StopFly()

    if flyBV then
        flyBV:Destroy()
        flyBV = nil
    end

    if flyBG then
        flyBG:Destroy()
        flyBG = nil
    end
end

local function StartFly()

    local character = LP.Character

    if not character then
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")

    if not root then
        return
    end

    if flyBV then
        return
    end

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e7, 1e7, 1e7)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = root

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
    flyBG.D = 100
    flyBG.Parent = root

    Notify("FLY: ВКЛ", Color3.fromRGB(80, 255, 120))
end

RunService.RenderStepped:Connect(function()

    if not IsAuthenticated then
        return
    end

    if not Settings.Fly then

        StopFly()
        return
    end

    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not root then
        StopFly()
        return
    end

    if not flyBV then
        StartFly()
    end

    if not flyBV or not flyBG then
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

    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
        direction -= Vector3.new(0, 1, 0)
    end

    if direction.Magnitude > 0 then
        direction = direction.Unit
        flyBV.Velocity = direction * Settings.FlySpeed
    else
        flyBV.Velocity = Vector3.zero
    end

    flyBG.CFrame = camera.CFrame
end)

--------------------------------------------------
-- NOCLIP
--------------------------------------------------

RunService.Stepped:Connect(function()

    if not IsAuthenticated then
        return
    end

    if not Settings.Noclip then
        return
    end

    local character = LP.Character

    if not character then
        return
    end

    for _, object in ipairs(character:GetDescendants()) do

        if object:IsA("BasePart") then
            object.CanCollide = false
        end

    end

end)

--------------------------------------------------
-- SPECTATOR
--------------------------------------------------

local function StopSpectating()

    Settings.Spectating = false
    Settings.SpectatedPlayer = nil

    local character = LP.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        workspace.CurrentCamera.CameraSubject = humanoid
    end

    Notify("SPECTATOR: ВЫКЛ", Color3.fromRGB(255, 80, 80))
end

local function SpectatePlayer(player)

    if not player or player == LP then
        return
    end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        Notify("Игрок ещё не загрузился", Color3.fromRGB(255, 180, 60))
        return
    end

    Settings.Spectating = true
    Settings.SpectatedPlayer = player

    workspace.CurrentCamera.CameraSubject = humanoid

    Notify(
        "SPECTATE: " .. player.DisplayName,
        Color3.fromRGB(120, 50, 255)
    )
end

--------------------------------------------------
-- PLAYER LIST GUI
--------------------------------------------------

local playerListGui
local playerListFrame
local playerListLayout

local function CreatePlayerList()

    if playerListGui then
        return
    end

    playerListGui = Instance.new("ScreenGui")
    playerListGui.Name = "Fondi_PlayerList"
    playerListGui.ResetOnSpawn = false
    playerListGui.Parent = pg

    playerListFrame = Instance.new("Frame")
    playerListFrame.Size = UDim2.new(0, 300, 0, 350)
    playerListFrame.Position = UDim2.new(1, -320, 0.5, -175)
    playerListFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
    playerListFrame.Active = true
    playerListFrame.Draggable = true
    playerListFrame.Parent = playerListGui

    Instance.new("UICorner", playerListFrame).CornerRadius =
        UDim.new(0, 10)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(120, 50, 255)
    stroke.Thickness = 2
    stroke.Parent = playerListFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundTransparency = 1
    title.Text = "FONDI // PLAYER LIST"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.Parent = playerListFrame

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 35, 0, 35)
    close.Position = UDim2.new(1, -40, 0, 5)
    close.Text = "X"
    close.TextColor3 = Color3.new(1,1,1)
    close.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    close.Font = Enum.Font.GothamBold
    close.Parent = playerListFrame

    Instance.new("UICorner", close).CornerRadius =
        UDim.new(0, 7)

    close.MouseButton1Click:Connect(function()
        playerListGui.Enabled = false
    end)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Players"
    scroll.Size = UDim2.new(1, -20, 1, -60)
    scroll.Position = UDim2.new(0, 10, 0, 50)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.Parent = playerListFrame

    playerListLayout = Instance.new("UIListLayout")
    playerListLayout.Padding = UDim.new(0, 6)
    playerListLayout.Parent = scroll

    local function RefreshList()

        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, player in ipairs(Players:GetPlayers()) do

            if player ~= LP then

                local role = GetRole(player)
                local roleColor = GetRoleColor(role)

                local button = Instance.new("TextButton")

                button.Size = UDim2.new(1, -5, 0, 48)
                button.BackgroundColor3 = Color3.fromRGB(27, 27, 34)
                button.TextColor3 = roleColor
                button.Font = Enum.Font.GothamBold
                button.TextSize = 12
                button.Text =
                    player.DisplayName ..
                    "  [" ..
                    role ..
                    "]"

                button.Parent = scroll

                Instance.new("UICorner", button).CornerRadius =
                    UDim.new(0, 7)

                button.MouseButton1Click:Connect(function()

                    SpectatePlayer(player)

                end)

            end
        end

        task.wait()

        scroll.CanvasSize = UDim2.new(
            0,
            0,
            0,
            playerListLayout.AbsoluteContentSize.Y + 10
        )
    end

    task.spawn(function()

        while playerListGui and playerListGui.Parent do

            if playerListGui.Enabled then
                RefreshList()
            end

            task.wait(1)

        end

    end)

    playerListGui.Enabled = true
end

--------------------------------------------------
-- MAIN MENU
--------------------------------------------------

local MainGUI
local MainFrame

local function BuildUI()

    if MainGUI then
        MainGUI.Enabled = true
        return
    end

    MainGUI = Instance.new("ScreenGui")
    MainGUI.Name = "Fondi_V41"
    MainGUI.ResetOnSpawn = false
    MainGUI.Parent = pg

    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 430)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -215)
    MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = MainGUI

    Instance.new("UICorner", MainFrame).CornerRadius =
        UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(120, 50, 255)
    stroke.Thickness = 2
    stroke.Parent = MainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 55)
    title.BackgroundTransparency = 1
    title.Text = "FONDI MM2 V4.1"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 18
    title.Parent = MainFrame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -70)
    scroll.Position = UDim2.new(0, 10, 0, 60)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.Parent = MainFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 7)
    layout.Parent = scroll

    local function Toggle(name, setting)

        local button = Instance.new("TextButton")

        button.Size = UDim2.new(1, -5, 0, 43)
        button.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
        button.TextColor3 = Color3.new(1,1,1)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 12
        button.Parent = scroll

        Instance.new("UICorner", button).CornerRadius =
            UDim.new(0, 8)

        local function Update()

            local enabled = Settings[setting]

            button.Text =
                name ..
                " : " ..
                (enabled and "ON" or "OFF")

            if enabled then
                button.BackgroundColor3 =
                    Color3.fromRGB(90, 40, 180)
            else
                button.BackgroundColor3 =
                    Color3.fromRGB(28, 28, 35)
            end

        end

        Update()

        button.MouseButton1Click:Connect(function()

            Settings[setting] = not Settings[setting]

            Update()

            Notify(
                name .. ": " ..
                (Settings[setting] and "ВКЛ" or "ВЫКЛ"),
                Settings[setting]
                and Color3.fromRGB(70,255,120)
                or Color3.fromRGB(255,70,70)
            )

            if setting == "Fly" and not Settings.Fly then
                StopFly()
            end

        end)

    end

    Toggle("ESP", "ESP")
    Toggle("OUTLINE", "Outline")
    Toggle("NAMES", "ShowNames")
    Toggle("ROLES", "ShowRoles")
    Toggle("TRACERS", "Tracers")
    Toggle("FLY", "Fly")
    Toggle("NOCLIP", "Noclip")

    --------------------------------------------------
    -- PLAYER LIST
    --------------------------------------------------

    local playerButton = Instance.new("TextButton")

    playerButton.Size = UDim2.new(1, -5, 0, 43)
    playerButton.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    playerButton.Text = "PLAYER LIST"
    playerButton.TextColor3 = Color3.new(1,1,1)
    playerButton.Font = Enum.Font.GothamBold
    playerButton.TextSize = 12
    playerButton.Parent = scroll

    Instance.new("UICorner", playerButton).CornerRadius =
        UDim.new(0, 8)

    playerButton.MouseButton1Click:Connect(function()

        CreatePlayerList()

        if playerListGui then
            playerListGui.Enabled = true
        end

    end)

    --------------------------------------------------
    -- STOP SPECTATE
    --------------------------------------------------

    local spectateButton = Instance.new("TextButton")

    spectateButton.Size = UDim2.new(1, -5, 0, 43)
    spectateButton.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    spectateButton.Text = "STOP SPECTATING"
    spectateButton.TextColor3 = Color3.new(1,1,1)
    spectateButton.Font = Enum.Font.GothamBold
    spectateButton.TextSize = 12
    spectateButton.Parent = scroll

    Instance.new("UICorner", spectateButton).CornerRadius =
        UDim.new(0, 8)

    spectateButton.MouseButton1Click:Connect(function()
        StopSpectating()
    end)

    --------------------------------------------------
    -- FLY SPEED
    --------------------------------------------------

    local speedBox = Instance.new("TextBox")

    speedBox.Size = UDim2.new(1, -5, 0, 43)
    speedBox.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    speedBox.TextColor3 = Color3.new(1,1,1)
    speedBox.PlaceholderText = "Fly Speed: 50"
    speedBox.Text = ""
    speedBox.Font = Enum.Font.GothamBold
    speedBox.TextSize = 12
    speedBox.ClearTextOnFocus = false
    speedBox.Parent = scroll

    Instance.new("UICorner", speedBox).CornerRadius =
        UDim.new(0, 8)

    speedBox.FocusLost:Connect(function()

        local number = tonumber(speedBox.Text)

        if number then

            Settings.FlySpeed =
                math.clamp(number, 1, 500)

            speedBox.Text = ""

            Notify(
                "Fly Speed: " ..
                Settings.FlySpeed,
                Color3.fromRGB(120,50,255)
            )

        end

    end)

    task.wait()

    scroll.CanvasSize = UDim2.new(
        0,
        0,
        0,
        layout.AbsoluteContentSize.Y + 15
    )
end

--------------------------------------------------
-- HOTKEYS
--------------------------------------------------

UIS.InputBegan:Connect(function(input, processed)

    if processed or not IsAuthenticated then
        return
    end

    --------------------------------------------------
    -- MENU
    --------------------------------------------------

    if input.KeyCode == Settings.MenuKey then

        if MainGUI then

            MainGUI.Enabled =
                not MainGUI.Enabled

        end

    --------------------------------------------------
    -- FLY
    --------------------------------------------------

    elseif input.KeyCode == Settings.FlyKey then

        Settings.Fly =
            not Settings.Fly

        if not Settings.Fly then
            StopFly()
        end

        Notify(
            "Fly: " ..
            (Settings.Fly and "ВКЛ" or "ВЫКЛ"),
            Settings.Fly
            and Color3.fromRGB(70,255,120)
            or Color3.fromRGB(255,70,70)
        )

    --------------------------------------------------
    -- NOCLIP
    --------------------------------------------------

    elseif input.KeyCode == Settings.NoclipKey then

        Settings.Noclip =
            not Settings.Noclip

        Notify(
            "Noclip: " ..
            (Settings.Noclip and "ВКЛ" or "ВЫКЛ"),
            Settings.Noclip
            and Color3.fromRGB(70,255,120)
            or Color3.fromRGB(255,70,70)
        )

    --------------------------------------------------
    -- PLAYER LIST
    --------------------------------------------------

    elseif input.KeyCode == Settings.PlayerListKey then

        CreatePlayerList()

        playerListGui.Enabled =
            not playerListGui.Enabled

    --------------------------------------------------
    -- SPECTATOR
    --------------------------------------------------

    elseif input.KeyCode == Settings.SpectatorKey then

        if Settings.Spectating then

            StopSpectating()

        else

            Notify(
                "Выбери игрока в Player List",
                Color3.fromRGB(120,50,255)
            )

            CreatePlayerList()
            playerListGui.Enabled = true

        end

    end

end)

--------------------------------------------------
-- AUTH WINDOW
--------------------------------------------------

local keyGui = Instance.new("ScreenGui")
keyGui.Name = "Fondi_Key"
keyGui.ResetOnSpawn = false
keyGui.Parent = pg

local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0, 320, 0, 190)
keyFrame.Position = UDim2.new(0.5, -160, 0.4, 0)
keyFrame.BackgroundColor3 = Color3.fromRGB(14,14,20)
keyFrame.Parent = keyGui

Instance.new("UICorner", keyFrame).CornerRadius =
    UDim.new(0, 12)

local keyStroke = Instance.new("UIStroke")
keyStroke.Color = Color3.fromRGB(120,50,255)
keyStroke.Thickness = 2
keyStroke.Parent = keyFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,45)
title.BackgroundTransparency = 1
title.Text = "FONDI MM2"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.Parent = keyFrame

local box = Instance.new("TextBox")
box.Size = UDim2.new(0.8,0,0,40)
box.Position = UDim2.new(0.1,0,0.28,0)
box.PlaceholderText = "ВВЕДИТЕ КЛЮЧ"
box.BackgroundColor3 = Color3.fromRGB(8,8,12)
box.TextColor3 = Color3.new(1,1,1)
box.Font = Enum.Font.GothamBold
box.TextSize = 12
box.Parent = keyFrame

Instance.new("UICorner", box).CornerRadius =
    UDim.new(0, 7)

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.8,0,0,40)
btn.Position = UDim2.new(0.1,0,0.57,0)
btn.Text = "АКТИВИРОВАТЬ"
btn.BackgroundColor3 = Color3.fromRGB(120,50,255)
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 12
btn.Parent = keyFrame

Instance.new("UICorner", btn).CornerRadius =
    UDim.new(0, 7)

--------------------------------------------------
-- AUTH
--------------------------------------------------

btn.MouseButton1Click:Connect(function()

    if box.Text == KEY then

        IsAuthenticated = true

        keyGui:Destroy()

        BuildUI()

        Notify(
            "FONDI MM2 V4.1 LOADED",
            Color3.fromRGB(70,255,120)
        )

    else

        box.Text = ""

        box.PlaceholderText =
            "НЕВЕРНЫЙ КЛЮЧ!"

        Notify(
            "Неверный ключ",
            Color3.fromRGB(255,60,60)
        )

    end

end)

print("================================")
print(" FONDI MM2 V4.1")
print(" Player List")
print(" Spectator")
print(" Highlight ESP")
print(" Fly")
print(" Noclip")
print(" Settings")
print("================================")
