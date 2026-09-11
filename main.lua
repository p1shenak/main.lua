--[[
    FONDI MM2 V4.1 // ROUND-SAFE EDITION

    FEATURES:
    - ESP
    - Highlight Outline
    - Role Detection
    - Murderer = RED
    - Sheriff = BLUE
    - Innocent = GREEN
    - Player List
    - Spectator
    - Fly
    - Noclip
    - Settings
    - Hotkeys

    HOTKEYS:
    L = Menu
    V = Fly
    B = Noclip
    P = Player List
    O = Spectator
]]

--------------------------------------------------
-- SERVICES
--------------------------------------------------

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
    SpectatedPlayer = nil,

    MenuKey = Enum.KeyCode.L,
    FlyKey = Enum.KeyCode.V,
    NoclipKey = Enum.KeyCode.B,
    PlayerListKey = Enum.KeyCode.P,
    SpectatorKey = Enum.KeyCode.O
}

local KEY = "FONDI-MM2-FOREVER"

local IsAuthenticated = false

--------------------------------------------------
-- STORAGE
--------------------------------------------------

local ESPObjects = {}

local MainGUI = nil
local MainFrame = nil

local PlayerListGUI = nil
local PlayerListFrame = nil

local flyBV = nil
local flyBG = nil

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

    frame.Size = UDim2.new(0, 250, 0, 45)
    frame.Position = UDim2.new(1, 20, 0.8, 0)

    frame.BackgroundColor3 =
        Color3.fromRGB(12, 12, 18)

    frame.Parent = sg

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color =
        color or Color3.fromRGB(120, 50, 255)
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local label = Instance.new("TextLabel")

    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)

    label.BackgroundTransparency = 1
    label.Text = tostring(text)

    label.TextColor3 =
        Color3.new(1, 1, 1)

    label.Font =
        Enum.Font.GothamBold

    label.TextSize = 13
    label.Parent = frame

    TweenService:Create(
        frame,
        TweenInfo.new(
            0.35,
            Enum.EasingStyle.Back,
            Enum.EasingDirection.Out
        ),
        {
            Position =
                UDim2.new(1, -270, 0.8, 0)
        }
    ):Play()

    task.delay(2.3, function()

        if not frame then
            return
        end

        TweenService:Create(
            frame,
            TweenInfo.new(0.3),
            {
                Position =
                    UDim2.new(1, 20, 0.8, 0)
            }
        ):Play()

        task.wait(0.35)

        if frame then
            frame:Destroy()
        end

    end)

end

--------------------------------------------------
-- ROLE DETECTION
--------------------------------------------------

local function HasTool(player, names)

    if not player then
        return false
    end

    local backpack =
        player:FindFirstChild("Backpack")

    local character =
        player.Character

    for _, name in ipairs(names) do

        if backpack
            and backpack:FindFirstChild(name) then

            return true

        end

        if character
            and character:FindFirstChild(name) then

            return true

        end

    end

    return false
end

--------------------------------------------------

local function GetRole(player)

    if not player then
        return "Innocent"
    end

    --------------------------------------------------
    -- MURDERER
    --------------------------------------------------

    if HasTool(player, {
        "Knife",
        "DefaultKnife",
        "KnifeServer"
    }) then

        return "Murderer"

    end

    --------------------------------------------------
    -- SHERIFF
    --------------------------------------------------

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

--------------------------------------------------

local function GetRoleColor(role)

    if role == "Murderer" then

        return Color3.fromRGB(
            255,
            30,
            30
        )

    elseif role == "Sheriff" then

        return Color3.fromRGB(
            40,
            120,
            255
        )

    else

        return Color3.fromRGB(
            50,
            255,
            100
        )

    end
end

--------------------------------------------------
-- ESP
--------------------------------------------------

local UpdateESP

--------------------------------------------------

local function RemoveESP(player)

    local data =
        ESPObjects[player]

    if not data then
        return
    end

    if data.Highlight then
        data.Highlight:Destroy()
    end

    if data.Billboard then
        data.Billboard:Destroy()
    end

    ESPObjects[player] = nil
end

--------------------------------------------------

local function CreateESP(player)

    if player == LP then
        return
    end

    RemoveESP(player)

    local data = {}

    --------------------------------------------------
    -- HIGHLIGHT
    --------------------------------------------------

    local highlight =
        Instance.new("Highlight")

    highlight.Name =
        "Fondi_Outline"

    highlight.DepthMode =
        Enum.HighlightDepthMode.AlwaysOnTop

    highlight.FillTransparency =
        0.88

    highlight.OutlineTransparency =
        0

    highlight.Enabled = false

    highlight.Parent = pg

    --------------------------------------------------
    -- NAME
    --------------------------------------------------

    local billboard =
        Instance.new("BillboardGui")

    billboard.Name =
        "Fondi_Name"

    billboard.Size =
        UDim2.new(0, 200, 0, 45)

    billboard.StudsOffset =
        Vector3.new(0, 3.5, 0)

    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    billboard.Parent = pg

    local label =
        Instance.new("TextLabel")

    label.Size =
        UDim2.new(1, 0, 1, 0)

    label.BackgroundTransparency = 1

    label.TextColor3 =
        Color3.new(1, 1, 1)

    label.TextStrokeTransparency =
        0.15

    label.Font =
        Enum.Font.GothamBold

    label.TextSize = 13

    label.Parent = billboard

    data.Highlight = highlight
    data.Billboard = billboard
    data.Label = label

    ESPObjects[player] = data

    --------------------------------------------------
    -- CHARACTER ADDED
    -- Срабатывает после каждой смерти
    -- и каждого нового раунда
    --------------------------------------------------

    player.CharacterAdded:Connect(function(character)

        data.Character = character

        highlight.Adornee = nil
        highlight.Enabled = false

        billboard.Adornee = nil
        billboard.Enabled = false

        local root =
            character:WaitForChild(
                "HumanoidRootPart",
                10
            )

        if not root then
            return
        end

        task.wait(0.2)

        if player.Parent == Players then
            UpdateESP(player)
        end

    end)

    --------------------------------------------------
    -- CHARACTER REMOVING
    --------------------------------------------------

    player.CharacterRemoving:Connect(function()

        data.Character = nil

        highlight.Adornee = nil
        highlight.Enabled = false

        billboard.Adornee = nil
        billboard.Enabled = false

    end)

    --------------------------------------------------
    -- EXISTING CHARACTER
    --------------------------------------------------

    if player.Character then

        data.Character =
            player.Character

        task.spawn(function()

            local root =
                player.Character:FindFirstChild(
                    "HumanoidRootPart"
                )

            if not root then

                root =
                    player.Character:WaitForChild(
                        "HumanoidRootPart",
                        10
                    )

            end

            if root then
                UpdateESP(player)
            end

        end)

    end
end

--------------------------------------------------
-- UPDATE ESP
--------------------------------------------------

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

    --------------------------------------------------
    -- NO CHARACTER
    --------------------------------------------------

    if not character then

        data.Highlight.Adornee = nil
        data.Highlight.Enabled = false

        data.Billboard.Adornee = nil
        data.Billboard.Enabled = false

        return
    end

    --------------------------------------------------
    -- HUMANOID
    --------------------------------------------------

    local humanoid =
        character:FindFirstChildOfClass(
            "Humanoid"
        )

    local root =
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    --------------------------------------------------
    -- DEAD
    --------------------------------------------------

    if not humanoid
        or not root
        or humanoid.Health <= 0 then

        data.Highlight.Adornee = nil
        data.Highlight.Enabled = false

        data.Billboard.Adornee = nil
        data.Billboard.Enabled = false

        return
    end

    --------------------------------------------------
    -- ESP OFF
    --------------------------------------------------

    if not Settings.ESP
        or not IsAuthenticated then

        data.Highlight.Enabled = false
        data.Billboard.Enabled = false

        return
    end

    --------------------------------------------------
    -- ROLE
    --------------------------------------------------

    local role =
        GetRole(player)

    local color =
        GetRoleColor(role)

    --------------------------------------------------
    -- HIGHLIGHT
    --------------------------------------------------

    data.Highlight.Adornee =
        character

    data.Highlight.Enabled =
        Settings.Outline

    data.Highlight.FillColor =
        color

    data.Highlight.OutlineColor =
        color

    --------------------------------------------------
    -- NAME
    --------------------------------------------------

    data.Billboard.Adornee =
        root

    data.Billboard.Enabled =
        Settings.ShowNames

    if Settings.ShowRoles then

        data.Label.Text =
            player.DisplayName ..
            "\n[" ..
            role ..
            "]"

    else

        data.Label.Text =
            player.DisplayName

    end

    data.Label.TextColor3 =
        color

end

--------------------------------------------------
-- SETUP PLAYER
--------------------------------------------------

local function SetupPlayer(player)

    if player == LP then
        return
    end

    CreateESP(player)

end

--------------------------------------------------
-- PLAYER ADDED
--------------------------------------------------

Players.PlayerAdded:Connect(function(player)

    SetupPlayer(player)

end)

--------------------------------------------------
-- PLAYER REMOVING
--------------------------------------------------

Players.PlayerRemoving:Connect(function(player)

    RemoveESP(player)

    if Settings.SpectatedPlayer == player then

        Settings.SpectatedPlayer = nil
        Settings.Spectating = false

        local character =
            LP.Character

        local humanoid =
            character
            and character:FindFirstChildOfClass(
                "Humanoid"
            )

        if humanoid then

            workspace.CurrentCamera.CameraSubject =
                humanoid

        end

    end

end)

--------------------------------------------------
-- EXISTING PLAYERS
--------------------------------------------------

for _, player in ipairs(
    Players:GetPlayers()
) do

    if player ~= LP then
        SetupPlayer(player)
    end

end

--------------------------------------------------
-- ESP UPDATE LOOP
--------------------------------------------------

task.spawn(function()

    while task.wait(0.15) do

        if not IsAuthenticated then
            continue
        end

        for _, player in ipairs(
            Players:GetPlayers()
        ) do

            if player ~= LP then

                if not ESPObjects[player] then
                    SetupPlayer(player)
                end

                UpdateESP(player)

            end

        end

    end

end)

--------------------------------------------------
-- EXTRA ROLE CHECK
-- Нужен для момента, когда Knife/Gun
-- появляется немного позже Character
--------------------------------------------------

task.spawn(function()

    while task.wait(0.5) do

        if not IsAuthenticated then
            continue
        end

        for player, data in pairs(
            ESPObjects
        ) do

            if player.Parent ~= Players then

                RemoveESP(player)

            else

                UpdateESP(player)

            end

        end

    end

end)

--------------------------------------------------
-- FLY
--------------------------------------------------

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

--------------------------------------------------

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

    if flyBV then
        return
    end

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

--------------------------------------------------

RunService.RenderStepped:Connect(function()

    if not IsAuthenticated then
        return
    end

    if not Settings.Fly then

        StopFly()
        return

    end

    local character =
        LP.Character

    local root =
        character
        and character:FindFirstChild(
            "HumanoidRootPart"
        )

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

    local camera =
        workspace.CurrentCamera

    local direction =
        Vector3.zero

    if UIS:IsKeyDown(
        Enum.KeyCode.W
    ) then

        direction +=
            camera.CFrame.LookVector

    end

    if UIS:IsKeyDown(
        Enum.KeyCode.S
    ) then

        direction -=
            camera.CFrame.LookVector

    end

    if UIS:IsKeyDown(
        Enum.KeyCode.A
    ) then

        direction -=
            camera.CFrame.RightVector

    end

    if UIS:IsKeyDown(
        Enum.KeyCode.D
    ) then

        direction +=
            camera.CFrame.RightVector

    end

    if UIS:IsKeyDown(
        Enum.KeyCode.Space
    ) then

        direction +=
            Vector3.new(0, 1, 0)

    end

    if UIS:IsKeyDown(
        Enum.KeyCode.LeftShift
    ) then

        direction -=
            Vector3.new(0, 1, 0)

    end

    if direction.Magnitude > 0 then

        direction =
            direction.Unit

        flyBV.Velocity =
            direction *
            Settings.FlySpeed

    else

        flyBV.Velocity =
            Vector3.zero

    end

    flyBG.CFrame =
        camera.CFrame

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

end)

--------------------------------------------------
-- SPECTATOR
--------------------------------------------------

local function StopSpectating()

    Settings.Spectating = false
    Settings.SpectatedPlayer = nil

    local character =
        LP.Character

    local humanoid =
        character
        and character:FindFirstChildOfClass(
            "Humanoid"
        )

    if humanoid then

        workspace.CurrentCamera.CameraSubject =
            humanoid

    end

    Notify(
        "SPECTATOR: ВЫКЛ",
        Color3.fromRGB(
            255,
            80,
            80
        )
    )

end

--------------------------------------------------

local function SpectatePlayer(player)

    if not player
        or player == LP then

        return
    end

    local character =
        player.Character

    local humanoid =
        character
        and character:FindFirstChildOfClass(
            "Humanoid"
        )

    if not humanoid then

        Notify(
            "Игрок ещё не загрузился",
            Color3.fromRGB(
                255,
                180,
                60
            )
        )

        return
    end

    Settings.Spectating = true
    Settings.SpectatedPlayer = player

    workspace.CurrentCamera.CameraSubject =
        humanoid

    Notify(
        "SPECTATE: " ..
        player.DisplayName,
        Color3.fromRGB(
            120,
            50,
            255
        )
    )

end

--------------------------------------------------
-- PLAYER LIST
--------------------------------------------------

local function CreatePlayerList()

    if PlayerListGUI then

        PlayerListGUI.Enabled = true
        return

    end

    PlayerListGUI =
        Instance.new("ScreenGui")

    PlayerListGUI.Name =
        "Fondi_PlayerList"

    PlayerListGUI.ResetOnSpawn = false
    PlayerListGUI.Parent = pg

    --------------------------------------------------

    PlayerListFrame =
        Instance.new("Frame")

    PlayerListFrame.Size =
        UDim2.new(
            0,
            300,
            0,
            360
        )

    PlayerListFrame.Position =
        UDim2.new(
            1,
            -320,
            0.5,
            -180
        )

    PlayerListFrame.BackgroundColor3 =
        Color3.fromRGB(
            14,
            14,
            20
        )

    PlayerListFrame.Active = true
    PlayerListFrame.Draggable = true

    PlayerListFrame.Parent =
        PlayerListGUI

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 10)

    corner.Parent =
        PlayerListFrame

    local stroke =
        Instance.new("UIStroke")

    stroke.Color =
        Color3.fromRGB(
            120,
            50,
            255
        )

    stroke.Thickness = 2
    stroke.Parent =
        PlayerListFrame

    --------------------------------------------------
    -- TITLE
    --------------------------------------------------

    local title =
        Instance.new("TextLabel")

    title.Size =
        UDim2.new(
            1,
            -50,
            0,
            45
        )

    title.Position =
        UDim2.new(
            0,
            10,
            0,
            0
        )

    title.BackgroundTransparency = 1

    title.Text =
        "FONDI // PLAYER LIST"

    title.TextColor3 =
        Color3.new(1, 1, 1)

    title.Font =
        Enum.Font.GothamBold

    title.TextSize = 15

    title.Parent =
        PlayerListFrame

    --------------------------------------------------
    -- CLOSE
    --------------------------------------------------

    local close =
        Instance.new("TextButton")

    close.Size =
        UDim2.new(
            0,
            35,
            0,
            35
        )

    close.Position =
        UDim2.new(
            1,
            -40,
            0,
            5
        )

    close.Text = "X"

    close.TextColor3 =
        Color3.new(1, 1, 1)

    close.BackgroundColor3 =
        Color3.fromRGB(
            35,
            35,
            45
        )

    close.Font =
        Enum.Font.GothamBold

    close.Parent =
        PlayerListFrame

    Instance.new(
        "UICorner",
        close
    ).CornerRadius =
        UDim.new(0, 7)

    close.MouseButton1Click:Connect(function()

        PlayerListGUI.Enabled = false

    end)

    --------------------------------------------------
    -- SCROLL
    --------------------------------------------------

    local scroll =
        Instance.new("ScrollingFrame")

    scroll.Name =
        "Players"

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
            50
        )

    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4

    scroll.Parent =
        PlayerListFrame

    local layout =
        Instance.new("UIListLayout")

    layout.Padding =
        UDim.new(0, 6)

    layout.Parent =
        scroll

    --------------------------------------------------
    -- REFRESH
    --------------------------------------------------

    local function RefreshPlayerList()

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

                local role =
                    GetRole(player)

                local color =
                    GetRoleColor(role)

                local button =
                    Instance.new("TextButton")

                button.Size =
                    UDim2.new(
                        1,
                        -5,
                        0,
                        48
                    )

                button.BackgroundColor3 =
                    Color3.fromRGB(
                        27,
                        27,
                        34
                    )

                button.TextColor3 =
                    color

                button.Font =
                    Enum.Font.GothamBold

                button.TextSize = 12

                button.Text =
                    player.DisplayName ..
                    "\n[" ..
                    role ..
                    "]"

                button.Parent =
                    scroll

                Instance.new(
                    "UICorner",
                    button
                ).CornerRadius =
                    UDim.new(0, 7)

                button.MouseButton1Click:Connect(
                    function()

                        SpectatePlayer(player)

                    end
                )

            end

        end

        task.wait()

        scroll.CanvasSize =
            UDim2.new(
                0,
                0,
                0,
                layout.AbsoluteContentSize.Y + 10
            )

    end

    --------------------------------------------------

    task.spawn(function()

        while PlayerListGUI
            and PlayerListGUI.Parent do

            if PlayerListGUI.Enabled then

                RefreshPlayerList()

            end

            task.wait(0.7)

        end

    end)

    PlayerListGUI.Enabled = true

end

--------------------------------------------------
-- MAIN UI
--------------------------------------------------

local function BuildUI()

    if MainGUI then

        MainGUI.Enabled = true
        return

    end

    MainGUI =
        Instance.new("ScreenGui")

    MainGUI.Name =
        "Fondi_V41"

    MainGUI.ResetOnSpawn = false
    MainGUI.Parent = pg

    --------------------------------------------------

    MainFrame =
        Instance.new("Frame")

    MainFrame.Size =
        UDim2.new(
            0,
            310,
            0,
            450
        )

    MainFrame.Position =
        UDim2.new(
            0.5,
            -155,
            0.5,
            -225
        )

    MainFrame.BackgroundColor3 =
        Color3.fromRGB(
            14,
            14,
            20
        )

    MainFrame.Active = true
    MainFrame.Draggable = true

    MainFrame.Parent =
        MainGUI

    --------------------------------------------------

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 12)

    corner.Parent =
        MainFrame

    local stroke =
        Instance.new("UIStroke")

    stroke.Color =
        Color3.fromRGB(
            120,
            50,
            255
        )

    stroke.Thickness = 2

    stroke.Parent =
        MainFrame

    --------------------------------------------------
    -- TITLE
    --------------------------------------------------

    local title =
        Instance.new("TextLabel")

    title.Size =
        UDim2.new(
            1,
            0,
            0,
            55
        )

    title.BackgroundTransparency = 1

    title.Text =
        "FONDI MM2 V4.1"

    title.TextColor3 =
        Color3.new(1, 1, 1)

    title.Font =
        Enum.Font.GothamBlack

    title.TextSize = 18

    title.Parent =
        MainFrame

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
            -70
        )

    scroll.Position =
        UDim2.new(
            0,
            10,
            0,
            60
        )

    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3

    scroll.Parent =
        MainFrame

    local layout =
        Instance.new("UIListLayout")

    layout.Padding =
        UDim.new(0, 7)

    layout.Parent =
        scroll

    --------------------------------------------------
    -- TOGGLE
    --------------------------------------------------

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
                43
            )

        button.BackgroundColor3 =
            Color3.fromRGB(
                28,
                28,
                35
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
        ).CornerRadius =
            UDim.new(0, 8)

        local function Refresh()

            local enabled =
                Settings[setting]

            button.Text =
                name ..
                " : " ..
                (
                    enabled
                    and "ON"
                    or "OFF"
                )

            if enabled then

                button.BackgroundColor3 =
                    Color3.fromRGB(
                        90,
                        40,
                        180
                    )

            else

                button.BackgroundColor3 =
                    Color3.fromRGB(
                        28,
                        28,
                        35
                    )

            end

        end

        Refresh()

        button.MouseButton1Click:Connect(
            function()

                Settings[setting] =
                    not Settings[setting]

                Refresh()

                if setting == "Fly"
                    and not Settings.Fly then

                    StopFly()

                end

                Notify(
                    name ..
                    ": " ..
                    (
                        Settings[setting]
                        and "ВКЛ"
                        or "ВЫКЛ"
                    ),
                    Settings[setting]
                    and Color3.fromRGB(
                        70,
                        255,
                        120
                    )
                    or Color3.fromRGB(
                        255,
                        70,
                        70
                    )
                )

            end
        )

    end

    --------------------------------------------------
    -- SETTINGS
    --------------------------------------------------

    CreateToggle(
        "ESP",
        "ESP"
    )

    CreateToggle(
        "OUTLINE",
        "Outline"
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
    -- PLAYER LIST BUTTON
    --------------------------------------------------

    local playerListButton =
        Instance.new("TextButton")

    playerListButton.Size =
        UDim2.new(
            1,
            -5,
            0,
            43
        )

    playerListButton.BackgroundColor3 =
        Color3.fromRGB(
            28,
            28,
            35
        )

    playerListButton.Text =
        "PLAYER LIST"

    playerListButton.TextColor3 =
        Color3.new(1, 1, 1)

    playerListButton.Font =
        Enum.Font.GothamBold

    playerListButton.TextSize = 12

    playerListButton.Parent =
        scroll

    Instance.new(
        "UICorner",
        playerListButton
    ).CornerRadius =
        UDim.new(0, 8)

    playerListButton.MouseButton1Click:Connect(
        function()

            CreatePlayerList()

        end
    )

    --------------------------------------------------
    -- STOP SPECTATE
    --------------------------------------------------

    local stopSpectate =
        Instance.new("TextButton")

    stopSpectate.Size =
        UDim2.new(
            1,
            -5,
            0,
            43
        )

    stopSpectate.BackgroundColor3 =
        Color3.fromRGB(
            28,
            28,
            35
        )

    stopSpectate.Text =
        "STOP SPECTATING"

    stopSpectate.TextColor3 =
        Color3.new(1, 1, 1)

    stopSpectate.Font =
        Enum.Font.GothamBold

    stopSpectate.TextSize = 12

    stopSpectate.Parent =
        scroll

    Instance.new(
        "UICorner",
        stopSpectate
    ).CornerRadius =
        UDim.new(0, 8)

    stopSpectate.MouseButton1Click:Connect(
        function()

            StopSpectating()

        end
    )

    --------------------------------------------------
    -- FLY SPEED
    --------------------------------------------------

    local speedBox =
        Instance.new("TextBox")

    speedBox.Size =
        UDim2.new(
            1,
            -5,
            0,
            43
        )

    speedBox.BackgroundColor3 =
        Color3.fromRGB(
            28,
            28,
            35
        )

    speedBox.TextColor3 =
        Color3.new(1, 1, 1)

    speedBox.PlaceholderText =
        "Fly Speed: 50"

    speedBox.Text = ""

    speedBox.ClearTextOnFocus = false

    speedBox.Font =
        Enum.Font.GothamBold

    speedBox.TextSize = 12

    speedBox.Parent =
        scroll

    Instance.new(
        "UICorner",
        speedBox
    ).CornerRadius =
        UDim.new(0, 8)

    speedBox.FocusLost:Connect(
        function()

            local value =
                tonumber(
                    speedBox.Text
                )

            if value then

                Settings.FlySpeed =
                    math.clamp(
                        value,
                        1,
                        500
                    )

                Notify(
                    "Fly Speed: " ..
                    Settings.FlySpeed,
                    Color3.fromRGB(
                        120,
                        50,
                        255
                    )
                )

            end

            speedBox.Text = ""

        end
    )

    --------------------------------------------------

    task.wait()

    scroll.CanvasSize =
        UDim2.new(
            0,
            0,
            0,
            layout.AbsoluteContentSize.Y + 15
        )

end

--------------------------------------------------
-- HOTKEYS
--------------------------------------------------

UIS.InputBegan:Connect(
    function(input, processed)

        if processed then
            return
        end

        if not IsAuthenticated then
            return
        end

        --------------------------------------------------
        -- MENU
        --------------------------------------------------

        if input.KeyCode ==
            Settings.MenuKey then

            if MainGUI then

                MainGUI.Enabled =
                    not MainGUI.Enabled

            end

        --------------------------------------------------
        -- FLY
        --------------------------------------------------

        elseif input.KeyCode ==
            Settings.FlyKey then

            Settings.Fly =
                not Settings.Fly

            if not Settings.Fly then
                StopFly()
            end

            Notify(
                "Fly: " ..
                (
                    Settings.Fly
                    and "ВКЛ"
                    or "ВЫКЛ"
                ),
                Settings.Fly
                and Color3.fromRGB(
                    70,
                    255,
                    120
                )
                or Color3.fromRGB(
                    255,
                    70,
                    70
                )
            )

        --------------------------------------------------
        -- NOCLIP
        --------------------------------------------------

        elseif input.KeyCode ==
            Settings.NoclipKey then

            Settings.Noclip =
                not Settings.Noclip

            Notify(
                "Noclip: " ..
                (
                    Settings.Noclip
                    and "ВКЛ"
                    or "ВЫКЛ"
                ),
                Settings.Noclip
                and Color3.fromRGB(
                    70,
                    255,
                    120
                )
                or Color3.fromRGB(
                    255,
                    70,
                    70
                )
            )

        --------------------------------------------------
        -- PLAYER LIST
        --------------------------------------------------

        elseif input.KeyCode ==
            Settings.PlayerListKey then

            CreatePlayerList()

            if PlayerListGUI then

                PlayerListGUI.Enabled =
                    not PlayerListGUI.Enabled

            end

        --------------------------------------------------
        -- SPECTATOR
        --------------------------------------------------

        elseif input.KeyCode ==
            Settings.SpectatorKey then

            if Settings.Spectating then

                StopSpectating()

            else

                CreatePlayerList()

                Notify(
                    "Выбери игрока",
                    Color3.fromRGB(
                        120,
                        50,
                        255
                    )
                )

            end

        end

    end
)

--------------------------------------------------
-- KEY GUI
--------------------------------------------------

local KeyGUI =
    Instance.new("ScreenGui")

KeyGUI.Name =
    "Fondi_Key"

KeyGUI.ResetOnSpawn = false
KeyGUI.Parent = pg

--------------------------------------------------

local KeyFrame =
    Instance.new("Frame")

KeyFrame.Size =
    UDim2.new(
        0,
        320,
        0,
        190
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
        14,
        14,
        20
    )

KeyFrame.Parent =
    KeyGUI

local keyCorner =
    Instance.new("UICorner")

keyCorner.CornerRadius =
    UDim.new(0, 12)

keyCorner.Parent =
    KeyFrame

local keyStroke =
    Instance.new("UIStroke")

keyStroke.Color =
    Color3.fromRGB(
        120,
        50,
        255
    )

keyStroke.Thickness = 2

keyStroke.Parent =
    KeyFrame

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
    Color3.new(1, 1, 1)

keyTitle.Font =
    Enum.Font.GothamBlack

keyTitle.TextSize = 18

keyTitle.Parent =
    KeyFrame

--------------------------------------------------

local keyBox =
    Instance.new("TextBox")

keyBox.Size =
    UDim2.new(
        0.8,
        0,
        0,
        40
    )

keyBox.Position =
    UDim2.new(
        0.1,
        0,
        0.28,
        0
    )

keyBox.PlaceholderText =
    "ВВЕДИТЕ КЛЮЧ"

keyBox.BackgroundColor3 =
    Color3.fromRGB(
        8,
        8,
        12
    )

keyBox.TextColor3 =
    Color3.new(1, 1, 1)

keyBox.Font =
    Enum.Font.GothamBold

keyBox.TextSize = 12

keyBox.Parent =
    KeyFrame

Instance.new(
    "UICorner",
    keyBox
).CornerRadius =
    UDim.new(0, 7)

--------------------------------------------------

local keyButton =
    Instance.new("TextButton")

keyButton.Size =
    UDim2.new(
        0.8,
        0,
        0,
        40
    )

keyButton.Position =
    UDim2.new(
        0.1,
        0,
        0.57,
        0
    )

keyButton.Text =
    "АКТИВИРОВАТЬ"

keyButton.BackgroundColor3 =
    Color3.fromRGB(
        120,
        50,
        255
    )

keyButton.TextColor3 =
    Color3.new(1, 1, 1)

keyButton.Font =
    Enum.Font.GothamBold

keyButton.TextSize = 12

keyButton.Parent =
    KeyFrame

Instance.new(
    "UICorner",
    keyButton
).CornerRadius =
    UDim.new(0, 7)

--------------------------------------------------
-- AUTH
--------------------------------------------------

keyButton.MouseButton1Click:Connect(
    function()

        if keyBox.Text == KEY then

            IsAuthenticated = true

            KeyGUI:Destroy()

            BuildUI()

            Notify(
                "FONDI MM2 V4.1 LOADED",
                Color3.fromRGB(
                    70,
                    255,
                    120
                )
            )

        else

            keyBox.Text = ""

            keyBox.PlaceholderText =
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

--------------------------------------------------
-- FINAL
--------------------------------------------------

print("================================")
print(" FONDI MM2 V4.1")
print(" ROUND-SAFE ESP")
print(" PLAYER LIST")
print(" SPECTATOR")
print(" FLY")
print(" NOCLIP")
print(" HIGHLIGHT")
print("================================")
