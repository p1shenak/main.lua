--[[
    FONDI MM2 V6.5 // RU/EN
    - Переключение языка RU/EN кнопкой
    - Fly через CFrame + Velocity lock
    - Noclip через CanCollide
    - Автосохранение ключа
    - Online key auth
    - ESP / Outline / Tracers / Names / Roles
    - Hotkeys: [L] menu, [F] Fly, [N] Noclip
]]

--==================================================
-- SERVICES
--==================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local pg = LP:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================
local AUTH_URL = "https://fondi-mm-2-auntification.vercel.app/api/validate"
local GENERATE_URL = "https://fondi-mm-2-auntification.vercel.app/api/generate"
local SITE_URL = "https://fondi-mm-2-auntification.vercel.app/"
local KEY_FILE = "fondi_key.txt"
local LANG_FILE = "fondi_lang.txt"

--==================================================
-- SETTINGS
--==================================================
local Settings = {
    ESP = false, Outline = true, Tracers = true,
    ShowNames = true, ShowRoles = true,
    Fly = false, Noclip = false, FlySpeed = 55,
    Spectator = false
}

local IsAuthenticated = false
local Lang = "ru"

--==================================================
-- COLORS
--==================================================
local COLORS = {
    Murderer = Color3.fromRGB(255, 60, 60),
    Sheriff  = Color3.fromRGB(60, 140, 255),
    Innocent = Color3.fromRGB(60, 255, 120),
    Dead     = Color3.fromRGB(130, 130, 130),
    Accent   = Color3.fromRGB(124, 58, 237),
    Accent2  = Color3.fromRGB(6, 182, 212),
    Card     = Color3.fromRGB(15, 15, 22),
    Text     = Color3.fromRGB(255, 255, 255),
    SubText  = Color3.fromRGB(150, 150, 170),
    Success  = Color3.fromRGB(16, 185, 129),
    Danger   = Color3.fromRGB(239, 68, 68),
    Warning  = Color3.fromRGB(245, 158, 11)
}

--==================================================
-- I18N
--==================================================
local I18N = {
    ru = {
        esp = "ESP", outline = "OUTLINE", tracers = "TRACERS",
        names = "NAMES", roles = "ROLES",
        fly = "FLY [F]", noclip = "NOCLIP [N]",
        spectator = "SPECTATOR",
        playerList = "PLAYER LIST",
        menuTitle = "FONDI MM2",
        on = "ВКЛ", off = "ВЫКЛ",
        keyInput = "ВВЕДИТЕ КЛЮЧ",
        keyInvalid = "НЕВЕРНЫЙ КЛЮЧ",
        keyExpired = "СЕССИЯ ИСТЕКЛА",
        activate = "АКТИВИРОВАТЬ",
        checking = "ПРОВЕРКА...",
        autologin = "АВТОВХОД...",
        genTitle = "СГЕНЕРИРОВАТЬ НОВЫЙ КЛЮЧ",
        generate = "СГЕНЕРИРОВАТЬ",
        generating = "ГЕНЕРАЦИЯ...",
        done = "✓ ГОТОВО",
        copyKey = "СКОПИРОВАТЬ КЛЮЧ",
        copied = "✓ СКОПИРОВАНО",
        getScript = "ПОЛУЧИТЬ СКРИПТ",
        linkCopied = "✓ ССЫЛКА СКОПИРОВАНА",
        accessGranted = "ДОСТУП РАЗРЕШЁН",
        autologinOk = "АВТОВХОД: ДОСТУП РАЗРЕШЁН",
        sessionExpired = "Сессия истекла, введите ключ",
        keyCreated = "КЛЮЧ СОЗДАН",
        keyCopiedMsg = "Ключ скопирован!",
        linkCopiedMsg = "Ссылка скопирована!",
        noKey = "Нет ключа",
        errorMsg = "Ошибка",
        noPlayers = "Нет игроков",
        invalidKey = "Неверный ключ",
        flightOn = "FLY: ВКЛ", flightOff = "FLY: ВЫКЛ",
        noclipOn = "NOCLIP: ВКЛ", noclipOff = "NOCLIP: ВЫКЛ",
        langBtn = "EN",
        clipUnavailable = "setclipboard недоступен",
        autologinText = "АВТОВХОД..."
    },
    en = {
        esp = "ESP", outline = "OUTLINE", tracers = "TRACERS",
        names = "NAMES", roles = "ROLES",
        fly = "FLY [F]", noclip = "NOCLIP [N]",
        spectator = "SPECTATOR",
        playerList = "PLAYER LIST",
        menuTitle = "FONDI MM2",
        on = "ON", off = "OFF",
        keyInput = "ENTER KEY",
        keyInvalid = "INVALID KEY",
        keyExpired = "SESSION EXPIRED",
        activate = "ACTIVATE",
        checking = "CHECKING...",
        autologin = "AUTO-LOGIN...",
        genTitle = "GENERATE NEW KEY",
        generate = "GENERATE",
        generating = "GENERATING...",
        done = "✓ DONE",
        copyKey = "COPY KEY",
        copied = "✓ COPIED",
        getScript = "GET SCRIPT",
        linkCopied = "✓ LINK COPIED",
        accessGranted = "ACCESS GRANTED",
        autologinOk = "AUTO-LOGIN: ACCESS GRANTED",
        sessionExpired = "Session expired, enter key",
        keyCreated = "KEY CREATED",
        keyCopiedMsg = "Key copied!",
        linkCopiedMsg = "Link copied!",
        noKey = "No key",
        errorMsg = "Error",
        noPlayers = "No players",
        invalidKey = "Invalid key",
        flightOn = "FLY: ON", flightOff = "FLY: OFF",
        noclipOn = "NOCLIP: ON", noclipOff = "NOCLIP: OFF",
        langBtn = "RU",
        clipUnavailable = "setclipboard unavailable",
        autologinText = "AUTO-LOGIN..."
    }
}

local function T(key)
    return (I18N[Lang] and I18N[Lang][key]) or key
end

--==================================================
-- HELPERS
--==================================================
local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function Stroke(p, col, th)
    local s = Instance.new("UIStroke")
    s.Color = col or COLORS.Accent
    s.Thickness = th or 1
    s.Parent = p
    return s
end

local function Tween(o, t, props, style, dir)
    local info = TweenInfo.new(t or 0.3, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(o, info, props)
    tw:Play()
    return tw
end

--==================================================
-- HTTP
--==================================================
local function HttpPost(url, body)
    local json = HttpService:JSONEncode(body)
    local ok, result = pcall(function()
        if request then
            return request({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json})
        elseif syn and syn.request then
            return syn.request({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json})
        elseif http_request then
            return http_request({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json})
        elseif fluxus and fluxus.request then
            return fluxus.request({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json})
        else
            error("No HTTP method")
        end
    end)
    if not ok or not result then return nil, "HTTP failed" end
    local ok2, data = pcall(function() return HttpService:JSONDecode(result.Body or result) end)
    if not ok2 then return nil, "Invalid JSON" end
    return data
end

local function GetHWID()
    local ok, hwid = pcall(function()
        if gethwid then return gethwid() end
        if syn and syn.get_hwid then return syn.get_hwid() end
        return tostring(LP.UserId)
    end)
    return ok and hwid or tostring(LP.UserId)
end

local function ValidateKey(key)
    local data, err = HttpPost(AUTH_URL, {
        key = key,
        userId = tostring(LP.UserId),
        hwid = GetHWID(),
        lang = Lang
    })
    if not data then return false, err end
    if data.valid then return true, data end
    return false, data.reason or T("invalidKey")
end

local function GenerateKeyRemote(duration)
    local data, err = HttpPost(GENERATE_URL, {
        duration = duration,
        userId = tostring(LP.UserId),
        lang = Lang
    })
    if not data then return nil, err end
    if data.error then return nil, data.error end
    return data.key, data
end

--==================================================
-- SESSION
--==================================================
local function SaveKey(key)
    pcall(function()
        if writefile then writefile(KEY_FILE, key) end
    end)
end

local function LoadKey()
    local ok, content = pcall(function()
        if readfile and isfile and isfile(KEY_FILE) then return readfile(KEY_FILE) end
        return nil
    end)
    if ok and content and content ~= "" then return content end
    return nil
end

local function ClearKey()
    pcall(function()
        if delfile and isfile and isfile(KEY_FILE) then delfile(KEY_FILE) end
    end)
end

local function SaveLang(l)
    pcall(function()
        if writefile then writefile(LANG_FILE, l) end
    end)
end

local function LoadLang()
    local ok, content = pcall(function()
        if readfile and isfile and isfile(LANG_FILE) then return readfile(LANG_FILE) end
        return nil
    end)
    if ok and content and (content == "ru" or content == "en") then return content end
    return nil
end

--==================================================
-- NOTIFY
--==================================================
local function Notify(text, color)
    local sg = pg:FindFirstChild("Fondi_Notify")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "Fondi_Notify"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.Parent = pg
    end
    color = color or COLORS.Accent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 55)
    frame.Position = UDim2.new(1, 20, 0.82, 0)
    frame.BackgroundColor3 = COLORS.Card
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    frame.Parent = sg
    Corner(frame, 10)
    local st = Stroke(frame, color, 1.5)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 3, 1, 0)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    accent.Parent = frame
    Corner(accent, 10)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = tostring(text)
    label.TextColor3 = COLORS.Text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = frame

    Tween(frame, 0.35, {Position = UDim2.new(1, -300, 0.82, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    task.delay(3, function()
        if frame and frame.Parent then
            Tween(frame, 0.3, {Position = UDim2.new(1, 20, 0.82, 0), BackgroundTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            Tween(label, 0.3, {TextTransparency = 1})
            Tween(st, 0.3, {Transparency = 1})
            task.wait(0.35)
            if frame then frame:Destroy() end
        end
    end)
end

--==================================================
-- SOUND
--==================================================
local ToggleSound = Instance.new("Sound")
ToggleSound.Name = "FondiToggleSound"
ToggleSound.SoundId = "rbxassetid://133095302935970"
ToggleSound.Volume = 0.5
ToggleSound.Parent = SoundService

local function PlayToggleSound()
    pcall(function()
        ToggleSound:Stop()
        ToggleSound.TimePosition = 0
        ToggleSound:Play()
    end)
end

--==================================================
-- ROLE / ESP
--==================================================
local function GetRole(player)
    if not player then return "Innocent" end
    local char = player.Character
    local bp = player:FindFirstChildOfClass("Backpack")
    local function Has(c, n) return c and c:FindFirstChild(n) ~= nil end
    if Has(char, "Knife") or Has(bp, "Knife") then return "Murderer" end
    if Has(char, "Gun") or Has(bp, "Gun") or Has(char, "Revolver") or Has(bp, "Revolver") then return "Sheriff" end
    return "Innocent"
end

local function GetRoleColor(role) return COLORS[role] or COLORS.Innocent end

local ESPObjects, PlayerConnections = {}, {}

local function RemoveESP(player)
    local d = ESPObjects[player]
    if not d then return end
    for _, k in ipairs({"Highlight", "Billboard", "Tracer", "TracerStart", "TracerEnd"}) do
        if d[k] then pcall(function() d[k]:Destroy() end) end
    end
    ESPObjects[player] = nil
end

local UpdateESP

local function CreateESP(player)
    if player == LP or not player.Parent then return end
    local char = player.Character
    if not char then return end
    if not char:FindFirstChildOfClass("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then return end
    RemoveESP(player)
    local root = char.HumanoidRootPart
    local data = {Character = char, Root = root}

    local hl = Instance.new("Highlight")
    hl.Name = "FondiHighlight"
    hl.Adornee = char
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = 0.78
    hl.OutlineTransparency = Settings.Outline and 0 or 1
    hl.Parent = char
    data.Highlight = hl

    local bb = Instance.new("BillboardGui")
    bb.Name = "FondiName"
    bb.Adornee = root
    bb.Size = UDim2.new(0, 220, 0, 50)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 10000
    bb.Parent = root
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.new(0,0,0)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.Parent = bb
    data.Billboard = bb
    data.Label = lbl

    local attachEnd = Instance.new("Attachment")
    attachEnd.Name = "FondiTracerEnd"
    attachEnd.Parent = root
    data.TracerEnd = attachEnd

    local tracer = Instance.new("Beam")
    tracer.Name = "FondiTracer"
    tracer.FaceCamera = true
    tracer.Width0 = 0.04
    tracer.Width1 = 0.04
    tracer.Transparency = NumberSequence.new(0.15)
    tracer.Attachment1 = attachEnd
    tracer.Parent = root
    data.Tracer = tracer

    ESPObjects[player] = data
    UpdateESP(player)
end

UpdateESP = function(player)
    if player == LP then return end
    local d = ESPObjects[player]
    if not d then return end
    local char = player.Character
    if not char then RemoveESP(player); return end
    if d.Character ~= char then CreateESP(player); return end

    local role = GetRole(player)
    local rc = GetRoleColor(role)

    if d.Highlight and d.Highlight.Parent then
        d.Highlight.Adornee = char
        d.Highlight.Enabled = Settings.ESP
        d.Highlight.FillColor = rc
        d.Highlight.OutlineColor = rc
        d.Highlight.OutlineTransparency = Settings.Outline and 0 or 1
    end

    if d.Billboard and d.Billboard.Parent and d.Label then
        d.Billboard.Adornee = d.Root
        d.Billboard.Enabled = Settings.ESP and Settings.ShowNames
        d.Label.Text = Settings.ShowRoles and (player.DisplayName .. "\n" .. role) or player.DisplayName
        d.Label.TextColor3 = rc
    end

    if d.Tracer and d.Tracer.Parent then
        d.Tracer.Enabled = Settings.ESP and Settings.Tracers
        d.Tracer.Color = ColorSequence.new(rc)
        if d.TracerEnd then
            if d.TracerEnd.Parent ~= d.Root then d.TracerEnd.Parent = d.Root end
            d.Tracer.Attachment1 = d.TracerEnd
        end
        local myChar = LP.Character
        if myChar then
            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            if myRoot then
                if not d.TracerStart or not d.TracerStart.Parent then
                    local ns = Instance.new("Attachment")
                    ns.Name = "FondiTracerStart"
                    ns.Parent = myRoot
                    d.TracerStart = ns
                elseif d.TracerStart.Parent ~= myRoot then
                    d.TracerStart.Parent = myRoot
                end
                d.Tracer.Attachment0 = d.TracerStart
            end
        end
    end
end

local function DisconnectPlayer(player)
    local c = PlayerConnections[player]
    if not c then return end
    for _, con in ipairs(c) do pcall(function() con:Disconnect() end) end
    PlayerConnections[player] = nil
end

local function SetupPlayer(player)
    if player == LP then return end
    DisconnectPlayer(player)
    PlayerConnections[player] = {}

    local ca = player.CharacterAdded:Connect(function(char)
        RemoveESP(player)
        char:WaitForChild("HumanoidRootPart", 10)
        task.wait(0.25)
        if player.Parent and player.Character == char and Settings.ESP then
            CreateESP(player)
        end
    end)
    table.insert(PlayerConnections[player], ca)

    local cr = player.CharacterRemoving:Connect(function(char)
        local d = ESPObjects[player]
        if d and d.Character == char then RemoveESP(player) end
    end)
    table.insert(PlayerConnections[player], cr)

    local bp = player:FindFirstChildOfClass("Backpack")
    if bp then
        local a = bp.ChildAdded:Connect(function() task.wait(0.05); if Settings.ESP then UpdateESP(player) end end)
        local r = bp.ChildRemoved:Connect(function() task.wait(0.05); if Settings.ESP then UpdateESP(player) end end)
        table.insert(PlayerConnections[player], a)
        table.insert(PlayerConnections[player], r)
    end

    if player.Character then
        task.spawn(function()
            local char = player.Character
            char:WaitForChild("HumanoidRootPart", 5)
            if player.Character == char and Settings.ESP then
                task.wait(0.2)
                CreateESP(player)
            end
        end)
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then SetupPlayer(p) end
end

Players.PlayerAdded:Connect(SetupPlayer)
Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p)
    DisconnectPlayer(p)
end)

task.spawn(function()
    while task.wait(0.5) do
        if Settings.ESP and IsAuthenticated then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Parent and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local d = ESPObjects[p]
                    if not d or d.Character ~= p.Character
                        or not d.Highlight or not d.Highlight.Parent
                        or not d.Billboard or not d.Billboard.Parent then
                        CreateESP(p)
                    else
                        UpdateESP(p)
                    end
                end
            end
        end
    end
end)

--==================================================
-- NOCLIP
--==================================================
local noclipConnection = nil

local function StopNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    local c = LP.Character
    if c then
        for _, o in ipairs(c:GetDescendants()) do
            if o:IsA("BasePart") then
                pcall(function() o.CanCollide = true end)
            end
        end
    end
end

local function StartNoclip()
    StopNoclip()
    noclipConnection = RunService.Stepped:Connect(function()
        if not IsAuthenticated or not Settings.Noclip then return end
        local c = LP.Character
        if not c then return end
        for _, o in ipairs(c:GetDescendants()) do
            if o:IsA("BasePart") then
                if o.CanCollide then
                    o.CanCollide = false
                end
            end
        end
    end)
end

--==================================================
-- FLY
--==================================================
local flyConnection = nil
local flyActive = false

local function StopFly()
    flyActive = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    local c = LP.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then
            pcall(function() h.PlatformStand = false end)
        end
    end
end

local function StartFly()
    StopFly()
    flyActive = true

    flyConnection = RunService.RenderStepped:Connect(function(dt)
        if not IsAuthenticated or not Settings.Fly or not flyActive then return end
        local c = LP.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        local h = c:FindFirstChildOfClass("Humanoid")
        if not r or not h then return end

        h.PlatformStand = true
        r.Velocity = Vector3.zero
        r.RotVelocity = Vector3.zero

        local cam = workspace.CurrentCamera
        if not cam then return end

        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end

        if move.Magnitude > 0 then
            local speed = Settings.FlySpeed
            local delta = move.Unit * speed * dt
            r.CFrame = r.CFrame + delta
        end
    end)
end

LP.CharacterAdded:Connect(function()
    StopFly()
    StopNoclip()
    task.wait(0.5)
    if Settings.Fly and IsAuthenticated then StartFly() end
    if Settings.Noclip and IsAuthenticated then StartNoclip() end
end)

--==================================================
-- KEY GUI
--==================================================
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "FondiKeyGui"
KeyGui.ResetOnSpawn = false
KeyGui.IgnoreGuiInset = true
KeyGui.Parent = pg

local backdrop = Instance.new("Frame", KeyGui)
backdrop.Size = UDim2.new(1, 0, 1, 0)
backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
backdrop.BackgroundTransparency = 0.5
backdrop.BorderSizePixel = 0

local KeyFrame = Instance.new("Frame", KeyGui)
KeyFrame.Size = UDim2.new(0, 400, 0, 530)
KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -265)
KeyFrame.BackgroundColor3 = COLORS.Card
KeyFrame.BackgroundTransparency = 0.03
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
Corner(KeyFrame, 18)
Stroke(KeyFrame, COLORS.Accent, 1.5)

-- Кнопка языка в окне ключа
local keyLangBtn = Instance.new("TextButton", KeyFrame)
keyLangBtn.Size = UDim2.new(0, 50, 0, 26)
keyLangBtn.Position = UDim2.new(1, -62, 0, 10)
keyLangBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
keyLangBtn.Text = T("langBtn")
keyLangBtn.TextColor3 = COLORS.Accent2
keyLangBtn.Font = Enum.Font.GothamBold
keyLangBtn.TextSize = 12
keyLangBtn.BorderSizePixel = 0
keyLangBtn.AutoButtonColor = false
Corner(keyLangBtn, 8)
Stroke(keyLangBtn, COLORS.Accent2, 1)

keyLangBtn.MouseEnter:Connect(function() Tween(keyLangBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}) end)
keyLangBtn.MouseLeave:Connect(function() Tween(keyLangBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(28, 28, 42)}) end)

local keyHeader = Instance.new("TextLabel", KeyFrame)
keyHeader.Size = UDim2.new(1, 0, 0, 42)
keyHeader.Position = UDim2.new(0, 0, 0, 30)
keyHeader.BackgroundTransparency = 1
keyHeader.Text = T("menuTitle")
keyHeader.TextColor3 = COLORS.Text
keyHeader.Font = Enum.Font.GothamBold
keyHeader.TextSize = 26

local keySub = Instance.new("TextLabel", KeyFrame)
keySub.Size = UDim2.new(1, 0, 0, 18)
keySub.Position = UDim2.new(0, 0, 0, 72)
keySub.BackgroundTransparency = 1
keySub.Text = "V6.5 • RU/EN"
keySub.TextColor3 = COLORS.Accent2
keySub.Font = Enum.Font.GothamBold
keySub.TextSize = 11

local KeyBox = Instance.new("TextBox", KeyFrame)
KeyBox.Size = UDim2.new(0.85, 0, 0, 46)
KeyBox.Position = UDim2.new(0.075, 0, 0, 115)
KeyBox.PlaceholderText = T("keyInput")
KeyBox.Text = ""
KeyBox.ClearTextOnFocus = false
KeyBox.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
KeyBox.TextColor3 = COLORS.Text
KeyBox.PlaceholderColor3 = COLORS.SubText
KeyBox.Font = Enum.Font.Code
KeyBox.TextSize = 14
KeyBox.BorderSizePixel = 0
Corner(KeyBox, 10)
Stroke(KeyBox, Color3.fromRGB(45, 45, 65), 1)

local ActivateBtn = Instance.new("TextButton", KeyFrame)
ActivateBtn.Size = UDim2.new(0.85, 0, 0, 46)
ActivateBtn.Position = UDim2.new(0.075, 0, 0, 172)
ActivateBtn.Text = T("activate")
ActivateBtn.BackgroundColor3 = COLORS.Accent
ActivateBtn.TextColor3 = COLORS.Text
ActivateBtn.Font = Enum.Font.GothamBold
ActivateBtn.TextSize = 14
ActivateBtn.BorderSizePixel = 0
ActivateBtn.AutoButtonColor = false
Corner(ActivateBtn, 10)

local divider = Instance.new("Frame", KeyFrame)
divider.Size = UDim2.new(0.85, 0, 0, 1)
divider.Position = UDim2.new(0.075, 0, 0, 240)
divider.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
divider.BorderSizePixel = 0

local genTitle = Instance.new("TextLabel", KeyFrame)
genTitle.Size = UDim2.new(1, 0, 0, 20)
genTitle.Position = UDim2.new(0, 0, 0, 255)
genTitle.BackgroundTransparency = 1
genTitle.Text = T("genTitle")
genTitle.TextColor3 = COLORS.SubText
genTitle.Font = Enum.Font.GothamBold
genTitle.TextSize = 11

local durFrame = Instance.new("Frame", KeyFrame)
durFrame.Size = UDim2.new(0.85, 0, 0, 34)
durFrame.Position = UDim2.new(0.075, 0, 0, 285)
durFrame.BackgroundTransparency = 1
local durLayout = Instance.new("UIListLayout", durFrame)
durLayout.FillDirection = Enum.FillDirection.Horizontal
durLayout.Padding = UDim.new(0, 6)
durLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local DURATIONS = {
    {label = "1D", value = "1d"},
    {label = "7D", value = "7d"},
    {label = "30D", value = "30d"},
    {label = "∞", value = "inf"}
}

local selectedDuration = "1d"
local durButtons = {}

for _, opt in ipairs(DURATIONS) do
    local b = Instance.new("TextButton", durFrame)
    b.Size = UDim2.new(0, 74, 1, 0)
    b.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
    b.Text = opt.label
    b.TextColor3 = COLORS.SubText
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    Corner(b, 8)
    local bs = Stroke(b, Color3.fromRGB(45, 45, 65), 1)

    b.MouseButton1Click:Connect(function()
        selectedDuration = opt.value
        for _, other in ipairs(durButtons) do
            Tween(other.btn, 0.2, {BackgroundColor3 = Color3.fromRGB(28, 28, 42)})
            other.btn.TextColor3 = COLORS.SubText
            other.stroke.Color = Color3.fromRGB(45, 45, 65)
        end
        Tween(b, 0.2, {BackgroundColor3 = COLORS.Accent})
        b.TextColor3 = COLORS.Text
        bs.Color = COLORS.Accent2
        PlayToggleSound()
    end)
    table.insert(durButtons, {btn = b, stroke = bs})
end

durButtons[1].btn.BackgroundColor3 = COLORS.Accent
durButtons[1].btn.TextColor3 = COLORS.Text
durButtons[1].stroke.Color = COLORS.Accent2

local GenBtn = Instance.new("TextButton", KeyFrame)
GenBtn.Size = UDim2.new(0.85, 0, 0, 42)
GenBtn.Position = UDim2.new(0.075, 0, 0, 335)
GenBtn.Text = T("generate")
GenBtn.BackgroundColor3 = COLORS.Success
GenBtn.TextColor3 = COLORS.Text
GenBtn.Font = Enum.Font.GothamBold
GenBtn.TextSize = 13
GenBtn.BorderSizePixel = 0
GenBtn.AutoButtonColor = false
Corner(GenBtn, 10)

local CopyBtn = Instance.new("TextButton", KeyFrame)
CopyBtn.Size = UDim2.new(0.85, 0, 0, 42)
CopyBtn.Position = UDim2.new(0.075, 0, 0, 388)
CopyBtn.Text = T("copyKey")
CopyBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
CopyBtn.TextColor3 = COLORS.Accent2
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 13
CopyBtn.BorderSizePixel = 0
CopyBtn.AutoButtonColor = false
Corner(CopyBtn, 10)
Stroke(CopyBtn, COLORS.Accent2, 1)

local GetScriptBtn = Instance.new("TextButton", KeyFrame)
GetScriptBtn.Size = UDim2.new(0.85, 0, 0, 42)
GetScriptBtn.Position = UDim2.new(0.075, 0, 0, 441)
GetScriptBtn.Text = T("getScript")
GetScriptBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
GetScriptBtn.TextColor3 = COLORS.Accent2
GetScriptBtn.Font = Enum.Font.GothamBold
GetScriptBtn.TextSize = 13
GetScriptBtn.BorderSizePixel = 0
GetScriptBtn.AutoButtonColor = false
Corner(GetScriptBtn, 10)
Stroke(GetScriptBtn, COLORS.Accent2, 1)

ActivateBtn.MouseEnter:Connect(function() Tween(ActivateBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(145, 80, 255)}) end)
ActivateBtn.MouseLeave:Connect(function() Tween(ActivateBtn, 0.2, {BackgroundColor3 = COLORS.Accent}) end)
GenBtn.MouseEnter:Connect(function() Tween(GenBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(20, 210, 140)}) end)
GenBtn.MouseLeave:Connect(function() Tween(GenBtn, 0.2, {BackgroundColor3 = COLORS.Success}) end)
CopyBtn.MouseEnter:Connect(function() Tween(CopyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}) end)
CopyBtn.MouseLeave:Connect(function() Tween(CopyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(28, 28, 42)}) end)
GetScriptBtn.MouseEnter:Connect(function() Tween(GetScriptBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}) end)
GetScriptBtn.MouseLeave:Connect(function() Tween(GetScriptBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(28, 28, 42)}) end)

KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
Tween(KeyFrame, 0.5, {Position = UDim2.new(0.5, -200, 0.5, -265)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Смена языка в окне ключа
keyLangBtn.MouseButton1Click:Connect(function()
    Lang = (Lang == "ru") and "en" or "ru"
    SaveLang(Lang)
    PlayToggleSound()

    -- Обновляем тексты
    keyLangBtn.Text = T("langBtn")
    keyHeader.Text = T("menuTitle")
    KeyBox.PlaceholderText = T("keyInput")
    ActivateBtn.Text = T("activate")
    genTitle.Text = T("genTitle")
    GenBtn.Text = T("generate")
    CopyBtn.Text = T("copyKey")
    GetScriptBtn.Text = T("getScript")

    -- Пересобираем главное меню
    if MainGui and MainGui.Parent then
        pcall(function() MainGui:Destroy() end)
        BuildUI()
    end
end)

local function CloseKeyGui()
    Tween(KeyFrame, 0.3, {
        Position = UDim2.new(0.5, -200, 0.5, -225),
        BackgroundTransparency = 1
    }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    for _, obj in ipairs(KeyFrame:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            Tween(obj, 0.3, {TextTransparency = 1})
        elseif obj:IsA("Frame") and obj ~= KeyFrame then
            Tween(obj, 0.3, {BackgroundTransparency = 1})
        elseif obj:IsA("UIStroke") then
            Tween(obj, 0.3, {Transparency = 1})
        end
    end
    task.wait(0.4)
    KeyGui:Destroy()
    BuildUI()
end

-- AUTH
ActivateBtn.MouseButton1Click:Connect(function()
    if KeyBox.Text == "" then Notify(T("keyInput"), COLORS.Warning); return end
    ActivateBtn.Text = T("checking")
    ActivateBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)

    local valid, info = ValidateKey(KeyBox.Text)
    if valid then
        IsAuthenticated = true
        SaveKey(KeyBox.Text)
        Notify(T("accessGranted"), COLORS.Success)
        CloseKeyGui()
    else
        KeyBox.Text = ""
        KeyBox.PlaceholderText = T("keyInvalid")
        ActivateBtn.Text = T("activate")
        ActivateBtn.BackgroundColor3 = COLORS.Accent
        Notify(info or T("invalidKey"), COLORS.Danger)
        local orig = KeyBox.Position
        for i = 1, 4 do
            Tween(KeyBox, 0.05, {Position = orig + UDim2.new(0, (i%2==0 and 6 or -6), 0, 0)})
            task.wait(0.05)
        end
        Tween(KeyBox, 0.05, {Position = orig})
    end
end)

-- GENERATE
GenBtn.MouseButton1Click:Connect(function()
    GenBtn.Text = T("generating")
    GenBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    GenBtn.Active = false

    task.spawn(function()
        local key, info = GenerateKeyRemote(selectedDuration)
        if key then
            KeyBox.Text = key
            Notify(T("keyCreated"), COLORS.Success)
            GenBtn.Text = T("done")
            GenBtn.BackgroundColor3 = COLORS.Success
        else
            Notify(info or T("errorMsg"), COLORS.Danger)
            GenBtn.Text = T("generate")
            GenBtn.BackgroundColor3 = COLORS.Success
            GenBtn.Active = true
        end
    end)
end)

-- COPY KEY
CopyBtn.MouseButton1Click:Connect(function()
    if KeyBox.Text == "" then Notify(T("noKey"), COLORS.Warning); return end
    if setclipboard then
        setclipboard(KeyBox.Text)
        Notify(T("keyCopiedMsg"), COLORS.Success)
        CopyBtn.Text = T("copied")
        task.wait(1.2)
        CopyBtn.Text = T("copyKey")
    else
        Notify(T("clipUnavailable"), COLORS.Danger)
    end
end)

-- GET SCRIPT
GetScriptBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(SITE_URL)
        Notify(T("linkCopiedMsg"), COLORS.Success)
        GetScriptBtn.Text = T("linkCopied")
        Tween(GetScriptBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(16, 60, 40)})
        task.wait(1.8)
        GetScriptBtn.Text = T("getScript")
        Tween(GetScriptBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(28, 28, 42)})
    else
        Notify(T("clipUnavailable"), COLORS.Danger)
    end
end)

-- AUTO-LOGIN
task.spawn(function()
    task.wait(1.5)
    local savedKey = LoadKey()
    if not savedKey then return end

    KeyBox.Text = savedKey
    ActivateBtn.Text = T("autologin")
    ActivateBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)

    local valid, info = ValidateKey(savedKey)
    if valid then
        IsAuthenticated = true
        Notify(T("autologinOk"), COLORS.Success)
        CloseKeyGui()
    else
        ClearKey()
        KeyBox.Text = ""
        KeyBox.PlaceholderText = T("keyExpired")
        ActivateBtn.Text = T("activate")
        ActivateBtn.BackgroundColor3 = COLORS.Accent
        Notify(T("sessionExpired"), COLORS.Warning)
    end
end)

--==================================================
-- MAIN UI
--==================================================
local MainGui, MainFrame

function BuildUI()
    if MainGui then pcall(function() MainGui:Destroy() end) end
    MainGui = Instance.new("ScreenGui")
    MainGui.Name = "Fondi_V6"
    MainGui.ResetOnSpawn = false
    MainGui.IgnoreGuiInset = true
    MainGui.Parent = pg

    MainFrame = Instance.new("Frame", MainGui)
    MainFrame.Size = UDim2.new(0, 360, 0, 560)
    MainFrame.Position = UDim2.new(0.5, -180, 0.5, -280)
    MainFrame.BackgroundColor3 = COLORS.Card
    MainFrame.BackgroundTransparency = 0.03
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    Corner(MainFrame, 18)
    Stroke(MainFrame, COLORS.Accent, 1.5)

    local header = Instance.new("Frame", MainFrame)
    header.Size = UDim2.new(1, 0, 0, 65)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    Corner(header, 18)

    local ht = Instance.new("TextLabel", header)
    ht.Size = UDim2.new(1, -120, 0, 30)
    ht.Position = UDim2.new(0, 20, 0, 8)
    ht.BackgroundTransparency = 1
    ht.Text = T("menuTitle")
    ht.TextColor3 = COLORS.Text
    ht.Font = Enum.Font.GothamBold
    ht.TextSize = 20
    ht.TextXAlignment = Enum.TextXAlignment.Left

    local hs = Instance.new("TextLabel", header)
    hs.Size = UDim2.new(1, -120, 0, 18)
    hs.Position = UDim2.new(0, 20, 0, 36)
    hs.BackgroundTransparency = 1
    hs.Text = "V6.5 • " .. (LP.DisplayName or "User")
    hs.TextColor3 = COLORS.Accent2
    hs.Font = Enum.Font.Gotham
    hs.TextSize = 11
    hs.TextXAlignment = Enum.TextXAlignment.Left

    -- Lang button
    local langBtn = Instance.new("TextButton", header)
    langBtn.Size = UDim2.new(0, 40, 0, 30)
    langBtn.Position = UDim2.new(1, -80, 0, 17)
    langBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
    langBtn.Text = T("langBtn")
    langBtn.TextColor3 = COLORS.Accent2
    langBtn.Font = Enum.Font.GothamBold
    langBtn.TextSize = 12
    langBtn.BorderSizePixel = 0
    langBtn.AutoButtonColor = false
    Corner(langBtn, 8)
    Stroke(langBtn, COLORS.Accent2, 1)

    langBtn.MouseEnter:Connect(function() Tween(langBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}) end)
    langBtn.MouseLeave:Connect(function() Tween(langBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(28, 28, 42)}) end)

    langBtn.MouseButton1Click:Connect(function()
        Lang = (Lang == "ru") and "en" or "ru"
        SaveLang(Lang)
        PlayToggleSound()
        if MainGui then pcall(function() MainGui:Destroy() end) end
        BuildUI()
    end)

    -- Close button
    local close = Instance.new("TextButton", header)
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -36, 0, 17)
    close.BackgroundColor3 = Color3.fromRGB(45, 20, 25)
    close.Text = "✕"
    close.TextColor3 = COLORS.Danger
    close.Font = Enum.Font.GothamBold
    close.TextSize = 14
    close.BorderSizePixel = 0
    Corner(close, 8)
    close.MouseButton1Click:Connect(function()
        Tween(MainFrame, 0.25, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.25)
        MainFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 360, 0, 560)
        MainFrame.Position = UDim2.new(0.5, -180, 0.5, -280)
    end)

    local scroll = Instance.new("ScrollingFrame", MainFrame)
    scroll.Size = UDim2.new(1, -20, 1, -85)
    scroll.Position = UDim2.new(0, 10, 0, 75)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = COLORS.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 8)

    local function CreateToggle(name, setting, color)
        color = color or COLORS.Accent

        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1, -5, 0, 46)
        btn.BackgroundColor3 = Settings[setting] and Color3.fromRGB(28, 28, 44) or Color3.fromRGB(20, 20, 30)
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        Corner(btn, 10)
        local bs = Stroke(btn, Settings[setting] and color or Color3.fromRGB(45, 45, 65), 1.5)

        local lbl = Instance.new("TextLabel", btn)
        lbl.Size = UDim2.new(1, -100, 1, 0)
        lbl.Position = UDim2.new(0, 16, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.TextColor3 = Settings[setting] and color or COLORS.Text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local pill = Instance.new("Frame", btn)
        pill.Size = UDim2.new(0, 40, 0, 22)
        pill.Position = UDim2.new(1, -54, 0.5, -11)
        pill.BackgroundColor3 = Settings[setting] and color or Color3.fromRGB(50, 50, 70)
        pill.BorderSizePixel = 0
        Corner(pill, 11)

        local knob = Instance.new("Frame", pill)
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = Settings[setting] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        knob.BackgroundColor3 = Color3.new(1,1,1)
        knob.BorderSizePixel = 0
        Corner(knob, 8)

        btn.MouseEnter:Connect(function()
            Tween(btn, 0.2, {BackgroundColor3 = Color3.fromRGB(30, 30, 45)})
        end)
        btn.MouseLeave:Connect(function()
            if not Settings[setting] then
                Tween(btn, 0.2, {BackgroundColor3 = Color3.fromRGB(20, 20, 30)})
            end
        end)

        btn.MouseButton1Click:Connect(function()
            Settings[setting] = not Settings[setting]
            local on = Settings[setting]

            Tween(btn, 0.2, {BackgroundColor3 = on and Color3.fromRGB(28, 28, 44) or Color3.fromRGB(20, 20, 30)})
            Tween(bs, 0.2, {Color = on and color or Color3.fromRGB(45, 45, 65)})
            Tween(lbl, 0.2, {TextColor3 = on and color or COLORS.Text})
            Tween(pill, 0.2, {BackgroundColor3 = on and color or Color3.fromRGB(50, 50, 70)})
            Tween(knob, 0.25, {
                Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

            PlayToggleSound()
            Notify(name .. ": " .. (on and T("on") or T("off")), on and COLORS.Success or COLORS.Danger)

            if setting == "ESP" then
                if Settings.ESP then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LP then CreateESP(p) end
                    end
                else
                    for p, _ in pairs(ESPObjects) do RemoveESP(p) end
                end
            end
            if setting == "Fly" then
                if Settings.Fly then StartFly() else StopFly() end
            end
            if setting == "Noclip" then
                if Settings.Noclip then StartNoclip() else StopNoclip() end
            end
        end)
    end

    CreateToggle(T("esp"), "ESP", COLORS.Accent)
    CreateToggle(T("outline"), "Outline", COLORS.Accent2)
    CreateToggle(T("tracers"), "Tracers", Color3.fromRGB(255, 100, 200))
    CreateToggle(T("names"), "ShowNames", Color3.fromRGB(150, 200, 255))
    CreateToggle(T("roles"), "ShowRoles", Color3.fromRGB(200, 150, 255))
    CreateToggle(T("fly"), "Fly", Color3.fromRGB(0, 200, 255))
    CreateToggle(T("noclip"), "Noclip", Color3.fromRGB(100, 255, 100))

    local specBtn = Instance.new("TextButton", scroll)
    specBtn.Size = UDim2.new(1, -5, 0, 46)
    specBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    specBtn.Text = T("spectator")
    specBtn.TextColor3 = COLORS.Text
    specBtn.Font = Enum.Font.GothamBold
    specBtn.TextSize = 13
    specBtn.BorderSizePixel = 0
    specBtn.AutoButtonColor = false
    Corner(specBtn, 10)
    Stroke(specBtn, Color3.fromRGB(45, 45, 65), 1.5)

    specBtn.MouseButton1Click:Connect(function()
        Settings.Spectator = not Settings.Spectator
        local cam = workspace.CurrentCamera
        if not Settings.Spectator then
            cam.CameraSubject = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            specBtn.Text = T("spectator")
            specBtn.TextColor3 = COLORS.Text
            Tween(specBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(20, 20, 30)})
            return
        end
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
                table.insert(list, p)
            end
        end
        if #list == 0 then
            Settings.Spectator = false
            Notify(T("noPlayers"), COLORS.Danger)
            return
        end
        local t = list[1]
        cam.CameraSubject = t.Character:FindFirstChildOfClass("Humanoid")
        specBtn.Text = T("spectator") .. ": " .. t.DisplayName
        specBtn.TextColor3 = COLORS.Accent2
        Tween(specBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(28, 28, 44)})
    end)

    local listTitle = Instance.new("TextLabel", scroll)
    listTitle.Size = UDim2.new(1, -5, 0, 26)
    listTitle.BackgroundTransparency = 1
    listTitle.Text = T("playerList")
    listTitle.TextColor3 = COLORS.SubText
    listTitle.Font = Enum.Font.GothamBold
    listTitle.TextSize = 11
    listTitle.TextXAlignment = Enum.TextXAlignment.Left

    local playerList = Instance.new("Frame", scroll)
    playerList.Size = UDim2.new(1, -5, 0, 0)
    playerList.AutomaticSize = Enum.AutomaticSize.Y
    playerList.BackgroundColor3 = Color3.fromRGB(15, 15, 24)
    playerList.BorderSizePixel = 0
    Corner(playerList, 10)
    Stroke(playerList, Color3.fromRGB(45, 45, 65), 1)
    local ll = Instance.new("UIListLayout", playerList)
    ll.Padding = UDim.new(0, 2)
    local lp2 = Instance.new("UIPadding", playerList)
    lp2.PaddingTop = UDim.new(0, 6)
    lp2.PaddingBottom = UDim.new(0, 6)

    local function RefreshList()
        for _, c in ipairs(playerList:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                local role = GetRole(p)
                local row = Instance.new("TextLabel", playerList)
                row.Size = UDim2.new(1, -10, 0, 22)
                row.Position = UDim2.new(0, 5, 0, 0)
                row.BackgroundTransparency = 1
                row.Text = p.DisplayName .. "  ·  " .. role
                row.TextColor3 = GetRoleColor(role)
                row.Font = Enum.Font.Gotham
                row.TextSize = 11
                row.TextXAlignment = Enum.TextXAlignment.Left
            end
        end
    end
    RefreshList()

    task.spawn(function()
        while MainGui and MainGui.Parent do
            task.wait(1)
            if playerList and playerList.Parent then RefreshList() end
        end
    end)

    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Tween(MainFrame, 0.4, {
        Size = UDim2.new(0, 360, 0, 560),
        Position = UDim2.new(0.5, -180, 0.5, -280)
    }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

--==================================================
-- HOTKEYS
--==================================================
local function ToggleMenu()
    if not MainGui or not MainGui.Parent then return end
    if not MainFrame.Visible then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        Tween(MainFrame, 0.3, {
            Size = UDim2.new(0, 360, 0, 560),
            Position = UDim2.new(0.5, -180, 0.5, -280)
        }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        Tween(MainFrame, 0.25, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.25)
        MainFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 360, 0, 560)
        MainFrame.Position = UDim2.new(0.5, -180, 0.5, -280)
    end
end

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.L then
        ToggleMenu()
    elseif input.KeyCode == Enum.KeyCode.F then
        if IsAuthenticated then
            Settings.Fly = not Settings.Fly
            if Settings.Fly then StartFly() else StopFly() end
            Notify(Settings.Fly and T("flightOn") or T("flightOff"), Settings.Fly and COLORS.Success or COLORS.Danger)
        end
    elseif input.KeyCode == Enum.KeyCode.N then
        if IsAuthenticated then
            Settings.Noclip = not Settings.Noclip
            if Settings.Noclip then StartNoclip() else StopNoclip() end
            Notify(Settings.Noclip and T("noclipOn") or T("noclipOff"), Settings.Noclip and COLORS.Success or COLORS.Danger)
        end
    end
end)

-- Загрузка сохранённого языка
do
    local saved = LoadLang()
    if saved then Lang = saved end
end

print("==========================================")
print("[FONDI MM2 V6.5] RU/EN READY")
print("[FONDI MM2] Press L to toggle menu")
print("==========================================")
