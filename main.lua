--[[
    FONDI MM2 V4.3
    ESP REWORKED
    - ESP survives death
    - ESP survives round restart
    - Automatic CharacterAdded reconnect
    - Automatic CharacterRemoving cleanup
    - Role refresh
    - Murderer = RED
    - Sheriff = BLUE
    - Innocent = GREEN
    - Outline
    - Names
    - Fly
    - Noclip
    - Player List
    - Spectator
    - Toggle Sound
    - L = Menu
]]

--==================================================
-- SERVICES
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

--==================================================
-- SETTINGS
--==================================================

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
local IsAuthenticated = false

--==================================================
-- TOGGLE SOUND
--==================================================

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

--==================================================
-- NOTIFICATION
--==================================================

local function Notify(text, color)

    print("[FONDI_NOTIFY]: " .. tostring(text))

    local old = PG:FindFirstChild("Fondi_Notify")

    if old then
        old:Destroy()
    end

    local sg = Instance.new("ScreenGui")
    sg.Name = "Fondi_Notify"
    sg.ResetOnSpawn = false
    sg.Parent = PG

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 240, 0, 45)
    frame.Position = UDim2.new(1, 10, 0.8, 0)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    frame.BorderSizePixel = 0
    frame.Parent = sg

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(120, 50, 255)
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 1, 0)
    lbl.Position = UDim2.new(0, 5, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.Parent = frame

    frame:TweenPosition(
        UDim2.new(1, -250, 0.8, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Back,
        0.5,
        true
    )

    task.delay(2.5, function()

        if frame and frame.Parent then

            frame:TweenPosition(
                UDim2.new(1, 10, 0.8, 0),
                Enum.EasingDirection.In,
                Enum.EasingStyle.Quad,
                0.5,
                true
            )

            task.wait(0.5)

            if sg then
                sg:Destroy()
            end
        end

    end)
end

--==================================================
-- ROLE SYSTEM
--==================================================

local function GetRole(player)

    if not player then
        return "Innocent"
    end

    local backpack = player:FindFirstChildOfClass("Backpack")
    local character = player.Character

    -- MURDERER

    if backpack and backpack:FindFirstChild("Knife") then
        return "Murderer"
    end

    if character and character:FindFirstChild("Knife") then
        return "Murderer"
    end

    -- SHERIFF

    if backpack then

        if backpack:FindFirstChild("Gun")
            or backpack:FindFirstChild("Revolver") then

            return "Sheriff"
        end
    end

    if character then

        if character:FindFirstChild("Gun")
            or character:FindFirstChild("Revolver") then

            return "Sheriff"
        end
    end

    return "Innocent"
end

local function GetRoleColor(role)

    if role == "Murderer" then
        return Color3.fromRGB(255, 40, 40)

    elseif role == "Sheriff" then
        return Color3.fromRGB(50, 120, 255)

    else
        return Color3.fromRGB(70, 255, 100)
    end
end

--==================================================
-- ESP CORE
--==================================================

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "FondiESP"
ESPFolder.Parent = PG

local ESPObjects = {}

-- IMPORTANT:
-- UpdateESP объявляется заранее, чтобы CreateESP
-- мог безопасно её использовать.

local UpdateESP

--==================================================
-- REMOVE ESP
--==================================================

local function RemoveESP(player)

    local data = ESPObjects[player]

    if not data then
        return
    end

    if data.Highlight then
        pcall(function()
            data.Highlight:Destroy()
        end)
    end

    if data.Billboard then
        pcall(function()
            data.Billboard:Destroy()
        end)
    end

    if data.Tracer then
        pcall(function()
            data.Tracer:Destroy()
        end)
    end

    ESPObjects[player] = nil
end

--==================================================
-- CREATE ESP
--==================================================

local function CreateESP(player)

    if player == LP then
        return
    end

    if not player or not player.Parent then
        return
    end

    local character = player.Character

    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root then
        return
    end

    -- удаляем старый ESP
    RemoveESP(player)

    local data = {}

    --==================================================
    -- HIGHLIGHT
    --==================================================

    local highlight = Instance.new("Highlight")

    highlight.Name = "FondiHighlight"
    highlight.Adornee = character

    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    highlight.FillTransparency = 0.78
    highlight.OutlineTransparency = 0

    highlight.Parent = ESPFolder

    data.Highlight = highlight

    --==================================================
    -- NAME
    --==================================================

    local billboard = Instance.new("BillboardGui")

    billboard.Name = "FondiName"
    billboard.Adornee = root

    billboard.Size = UDim2.new(0, 220, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)

    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 10000

    billboard.Parent = ESPFolder

    local label = Instance.new("TextLabel")

    label.Name = "Info"

    label.Size = UDim2.new(1, 0, 1, 0)

    label.BackgroundTransparency = 1

    label.TextStrokeTransparency = 0

    label.TextStrokeColor3 = Color3.new(0, 0, 0)

    label.Font = Enum.Font.GothamBold
    label.TextSize = 14

    label.Parent = billboard

    data.Billboard = billboard
    data.Label = label

    --==================================================
    -- TRACER
    --==================================================

    local tracer = Instance.new("Beam")

    tracer.Name = "FondiTracer"

    tracer.FaceCamera = true

    tracer.Width0 = 0.04
    tracer.Width1 = 0.04

    tracer.Transparency = NumberSequence.new(0.15)

    tracer.Parent = ESPFolder

    local attachment0 = Instance.new("Attachment")
    attachment0.Name = "FondiTracerStart"

    local myCharacter = LP.Character

    if myCharacter then

        local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")

        if myRoot then
            attachment0.Parent = myRoot
        end
    end

    local attachment1 = Instance.new("Attachment")
    attachment1.Name = "FondiTracerEnd"
    attachment1.Parent = root

    tracer.Attachment0 = attachment0
    tracer.Attachment1 = attachment1

    data.Tracer = tracer
    data.TracerStart = attachment0
    data.TracerEnd = attachment1

    ESPObjects[player] = data

    UpdateESP(player)
end

--==================================================
-- UPDATE ESP
--==================================================

UpdateESP = function(player)

    if player == LP then
        return
    end

    local data = ESPObjects[player]

    if not data then
        return
    end

    local character = player.Character

    if not character then
        RemoveESP(player)
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root then
        return
    end

    --==================================================
    -- ROLE
    --==================================================

    local role = GetRole(player)
    local roleColor = GetRoleColor(role)

    --==================================================
    -- HIGHLIGHT
    --==================================================

    if data.Highlight then

        data.Highlight.Adornee = character

        data.Highlight.Enabled = Settings.ESP

        data.Highlight.FillColor = roleColor
        data.Highlight.OutlineColor = roleColor

        data.Highlight.FillTransparency = 0.78

        if Settings.Outline then
            data.Highlight.OutlineTransparency = 0
        else
            data.Highlight.OutlineTransparency = 1
        end
    end

    --==================================================
    -- NAME
    --==================================================

    if data.Billboard and data.Label then

        data.Billboard.Adornee = root

        data.Billboard.Enabled =
            Settings.ESP
            and Settings.ShowNames

        if Settings.ShowRoles then

            data.Label.Text =
                player.DisplayName
                .. "\n"
                .. role

        else

            data.Label.Text =
                player.DisplayName
        end

        data.Label.TextColor3 = roleColor
    end

    --==================================================
    -- TRACER
    --==================================================

    if data.Tracer then

        data.Tracer.Enabled =
            Settings.ESP
            and Settings.Tracers

        data.Tracer.Color = ColorSequence.new(roleColor)

        if data.TracerEnd then
            data.TracerEnd.Parent = root
        end

        local myCharacter = LP.Character

        if myCharacter then

            local myRoot =
                myCharacter:FindFirstChild("HumanoidRootPart")

            if myRoot and data.TracerStart then
                data.TracerStart.Parent = myRoot
            end
        end
    end
end

--==================================================
-- CHARACTER SYSTEM
--==================================================

local PlayerConnections = {}

local function DisconnectPlayerConnections(player)

    local connections = PlayerConnections[player]

    if not connections then
        return
    end

    for _, connection in ipairs(connections) do

        if connection then
            pcall(function()
                connection:Disconnect()
            end)
        end
    end

    PlayerConnections[player] = nil
end

local function SetupPlayer(player)

    if player == LP then
        return
    end

    DisconnectPlayerConnections(player)

    PlayerConnections[player] = {}

    --==================================================
    -- CHARACTER ADDED
    --==================================================

    local characterAdded =
        player.CharacterAdded:Connect(function(character)

            -- Старый ESP сразу удаляем
            RemoveESP(player)

            -- Ждём новый персонаж
            local root =
                character:WaitForChild(
                    "HumanoidRootPart",
                    10
                )

            if not root then
                return
            end

            -- Небольшая задержка нужна MM2,
            -- потому что Knife/Gun могут появляться
            -- чуть позже персонажа.

            task.wait(0.25)

            if player.Parent
                and player.Character == character
                and Settings.ESP then

                CreateESP(player)
            end
        end)

    table.insert(
        PlayerConnections[player],
        characterAdded
    )

    --==================================================
    -- CHARACTER REMOVING
    --==================================================

    local characterRemoving =
        player.CharacterRemoving:Connect(function(character)

            RemoveESP(player)

        end)

    table.insert(
        PlayerConnections[player],
        characterRemoving
    )

    --==================================================
    -- BACKPACK CHANGES
    --==================================================

    local function WatchBackpack(backpack)

        if not backpack then
            return
        end

        local childAdded =
            backpack.ChildAdded:Connect(function()

                task.wait(0.05)

                if Settings.ESP then
                    UpdateESP(player)
                end
            end)

        local childRemoved =
            backpack.ChildRemoved:Connect(function()

                task.wait(0.05)

                if Settings.ESP then
                    UpdateESP(player)
                end
            end)

        table.insert(
            PlayerConnections[player],
            childAdded
        )

        table.insert(
            PlayerConnections[player],
            childRemoved
        )
    end

    local backpack =
        player:FindFirstChildOfClass("Backpack")

    if backpack then
        WatchBackpack(backpack)
    end

    --==================================================
    -- CURRENT CHARACTER
    --==================================================

    if player.Character then

        task.spawn(function()

            local root =
                player.Character:WaitForChild(
                    "HumanoidRootPart",
                    5
                )

            if root and Settings.ESP then

                task.wait(0.2)

                if player.Character then
                    CreateESP(player)
                end
            end

        end)
    end
end

--==================================================
-- INITIAL PLAYERS
--==================================================

for _, player in ipairs(Players:GetPlayers()) do

    if player ~= LP then
        SetupPlayer(player)
    end
end

--==================================================
-- PLAYER ADDED
--==================================================

Players.PlayerAdded:Connect(function(player)

    SetupPlayer(player)

end)

--==================================================
-- PLAYER REMOVING
--==================================================

Players.PlayerRemoving:Connect(function(player)

    RemoveESP(player)

    DisconnectPlayerConnections(player)

end)

--==================================================
-- ESP AUTO REPAIR
--==================================================

task.spawn(function()

    while task.wait(0.35) do

        if Settings.ESP and IsAuthenticated then

            for _, player in ipairs(Players:GetPlayers()) do

                if player ~= LP then

                    local character = player.Character

                    if character then

                        local root =
                            character:FindFirstChild(
                                "HumanoidRootPart"
                            )

                        if root then

                            -- ESP отсутствует
                            if not ESPObjects[player] then

                                CreateESP(player)

                            else

                                -- ESP есть, но персонаж уже новый
                                local data =
                                    ESPObjects[player]

                                if data.Highlight
                                    and data.Highlight.Adornee ~= character then

                                    CreateESP(player)

                                else

                                    UpdateESP(player)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

--==================================================
-- ROLE FAST REFRESH
--==================================================

task.spawn(function()

    while task.wait(0.15) do

        if Settings.ESP and IsAuthenticated then

            for player, _ in pairs(ESPObjects) do

                if player
                    and player.Parent
                    and player.Character then

                    UpdateESP(player)
                end
            end
        end
    end
end)

--==================================================
-- FLY
--==================================================

local flyBV = nil
local flyBG = nil
local flyConnection = nil

local function StopFly()

    Settings.Fly = false

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if flyBV then
        flyBV:Destroy()
        flyBV = nil
    end

    if flyBG then
        flyBG:Destroy()
        flyBG = nil
    end

    local character = LP.Character

    if character then

        local humanoid =
            character:FindFirstChildOfClass("Humanoid")

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

    local root =
        character:FindFirstChild("HumanoidRootPart")

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then
        return
    end

    flyBV = Instance.new("BodyVelocity")

    flyBV.Name = "FondiFlyVelocity"

    flyBV.MaxForce =
        Vector3.new(
            1000000,
            1000000,
            1000000
        )

    flyBV.Velocity = Vector3.zero

    flyBV.Parent = root

    flyBG = Instance.new("BodyGyro")

    flyBG.Name = "FondiFlyGyro"

    flyBG.MaxTorque =
        Vector3.new(
            1000000,
            1000000,
            1000000
        )

    flyBG.P = 10000

    flyBG.Parent = root

    humanoid.PlatformStand = true

    flyConnection =
        RunService.RenderStepped:Connect(function()

            if not Settings.Fly then
                return
            end

            if not root
                or not root.Parent
                or not flyBV
                or not flyBG then

                return
            end

            local camera =
                workspace.CurrentCamera

            if not camera then
                return
            end

            local direction =
                Vector3.zero

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

                direction =
                    direction.Unit

            end

            flyBV.Velocity =
                direction * Settings.FlySpeed

            flyBG.CFrame =
                camera.CFrame
        end)
end

--==================================================
-- NOCLIP
--==================================================

local noclipConnection = nil

local function StartNoclip()

    if noclipConnection then
        noclipConnection:Disconnect()
    end

    Settings.Noclip = true

    noclipConnection =
        RunService.Stepped:Connect(function()

            if not Settings.Noclip then
                return
            end

            local character =
                LP.Character

            if not character then
                return
            end

            for _, part in ipairs(
                character:GetDescendants()
            ) do

                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
end

local function StopNoclip()

    Settings.Noclip = false

    if noclipConnection then

        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

--==================================================
-- SPECTATOR
--==================================================

local SpectateLabel = nil

local function StopSpectating()

    Settings.Spectating = false
    Settings.SpectatedPlayer = nil

    local camera =
        workspace.CurrentCamera

    if camera and LP.Character then

        local humanoid =
            LP.Character:FindFirstChildOfClass(
                "Humanoid"
            )

        if humanoid then
            camera.CameraSubject = humanoid
        end
    end

    if SpectateLabel then
        SpectateLabel.Text =
            "Spectating: Nobody"
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

    local character =
        player.Character

    if not character then
        return
    end

    local humanoid =
        character:FindFirstChildOfClass(
            "Humanoid"
        )

    if not humanoid then
        return
    end

    Settings.Spectating = true
    Settings.SpectatedPlayer = player

    workspace.CurrentCamera.CameraSubject =
        humanoid

    if SpectateLabel then

        SpectateLabel.Text =
            "Spectating: "
            .. player.DisplayName
    end
end

--==================================================
-- UI
--==================================================

local function MakeToggle(
    parent,
    text,
    y,
    settingName,
    callback
)

    local button =
        Instance.new("TextButton")

    button.Size =
        UDim2.new(1, -20, 0, 36)

    button.Position =
        UDim2.new(0, 10, 0, y)

    button.BackgroundColor3 =
        Color3.fromRGB(35, 35, 42)

    button.BorderSizePixel = 0

    button.TextColor3 =
        Color3.new(1, 1, 1)

    button.TextSize = 13

    button.Font =
        Enum.Font.GothamBold

    button.Parent = parent

    Instance.new("UICorner", button).CornerRadius =
        UDim.new(0, 6)

    local function Refresh()

        local state =
            Settings[settingName]

        if state then

            button.Text =
                text .. "  [ON]"

            button.BackgroundColor3 =
                Color3.fromRGB(
                    55,
                    100,
                    65
                )

        else

            button.Text =
                text .. "  [OFF]"

            button.BackgroundColor3 =
                Color3.fromRGB(
                    35,
                    35,
                    42
                )
        end
    end

    button.MouseButton1Click:Connect(function()

        Settings[settingName] =
            not Settings[settingName]

        PlayToggleSound()

        if callback then
            callback(
                Settings[settingName]
            )
        end

        Refresh()

        Notify(
            text
            .. ": "
            .. (
                Settings[settingName]
                and "ВКЛ"
                or "ВЫКЛ"
            ),
            Settings[settingName]
            and Color3.fromRGB(70, 255, 100)
            or Color3.fromRGB(255, 70, 70)
        )
    end)

    Refresh()

    return button
end

--==================================================
-- BUILD UI
--==================================================

local function BuildUI()

    local old =
        PG:FindFirstChild("Fondi_V4")

    if old then
        old:Destroy()
    end

    local gui =
        Instance.new("ScreenGui")

    gui.Name = "Fondi_V4"
    gui.ResetOnSpawn = false
    gui.Enabled = true
    gui.Parent = PG

    local main =
        Instance.new("Frame")

    main.Size =
        UDim2.new(0, 310, 0, 500)

    main.Position =
        UDim2.new(
            0,
            25,
            0.5,
            -250
        )

    main.BackgroundColor3 =
        Color3.fromRGB(
            18,
            18,
            22
        )

    main.BorderSizePixel = 0

    main.Active = true
    main.Draggable = true

    main.Parent = gui

    Instance.new("UICorner", main).CornerRadius =
        UDim.new(0, 10)

    local stroke =
        Instance.new("UIStroke")

    stroke.Color =
        Color3.fromRGB(
            120,
            50,
            255
        )

    stroke.Thickness = 1.5
    stroke.Parent = main

    --==================================================
    -- TITLE
    --==================================================

    local title =
        Instance.new("TextLabel")

    title.Size =
        UDim2.new(1, -20, 0, 35)

    title.Position =
        UDim2.new(0, 10, 0, 8)

    title.BackgroundTransparency = 1

    title.Text =
        "FONDI MM2 V4.3"

    title.TextColor3 =
        Color3.new(1, 1, 1)

    title.Font =
        Enum.Font.GothamBold

    title.TextSize = 20

    title.Parent = main

    --==================================================
    -- SPECTATE STATUS
    --==================================================

    SpectateLabel =
        Instance.new("TextLabel")

    SpectateLabel.Size =
        UDim2.new(1, -20, 0, 22)

    SpectateLabel.Position =
        UDim2.new(0, 10, 0, 42)

    SpectateLabel.BackgroundTransparency = 1

    SpectateLabel.Text =
        "Spectating: Nobody"

    SpectateLabel.TextColor3 =
        Color3.fromRGB(
            160,
            160,
            160
        )

    SpectateLabel.Font =
        Enum.Font.Gotham

    SpectateLabel.TextSize = 11

    SpectateLabel.Parent = main

    --==================================================
    -- TOGGLES
    --==================================================

    MakeToggle(
        main,
        "ESP",
        70,
        "ESP",
        function(state)

            if state then

                for _, player in ipairs(
                    Players:GetPlayers()
                ) do

                    if player ~= LP then

                        if player.Character then
                            CreateESP(player)
                        end
                    end
                end

            else

                for player, _ in pairs(
                    ESPObjects
                ) do

                    RemoveESP(player)
                end
            end
        end
    )

    MakeToggle(
        main,
        "Outline",
        110,
        "Outline",
        function()

            for player, _ in pairs(
                ESPObjects
            ) do

                UpdateESP(player)
            end
        end
    )

    MakeToggle(
        main,
        "Tracers",
        150,
        "Tracers",
        function()

            for player, _ in pairs(
                ESPObjects
            ) do

                UpdateESP(player)
            end
        end
    )

    MakeToggle(
        main,
        "Names",
        190,
        "ShowNames",
        function()

            for player, _ in pairs(
                ESPObjects
            ) do

                UpdateESP(player)
            end
        end
    )

    MakeToggle(
        main,
        "Roles",
        230,
        "ShowRoles",
        function()

            for player, _ in pairs(
                ESPObjects
            ) do

                UpdateESP(player)
            end
        end
    )

    MakeToggle(
        main,
        "Fly",
        270,
        "Fly",
        function(state)

            if state then
                StartFly()
            else
                StopFly()
            end
        end
    )

    MakeToggle(
        main,
        "Noclip",
        310,
        "Noclip",
        function(state)

            if state then
                StartNoclip()
            else
                StopNoclip()
            end
        end
    )

    --==================================================
    -- SPEED
    --==================================================

    local speedLabel =
        Instance.new("TextLabel")

    speedLabel.Size =
        UDim2.new(1, -20, 0, 25)

    speedLabel.Position =
        UDim2.new(0, 10, 0, 350)

    speedLabel.BackgroundTransparency = 1

    speedLabel.Text =
        "Fly Speed: "
        .. tostring(
            Settings.FlySpeed
        )

    speedLabel.TextColor3 =
        Color3.fromRGB(
            200,
            200,
            200
        )

    speedLabel.Font =
        Enum.Font.Gotham

    speedLabel.TextSize = 12

    speedLabel.Parent = main

    local minus =
        Instance.new("TextButton")

    minus.Size =
        UDim2.new(
            0.45,
            -5,
            0,
            30
        )

    minus.Position =
        UDim2.new(
            0,
            10,
            0,
            380
        )

    minus.Text = "-"

    minus.TextSize = 18

    minus.Font =
        Enum.Font.GothamBold

    minus.TextColor3 =
        Color3.new(1, 1, 1)

    minus.BackgroundColor3 =
        Color3.fromRGB(
            35,
            35,
            42
        )

    minus.Parent = main

    Instance.new("UICorner", minus).CornerRadius =
        UDim.new(0, 6)

    local plus =
        Instance.new("TextButton")

    plus.Size =
        UDim2.new(
            0.45,
            -5,
            0,
            30
        )

    plus.Position =
        UDim2.new(
            0.55,
            0,
            0,
            380
        )

    plus.Text = "+"

    plus.TextSize = 18

    plus.Font =
        Enum.Font.GothamBold

    plus.TextColor3 =
        Color3.new(1, 1, 1)

    plus.BackgroundColor3 =
        Color3.fromRGB(
            35,
            35,
            42
        )

    plus.Parent = main

    Instance.new("UICorner", plus).CornerRadius =
        UDim.new(0, 6)

    minus.MouseButton1Click:Connect(function()

        Settings.FlySpeed =
            math.max(
                10,
                Settings.FlySpeed - 10
            )

        speedLabel.Text =
            "Fly Speed: "
            .. tostring(
                Settings.FlySpeed
            )

        PlayToggleSound()
    end)

    plus.MouseButton1Click:Connect(function()

        Settings.FlySpeed =
            math.min(
                300,
                Settings.FlySpeed + 10
            )

        speedLabel.Text =
            "Fly Speed: "
            .. tostring(
                Settings.FlySpeed
            )

        PlayToggleSound()
    end)

    --==================================================
    -- STOP SPECTATE
    --==================================================

    local stop =
        Instance.new("TextButton")

    stop.Size =
        UDim2.new(
            1,
            -20,
            0,
            30
        )

    stop.Position =
        UDim2.new(
            0,
            10,
            0,
            420
        )

    stop.Text =
        "STOP SPECTATING"

    stop.TextColor3 =
        Color3.new(1, 1, 1)

    stop.TextSize = 12

    stop.Font =
        Enum.Font.GothamBold

    stop.BackgroundColor3 =
        Color3.fromRGB(
            70,
            35,
            35
        )

    stop.Parent = main

    Instance.new("UICorner", stop).CornerRadius =
        UDim.new(0, 6)

    stop.MouseButton1Click:Connect(function()

        StopSpectating()

        PlayToggleSound()
    end)

    --==================================================
    -- PLAYER LIST
    --==================================================

    local playerList =
        Instance.new("ScrollingFrame")

    playerList.Name =
        "PlayerList"

    playerList.Size =
        UDim2.new(
            1,
            -20,
            0,
            35
        )

    playerList.Position =
        UDim2.new(
            0,
            10,
            0,
            457
        )

    playerList.BackgroundColor3 =
        Color3.fromRGB(
            25,
            25,
            30
        )

    playerList.BorderSizePixel = 0

    playerList.ScrollBarThickness = 3

    playerList.Parent = main

    Instance.new("UICorner", playerList).CornerRadius =
        UDim.new(0, 6)

    local layout =
        Instance.new("UIListLayout")

    layout.Padding =
        UDim.new(0, 3)

    layout.Parent = playerList

    local function RefreshPlayerList()

        for _, child in ipairs(
            playerList:GetChildren()
        ) do

            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        local players =
            Players:GetPlayers()

        for _, player in ipairs(players) do

            if player ~= LP then

                local button =
                    Instance.new("TextButton")

                button.Size =
                    UDim2.new(
                        1,
                        -5,
                        0,
                        25
                    )

                button.BackgroundColor3 =
                    Color3.fromRGB(
                        35,
                        35,
                        42
                    )

                button.BorderSizePixel = 0

                button.Text =
                    player.DisplayName

                button.TextColor3 =
                    GetRoleColor(
                        GetRole(player)
                    )

                button.TextSize = 11

                button.Font =
                    Enum.Font.Gotham

                button.Parent =
                    playerList

                Instance.new("UICorner", button).CornerRadius =
                    UDim.new(0, 5)

                button.MouseButton1Click:Connect(
                    function()

                        SpectatePlayer(
                            player
                        )
                    end
                )
            end
        end

        playerList.CanvasSize =
            UDim2.new(
                0,
                0,
                0,
                math.max(
                    35,
                    (#players - 1) * 28
                )
            )
    end

    RefreshPlayerList()

    Players.PlayerAdded:Connect(
        function()

            task.wait(0.2)

            RefreshPlayerList()
        end
    )

    Players.PlayerRemoving:Connect(
        function(player)

            if Settings.SpectatedPlayer
                == player then

                StopSpectating()
            end

            task.wait(0.1)

            RefreshPlayerList()
        end
    )
end

--==================================================
-- LOCAL PLAYER RESPAWN
--==================================================

LP.CharacterAdded:Connect(function(character)

    -- Fly objects от старого персонажа
    StopFly()

    task.wait(0.5)

    if Settings.Noclip then
        StartNoclip()
    end

    -- Если смотрели за игроком,
    -- возвращаем камеру себе.

    if Settings.Spectating then
        StopSpectating()
    end

end)

--==================================================
-- L = TOGGLE MENU
--==================================================

local function ToggleMenu()

    local menu =
        PG:FindFirstChild(
            "Fondi_V4"
        )

    if menu then

        menu.Enabled =
            not menu.Enabled
    end
end

UIS.InputBegan:Connect(function(input)

    if input.KeyCode
        == Enum.KeyCode.L then

        ToggleMenu()
    end

end)

--==================================================
-- KEY SYSTEM
--==================================================

local function BuildKeyUI()

    local gui =
        Instance.new("ScreenGui")

    gui.Name =
        "FondiKey"

    gui.ResetOnSpawn = false

    gui.Parent = PG

    local frame =
        Instance.new("Frame")

    frame.Size =
        UDim2.new(
            0,
            350,
            0,
            190
        )

    frame.Position =
        UDim2.new(
            0.5,
            -175,
            0.5,
            -95
        )

    frame.BackgroundColor3 =
        Color3.fromRGB(
            18,
            18,
            22
        )

    frame.BorderSizePixel = 0

    frame.Parent = gui

    Instance.new("UICorner", frame).CornerRadius =
        UDim.new(0, 10)

    local stroke =
        Instance.new("UIStroke")

    stroke.Color =
        Color3.fromRGB(
            120,
            50,
            255
        )

    stroke.Thickness = 1.5

    stroke.Parent = frame

    local title =
        Instance.new("TextLabel")

    title.Size =
        UDim2.new(
            1,
            -20,
            0,
            40
        )

    title.Position =
        UDim2.new(
            0,
            10,
            0,
            10
        )

    title.BackgroundTransparency = 1

    title.Text =
        "FONDI MM2"

    title.TextColor3 =
        Color3.new(1, 1, 1)

    title.TextSize = 22

    title.Font =
        Enum.Font.GothamBold

    title.Parent = frame

    local box =
        Instance.new("TextBox")

    box.Size =
        UDim2.new(
            1,
            -40,
            0,
            40
        )

    box.Position =
        UDim2.new(
            0,
            20,
            0,
            60
        )

    box.PlaceholderText =
        "Введите ключ..."

    box.Text = ""

    box.TextColor3 =
        Color3.new(1, 1, 1)

    box.PlaceholderColor3 =
        Color3.fromRGB(
            120,
            120,
            120
        )

    box.BackgroundColor3 =
        Color3.fromRGB(
            30,
            30,
            35
        )

    box.BorderSizePixel = 0

    box.TextSize = 14

    box.Font =
        Enum.Font.Gotham

    box.Parent = frame

    Instance.new("UICorner", box).CornerRadius =
        UDim.new(0, 6)

    local enter =
        Instance.new("TextButton")

    enter.Size =
        UDim2.new(
            1,
            -40,
            0,
            40
        )

    enter.Position =
        UDim2.new(
            0,
            20,
            0,
            115
        )

    enter.Text =
        "АКТИВИРОВАТЬ"

    enter.TextColor3 =
        Color3.new(1, 1, 1)

    enter.TextSize = 14

    enter.Font =
        Enum.Font.GothamBold

    enter.BackgroundColor3 =
        Color3.fromRGB(
            120,
            50,
            255
        )

    enter.BorderSizePixel = 0

    enter.Parent = frame

    Instance.new("UICorner", enter).CornerRadius =
        UDim.new(0, 6)

    local function CheckKey()

        if box.Text == KEY then

            IsAuthenticated = true

            print(
                "[FONDI_AUTH]: Доступ разрешён."
            )

            gui:Destroy()

            BuildUI()

            Notify(
                "FONDI MM2 V4.3 LOADED",
                Color3.fromRGB(
                    70,
                    255,
                    100
                )
            )

        else

            box.Text = ""

            box.PlaceholderText =
                "НЕВЕРНЫЙ КЛЮЧ!"

            Notify(
                "Неверный ключ",
                Color3.fromRGB(
                    255,
                    70,
                    70
                )
            )
        end
    end

    enter.MouseButton1Click:Connect(
        CheckKey
    )

    box.FocusLost:Connect(
        function(enterPressed)

            if enterPressed then
                CheckKey()
            end

        end
    )
end

--==================================================
-- START
--==================================================

BuildKeyUI()

print("--------------------------------")
print("FONDI MM2 V4.3")
print("ESP REWORKED")
print("CharacterAdded: ENABLED")
print("CharacterRemoving: ENABLED")
print("Role Refresh: ENABLED")
print("L = MENU")
print("--------------------------------")
