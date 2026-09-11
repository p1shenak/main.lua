--[[
    FONDI MM2 V4.1 // ROUND SAFE EDITION

    FIX:
    - ESP восстанавливается после смерти
    - ESP восстанавливается после нового раунда
    - ESP восстанавливается после респавна
    - Роль обновляется автоматически
    - Murderer = RED
    - Sheriff = BLUE
    - Innocent = GREEN
    - Box ESP
    - Tracers
    - Fly
    - Noclip
    - GUI
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

--------------------------------------------------
-- NOTIFICATION
--------------------------------------------------

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
    frame.Size = UDim2.new(0, 230, 0, 45)
    frame.Position = UDim2.new(1, 10, 0.8, 0)

    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)

    Instance.new("UICorner", frame)

    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(120, 50, 255)
    stroke.Parent = frame

    frame.Parent = sg

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.Text = tostring(text)
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.Parent = frame

    frame:TweenPosition(
        UDim2.new(1, -240, 0.8, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Back,
        0.5
    )

    task.delay(2.5, function()

        if frame and frame.Parent then

            frame:TweenPosition(
                UDim2.new(1, 10, 0.8, 0),
                Enum.EasingDirection.In,
                Enum.EasingStyle.Quad,
                0.5
            )

            task.wait(0.5)

            if frame then
                frame:Destroy()
            end

        end

    end)

end

--------------------------------------------------
-- ROLE DETECTION
--------------------------------------------------

local function GetRole(player)

    if not player then
        return "Innocent"
    end

    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character

    if
        (backpack and backpack:FindFirstChild("Knife"))
        or
        (character and character:FindFirstChild("Knife"))
    then
        return "Murderer"
    end

    if
        (backpack and backpack:FindFirstChild("Gun"))
        or
        (character and character:FindFirstChild("Gun"))
        or
        (backpack and backpack:FindFirstChild("Revolver"))
        or
        (character and character:FindFirstChild("Revolver"))
    then
        return "Sheriff"
    end

    return "Innocent"
end

--------------------------------------------------
-- ROLE COLOR
--------------------------------------------------

local function GetRoleColor(role)

    if role == "Murderer" then
        return Color3.fromRGB(255, 40, 40)

    elseif role == "Sheriff" then
        return Color3.fromRGB(50, 120, 255)

    else
        return Color3.fromRGB(70, 255, 100)
    end

end

--------------------------------------------------
-- ESP SYSTEM
--------------------------------------------------

local ESPObjects = {}

local UpdateESP

--------------------------------------------------
-- REMOVE ESP
--------------------------------------------------

local function RemoveESP(player)

    local data = ESPObjects[player]

    if not data then
        return
    end

    if data.Highlight then
        data.Highlight:Destroy()
    end

    if data.NameGui then
        data.NameGui:Destroy()
    end

    if data.Tracer then
        data.Tracer:Destroy()
    end

    ESPObjects[player] = nil

end

--------------------------------------------------
-- CREATE ESP
--------------------------------------------------

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

    --------------------------------------------------
    -- HIGHLIGHT
    --------------------------------------------------

    local highlight = Instance.new("Highlight")

    highlight.Name = "Fondi_ESP"

    highlight.Adornee = character

    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    highlight.FillTransparency = 0.75

    highlight.OutlineTransparency =
        Settings.Outline and 0 or 1

    local role = GetRole(player)

    highlight.FillColor = GetRoleColor(role)
    highlight.OutlineColor = GetRoleColor(role)

    highlight.Enabled = Settings.ESP

    highlight.Parent = character

    --------------------------------------------------
    -- NAME GUI
    --------------------------------------------------

    local nameGui = nil

    if Settings.ShowNames or Settings.ShowRoles then

        nameGui = Instance.new("BillboardGui")

        nameGui.Name = "Fondi_NameESP"

        nameGui.Adornee = root

        nameGui.Size = UDim2.new(0, 220, 0, 50)

        nameGui.StudsOffset = Vector3.new(0, 3.2, 0)

        nameGui.AlwaysOnTop = true

        nameGui.Parent = character

        local label = Instance.new("TextLabel")

        label.Name = "Text"

        label.Size = UDim2.fromScale(1, 1)

        label.BackgroundTransparency = 1

        label.Font = Enum.Font.GothamBold

        label.TextScaled = true

        label.TextStrokeTransparency = 0

        label.TextColor3 = GetRoleColor(role)

        label.Parent = nameGui

        local text = ""

        if Settings.ShowNames then
            text = player.DisplayName
        end

        if Settings.ShowRoles then

            if text ~= "" then
                text = text .. " | "
            end

            text = text .. role

        end

        label.Text = text

    end

    --------------------------------------------------
    -- TRACER
    --------------------------------------------------

    local tracer = nil

    if Settings.Tracers then

        tracer = Instance.new("Beam")

        tracer.Name = "Fondi_Tracer"

        tracer.FaceCamera = true

        tracer.Width0 = 0.08
        tracer.Width1 = 0.08

        tracer.Color = ColorSequence.new(
            GetRoleColor(role)
        )

        tracer.Transparency =
            NumberSequence.new(0.15)

        local attachment0 = Instance.new("Attachment")

        attachment0.Name = "Fondi_TracerStart"

        attachment0.Parent = root

        local myCharacter = LP.Character

        local myRoot =
            myCharacter
            and myCharacter:FindFirstChild("HumanoidRootPart")

        if myRoot then

            local attachment1 = Instance.new("Attachment")

            attachment1.Name = "Fondi_TracerEnd"

            attachment1.Parent = myRoot

            tracer.Attachment0 = attachment1
            tracer.Attachment1 = attachment0

            tracer.Parent = character

        else

            tracer:Destroy()
            tracer = nil

        end

    end

    --------------------------------------------------
    -- SAVE
    --------------------------------------------------

    ESPObjects[player] = {

        Highlight = highlight,

        NameGui = nameGui,

        Tracer = tracer,

        Character = character

    }

end

--------------------------------------------------
-- UPDATE ESP
--------------------------------------------------

UpdateESP = function(player)

    if player == LP then
        return
    end

    if not Settings.ESP then

        RemoveESP(player)

        return

    end

    local character = player.Character

    if not character then

        RemoveESP(player)

        return

    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    local root =
        character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root then

        RemoveESP(player)

        return

    end

    if humanoid.Health <= 0 then

        RemoveESP(player)

        return

    end

    --------------------------------------------------
    -- CHARACTER CHANGED
    --------------------------------------------------

    local data = ESPObjects[player]

    if not data or data.Character ~= character then

        CreateESP(player)

        return

    end

    --------------------------------------------------
    -- ROLE UPDATE
    --------------------------------------------------

    local role = GetRole(player)

    local roleColor = GetRoleColor(role)

    --------------------------------------------------
    -- HIGHLIGHT UPDATE
    --------------------------------------------------

    if data.Highlight then

        data.Highlight.Adornee = character

        data.Highlight.Enabled = Settings.ESP

        data.Highlight.FillColor = roleColor

        data.Highlight.OutlineColor = roleColor

        data.Highlight.OutlineTransparency =
            Settings.Outline and 0 or 1

    end

    --------------------------------------------------
    -- NAME UPDATE
    --------------------------------------------------

    if data.NameGui then

        data.NameGui.Adornee = root

        local label =
            data.NameGui:FindFirstChild("Text")

        if label then

            local text = ""

            if Settings.ShowNames then
                text = player.DisplayName
            end

            if Settings.ShowRoles then

                if text ~= "" then
                    text = text .. " | "
                end

                text = text .. role

            end

            label.Text = text

            label.TextColor3 = roleColor

        end

    end

    --------------------------------------------------
    -- TRACER UPDATE
    --------------------------------------------------

    if Settings.Tracers then

        if not data.Tracer then

            CreateESP(player)

            return

        end

        data.Tracer.Color =
            ColorSequence.new(roleColor)

    elseif data.Tracer then

        data.Tracer:Destroy()

        data.Tracer = nil

    end

end

--------------------------------------------------
-- PLAYER ESP SETUP
--------------------------------------------------

local function SetupPlayerESP(player)

    if player == LP then
        return
    end

    --------------------------------------------------
    -- NEW CHARACTER
    --------------------------------------------------

    player.CharacterAdded:Connect(function(character)

        task.spawn(function()

            local humanoid =
                character:WaitForChild(
                    "Humanoid",
                    8
                )

            local root =
                character:WaitForChild(
                    "HumanoidRootPart",
                    8
                )

            if humanoid and root then

                task.wait(0.25)

                if IsAuthenticated
                    and Settings.ESP
                    and player.Parent
                then

                    CreateESP(player)

                end

            end

        end)

    end)

    --------------------------------------------------
    -- CHARACTER REMOVING
    --------------------------------------------------

    player.CharacterRemoving:Connect(function()

        RemoveESP(player)

    end)

    --------------------------------------------------
    -- EXISTING CHARACTER
    --------------------------------------------------

    if player.Character then

        task.defer(function()

            if IsAuthenticated
                and Settings.ESP
            then

                CreateESP(player)

            end

        end)

    end

end

--------------------------------------------------
-- SETUP CURRENT PLAYERS
--------------------------------------------------

for _, player in ipairs(Players:GetPlayers()) do

    if player ~= LP then
        SetupPlayerESP(player)
    end

end

--------------------------------------------------
-- NEW PLAYER
--------------------------------------------------

Players.PlayerAdded:Connect(function(player)

    SetupPlayerESP(player)

end)

--------------------------------------------------
-- PLAYER LEFT
--------------------------------------------------

Players.PlayerRemoving:Connect(function(player)

    RemoveESP(player)

end)

--------------------------------------------------
-- ESP REFRESH LOOP
--------------------------------------------------

task.spawn(function()

    while true do

        task.wait(0.4)

        if IsAuthenticated then

            for _, player in ipairs(Players:GetPlayers()) do

                if player ~= LP then
                    UpdateESP(player)
                end

            end

        end

    end

end)

--------------------------------------------------
-- FLY
--------------------------------------------------

local flyBV = nil
local flyBG = nil

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

RunService.RenderStepped:Connect(function()

    if not IsAuthenticated then
        return
    end

    local character = LP.Character

    if not character then
        StopFly()
        return
    end

    local root =
        character:FindFirstChild("HumanoidRootPart")

    if not root then
        StopFly()
        return
    end

    if Settings.Fly then

        if not flyBV then

            flyBV = Instance.new("BodyVelocity")

            flyBV.Name = "Fondi_FlyVelocity"

            flyBV.MaxForce =
                Vector3.new(
                    10000000,
                    10000000,
                    10000000
                )

            flyBV.Parent = root

        end

        if not flyBG then

            flyBG = Instance.new("BodyGyro")

            flyBG.Name = "Fondi_FlyGyro"

            flyBG.MaxTorque =
                Vector3.new(
                    10000000,
                    10000000,
                    10000000
                )

            flyBG.D = 100

            flyBG.Parent = root

        end

        local camera =
            workspace.CurrentCamera

        local direction =
            Vector3.new(0, 0, 0)

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            direction =
                direction + camera.CFrame.LookVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.S) then
            direction =
                direction - camera.CFrame.LookVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.A) then
            direction =
                direction - camera.CFrame.RightVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.D) then
            direction =
                direction + camera.CFrame.RightVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            direction =
                direction + Vector3.new(0, 1, 0)
        end

        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction =
                direction - Vector3.new(0, 1, 0)
        end

        if direction.Magnitude > 0 then

            flyBV.Velocity =
                direction.Unit *
                Settings.FlySpeed

        else

            flyBV.Velocity =
                Vector3.new(0, 0, 0)

        end

        flyBG.CFrame =
            camera.CFrame

    else

        StopFly()

    end

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

    for _, object in ipairs(
        character:GetDescendants()
    ) do

        if object:IsA("BasePart") then
            object.CanCollide = false
        end

    end

end)

--------------------------------------------------
-- PLAYER LIST
--------------------------------------------------

local function CreatePlayerList(parent)

    local listFrame = Instance.new("Frame")

    listFrame.Name = "PlayerList"

    listFrame.Size =
        UDim2.new(1, -20, 0, 120)

    listFrame.BackgroundTransparency = 1

    listFrame.Parent = parent

    local title = Instance.new("TextLabel")

    title.Size =
        UDim2.new(1, 0, 0, 25)

    title.BackgroundTransparency = 1

    title.Text = "PLAYER LIST"

    title.TextColor3 =
        Color3.fromRGB(180, 180, 180)

    title.Font = Enum.Font.GothamBold

    title.TextSize = 12

    title.Parent = listFrame

    local scroll = Instance.new("ScrollingFrame")

    scroll.Position =
        UDim2.new(0, 0, 0, 28)

    scroll.Size =
        UDim2.new(1, 0, 1, -28)

    scroll.BackgroundTransparency = 1

    scroll.ScrollBarThickness = 3

    scroll.Parent = listFrame

    local layout =
        Instance.new("UIListLayout")

    layout.Padding =
        UDim.new(0, 4)

    layout.Parent = scroll

    local function Refresh()

        for _, child in ipairs(
            scroll:GetChildren()
        ) do

            if child:IsA("TextButton") then
                child:Destroy()
            end

        end

        for _, player in ipairs(
            Players:GetPlayers()
        ) do

            if player ~= LP then

                local button =
                    Instance.new("TextButton")

                button.Size =
                    UDim2.new(1, 0, 0, 30)

                button.BackgroundColor3 =
                    Color3.fromRGB(
                        30,
                        30,
                        35
                    )

                button.Text =
                    player.DisplayName

                button.TextColor3 =
                    Color3.fromRGB(
                        220,
                        220,
                        220
                    )

                button.Font =
                    Enum.Font.Gotham

                button.TextSize = 11

                button.Parent = scroll

                Instance.new(
                    "UICorner",
                    button
                )

                button.MouseButton1Click:Connect(
                    function()

                        local character =
                            player.Character

                        local humanoid =
                            character
                            and character:FindFirstChildOfClass(
                                "Humanoid"
                            )

                        if humanoid then

                            workspace.CurrentCamera.CameraSubject =
                                humanoid

                            Settings.SpectatedPlayer =
                                player

                            Settings.Spectating =
                                true

                            Notify(
                                "Spectating: "
                                .. player.DisplayName,
                                Color3.fromRGB(
                                    120,
                                    50,
                                    255
                                )
                            )

                        end

                    end
                )

            end

        end

    end

    Refresh()

    Players.PlayerAdded:Connect(Refresh)
    Players.PlayerRemoving:Connect(Refresh)

end

--------------------------------------------------
-- MAIN UI
--------------------------------------------------

local function BuildUI()

    local old =
        pg:FindFirstChild("Fondi_V4")

    if old then
        old:Destroy()
    end

    local sg =
        Instance.new("ScreenGui")

    sg.Name = "Fondi_V4"

    sg.ResetOnSpawn = false

    sg.Parent = pg

    --------------------------------------------------
    -- MAIN
    --------------------------------------------------

    local main =
        Instance.new("Frame")

    main.Size =
        UDim2.new(0, 280, 0, 420)

    main.Position =
        UDim2.new(
            0.5,
            -140,
            0.5,
            -210
        )

    main.BackgroundColor3 =
        Color3.fromRGB(
            15,
            15,
            20
        )

    main.Active = true

    main.Draggable = true

    main.Parent = sg

    Instance.new(
        "UICorner",
        main
    )

    local stroke =
        Instance.new("UIStroke")

    stroke.Color =
        Color3.fromRGB(
            120,
            50,
            255
        )

    stroke.Thickness = 2

    stroke.Parent = main

    --------------------------------------------------
    -- TITLE
    --------------------------------------------------

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
            5
        )

    title.BackgroundTransparency = 1

    title.Text =
        "FONDI MM2 V4.1"

    title.TextColor3 =
        Color3.fromRGB(
            180,
            100,
            255
        )

    title.Font =
        Enum.Font.GothamBold

    title.TextSize = 17

    title.Parent = main

    --------------------------------------------------
    -- SCROLL
    --------------------------------------------------

    local scroll =
        Instance.new("ScrollingFrame")

    scroll.Size =
        UDim2.new(
            1,
            -20,
            1,
            -55
        )

    scroll.Position =
        UDim2.new(
            0,
            10,
            0,
            50
        )

    scroll.BackgroundTransparency = 1

    scroll.ScrollBarThickness = 3

    scroll.Parent = main

    local layout =
        Instance.new("UIListLayout")

    layout.Padding =
        UDim.new(0, 7)

    layout.Parent = scroll

    --------------------------------------------------
    -- TOGGLE
    --------------------------------------------------

    local function CreateToggle(
        name,
        variable
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
            Settings[variable]
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
                Settings[variable]
                and "ON"
                or "OFF"
            )

        button.TextColor3 =
            Color3.new(
                1,
                1,
                1
            )

        button.Font =
            Enum.Font.GothamBold

        button.TextSize = 11

        button.Parent = scroll

        Instance.new(
            "UICorner",
            button
        )

        button.MouseButton1Click:Connect(
            function()

                Settings[variable] =
                    not Settings[variable]

                button.Text =
                    name
                    .. " : "
                    .. (
                        Settings[variable]
                        and "ON"
                        or "OFF"
                    )

                local targetColor =
                    Settings[variable]
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

                TweenService:Create(
                    button,
                    TweenInfo.new(0.25),
                    {
                        BackgroundColor3 =
                            targetColor
                    }
                ):Play()

                Notify(
                    name
                    .. ": "
                    .. (
                        Settings[variable]
                        and "ВКЛ"
                        or "ВЫКЛ"
                    ),
                    Settings[variable]
                    and Color3.fromRGB(
                        0,
                        255,
                        100
                    )
                    or Color3.fromRGB(
                        255,
                        60,
                        60
                    )
                )

                --------------------------------------------------
                -- ESP REFRESH
                --------------------------------------------------

                if variable == "ESP" then

                    for _, player in ipairs(
                        Players:GetPlayers()
                    ) do

                        if player ~= LP then

                            if Settings.ESP then
                                CreateESP(player)
                            else
                                RemoveESP(player)
                            end

                        end

                    end

                end

                --------------------------------------------------
                -- OUTLINE
                --------------------------------------------------

                if variable == "Outline" then

                    for _, data in pairs(
                        ESPObjects
                    ) do

                        if data.Highlight then

                            data.Highlight.OutlineTransparency =
                                Settings.Outline
                                and 0
                                or 1

                        end

                    end

                end

                --------------------------------------------------
                -- TRACERS
                --------------------------------------------------

                if variable == "Tracers" then

                    for _, player in ipairs(
                        Players:GetPlayers()
                    ) do

                        if player ~= LP then
                            UpdateESP(player)
                        end

                    end

                end

            end
        )

        return button

    end

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

    CreateToggle(
        "FLY",
        "Fly"
    )

    CreateToggle(
        "NOCLIP",
        "Noclip"
    )

    --------------------------------------------------
    -- PLAYER LIST
    --------------------------------------------------

    CreatePlayerList(scroll)

end

--------------------------------------------------
-- KEY GUI
--------------------------------------------------

local keyGui =
    Instance.new("ScreenGui")

keyGui.Name =
    "Fondi_KeyGui"

keyGui.ResetOnSpawn = false

keyGui.Parent = pg

--------------------------------------------------
-- KEY FRAME
--------------------------------------------------

local kFrame =
    Instance.new("Frame")

kFrame.Size =
    UDim2.new(
        0,
        320,
        0,
        180
    )

kFrame.Position =
    UDim2.new(
        0.5,
        -160,
        0.4,
        0
    )

kFrame.BackgroundColor3 =
    Color3.fromRGB(
        15,
        15,
        20
    )

kFrame.Parent = keyGui

Instance.new(
    "UICorner",
    kFrame
)

local kStroke =
    Instance.new("UIStroke")

kStroke.Color =
    Color3.fromRGB(
        120,
        50,
        255
    )

kStroke.Thickness = 2

kStroke.Parent = kFrame

--------------------------------------------------
-- KEY TITLE
--------------------------------------------------

local keyTitle =
    Instance.new("TextLabel")

keyTitle.Size =
    UDim2.new(
        1,
        0,
        0,
        45
    )

keyTitle.BackgroundTransparency = 1

keyTitle.Text =
    "FONDI MM2"

keyTitle.TextColor3 =
    Color3.fromRGB(
        180,
        100,
        255
    )

keyTitle.Font =
    Enum.Font.GothamBold

keyTitle.TextSize = 18

keyTitle.Parent = kFrame

--------------------------------------------------
-- KEY BOX
--------------------------------------------------

local box =
    Instance.new("TextBox")

box.Size =
    UDim2.new(
        0.8,
        0,
        0,
        40
    )

box.Position =
    UDim2.new(
        0.1,
        0,
        0.3,
        0
    )

box.PlaceholderText =
    "ВВЕДИТЕ КЛЮЧ"

box.BackgroundColor3 =
    Color3.fromRGB(
        10,
        10,
        10
    )

box.TextColor3 =
    Color3.new(
        1,
        1,
        1
    )

box.Font =
    Enum.Font.Gotham

box.TextSize = 13

box.Parent = kFrame

Instance.new(
    "UICorner",
    box
)

--------------------------------------------------
-- ACTIVATE
--------------------------------------------------

local btn =
    Instance.new("TextButton")

btn.Size =
    UDim2.new(
        0.8,
        0,
        0,
        40
    )

btn.Position =
    UDim2.new(
        0.1,
        0,
        0.58,
        0
    )

btn.Text =
    "АКТИВИРОВАТЬ"

btn.BackgroundColor3 =
    Color3.fromRGB(
        120,
        50,
        255
    )

btn.TextColor3 =
    Color3.new(
        1,
        1,
        1
    )

btn.Font =
    Enum.Font.GothamBold

btn.TextSize = 12

btn.Parent = kFrame

Instance.new(
    "UICorner",
    btn
)

--------------------------------------------------
-- AUTH
--------------------------------------------------

btn.MouseButton1Click:Connect(
    function()

        if box.Text == KEY then

            IsAuthenticated = true

            print(
                "[FONDI_AUTH]: Доступ разрешен."
            )

            keyGui:Destroy()

            BuildUI()

            Notify(
                "FONDI LOADED",
                Color3.fromRGB(
                    0,
                    255,
                    100
                )
            )

            --------------------------------------------------
            -- INITIAL ESP
            --------------------------------------------------

            task.wait(0.5)

            for _, player in ipairs(
                Players:GetPlayers()
            ) do

                if player ~= LP then
                    CreateESP(player)
                end

            end

        else

            print(
                "[FONDI_AUTH]: Неверный ключ."
            )

            box.Text = ""

            box.PlaceholderText =
                "НЕВЕРНЫЙ КЛЮЧ!"

            Notify(
                "Неверный ключ",
                Color3.fromRGB(
                    255,
                    50,
                    50
                )
            )

        end

    end
)
