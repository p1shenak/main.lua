--[[
    FONDI MM2 V4.4
    ROUND-SAFE ESP EDITION

    FIX:
    - ESP не пропадает после окончания раунда
    - ESP пересоздаётся после респавна
    - ESP пересоздаётся при уничтожении старого Character
    - Highlight находится непосредственно в Character
    - Billboard находится в HumanoidRootPart
    - Tracers переключаются на новый Character
    - Murderer/Sheriff обновляются
    - Outline
    - Player List
    - Spectator
    - Fly
    - Noclip
    - L = открыть/закрыть меню
    - Toggle Sound
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
local pg = LP:WaitForChild("PlayerGui")

--==================================================
-- SETTINGS
--==================================================

local Settings = {
    ESP = false,
    Outline = true,
    Tracers = true,
    ShowNames = true,
    ShowRoles = true,

    Fly = false,
    Noclip = false,

    FlySpeed = 50,

    Spectator = false
}

--==================================================
-- KEY
--==================================================

local KEY = "FONDI-MM2-FOREVER"

local IsAuthenticated = false

--==================================================
-- COLORS
--==================================================

local COLORS = {
    Murderer = Color3.fromRGB(255, 50, 50),
    Sheriff = Color3.fromRGB(60, 140, 255),
    Innocent = Color3.fromRGB(60, 255, 100),
    Dead = Color3.fromRGB(130, 130, 130)
}

--==================================================
-- ROLE
--==================================================

local function GetRole(player)

    if not player then
        return "Innocent"
    end

    local character = player.Character
    local backpack = player:FindFirstChildOfClass("Backpack")

    local function HasTool(container, toolName)

        if not container then
            return false
        end

        return container:FindFirstChild(toolName) ~= nil
    end

    -- Murderer

    if HasTool(character, "Knife")
        or HasTool(backpack, "Knife") then

        return "Murderer"
    end

    -- Sheriff

    if HasTool(character, "Gun")
        or HasTool(backpack, "Gun")
        or HasTool(character, "Revolver")
        or HasTool(backpack, "Revolver") then

        return "Sheriff"
    end

    return "Innocent"
end

--==================================================
-- ROLE COLOR
--==================================================

local function GetRoleColor(role)

    return COLORS[role] or COLORS.Innocent

end

--==================================================
-- NOTIFY
--==================================================

local function Notify(text, color)

    print("[FONDI_NOTIFY]: " .. tostring(text))

    local sg = pg:FindFirstChild("Fondi_Notify")

    if not sg then

        sg = Instance.new("ScreenGui")
        sg.Name = "Fondi_Notify"
        sg.ResetOnSpawn = false
        sg.Parent = pg

    end

    local frame = Instance.new("Frame")

    frame.Size = UDim2.new(0, 240, 0, 48)
    frame.Position = UDim2.new(1, 10, 0.8, 0)

    frame.BackgroundColor3 =
        Color3.fromRGB(10, 10, 14)

    frame.Parent = sg

    Instance.new("UICorner", frame)

    local stroke =
        Instance.new("UIStroke")

    stroke.Color =
        color or Color3.fromRGB(120, 50, 255)

    stroke.Parent = frame

    local label =
        Instance.new("TextLabel")

    label.Size =
        UDim2.new(1, -10, 1, 0)

    label.Position =
        UDim2.new(0, 5, 0, 0)

    label.BackgroundTransparency = 1

    label.Text = tostring(text)

    label.TextColor3 =
        Color3.new(1, 1, 1)

    label.Font =
        Enum.Font.GothamBold

    label.TextSize = 13

    label.Parent = frame

    frame:TweenPosition(
        UDim2.new(1, -250, 0.8, 0),
        "Out",
        "Back",
        0.4,
        true
    )

    task.delay(2.5, function()

        if frame and frame.Parent then

            frame:TweenPosition(
                UDim2.new(1, 10, 0.8, 0),
                "In",
                "Quad",
                0.4,
                true
            )

            task.wait(0.45)

            if frame then
                frame:Destroy()
            end

        end

    end)
end

--==================================================
-- TOGGLE SOUND
--==================================================

local ToggleSound =
    Instance.new("Sound")

ToggleSound.Name = "FondiToggleSound"

ToggleSound.SoundId =
    "rbxassetid://133095302935970"

ToggleSound.Volume = 1

ToggleSound.Parent = SoundService

local function PlayToggleSound()

    pcall(function()

        ToggleSound:Stop()
        ToggleSound.TimePosition = 0
        ToggleSound:Play()

    end)

end

--==================================================
-- ESP DATA
--==================================================

local ESPObjects = {}

local PlayerConnections = {}

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

    if data.TracerStart then

        pcall(function()
            data.TracerStart:Destroy()
        end)

    end

    if data.TracerEnd then

        pcall(function()
            data.TracerEnd:Destroy()
        end)

    end

    ESPObjects[player] = nil

end

--==================================================
-- UPDATE ESP
--==================================================

local UpdateESP

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

    local character =
        player.Character

    if not character then
        return
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    local root =
        character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root then
        return
    end

    -- Старый ESP этого игрока удаляем

    RemoveESP(player)

    local data = {
        Character = character,
        Root = root
    }

    --==================================================
    -- HIGHLIGHT
    --==================================================

    local highlight =
        Instance.new("Highlight")

    highlight.Name =
        "FondiHighlight"

    highlight.Adornee =
        character

    highlight.DepthMode =
        Enum.HighlightDepthMode.AlwaysOnTop

    highlight.FillTransparency =
        0.78

    highlight.OutlineTransparency =
        Settings.Outline and 0 or 1

    highlight.Parent =
        character

    data.Highlight =
        highlight

    --==================================================
    -- BILLBOARD
    --==================================================

    local billboard =
        Instance.new("BillboardGui")

    billboard.Name =
        "FondiName"

    billboard.Adornee =
        root

    billboard.Size =
        UDim2.new(0, 220, 0, 50)

    billboard.StudsOffset =
        Vector3.new(0, 3.2, 0)

    billboard.AlwaysOnTop = true

    billboard.MaxDistance = 10000

    billboard.Parent =
        root

    local label =
        Instance.new("TextLabel")

    label.Name = "Info"

    label.Size =
        UDim2.new(1, 0, 1, 0)

    label.BackgroundTransparency = 1

    label.TextStrokeTransparency = 0

    label.TextStrokeColor3 =
        Color3.new(0, 0, 0)

    label.Font =
        Enum.Font.GothamBold

    label.TextSize = 14

    label.Parent =
        billboard

    data.Billboard =
        billboard

    data.Label =
        label

    --==================================================
    -- TRACER END
    --==================================================

    local attachmentEnd =
        Instance.new("Attachment")

    attachmentEnd.Name =
        "FondiTracerEnd"

    attachmentEnd.Parent =
        root

    data.TracerEnd =
        attachmentEnd

    --==================================================
    -- TRACER
    --==================================================

    local tracer =
        Instance.new("Beam")

    tracer.Name =
        "FondiTracer"

    tracer.FaceCamera = true

    tracer.Width0 = 0.04

    tracer.Width1 = 0.04

    tracer.Transparency =
        NumberSequence.new(0.15)

    tracer.Attachment1 =
        attachmentEnd

    tracer.Parent =
        root

    data.Tracer =
        tracer

    --==================================================
    -- SAVE
    --==================================================

    ESPObjects[player] =
        data

    UpdateESP(player)

end

--==================================================
-- UPDATE ESP
--==================================================

UpdateESP = function(player)

    if player == LP then
        return
    end

    local data =
        ESPObjects[player]

    if not data then
        return
    end

    local character =
        player.Character

    if not character then

        RemoveESP(player)

        return

    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    local root =
        character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root then
        return
    end

    -- Новый Character

    if data.Character ~= character then

        CreateESP(player)

        return

    end

    --==================================================
    -- ROLE
    --==================================================

    local role =
        GetRole(player)

    local roleColor =
        GetRoleColor(role)

    --==================================================
    -- HIGHLIGHT
    --==================================================

    if data.Highlight
        and data.Highlight.Parent then

        data.Highlight.Adornee =
            character

        data.Highlight.Enabled =
            Settings.ESP

        data.Highlight.FillColor =
            roleColor

        data.Highlight.OutlineColor =
            roleColor

        if Settings.Outline then

            data.Highlight.OutlineTransparency = 0

        else

            data.Highlight.OutlineTransparency = 1

        end

    end

    --==================================================
    -- NAME
    --==================================================

    if data.Billboard
        and data.Billboard.Parent
        and data.Label then

        data.Billboard.Adornee =
            root

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

        data.Label.TextColor3 =
            roleColor

    end

    --==================================================
    -- TRACER
    --==================================================

    if data.Tracer
        and data.Tracer.Parent then

        data.Tracer.Enabled =
            Settings.ESP
            and Settings.Tracers

        data.Tracer.Color =
            ColorSequence.new(roleColor)

        -- Target

        if data.TracerEnd then

            if data.TracerEnd.Parent ~= root then

                data.TracerEnd.Parent =
                    root

            end

            data.Tracer.Attachment1 =
                data.TracerEnd

        end

        -- Local player root

        local myCharacter =
            LP.Character

        if myCharacter then

            local myRoot =
                myCharacter:FindFirstChild(
                    "HumanoidRootPart"
                )

            if myRoot then

                if not data.TracerStart
                    or not data.TracerStart.Parent then

                    local newStart =
                        Instance.new("Attachment")

                    newStart.Name =
                        "FondiTracerStart"

                    newStart.Parent =
                        myRoot

                    data.TracerStart =
                        newStart

                elseif data.TracerStart.Parent ~= myRoot then

                    data.TracerStart.Parent =
                        myRoot

                end

                data.Tracer.Attachment0 =
                    data.TracerStart

            end

        end

    end

end

--==================================================
-- DISCONNECT PLAYER
--==================================================

local function DisconnectPlayerConnections(player)

    local connections =
        PlayerConnections[player]

    if not connections then
        return
    end

    for _, connection in ipairs(connections) do

        pcall(function()
            connection:Disconnect()
        end)

    end

    PlayerConnections[player] = nil

end

--==================================================
-- SETUP PLAYER
--==================================================

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
        player.CharacterAdded:Connect(
            function(character)

                -- Удаляем старый ESP

                RemoveESP(player)

                local root =
                    character:WaitForChild(
                        "HumanoidRootPart",
                        10
                    )

                if not root then
                    return
                end

                -- Ждём выдачи Knife/Gun

                task.wait(0.25)

                if player.Parent
                    and player.Character == character
                    and Settings.ESP then

                    CreateESP(player)

                end

            end
        )

    table.insert(
        PlayerConnections[player],
        characterAdded
    )

    --==================================================
    -- CHARACTER REMOVING
    --==================================================

    local characterRemoving =
        player.CharacterRemoving:Connect(
            function(character)

                local data =
                    ESPObjects[player]

                if data
                    and data.Character == character then

                    RemoveESP(player)

                end

            end
        )

    table.insert(
        PlayerConnections[player],
        characterRemoving
    )

    --==================================================
    -- BACKPACK
    --==================================================

    local function WatchBackpack(backpack)

        if not backpack then
            return
        end

        local childAdded =
            backpack.ChildAdded:Connect(
                function()

                    task.wait(0.05)

                    if Settings.ESP then
                        UpdateESP(player)
                    end

                end
            )

        local childRemoved =
            backpack.ChildRemoved:Connect(
                function()

                    task.wait(0.05)

                    if Settings.ESP then
                        UpdateESP(player)
                    end

                end
            )

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

            local character =
                player.Character

            local root =
                character:WaitForChild(
                    "HumanoidRootPart",
                    5
                )

            if root
                and player.Character == character
                and Settings.ESP then

                task.wait(0.2)

                CreateESP(player)

            end

        end)

    end

end

--==================================================
-- SETUP EXISTING PLAYERS
--==================================================

for _, player in ipairs(
    Players:GetPlayers()
) do

    if player ~= LP then
        SetupPlayer(player)
    end

end

--==================================================
-- PLAYER ADDED
--==================================================

Players.PlayerAdded:Connect(
    function(player)

        SetupPlayer(player)

    end
)

--==================================================
-- PLAYER REMOVING
--==================================================

Players.PlayerRemoving:Connect(
    function(player)

        RemoveESP(player)

        DisconnectPlayerConnections(
            player
        )

    end
)

--==================================================
-- ESP AUTO REPAIR
--==================================================

task.spawn(function()

    while task.wait(0.5) do

        if Settings.ESP
            and IsAuthenticated then

            for _, player in ipairs(
                Players:GetPlayers()
            ) do

                if player ~= LP
                    and player.Parent then

                    local character =
                        player.Character

                    if character then

                        local root =
                            character:FindFirstChild(
                                "HumanoidRootPart"
                            )

                        if root then

                            local data =
                                ESPObjects[player]

                            -- ESP отсутствует

                            if not data then

                                CreateESP(player)

                            -- Старый Character

                            elseif data.Character
                                ~= character then

                                CreateESP(player)

                            -- Highlight уничтожен

                            elseif not data.Highlight
                                or not data.Highlight.Parent then

                                CreateESP(player)

                            -- Billboard уничтожен

                            elseif not data.Billboard
                                or not data.Billboard.Parent then

                                CreateESP(player)

                            -- Всё нормально

                            else

                                UpdateESP(player)

                            end

                        end

                    end

                end

            end

        end

    end

end)

--==================================================
-- FAST ROLE REFRESH
--==================================================

task.spawn(function()

    while task.wait(0.2) do

        if Settings.ESP
            and IsAuthenticated then

            for player, _ in pairs(
                ESPObjects
            ) do

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
-- NOCLIP
--==================================================

RunService.Stepped:Connect(
    function()

        if not IsAuthenticated then
            return
        end

        if not Settings.Noclip then
            return
        end

        local character =
            LP.Character

        if not character then
            return
        end

        for _, object in ipairs(
            character:GetDescendants()
        ) do

            if object:IsA("BasePart") then

                object.CanCollide = false

            end

        end

    end
)

--==================================================
-- FLY
--==================================================

local flyBV = nil
local flyBG = nil

local function StopFly()

    if flyBV then

        pcall(function()
            flyBV:Destroy()
        end)

        flyBV = nil

    end

    if flyBG then

        pcall(function()
            flyBG:Destroy()
        end)

        flyBG = nil

    end

end

local function StartFly()

    local character =
        LP.Character

    if not character then
        return
    end

    local root =
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not root then
        return
    end

    StopFly()

    flyBV =
        Instance.new("BodyVelocity")

    flyBV.MaxForce =
        Vector3.new(
            1e7,
            1e7,
            1e7
        )

    flyBV.Velocity =
        Vector3.zero

    flyBV.Parent =
        root

    flyBG =
        Instance.new("BodyGyro")

    flyBG.MaxTorque =
        Vector3.new(
            1e7,
            1e7,
            1e7
        )

    flyBG.D = 100

    flyBG.Parent =
        root

end

RunService.RenderStepped:Connect(
    function()

        if not IsAuthenticated then
            StopFly()
            return
        end

        if not Settings.Fly then
            StopFly()
            return
        end

        local character =
            LP.Character

        if not character then
            StopFly()
            return
        end

        local root =
            character:FindFirstChild(
                "HumanoidRootPart"
            )

        if not root then
            StopFly()
            return
        end

        if not flyBV
            or not flyBV.Parent
            or not flyBG
            or not flyBG.Parent then

            StartFly()

        end

        if not flyBV or not flyBG then
            return
        end

        local camera =
            workspace.CurrentCamera

        if not camera then
            return
        end

        local move =
            Vector3.zero

        if UIS:IsKeyDown(
            Enum.KeyCode.W
        ) then

            move +=
                camera.CFrame.LookVector

        end

        if UIS:IsKeyDown(
            Enum.KeyCode.S
        ) then

            move -=
                camera.CFrame.LookVector

        end

        if UIS:IsKeyDown(
            Enum.KeyCode.A
        ) then

            move -=
                camera.CFrame.RightVector

        end

        if UIS:IsKeyDown(
            Enum.KeyCode.D
        ) then

            move +=
                camera.CFrame.RightVector

        end

        if UIS:IsKeyDown(
            Enum.KeyCode.Space
        ) then

            move +=
                Vector3.new(0, 1, 0)

        end

        if UIS:IsKeyDown(
            Enum.KeyCode.LeftControl
        ) then

            move -=
                Vector3.new(0, 1, 0)

        end

        if move.Magnitude > 0 then

            flyBV.Velocity =
                move.Unit
                * Settings.FlySpeed

        else

            flyBV.Velocity =
                Vector3.zero

        end

        flyBG.CFrame =
            camera.CFrame

    end
)

--==================================================
-- LOCAL PLAYER RESPAWN
--==================================================

LP.CharacterAdded:Connect(
    function(character)

        StopFly()

        task.wait(0.5)

        -- Ничего не выключаем:
        -- ESP продолжает работать

        if Settings.Fly
            and IsAuthenticated then

            StartFly()

        end

    end
)

--==================================================
-- GUI
--==================================================

local MainGui = nil
local MainFrame = nil

local function BuildUI()

    if MainGui then

        pcall(function()
            MainGui:Destroy()
        end)

    end

    MainGui =
        Instance.new("ScreenGui")

    MainGui.Name =
        "Fondi_V44"

    MainGui.ResetOnSpawn = false

    MainGui.Parent =
        pg

    --==================================================
    -- MAIN
    --==================================================

    MainFrame =
        Instance.new("Frame")

    MainFrame.Size =
        UDim2.new(0, 310, 0, 500)

    MainFrame.Position =
        UDim2.new(
            0.5,
            -155,
            0.5,
            -250
        )

    MainFrame.BackgroundColor3 =
        Color3.fromRGB(
            15,
            15,
            20
        )

    MainFrame.Active = true

    MainFrame.Draggable = true

    MainFrame.Parent =
        MainGui

    Instance.new(
        "UICorner",
        MainFrame
    )

    local stroke =
        Instance.new("UIStroke")

    stroke.Color =
        Color3.fromRGB(
            120,
            50,
            255
        )

    stroke.Thickness = 1.5

    stroke.Parent =
        MainFrame

    --==================================================
    -- TITLE
    --==================================================

    local title =
        Instance.new("TextLabel")

    title.Size =
        UDim2.new(
            1,
            0,
            0,
            50
        )

    title.BackgroundTransparency = 1

    title.Text =
        "FONDI MM2 V4.4"

    title.TextColor3 =
        Color3.new(1, 1, 1)

    title.Font =
        Enum.Font.GothamBold

    title.TextSize = 20

    title.Parent =
        MainFrame

    --==================================================
    -- SCROLL
    --==================================================

    local scroll =
        Instance.new("ScrollingFrame")

    scroll.Size =
        UDim2.new(
            1,
            -20,
            1,
            -60
        )

    scroll.Position =
        UDim2.new(
            0,
            10,
            0,
            55
        )

    scroll.BackgroundTransparency = 1

    scroll.BorderSizePixel = 0

    scroll.ScrollBarThickness = 4

    scroll.CanvasSize =
        UDim2.new(0, 0, 0, 0)

    scroll.AutomaticCanvasSize =
        Enum.AutomaticSize.Y

    scroll.Parent =
        MainFrame

    local layout =
        Instance.new("UIListLayout")

    layout.Padding =
        UDim.new(0, 8)

    layout.Parent =
        scroll

    --==================================================
    -- TOGGLE
    --==================================================

    local function CreateToggle(
        name,
        setting
    )

        local button =
            Instance.new("TextButton")

        button.Size =
            UDim2.new(
                1,
                -5,
                0,
                42
            )

        button.BackgroundColor3 =
            Settings[setting]
            and Color3.fromRGB(
                120,
                50,
                255
            )
            or Color3.fromRGB(
                30,
                30,
                35
            )

        button.Text =
            name
            .. " : "
            .. (
                Settings[setting]
                and "ON"
                or "OFF"
            )

        button.TextColor3 =
            Color3.new(1, 1, 1)

        button.Font =
            Enum.Font.GothamBold

        button.TextSize = 12

        button.Parent =
            scroll

        Instance.new(
            "UICorner",
            button
        )

        button.MouseButton1Click:Connect(
            function()

                Settings[setting] =
                    not Settings[setting]

                button.Text =
                    name
                    .. " : "
                    .. (
                        Settings[setting]
                        and "ON"
                        or "OFF"
                    )

                TweenService:Create(
                    button,
                    TweenInfo.new(0.2),
                    {
                        BackgroundColor3 =
                            Settings[setting]
                            and Color3.fromRGB(
                                120,
                                50,
                                255
                            )
                            or Color3.fromRGB(
                                30,
                                30,
                                35
                            )
                    }
                ):Play()

                PlayToggleSound()

                Notify(
                    name
                    .. ": "
                    .. (
                        Settings[setting]
                        and "ВКЛ"
                        or "ВЫКЛ"
                    ),
                    Settings[setting]
                    and Color3.fromRGB(
                        50,
                        255,
                        100
                    )
                    or Color3.fromRGB(
                        255,
                        60,
                        60
                    )
                )

                --==================================================
                -- ESP SWITCH
                --==================================================

                if setting == "ESP" then

                    if Settings.ESP then

                        for _, player in ipairs(
                            Players:GetPlayers()
                        ) do

                            if player ~= LP then
                                CreateESP(player)
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

                --==================================================
                -- FLY SWITCH
                --==================================================

                if setting == "Fly" then

                    if Settings.Fly then

                        StartFly()

                    else

                        StopFly()

                    end

                end

            end
        )

        return button

    end

    --==================================================
    -- ESP
    --==================================================

    CreateToggle(
        "ESP",
        "ESP"
    )

    CreateToggle(
        "OUTLINE",
        "Outline"
    )

    CreateToggle(
        "TRACERS",
        "Tracers"
    )

    CreateToggle(
        "NAMES",
        "ShowNames"
    )

    CreateToggle(
        "ROLES",
        "ShowRoles"
    )

    --==================================================
    -- FLY
    --==================================================

    CreateToggle(
        "FLY",
        "Fly"
    )

    CreateToggle(
        "NOCLIP",
        "Noclip"
    )

    --==================================================
    -- SPECTATOR
    --==================================================

    local spectateButton =
        Instance.new("TextButton")

    spectateButton.Size =
        UDim2.new(
            1,
            -5,
            0,
            42
        )

    spectateButton.BackgroundColor3 =
        Color3.fromRGB(
            30,
            30,
            35
        )

    spectateButton.Text =
        "SPECTATOR"

    spectateButton.TextColor3 =
        Color3.new(1, 1, 1)

    spectateButton.Font =
        Enum.Font.GothamBold

    spectateButton.TextSize = 12

    spectateButton.Parent =
        scroll

    Instance.new(
        "UICorner",
        spectateButton
    )

    local spectatingPlayer = nil

    spectateButton.MouseButton1Click:Connect(
        function()

            Settings.Spectator =
                not Settings.Spectator

            local camera =
                workspace.CurrentCamera

            if not Settings.Spectator then

                camera.CameraSubject =
                    LP.Character
                    and LP.Character:FindFirstChildOfClass(
                        "Humanoid"
                    )

                spectateButton.Text =
                    "SPECTATOR : OFF"

                spectateButton.BackgroundColor3 =
                    Color3.fromRGB(
                        30,
                        30,
                        35
                    )

                return

            end

            local list = {}

            for _, player in ipairs(
                Players:GetPlayers()
            ) do

                if player ~= LP
                    and player.Character
                    and player.Character:FindFirstChildOfClass(
                        "Humanoid"
                    ) then

                    table.insert(
                        list,
                        player
                    )

                end

            end

            if #list == 0 then

                Settings.Spectator = false

                Notify(
                    "Нет игроков для наблюдения",
                    Color3.fromRGB(
                        255,
                        60,
                        60
                    )
                )

                return

            end

            spectatingPlayer =
                list[1]

            camera.CameraSubject =
                spectatingPlayer.Character:
                FindFirstChildOfClass(
                    "Humanoid"
                )

            spectateButton.Text =
                "SPECTATOR : "
                .. spectatingPlayer.DisplayName

            spectateButton.BackgroundColor3 =
                Color3.fromRGB(
                    120,
                    50,
                    255
                )

        end
    )

    --==================================================
    -- PLAYER LIST
    --==================================================

    local playerListTitle =
        Instance.new("TextLabel")

    playerListTitle.Size =
        UDim2.new(
            1,
            -5,
            0,
            30
        )

    playerListTitle.BackgroundTransparency = 1

    playerListTitle.Text =
        "PLAYER LIST"

    playerListTitle.TextColor3 =
        Color3.fromRGB(
            180,
            180,
            180
        )

    playerListTitle.Font =
        Enum.Font.GothamBold

    playerListTitle.TextSize = 12

    playerListTitle.Parent =
        scroll

    local playerList =
        Instance.new("Frame")

    playerList.Size =
        UDim2.new(
            1,
            -5,
            0,
            100
        )

    playerList.BackgroundColor3 =
        Color3.fromRGB(
            20,
            20,
            25
        )

    playerList.Parent =
        scroll

    Instance.new(
        "UICorner",
        playerList
    )

    local listLayout =
        Instance.new("UIListLayout")

    listLayout.Padding =
        UDim.new(0, 2)

    listLayout.Parent =
        playerList

    local function RefreshPlayerList()

        for _, child in ipairs(
            playerList:GetChildren()
        ) do

            if child:IsA("TextLabel") then
                child:Destroy()
            end

        end

        for _, player in ipairs(
            Players:GetPlayers()
        ) do

            if player ~= LP then

                local role =
                    GetRole(player)

                local row =
                    Instance.new("TextLabel")

                row.Size =
                    UDim2.new(
                        1,
                        -5,
                        0,
                        22
                    )

                row.BackgroundTransparency = 1

                row.Text =
                    player.DisplayName
                    .. "  |  "
                    .. role

                row.TextColor3 =
                    GetRoleColor(role)

                row.Font =
                    Enum.Font.Gotham

                row.TextSize = 11

                row.Parent =
                    playerList

            end

        end

    end

    RefreshPlayerList()

    task.spawn(function()

        while MainGui
            and MainGui.Parent do

            task.wait(1)

            if playerList
                and playerList.Parent then

                RefreshPlayerList()

            end

        end

    end)

end

--==================================================
-- KEY GUI
--==================================================

local KeyGui =
    Instance.new("ScreenGui")

KeyGui.Name =
    "FondiKeyGui"

KeyGui.ResetOnSpawn = false

KeyGui.Parent =
    pg

local KeyFrame =
    Instance.new("Frame")

KeyFrame.Size =
    UDim2.new(
        0,
        320,
        0,
        180
    )

KeyFrame.Position =
    UDim2.new(
        0.5,
        -160,
        0.4,
        0
    )

KeyFrame.BackgroundColor3 =
    Color3.fromRGB(
        15,
        15,
        20
    )

KeyFrame.Parent =
    KeyGui

Instance.new(
    "UICorner",
    KeyFrame
)

local KeyStroke =
    Instance.new("UIStroke")

KeyStroke.Color =
    Color3.fromRGB(
        120,
        50,
        255
    )

KeyStroke.Parent =
    KeyFrame

--==================================================
-- KEY TITLE
--==================================================

local KeyTitle =
    Instance.new("TextLabel")

KeyTitle.Size =
    UDim2.new(
        1,
        0,
        0,
        45
    )

KeyTitle.BackgroundTransparency = 1

KeyTitle.Text =
    "FONDI MM2"

KeyTitle.TextColor3 =
    Color3.new(1, 1, 1)

KeyTitle.Font =
    Enum.Font.GothamBold

KeyTitle.TextSize = 20

KeyTitle.Parent =
    KeyFrame

--==================================================
-- KEY BOX
--==================================================

local KeyBox =
    Instance.new("TextBox")

KeyBox.Size =
    UDim2.new(
        0.8,
        0,
        0,
        40
    )

KeyBox.Position =
    UDim2.new(
        0.1,
        0,
        0.3,
        0
    )

KeyBox.PlaceholderText =
    "ВВЕДИТЕ КЛЮЧ"

KeyBox.Text = ""

KeyBox.ClearTextOnFocus = false

KeyBox.BackgroundColor3 =
    Color3.fromRGB(
        10,
        10,
        12
    )

KeyBox.TextColor3 =
    Color3.new(1, 1, 1)

KeyBox.Font =
    Enum.Font.Gotham

KeyBox.TextSize = 13

KeyBox.Parent =
    KeyFrame

Instance.new(
    "UICorner",
    KeyBox
)

--==================================================
-- ACTIVATE
--==================================================

local ActivateButton =
    Instance.new("TextButton")

ActivateButton.Size =
    UDim2.new(
        0.8,
        0,
        0,
        40
    )

ActivateButton.Position =
    UDim2.new(
        0.1,
        0,
        0.62,
        0
    )

ActivateButton.Text =
    "АКТИВИРОВАТЬ"

ActivateButton.BackgroundColor3 =
    Color3.fromRGB(
        120,
        50,
        255
    )

ActivateButton.TextColor3 =
    Color3.new(1, 1, 1)

ActivateButton.Font =
    Enum.Font.GothamBold

ActivateButton.TextSize = 13

ActivateButton.Parent =
    KeyFrame

Instance.new(
    "UICorner",
    ActivateButton
)

--==================================================
-- AUTH
--==================================================

ActivateButton.MouseButton1Click:Connect(
    function()

        if KeyBox.Text == KEY then

            IsAuthenticated = true

            print(
                "[FONDI_AUTH]: ACCESS GRANTED"
            )

            KeyGui:Destroy()

            BuildUI()

            Notify(
                "FONDI LOADED",
                Color3.fromRGB(
                    50,
                    255,
                    100
                )
            )

        else

            KeyBox.Text = ""

            KeyBox.PlaceholderText =
                "НЕВЕРНЫЙ КЛЮЧ!"

            Notify(
                "Неверный ключ",
                Color3.fromRGB(
                    255,
                    60,
                    60
                )
            )

        end

    end
)

--==================================================
-- L MENU HOTKEY
--==================================================

local function ToggleMenu()

    if not MainGui
        or not MainGui.Parent then

        return

    end

    MainFrame.Visible =
        not MainFrame.Visible

end

UIS.InputBegan:Connect(
    function(input)

        if input.KeyCode ==
            Enum.KeyCode.L then

            ToggleMenu()

        end

    end
)

--==================================================
-- LOADER
--==================================================

task.spawn(function()

    local stages = {

        "Инициализация FONDI_ENGINE...",
        "Загрузка ESP...",
        "Подключение CharacterAdded...",
        "Подключение Round-Safe системы...",
        "Ожидание ключа..."

    }

    local index = 1

    while not IsAuthenticated do

        print(
            "[FONDI_STATUS]: "
            .. stages[index]
        )

        index =
            (index % #stages) + 1

        task.wait(2)

    end

end)

print(
    "=========================================="
)

print(
    "[FONDI MM2 V4.4] READY"
)

print(
    "[FONDI MM2] ESP ROUND-SAFE ENABLED"
)

print(
    "[FONDI MM2] Press L to toggle menu"
)

print(
    "=========================================="
)
