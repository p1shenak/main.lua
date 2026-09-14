--[[
    FONDI MM2 V10.1 // NEON UI (ZIndex FIXED)
    - Красивое меню с анимациями запуска
    - Плавные переходы между вкладками
    - Particle burst при клике
    - Loading screen
    - ESP / Fly / Noclip / Bhop / Anti-Fling / Aimbot / Kill All / Farm / Fling / Reveal / Anti-Kick
    - RU/EN
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

local LP = Players.LocalPlayer
local pg = LP:WaitForChild("PlayerGui")

local AUTH_URL = "https://fondi-mm-2-auntification.vercel.app/api/validate"
local GENERATE_URL = "https://fondi-mm-2-auntification.vercel.app/api/generate"
local KEY_FILE = "fondi_key.txt"
local LANG_FILE = "fondi_lang.txt"

local IsAuthenticated = false
local Lang = "ru"

local Settings = {
    ESP=false, Outline=true, Tracers=true, ShowNames=true, ShowRoles=true,
    Fly=false, Noclip=false, Bhop=false, AntiFling=false, FlySpeed=55,
    Aimbot=false, RevealMurderer=false, AutoPickup=false,
    KillAll=false, KillAuraRange=15, Farm=false, Notifications=true
}

local C = {
    Murderer = Color3.fromRGB(255, 60, 60),
    Sheriff  = Color3.fromRGB(60, 140, 255),
    Innocent = Color3.fromRGB(60, 255, 120),
    Accent   = Color3.fromRGB(139, 92, 246),
    Accent2  = Color3.fromRGB(34, 211, 238),
    Bg       = Color3.fromRGB(10, 10, 15),
    Card     = Color3.fromRGB(18, 18, 26),
    Card2    = Color3.fromRGB(24, 24, 34),
    Text     = Color3.fromRGB(255, 255, 255),
    SubText  = Color3.fromRGB(140, 140, 160),
    Border   = Color3.fromRGB(45, 45, 60),
    Success  = Color3.fromRGB(16, 185, 129),
    Danger   = Color3.fromRGB(239, 68, 68),
    Warning  = Color3.fromRGB(245, 158, 11),
    Pink     = Color3.fromRGB(244, 114, 182),
    Green    = Color3.fromRGB(100, 255, 100),
    Orange   = Color3.fromRGB(255, 150, 50),
    Blue     = Color3.fromRGB(0, 200, 255),
    Purple2  = Color3.fromRGB(168, 85, 247)
}

local I18N = {
    ru = {
        menu="FONDI MM2", esp="ESP", outline="Контур", tracers="Трассеры",
        names="Имена", roles="Роли", fly="Полёт", noclip="Noclip",
        bhop="Bhop", antifling="Anti-Fling", aimbot="Aimbot",
        killall="Kill All", pickup="Auto-Pickup", reveal="Reveal Murderer",
        range="Радиус", farm="Farm (Монеты)", notif="Уведомления",
        spectator="Spectator", flingTitle="FLING",
        flingBtn="ВЫБРОСИТЬ", flingAll="ВЫБРОСИТЬ ВСЕХ",
        playerList="СПИСОК ИГРОКОВ",
        keyInput="Введите ключ", keyInvalid="Неверный ключ",
        keyExpired="Сессия истекла", activate="АКТИВИРОВАТЬ",
        checking="ПРОВЕРКА...", autologin="АВТОВХОД...",
        genTitle="Генерация ключа", generate="СГЕНЕРИРОВАТЬ",
        generating="ГЕНЕРАЦИЯ...", done="ГОТОВО",
        copyKey="СКОПИРОВАТЬ", copied="СКОПИРОВАНО",
        getScript="ССЫЛКА", linkCopied="Ссылка скопирована!",
        accessGranted="Доступ разрешён",
        autologinOk="Автовход выполнен",
        sessionExpired="Сессия истекла",
        keyCreated="Ключ создан", keyCopiedMsg="Ключ скопирован!",
        noKey="Нет ключа", errorMsg="Ошибка",
        noPlayers="Нет игроков", invalidKey="Неверный ключ",
        flightOn="FLY: ВКЛ", flightOff="FLY: ВЫКЛ",
        noclipOn="NOCLIP: ВКЛ", noclipOff="NOCLIP: ВЫКЛ",
        bhopOn="BHOP: ВКЛ", bhopOff="BHOP: ВЫКЛ",
        langBtn="EN", becameM=" стал MURDERER", becameS=" стал SHERIFF",
        clipUnavailable="setclipboard недоступен",
        catMain="ГЛАВНОЕ", catMove="ДВИЖЕНИЕ", catCombat="БОЙ",
        catFarm="ФАРМ", catMisc="РАЗНОЕ", catSettings="НАСТРОЙКИ",
        on="ВКЛ", off="ВЫКЛ", selectPlayer="ВЫБРАТЬ ИГРОКА",
        selected="ВЫБРАН: ", loading="ЗАГРУЗКА", ready="ГОТОВО"
    },
    en = {
        menu="FONDI MM2", esp="ESP", outline="Outline", tracers="Tracers",
        names="Names", roles="Roles", fly="Fly", noclip="Noclip",
        bhop="Bhop", antifling="Anti-Fling", aimbot="Aimbot",
        killall="Kill All", pickup="Auto-Pickup", reveal="Reveal Murderer",
        range="Range", farm="Farm (Coins)", notif="Notifications",
        spectator="Spectator", flingTitle="FLING",
        flingBtn="FLING", flingAll="FLING ALL",
        playerList="PLAYER LIST",
        keyInput="Enter key", keyInvalid="Invalid key",
        keyExpired="Session expired", activate="ACTIVATE",
        checking="CHECKING...", autologin="AUTO-LOGIN...",
        genTitle="Generate key", generate="GENERATE",
        generating="GENERATING...", done="DONE",
        copyKey="COPY", copied="COPIED",
        getScript="LINK", linkCopied="Link copied!",
        accessGranted="Access granted",
        autologinOk="Auto-login OK",
        sessionExpired="Session expired",
        keyCreated="Key created", keyCopiedMsg="Key copied!",
        noKey="No key", errorMsg="Error",
        noPlayers="No players", invalidKey="Invalid key",
        flightOn="FLY: ON", flightOff="FLY: OFF",
        noclipOn="NOCLIP: ON", noclipOff="NOCLIP: OFF",
        bhopOn="BHOP: ON", bhopOff="BHOP: OFF",
        langBtn="RU", becameM=" became MURDERER", becameS=" became SHERIFF",
        clipUnavailable="setclipboard unavailable",
        catMain="MAIN", catMove="MOVEMENT", catCombat="COMBAT",
        catFarm="FARM", catMisc="MISC", catSettings="SETTINGS",
        on="ON", off="OFF", selectPlayer="SELECT PLAYER",
        selected="SELECTED: ", loading="LOADING", ready="READY"
    }
}
local function T(k) return (I18N[Lang] and I18N[Lang][k]) or k end

local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end
local function Stroke(p, col, th, trans)
    local s = Instance.new("UIStroke")
    s.Color = col or C.Accent
    s.Thickness = th or 1
    s.Transparency = trans or 0
    s.Parent = p
    return s
end
local function Tween(o, t, props, style, dir)
    local info = TweenInfo.new(t or 0.3, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(o, info, props)
    tw:Play()
    return tw
end

local function HttpPost(url, body)
    local json = HttpService:JSONEncode(body)
    local ok, result = pcall(function()
        if request then
            return request({Url=url, Method="POST", Headers={["Content-Type"]="application/json"}, Body=json})
        elseif syn and syn.request then
            return syn.request({Url=url, Method="POST", Headers={["Content-Type"]="application/json"}, Body=json})
        elseif http_request then
            return http_request({Url=url, Method="POST", Headers={["Content-Type"]="application/json"}, Body=json})
        elseif fluxus and fluxus.request then
            return fluxus.request({Url=url, Method="POST", Headers={["Content-Type"]="application/json"}, Body=json})
        else error("No HTTP") end
    end)
    if not ok or not result then return nil, "HTTP failed" end
    local ok2, data = pcall(function() return HttpService:JSONDecode(result.Body or result) end)
    if not ok2 then return nil, "Invalid JSON" end
    return data
end

local function GetHWID()
    local ok, h = pcall(function()
        if gethwid then return gethwid() end
        if syn and syn.get_hwid then return syn.get_hwid() end
        return tostring(LP.UserId)
    end)
    return ok and h or tostring(LP.UserId)
end

local function ValidateKey(key)
    local data, err = HttpPost(AUTH_URL, {key=key, userId=tostring(LP.UserId), hwid=GetHWID(), lang=Lang})
    if not data then return false, err end
    if data.valid then return true, data end
    return false, data.reason or T("invalidKey")
end

local function GenerateKeyRemote(dur)
    local data, err = HttpPost(GENERATE_URL, {duration=dur, userId=tostring(LP.UserId), lang=Lang})
    if not data then return nil, err end
    if data.error then return nil, data.error end
    return data.key, data
end

local function SaveKey(k) pcall(function() if writefile then writefile(KEY_FILE, k) end end) end
local function LoadKey()
    local ok, c = pcall(function() if readfile and isfile and isfile(KEY_FILE) then return readfile(KEY_FILE) end end)
    if ok and c and c ~= "" then return c end
end
local function ClearKey() pcall(function() if delfile and isfile and isfile(KEY_FILE) then delfile(KEY_FILE) end end) end
local function SaveLang(l) pcall(function() if writefile then writefile(LANG_FILE, l) end end) end
local function LoadLang()
    local ok, c = pcall(function() if readfile and isfile and isfile(LANG_FILE) then return readfile(LANG_FILE) end end)
    if ok and (c == "ru" or c == "en") then return c end
end

local function Notify(text, color, duration)
    duration = duration or 3
    local sg = pg:FindFirstChild("Fondi_Notify")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "Fondi_Notify"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.DisplayOrder = 999
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.Parent = pg
    end
    color = color or C.Accent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 60)
    frame.Position = UDim2.new(1, 30, 0.82, 0)
    frame.BackgroundColor3 = C.Card
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    frame.Parent = sg
    Corner(frame, 12)
    local st = Stroke(frame, color, 1.5)

    local glow = Instance.new("Frame", frame)
    glow.Size = UDim2.new(1, 8, 1, 8)
    glow.Position = UDim2.new(0, -4, 0, -4)
    glow.BackgroundColor3 = color
    glow.BackgroundTransparency = 0.85
    glow.BorderSizePixel = 0
    glow.ZIndex = 0
    Corner(glow, 14)
    frame.ZIndex = 2

    local accent = Instance.new("Frame", frame)
    accent.Size = UDim2.new(0, 3, 1, -12)
    accent.Position = UDim2.new(0, 6, 0, 6)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    Corner(accent, 3)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = tostring(text)
    label.TextColor3 = C.Text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.TextTransparency = 1

    Tween(frame, 0.4, {Position = UDim2.new(1, -320, 0.82, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Tween(label, 0.3, {TextTransparency = 0})

    task.delay(duration, function()
        if frame and frame.Parent then
            Tween(frame, 0.3, {Position = UDim2.new(1, 30, 0.82, 0), BackgroundTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            Tween(glow, 0.3, {BackgroundTransparency = 1})
            Tween(label, 0.3, {TextTransparency = 1})
            Tween(st, 0.3, {Transparency = 1})
            task.wait(0.35)
            if frame then frame:Destroy() end
        end
    end)
end

local function BurstFrom(el)
    local sg = pg:FindFirstChild("Fondi_Burst")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "Fondi_Burst"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.DisplayOrder = 1000
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.Parent = pg
    end

    local absPos = el.AbsolutePosition
    local absSize = el.AbsoluteSize
    local cx = absPos.X + absSize.X / 2
    local cy = absPos.Y + absSize.Y / 2

    local colors = {C.Accent, C.Accent2, C.Success, C.Warning, C.Pink}
    for i = 1, 12 do
        local p = Instance.new("Frame", sg)
        p.Size = UDim2.new(0, 5, 0, 5)
        p.Position = UDim2.fromOffset(cx, cy)
        p.BackgroundColor3 = colors[math.random(1, #colors)]
        p.BorderSizePixel = 0
        Corner(p, 3)

        local angle = (math.pi * 2 * i) / 12 + math.random() * 0.5
        local dist = 40 + math.random() * 60
        local dx = math.cos(angle) * dist
        local dy = math.sin(angle) * dist

        Tween(p, 0.7, {
            Position = UDim2.fromOffset(cx + dx, cy + dy),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0)
        }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        task.delay(0.75, function() p:Destroy() end)
    end
end

local ToggleSound = Instance.new("Sound")
ToggleSound.SoundId = "rbxassetid://133095302935970"
ToggleSound.Volume = 0.4
ToggleSound.Parent = SoundService

local function PlayClick()
    pcall(function()
        ToggleSound:Stop()
        ToggleSound.TimePosition = 0
        ToggleSound:Play()
    end)
end

local function GetRole(player)
    if not player then return "Innocent" end
    local char = player.Character
    local bp = player:FindFirstChildOfClass("Backpack")
    local function Has(c, n) return c and c:FindFirstChild(n) ~= nil end
    if Has(char, "Knife") or Has(bp, "Knife") then return "Murderer" end
    if Has(char, "Gun") or Has(bp, "Gun") or Has(char, "Revolver") or Has(bp, "Revolver") then return "Sheriff" end
    return "Innocent"
end
local function RoleColor(r) return C[r] or C.Innocent end

local ESPObjects, PlayerConnections = {}, {}
local lastRoles = {}

local function RemoveESP(player)
    local d = ESPObjects[player]
    if not d then return end
    for _, k in ipairs({"Highlight","Billboard","Tracer","TracerStart","TracerEnd"}) do
        if d[k] then pcall(function() d[k]:Destroy() end) end
    end
    ESPObjects[player] = nil
end

local UpdateESP

local function CreateESP(player)
    if player == LP or not player.Parent then return end
    local char = player.Character
    if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then return end
    RemoveESP(player)
    local root = char.HumanoidRootPart
    local d = {Character = char, Root = root}

    local hl = Instance.new("Highlight")
    hl.Name = "FondiHL"; hl.Adornee = char
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = 0.78
    hl.OutlineTransparency = Settings.Outline and 0 or 1
    hl.Parent = char
    d.Highlight = hl

    local bb = Instance.new("BillboardGui")
    bb.Name = "FondiBB"; bb.Adornee = root
    bb.Size = UDim2.new(0, 220, 0, 50)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true; bb.MaxDistance = 10000
    bb.Parent = root
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
    lbl.TextStrokeTransparency = 0; lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14; lbl.Parent = bb
    d.Billboard = bb; d.Label = lbl

    local a1 = Instance.new("Attachment"); a1.Name = "FondiA1"; a1.Parent = root
    d.TracerEnd = a1

    local beam = Instance.new("Beam")
    beam.Name = "FondiBeam"; beam.FaceCamera = true
    beam.Width0 = 0.04; beam.Width1 = 0.04
    beam.Transparency = NumberSequence.new(0.15)
    beam.Attachment1 = a1; beam.Parent = root
    d.Tracer = beam

    ESPObjects[player] = d
    UpdateESP(player)
end

UpdateESP = function(player)
    if player == LP then return end
    local d = ESPObjects[player]; if not d then return end
    local char = player.Character
    if not char then RemoveESP(player); return end
    if d.Character ~= char then CreateESP(player); return end

    local role = GetRole(player)
    local rc = RoleColor(role)

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
                    local ns = Instance.new("Attachment"); ns.Name = "FondiA0"; ns.Parent = myRoot
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
    local c = PlayerConnections[player]; if not c then return end
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
        if player.Parent and player.Character == char and Settings.ESP then CreateESP(player) end
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
                task.wait(0.2); CreateESP(player)
            end
        end)
    end
end

for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then SetupPlayer(p) end end
Players.PlayerAdded:Connect(SetupPlayer)
Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p); DisconnectPlayer(p); lastRoles[p] = nil
end)

task.spawn(function()
    while task.wait(0.4) do
        if IsAuthenticated then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Parent then
                    if Settings.RevealMurderer then
                        local role = GetRole(p)
                        if role ~= lastRoles[p] then
                            lastRoles[p] = role
                            if role == "Murderer" then Notify(p.DisplayName .. T("becameM"), C.Murderer, 4)
                            elseif role == "Sheriff" then Notify(p.DisplayName .. T("becameS"), C.Sheriff, 4) end
                        end
                    end
                    if Settings.ESP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local d = ESPObjects[p]
                        if not d or d.Character ~= p.Character
                            or not d.Highlight or not d.Highlight.Parent
                            or not d.Billboard or not d.Billboard.Parent then
                            CreateESP(p)
                        else UpdateESP(p) end
                    end
                end
            end
        end
    end
end)

local noclipConnection = nil
local function StopNoclip()
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    local c = LP.Character
    if c then for _, o in ipairs(c:GetDescendants()) do
        if o:IsA("BasePart") then pcall(function() o.CanCollide = true end) end
    end end
end
local function StartNoclip()
    StopNoclip()
    noclipConnection = RunService.Stepped:Connect(function()
        if not IsAuthenticated or not Settings.Noclip then return end
        local c = LP.Character
        if not c then return end
        for _, o in ipairs(c:GetDescendants()) do
            if o:IsA("BasePart") and o.CanCollide then o.CanCollide = false end
        end
    end)
end

local flyConnection, flyActive = nil, false
local function StopFly()
    flyActive = false
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    local c = LP.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then pcall(function() h.PlatformStand = false end) end
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
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
        if move.Magnitude > 0 then
            r.CFrame = r.CFrame + (move.Unit * Settings.FlySpeed * dt)
        end
    end)
end

local bhopConnection = nil
local function StopBhop()
    if bhopConnection then bhopConnection:Disconnect(); bhopConnection = nil end
end
local function StartBhop()
    StopBhop()
    bhopConnection = RunService.Heartbeat:Connect(function()
        if not IsAuthenticated or not Settings.Bhop then return end
        if not UIS:IsKeyDown(Enum.KeyCode.Space) then return end
        local c = LP.Character
        if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        local r = c:FindFirstChild("HumanoidRootPart")
        if h and r and h.FloorMaterial ~= Enum.Material.Air then
            h.Jump = true
            r.Velocity = r.Velocity + (h.MoveDirection * 4)
        end
    end)
end

local afConnection = nil
local function StopAntiFling()
    if afConnection then afConnection:Disconnect(); afConnection = nil end
end
local function StartAntiFling()
    StopAntiFling()
    afConnection = RunService.Heartbeat:Connect(function()
        if not IsAuthenticated or not Settings.AntiFling then return end
        local c = LP.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        if r.Velocity.Magnitude > 200 or r.RotVelocity.Magnitude > 100 then
            r.Velocity = Vector3.zero
            r.RotVelocity = Vector3.zero
        end
    end)
end

local aimbotConnection = nil
local function StopAimbot()
    if aimbotConnection then aimbotConnection:Disconnect(); aimbotConnection = nil end
end
local function StartAimbot()
    StopAimbot()
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not IsAuthenticated or not Settings.Aimbot then return end
        if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local closest, minDist = nil, 200
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and pl.Character and GetRole(pl) == "Murderer" then
                local head = pl.Character:FindFirstChild("Head")
                if head then
                    local pos, vis = cam:WorldToViewportPoint(head.Position)
                    if vis then
                        local d = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                        if d < minDist then minDist = d; closest = pl end
                    end
                end
            end
        end
        if closest and closest.Character then
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, closest.Character.Head.Position), 0.2)
        end
    end)
end

local pickupConnection = nil
local function StopPickup()
    if pickupConnection then pickupConnection:Disconnect(); pickupConnection = nil end
end
local function StartPickup()
    StopPickup()
    pickupConnection = RunService.Heartbeat:Connect(function()
        if not IsAuthenticated or not Settings.AutoPickup then return end
        local c = LP.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("gun") or obj.Name:lower():find("revolver")) then
                if (obj.Position - r.Position).Magnitude < 50 then
                    r.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                end
            end
        end
    end)
end

local killAllConnection = nil
local function GetWeapon()
    local c = LP.Character
    if not c then return nil end
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") and (t.Name == "Knife" or t.Name == "Gun" or t.Name == "Revolver") then return t end
    end
end
local function StopKillAll()
    if killAllConnection then killAllConnection:Disconnect(); killAllConnection = nil end
end
local function StartKillAll()
    StopKillAll()
    killAllConnection = RunService.Heartbeat:Connect(function()
        if not IsAuthenticated or not Settings.KillAll then return end
        local c = LP.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        local w = GetWeapon()
        if not r or not w then return end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and pl.Character then
                local tr = pl.Character:FindFirstChild("HumanoidRootPart")
                if tr and (tr.Position - r.Position).Magnitude < Settings.KillAuraRange then
                    r.CFrame = CFrame.new(r.Position, Vector3.new(tr.Position.X, r.Position.Y, tr.Position.Z))
                    pcall(function() w:Activate() end)
                end
            end
        end
    end)
end

local function FlingPlayer(target)
    if not target or not target.Character then return end
    local tr = target.Character:FindFirstChild("HumanoidRootPart")
    if not tr then return end
    local bv = Instance.new("BodyVelocity", tr)
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.new(99999, 99999, 99999)
    task.delay(0.15, function() pcall(function() bv:Destroy() end) end)
    Notify("FLING → " .. target.DisplayName, C.Pink, 2)
end

local farmConnection = nil
local function StopFarm()
    if farmConnection then farmConnection:Disconnect(); farmConnection = nil end
end
local function StartFarm()
    StopFarm()
    farmConnection = RunService.Heartbeat:Connect(function()
        if not IsAuthenticated or not Settings.Farm then return end
        local c = LP.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        local closest, minDist = nil, math.huge
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("gem") or obj.Name:lower():find("money")) then
                local d = (obj.Position - r.Position).Magnitude
                if d < minDist then minDist = d; closest = obj end
            end
        end
        if closest then r.CFrame = CFrame.new(closest.Position + Vector3.new(0, 2, 0)) end
    end)
end

pcall(function()
    local oldKick = hookfunction or hookfunc
    if oldKick and LP.Kick then
        oldKick(LP.Kick, function(self, msg)
            Notify("ANTI-KICK: " .. tostring(msg), C.Danger, 5)
            task.wait(0.05)
            return LP.Kick(self, msg)
        end)
    end
end)

local function ShowLoadingScreen(callback)
    local loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "FondiLoading"
    loadingGui.ResetOnSpawn = false
    loadingGui.IgnoreGuiInset = true
    loadingGui.DisplayOrder = 9999
    loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loadingGui.Parent = pg

    local bg = Instance.new("Frame", loadingGui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = C.Bg
    bg.BorderSizePixel = 0

    local g1 = Instance.new("Frame", bg)
    g1.Size = UDim2.new(0, 500, 0, 500)
    g1.Position = UDim2.new(0.5, -250, 0.5, -250)
    g1.BackgroundColor3 = C.Accent
    g1.BackgroundTransparency = 0.7
    g1.BorderSizePixel = 0
    g1.ZIndex = 0
    Corner(g1, 250)
    Tween(g1, 3, {Size = UDim2.new(0, 700, 0, 700), Position = UDim2.new(0.5, -350, 0.5, -350)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

    local g2 = Instance.new("Frame", bg)
    g2.Size = UDim2.new(0, 300, 0, 300)
    g2.Position = UDim2.new(0.5, -150, 0.5, -150)
    g2.BackgroundColor3 = C.Accent2
    g2.BackgroundTransparency = 0.75
    g2.BorderSizePixel = 0
    g2.ZIndex = 0
    Corner(g2, 150)

    local logo = Instance.new("TextLabel", bg)
    logo.Size = UDim2.new(1, 0, 0, 60)
    logo.Position = UDim2.new(0, 0, 0.4, -60)
    logo.BackgroundTransparency = 1
    logo.ZIndex = 5
    logo.Text = "FONDI"
    logo.TextColor3 = C.Text
    logo.Font = Enum.Font.GothamBold
    logo.TextSize = 52
    logo.TextTransparency = 1

    local logo2 = Instance.new("TextLabel", bg)
    logo2.Size = UDim2.new(1, 0, 0, 40)
    logo2.Position = UDim2.new(0, 0, 0.4, -5)
    logo2.BackgroundTransparency = 1
    logo2.ZIndex = 5
    logo2.Text = "MM2 V10.1"
    logo2.TextColor3 = C.Accent2
    logo2.Font = Enum.Font.GothamBold
    logo2.TextSize = 16
    logo2.TextTransparency = 1

    local barBg = Instance.new("Frame", bg)
    barBg.Size = UDim2.new(0, 400, 0, 4)
    barBg.Position = UDim2.new(0.5, -200, 0.6, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    barBg.BorderSizePixel = 0
    barBg.BackgroundTransparency = 1
    barBg.ZIndex = 5
    Corner(barBg, 2)

    local barFill = Instance.new("Frame", barBg)
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = C.Accent
    barFill.BorderSizePixel = 0
    Corner(barFill, 2)

    local statusText = Instance.new("TextLabel", bg)
    statusText.Size = UDim2.new(1, 0, 0, 20)
    statusText.Position = UDim2.new(0, 0, 0.6, 15)
    statusText.BackgroundTransparency = 1
    statusText.ZIndex = 5
    statusText.Text = T("loading") .. "..."
    statusText.TextColor3 = C.SubText
    statusText.Font = Enum.Font.GothamBold
    statusText.TextSize = 11
    statusText.TextTransparency = 1

    Tween(logo, 0.6, {TextTransparency = 0}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Tween(logo2, 0.6, {TextTransparency = 0}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Tween(barBg, 0.5, {BackgroundTransparency = 0}, nil, nil, 0.5)
    Tween(statusText, 0.6, {TextTransparency = 0})

    task.spawn(function()
        local stages = {
            {T("loading") .. " UI...", 25},
            {T("loading") .. " ESP...", 55},
            {T("loading") .. " Functions...", 80},
            {T("ready") .. "!", 100}
        }
        for _, stage in ipairs(stages) do
            statusText.Text = stage[1]
            Tween(barFill, 0.4, {Size = UDim2.new(stage[2] / 100, 0, 1, 0)})
            task.wait(0.45)
        end
        task.wait(0.3)

        Tween(bg, 0.4, {BackgroundTransparency = 1})
        Tween(logo, 0.4, {TextTransparency = 1})
        Tween(logo2, 0.4, {TextTransparency = 1})
        Tween(statusText, 0.4, {TextTransparency = 1})
        Tween(barBg, 0.4, {BackgroundTransparency = 1})
        Tween(barFill, 0.4, {BackgroundTransparency = 1})
        Tween(g1, 0.4, {BackgroundTransparency = 1})
        Tween(g2, 0.4, {BackgroundTransparency = 1})

        task.wait(0.5)
        loadingGui:Destroy()
        if callback then callback() end
    end)
end

local MainGui, MainFrame

function BuildUI()
    if MainGui then pcall(function() MainGui:Destroy() end) end
    MainGui = Instance.new("ScreenGui")
    MainGui.Name = "Fondi_V10"
    MainGui.ResetOnSpawn = false
    MainGui.IgnoreGuiInset = true
    MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainGui.Parent = pg

    local bgGlow = Instance.new("Frame", MainGui)
    bgGlow.Size = UDim2.new(0, 500, 0, 500)
    bgGlow.Position = UDim2.new(0.5, -250, 0.5, -250)
    bgGlow.BackgroundColor3 = C.Accent
    bgGlow.BackgroundTransparency = 0.96
    bgGlow.BorderSizePixel = 0
    bgGlow.ZIndex = 0
    Corner(bgGlow, 250)
    Tween(bgGlow, 4, {Size = UDim2.new(0, 700, 0, 700), Position = UDim2.new(0.5, -350, 0.5, -350)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

    MainFrame = Instance.new("Frame", MainGui)
    MainFrame.Size = UDim2.new(0, 480, 0, 580)
    MainFrame.Position = UDim2.new(0.5, -240, 0.5, -290)
    MainFrame.BackgroundColor3 = C.Card
    MainFrame.BackgroundTransparency = 0.02
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ZIndex = 10
    Corner(MainFrame, 20)

    local mainStroke = Stroke(MainFrame, C.Accent, 1.5)
    mainStroke.Transparency = 0

    local outerGlow = Instance.new("Frame", MainFrame)
    outerGlow.Size = UDim2.new(1, 12, 1, 12)
    outerGlow.Position = UDim2.new(0, -6, 0, -6)
    outerGlow.BackgroundColor3 = C.Accent
    outerGlow.BackgroundTransparency = 0.94
    outerGlow.BorderSizePixel = 0
    outerGlow.ZIndex = 0
    Corner(outerGlow, 24)

    local header = Instance.new("Frame", MainFrame)
    header.Size = UDim2.new(1, 0, 0, 70)
    header.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
    header.BackgroundTransparency = 0.2
    header.BorderSizePixel = 0
    header.ZIndex = 11
    Corner(header, 20)

    local headerLine = Instance.new("Frame", header)
    headerLine.Size = UDim2.new(1, -40, 0, 1)
    headerLine.Position = UDim2.new(0, 20, 1, -1)
    headerLine.BackgroundColor3 = C.Accent
    headerLine.BackgroundTransparency = 0.6
    headerLine.BorderSizePixel = 0
    headerLine.ZIndex = 12

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -160, 0, 32)
    title.Position = UDim2.new(0, 24, 0, 12)
    title.BackgroundTransparency = 1
    title.ZIndex = 12
    title.Text = "FONDI MM2"
    title.TextColor3 = C.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left

    local subTitle = Instance.new("TextLabel", header)
    subTitle.Size = UDim2.new(1, -160, 0, 16)
    subTitle.Position = UDim2.new(0, 24, 0, 42)
    subTitle.BackgroundTransparency = 1
    subTitle.ZIndex = 12
    subTitle.Text = "V10.1 • " .. (LP.DisplayName or "User")
    subTitle.TextColor3 = C.Accent2
    subTitle.Font = Enum.Font.Gotham
    subTitle.TextSize = 11
    subTitle.TextXAlignment = Enum.TextXAlignment.Left

    local langBtn = Instance.new("TextButton", header)
    langBtn.Size = UDim2.new(0, 46, 0, 30)
    langBtn.Position = UDim2.new(1, -100, 0, 20)
    langBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    langBtn.Text = T("langBtn")
    langBtn.TextColor3 = C.Accent2
    langBtn.Font = Enum.Font.GothamBold
    langBtn.TextSize = 12
    langBtn.BorderSizePixel = 0
    langBtn.AutoButtonColor = false
    langBtn.ZIndex = 12
    Corner(langBtn, 10)
    Stroke(langBtn, C.Accent2, 1)

    langBtn.MouseEnter:Connect(function() Tween(langBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(50, 50, 70)}) end)
    langBtn.MouseLeave:Connect(function() Tween(langBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}) end)
    langBtn.MouseButton1Click:Connect(function()
        Lang = (Lang == "ru") and "en" or "ru"
        SaveLang(Lang)
        PlayClick()
        BurstFrom(langBtn)
        if MainGui then pcall(function() MainGui:Destroy() end) end
        BuildUI()
    end)

    local close = Instance.new("TextButton", header)
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -50, 0, 20)
    close.BackgroundColor3 = Color3.fromRGB(50, 20, 25)
    close.Text = "✕"
    close.TextColor3 = C.Danger
    close.Font = Enum.Font.GothamBold
    close.TextSize = 14
    close.BorderSizePixel = 0
    close.AutoButtonColor = false
    close.ZIndex = 12
    Corner(close, 10)

    close.MouseEnter:Connect(function() Tween(close, 0.2, {BackgroundColor3 = Color3.fromRGB(80, 25, 30)}) end)
    close.MouseLeave:Connect(function() Tween(close, 0.2, {BackgroundColor3 = Color3.fromRGB(50, 20, 25)}) end)

    close.MouseButton1Click:Connect(function()
        PlayClick()
        Tween(MainFrame, 0.3, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.3)
        MainFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 480, 0, 580)
        MainFrame.Position = UDim2.new(0.5, -240, 0.5, -290)
    end)

    local tabBar = Instance.new("Frame", MainFrame)
    tabBar.Size = UDim2.new(1, -24, 0, 38)
    tabBar.Position = UDim2.new(0, 12, 0, 82)
    tabBar.BackgroundColor3 = Color3.fromRGB(15, 15, 24)
    tabBar.BackgroundTransparency = 0.3
    tabBar.BorderSizePixel = 0
    tabBar.ZIndex = 11
    Corner(tabBar, 12)

    local tabLayout = Instance.new("UIListLayout", tabBar)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local indicator = Instance.new("Frame", tabBar)
    indicator.Size = UDim2.new(0, 60, 0, 3)
    indicator.Position = UDim2.new(0, 8, 1, -4)
    indicator.BackgroundColor3 = C.Accent
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 12
    Corner(indicator, 2)

    local contentArea = Instance.new("Frame", MainFrame)
    contentArea.Size = UDim2.new(1, -24, 1, -140)
    contentArea.Position = UDim2.new(0, 12, 0, 128)
    contentArea.BackgroundTransparency = 1
    contentArea.ZIndex = 11

    local tabData = {
        {id = "main", label = T("catMain")},
        {id = "move", label = T("catMove")},
        {id = "combat", label = T("catCombat")},
        {id = "farm", label = T("catFarm")},
        {id = "misc", label = T("catMisc")}
    }

    local tabButtons = {}
    local tabContents = {}
    local currentTab = "main"

    local function ShowTab(id)
        currentTab = id
        for tid, btn in pairs(tabButtons) do
            local isActive = (tid == id)
            Tween(btn, 0.25, {
                TextColor3 = isActive and C.Text or C.SubText
            })
            if tabContents[tid] then
                tabContents[tid].Visible = isActive
            end
        end

        local activeBtn = tabButtons[id]
        if activeBtn then
            Tween(indicator, 0.3, {
                Position = UDim2.new(0, activeBtn.AbsolutePosition.X - tabBar.AbsolutePosition.X, 1, -4),
                Size = UDim2.new(0, activeBtn.AbsoluteSize.X, 0, 3)
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

            if tabContents[id] then
                tabContents[id].Visible = true
            end
        end
    end

    for _, t in ipairs(tabData) do
        local btn = Instance.new("TextButton", tabBar)
        btn.Size = UDim2.new(0, 76, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
        btn.BackgroundTransparency = 1
        btn.Text = t.label
        btn.TextColor3 = C.SubText
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.ZIndex = 12
        Corner(btn, 8)

        tabButtons[t.id] = btn

        local content = Instance.new("ScrollingFrame", contentArea)
        content.Size = UDim2.new(1, 0, 1, 0)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.ScrollBarThickness = 3
        content.ScrollBarImageColor3 = C.Accent
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        content.Visible = false
        content.ZIndex = 12
        local cl = Instance.new("UIListLayout", content)
        cl.Padding = UDim.new(0, 8)

        tabContents[t.id] = content

        btn.MouseEnter:Connect(function()
            if currentTab ~= t.id then
                Tween(btn, 0.2, {BackgroundColor3 = Color3.fromRGB(35, 35, 50), BackgroundTransparency = 0.5})
            end
        end)
        btn.MouseLeave:Connect(function()
            if currentTab ~= t.id then
                Tween(btn, 0.2, {BackgroundTransparency = 1})
            end
        end)

        btn.MouseButton1Click:Connect(function()
            PlayClick()
            ShowTab(t.id)
        end)
    end

    task.wait(0.05)
    ShowTab("main")

    local function CreateToggle(parent, name, setting, color, callback)
        color = color or C.Accent

        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, -5, 0, 46)
        btn.BackgroundColor3 = Settings[setting] and Color3.fromRGB(30, 30, 48) or Color3.fromRGB(22, 22, 32)
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.ZIndex = 15
        Corner(btn, 12)

        local bs = Stroke(btn, Settings[setting] and color or C.Border, 1.5)

        local lbl = Instance.new("TextLabel", btn)
        lbl.Size = UDim2.new(1, -100, 1, 0)
        lbl.Position = UDim2.new(0, 18, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.ZIndex = 16
        lbl.Text = name
        lbl.TextColor3 = Settings[setting] and color or C.Text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local pill = Instance.new("Frame", btn)
        pill.Size = UDim2.new(0, 42, 0, 24)
        pill.Position = UDim2.new(1, -56, 0.5, -12)
        pill.BackgroundColor3 = Settings[setting] and color or Color3.fromRGB(50, 50, 70)
        pill.BorderSizePixel = 0
        pill.ZIndex = 16
        Corner(pill, 12)

        local knob = Instance.new("Frame", pill)
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = Settings[setting] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        knob.BackgroundColor3 = Color3.new(1,1,1)
        knob.BorderSizePixel = 0
        knob.ZIndex = 17
        Corner(knob, 9)

        local glow = Instance.new("Frame", pill)
        glow.Size = UDim2.new(1, 8, 1, 8)
        glow.Position = UDim2.new(0, -4, 0, -4)
        glow.BackgroundColor3 = color
        glow.BackgroundTransparency = Settings[setting] and 0.7 or 1
        glow.BorderSizePixel = 0
        glow.ZIndex = 15
        Corner(glow, 15)

        btn.MouseEnter:Connect(function()
            Tween(btn, 0.2, {BackgroundColor3 = Color3.fromRGB(32, 32, 46)})
        end)
        btn.MouseLeave:Connect(function()
            if not Settings[setting] then
                Tween(btn, 0.2, {BackgroundColor3 = Color3.fromRGB(22, 22, 32)})
            end
        end)

        btn.MouseButton1Click:Connect(function()
            Settings[setting] = not Settings[setting]
            local on = Settings[setting]

            PlayClick()
            BurstFrom(btn)

            Tween(btn, 0.25, {BackgroundColor3 = on and Color3.fromRGB(30, 30, 48) or Color3.fromRGB(22, 22, 32)})
            Tween(bs, 0.25, {Color = on and color or C.Border})
            Tween(lbl, 0.25, {TextColor3 = on and color or C.Text})
            Tween(pill, 0.25, {BackgroundColor3 = on and color or Color3.fromRGB(50, 50, 70)})
            Tween(glow, 0.3, {BackgroundTransparency = on and 0.7 or 1})
            Tween(knob, 0.3, {
                Position = on and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

            if callback then callback(on) end
        end)
    end

    local function CreateSlider(parent, name, minV, maxV, default, color, setter)
        color = color or C.Accent

        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, -5, 0, 48)
        frame.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
        frame.BorderSizePixel = 0
        frame.ZIndex = 15
        Corner(frame, 12)
        Stroke(frame, C.Border, 1.5)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(1, -30, 0, 20)
        lbl.Position = UDim2.new(0, 18, 0, 6)
        lbl.BackgroundTransparency = 1
        lbl.ZIndex = 16
        lbl.Text = name .. ": " .. default
        lbl.TextColor3 = C.Text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local bar = Instance.new("Frame", frame)
        bar.Size = UDim2.new(1, -36, 0, 6)
        bar.Position = UDim2.new(0, 18, 0, 32)
        bar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        bar.BorderSizePixel = 0
        bar.ZIndex = 16
        Corner(bar, 3)

        local rel = (default - minV) / (maxV - minV)
        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        fill.BackgroundColor3 = color
        fill.BorderSizePixel = 0
        fill.ZIndex = 17
        Corner(fill, 3)

        local knob = Instance.new("Frame", bar)
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = UDim2.new(rel, -7, 0.5, -7)
        knob.BackgroundColor3 = Color3.new(1,1,1)
        knob.BorderSizePixel = 0
        knob.ZIndex = 18
        Corner(knob, 7)

        local dragging = false
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local r = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
                r = math.clamp(r, 0, 1)
                local val = math.floor(minV + r * (maxV - minV))
                lbl.Text = name .. ": " .. val
                Tween(fill, 0.1, {Size = UDim2.new(r, 0, 1, 0)})
                Tween(knob, 0.1, {Position = UDim2.new(r, -7, 0.5, -7)})
                if setter then setter(val) end
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    CreateToggle(tabContents["main"], T("esp"), "ESP", C.Accent, function(on)
        if on then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP then CreateESP(p) end
            end
        else
            for p, _ in pairs(ESPObjects) do RemoveESP(p) end
        end
    end)
    CreateToggle(tabContents["main"], T("outline"), "Outline", C.Accent2)
    CreateToggle(tabContents["main"], T("tracers"), "Tracers", C.Pink)
    CreateToggle(tabContents["main"], T("names"), "ShowNames", Color3.fromRGB(150, 200, 255))
    CreateToggle(tabContents["main"], T("roles"), "ShowRoles", C.Purple2)
    CreateToggle(tabContents["main"], T("reveal"), "RevealMurderer", C.Murderer)

    CreateToggle(tabContents["move"], T("fly"), "Fly", C.Blue, function(on)
        if on then StartFly() else StopFly() end
    end)
    CreateSlider(tabContents["move"], "Fly Speed", 20, 150, Settings.FlySpeed, C.Blue, function(v)
        Settings.FlySpeed = v
    end)
    CreateToggle(tabContents["move"], T("noclip"), "Noclip", C.Green, function(on)
        if on then StartNoclip() else StopNoclip() end
    end)
    CreateToggle(tabContents["move"], T("bhop"), "Bhop", Color3.fromRGB(150, 200, 100), function(on)
        if on then StartBhop() else StopBhop() end
    end)
    CreateToggle(tabContents["move"], T("antifling"), "AntiFling", C.Orange, function(on)
        if on then StartAntiFling() else StopAntiFling() end
    end)

    CreateToggle(tabContents["combat"], T("aimbot"), "Aimbot", C.Danger, function(on)
        if on then StartAimbot() else StopAimbot() end
    end)
    CreateToggle(tabContents["combat"], T("killall"), "KillAll", C.Pink, function(on)
        if on then StartKillAll() else StopKillAll() end
    end)
    CreateSlider(tabContents["combat"], T("range"), 5, 50, Settings.KillAuraRange, C.Pink, function(v)
        Settings.KillAuraRange = v
    end)
    CreateToggle(tabContents["combat"], T("pickup"), "AutoPickup", Color3.fromRGB(200, 200, 100), function(on)
        if on then StartPickup() else StopPickup() end
    end)

    local flingDivider = Instance.new("Frame", tabContents["combat"])
    flingDivider.Size = UDim2.new(1, -5, 0, 1)
    flingDivider.BackgroundColor3 = C.Border
    flingDivider.BorderSizePixel = 0
    flingDivider.ZIndex = 15

    local flingTitle = Instance.new("TextLabel", tabContents["combat"])
    flingTitle.Size = UDim2.new(1, -5, 0, 20)
    flingTitle.BackgroundTransparency = 1
    flingTitle.ZIndex = 15
    flingTitle.Text = T("flingTitle")
    flingTitle.TextColor3 = C.Accent2
    flingTitle.Font = Enum.Font.GothamBold
    flingTitle.TextSize = 11
    flingTitle.TextXAlignment = Enum.TextXAlignment.Left

    local selectedFlingTarget = nil
    local playerBtn = Instance.new("TextButton", tabContents["combat"])
    playerBtn.Size = UDim2.new(1, -5, 0, 42)
    playerBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    playerBtn.Text = T("selectPlayer") .. " ▼"
    playerBtn.TextColor3 = C.Text
    playerBtn.Font = Enum.Font.GothamBold
    playerBtn.TextSize = 12
    playerBtn.BorderSizePixel = 0
    playerBtn.AutoButtonColor = false
    playerBtn.ZIndex = 15
    Corner(playerBtn, 12)
    Stroke(playerBtn, C.Border, 1.5)

    local dropdown = Instance.new("ScrollingFrame", tabContents["combat"])
    dropdown.Size = UDim2.new(1, -5, 0, 160)
    dropdown.BackgroundColor3 = Color3.fromRGB(15, 15, 24)
    dropdown.BorderSizePixel = 0
    dropdown.ScrollBarThickness = 3
    dropdown.ScrollBarImageColor3 = C.Accent
    dropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
    dropdown.AutomaticCanvasSize = Enum.AutomaticSize.Y
    dropdown.Visible = false
    dropdown.ZIndex = 25
    Corner(dropdown, 12)
    Stroke(dropdown, C.Accent, 1)
    local dLayout = Instance.new("UIListLayout", dropdown)
    dLayout.Padding = UDim.new(0, 3)
    local dPad = Instance.new("UIPadding", dropdown)
    dPad.PaddingTop = UDim.new(0, 6)
    dPad.PaddingBottom = UDim.new(0, 6)

    local function RefreshDropdown()
        for _, c in ipairs(dropdown:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP then
                local row = Instance.new("TextButton", dropdown)
                row.Size = UDim2.new(1, -12, 0, 28)
                row.Position = UDim2.new(0, 6, 0, 0)
                row.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
                row.Text = pl.DisplayName
                row.TextColor3 = C.Text
                row.Font = Enum.Font.Gotham
                row.TextSize = 11
                row.BorderSizePixel = 0
                row.AutoButtonColor = false
                row.ZIndex = 26
                Corner(row, 6)
                row.MouseEnter:Connect(function() Tween(row, 0.15, {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}) end)
                row.MouseLeave:Connect(function() Tween(row, 0.15, {BackgroundColor3 = Color3.fromRGB(22, 22, 32)}) end)
                row.MouseButton1Click:Connect(function()
                    selectedFlingTarget = pl
                    playerBtn.Text = T("selected") .. pl.DisplayName
                    dropdown.Visible = false
                    PlayClick()
                end)
            end
        end
    end

    playerBtn.MouseEnter:Connect(function() Tween(playerBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}) end)
    playerBtn.MouseLeave:Connect(function() Tween(playerBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(22, 22, 32)}) end)
    playerBtn.MouseButton1Click:Connect(function()
        RefreshDropdown()
        dropdown.Visible = not dropdown.Visible
        PlayClick()
    end)

    local flingBtn = Instance.new("TextButton", tabContents["combat"])
    flingBtn.Size = UDim2.new(1, -5, 0, 42)
    flingBtn.BackgroundColor3 = C.Danger
    flingBtn.Text = T("flingBtn")
    flingBtn.TextColor3 = Color3.new(1,1,1)
    flingBtn.Font = Enum.Font.GothamBold
    flingBtn.TextSize = 12
    flingBtn.BorderSizePixel = 0
    flingBtn.AutoButtonColor = false
    flingBtn.ZIndex = 15
    Corner(flingBtn, 12)
    Stroke(flingBtn, Color3.fromRGB(255, 100, 100), 1.5)
    flingBtn.MouseEnter:Connect(function() Tween(flingBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}) end)
    flingBtn.MouseLeave:Connect(function() Tween(flingBtn, 0.2, {BackgroundColor3 = C.Danger}) end)
    flingBtn.MouseButton1Click:Connect(function()
        if not selectedFlingTarget then
            Notify("FLING", T("noPlayers"), C.Warning, 2)
            return
        end
        PlayClick()
        BurstFrom(flingBtn)
        FlingPlayer(selectedFlingTarget)
    end)

    local flingAllBtn = Instance.new("TextButton", tabContents["combat"])
    flingAllBtn.Size = UDim2.new(1, -5, 0, 42)
    flingAllBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 80)
    flingAllBtn.Text = T("flingAll")
    flingAllBtn.TextColor3 = Color3.new(1,1,1)
    flingAllBtn.Font = Enum.Font.GothamBold
    flingAllBtn.TextSize = 12
    flingAllBtn.BorderSizePixel = 0
    flingAllBtn.AutoButtonColor = false
    flingAllBtn.ZIndex = 15
    Corner(flingAllBtn, 12)
    flingAllBtn.MouseEnter:Connect(function() Tween(flingAllBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(230, 60, 100)}) end)
    flingAllBtn.MouseLeave:Connect(function() Tween(flingAllBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(200, 40, 80)}) end)
    flingAllBtn.MouseButton1Click:Connect(function()
        PlayClick()
        BurstFrom(flingAllBtn)
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP then FlingPlayer(pl) end
        end
    end)

    CreateToggle(tabContents["farm"], T("farm"), "Farm", Color3.fromRGB(255, 200, 50), function(on)
        if on then StartFarm() else StopFarm() end
    end)

    CreateToggle(tabContents["misc"], T("notif"), "Notifications", Color3.fromRGB(100, 200, 255))

    local listTitle = Instance.new("TextLabel", tabContents["misc"])
    listTitle.Size = UDim2.new(1, -5, 0, 22)
    listTitle.BackgroundTransparency = 1
    listTitle.ZIndex = 15
    listTitle.Text = T("playerList")
    listTitle.TextColor3 = C.SubText
    listTitle.Font = Enum.Font.GothamBold
    listTitle.TextSize = 11
    listTitle.TextXAlignment = Enum.TextXAlignment.Left

    local playerList = Instance.new("Frame", tabContents["misc"])
    playerList.Size = UDim2.new(1, -5, 0, 0)
    playerList.AutomaticSize = Enum.AutomaticSize.Y
    playerList.BackgroundColor3 = Color3.fromRGB(15, 15, 24)
    playerList.BorderSizePixel = 0
    playerList.ZIndex = 15
    Corner(playerList, 12)
    Stroke(playerList, C.Border, 1)
    local pll = Instance.new("UIListLayout", playerList)
    pll.Padding = UDim.new(0, 3)
    local plp = Instance.new("UIPadding", playerList)
    plp.PaddingTop = UDim.new(0, 8)
    plp.PaddingBottom = UDim.new(0, 8)

    local function RefreshList()
        for _, c in ipairs(playerList:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP then
                local role = GetRole(pl)
                local row = Instance.new("TextLabel", playerList)
                row.Size = UDim2.new(1, -16, 0, 22)
                row.Position = UDim2.new(0, 8, 0, 0)
                row.BackgroundTransparency = 1
                row.ZIndex = 16
                row.Text = pl.DisplayName .. "  ·  " .. role
                row.TextColor3 = RoleColor(role)
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
    MainFrame.BackgroundTransparency = 1
    mainStroke.Transparency = 1
    outerGlow.BackgroundTransparency = 1

    task.wait(0.05)
    Tween(MainFrame, 0.5, {
        Size = UDim2.new(0, 480, 0, 580),
        Position = UDim2.new(0.5, -240, 0.5, -290),
        BackgroundTransparency = 0.02
    }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Tween(mainStroke, 0.5, {Transparency = 0})
    Tween(outerGlow, 0.5, {BackgroundTransparency = 0.94})
end

local function ToggleMenu()
    if not MainGui or not MainGui.Parent then return end
    if not MainFrame.Visible then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        MainFrame.BackgroundTransparency = 1
        Tween(MainFrame, 0.4, {
            Size = UDim2.new(0, 480, 0, 580),
            Position = UDim2.new(0.5, -240, 0.5, -290),
            BackgroundTransparency = 0.02
        }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        Tween(MainFrame, 0.3, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.3)
        MainFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 480, 0, 580)
        MainFrame.Position = UDim2.new(0.5, -240, 0.5, -290)
    end
end

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not IsAuthenticated then return end
    if input.KeyCode == Enum.KeyCode.L then ToggleMenu()
    elseif input.KeyCode == Enum.KeyCode.F then
        Settings.Fly = not Settings.Fly
        if Settings.Fly then StartFly() else StopFly() end
        Notify(Settings.Fly and T("flightOn") or T("flightOff"), Settings.Fly and C.Success or C.Danger)
    elseif input.KeyCode == Enum.KeyCode.N then
        Settings.Noclip = not Settings.Noclip
        if Settings.Noclip then StartNoclip() else StopNoclip() end
        Notify(Settings.Noclip and T("noclipOn") or T("noclipOff"), Settings.Noclip and C.Success or C.Danger)
    elseif input.KeyCode == Enum.KeyCode.B then
        Settings.Bhop = not Settings.Bhop
        if Settings.Bhop then StartBhop() else StopBhop() end
        Notify(Settings.Bhop and T("bhopOn") or T("bhopOff"), Settings.Bhop and C.Success or C.Danger)
    elseif input.KeyCode == Enum.KeyCode.K then
        Settings.KillAll = not Settings.KillAll
        if Settings.KillAll then StartKillAll() else StopKillAll() end
    elseif input.KeyCode == Enum.KeyCode.G then
        Settings.Farm = not Settings.Farm
        if Settings.Farm then StartFarm() else StopFarm() end
    end
end)

local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "FondiKeyGui"
KeyGui.ResetOnSpawn = false
KeyGui.IgnoreGuiInset = true
KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
KeyGui.Parent = pg

local KeyFrame = Instance.new("Frame", KeyGui)
KeyFrame.Size = UDim2.new(0, 420, 0, 550)
KeyFrame.Position = UDim2.new(0.5, -210, 0.5, -275)
KeyFrame.BackgroundColor3 = C.Card
KeyFrame.BackgroundTransparency = 0.02
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.ZIndex = 10
Corner(KeyFrame, 20)

local keyStroke = Stroke(KeyFrame, C.Accent, 1.5)

local keyOuterGlow = Instance.new("Frame", KeyFrame)
keyOuterGlow.Size = UDim2.new(1, 12, 1, 12)
keyOuterGlow.Position = UDim2.new(0, -6, 0, -6)
keyOuterGlow.BackgroundColor3 = C.Accent
keyOuterGlow.BackgroundTransparency = 0.92
keyOuterGlow.BorderSizePixel = 0
keyOuterGlow.ZIndex = 0
Corner(keyOuterGlow, 24)

local keyLogo = Instance.new("TextLabel", KeyFrame)
keyLogo.Size = UDim2.new(1, 0, 0, 50)
keyLogo.Position = UDim2.new(0, 0, 0, 30)
keyLogo.BackgroundTransparency = 1
keyLogo.ZIndex = 15
keyLogo.Text = "FONDI MM2"
keyLogo.TextColor3 = C.Text
keyLogo.Font = Enum.Font.GothamBold
keyLogo.TextSize = 28

local keySub = Instance.new("TextLabel", KeyFrame)
keySub.Size = UDim2.new(1, 0, 0, 18)
keySub.Position = UDim2.new(0, 0, 0, 78)
keySub.BackgroundTransparency = 1
keySub.ZIndex = 15
keySub.Text = "V10.1 • NEON"
keySub.TextColor3 = C.Accent2
keySub.Font = Enum.Font.GothamBold
keySub.TextSize = 11

local keyLangBtn = Instance.new("TextButton", KeyFrame)
keyLangBtn.Size = UDim2.new(0, 46, 0, 26)
keyLangBtn.Position = UDim2.new(1, -58, 0, 12)
keyLangBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
keyLangBtn.Text = T("langBtn")
keyLangBtn.TextColor3 = C.Accent2
keyLangBtn.Font = Enum.Font.GothamBold
keyLangBtn.TextSize = 12
keyLangBtn.BorderSizePixel = 0
keyLangBtn.AutoButtonColor = false
keyLangBtn.ZIndex = 15
Corner(keyLangBtn, 8)
Stroke(keyLangBtn, C.Accent2, 1)
keyLangBtn.MouseButton1Click:Connect(function()
    Lang = (Lang == "ru") and "en" or "ru"
    SaveLang(Lang)
    PlayClick()
    KeyGui:Destroy()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/p1shenak/main.lua/refs/heads/main/main.lua"))()
end)

local KeyBox = Instance.new("TextBox", KeyFrame)
KeyBox.Size = UDim2.new(0.85, 0, 0, 48)
KeyBox.Position = UDim2.new(0.075, 0, 0, 115)
KeyBox.PlaceholderText = T("keyInput")
KeyBox.Text = ""
KeyBox.ClearTextOnFocus = false
KeyBox.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
KeyBox.TextColor3 = C.Text
KeyBox.PlaceholderColor3 = C.SubText
KeyBox.Font = Enum.Font.Code
KeyBox.TextSize = 14
KeyBox.BorderSizePixel = 0
KeyBox.ZIndex = 15
Corner(KeyBox, 12)
Stroke(KeyBox, C.Border, 1)

local KeyBoxFocus = Instance.new("UIStroke", KeyBox)
KeyBoxFocus.Color = C.Accent
KeyBoxFocus.Thickness = 0
KeyBoxFocus.Transparency = 1

KeyBox.Focused:Connect(function()
    Tween(KeyBoxFocus, 0.2, {Thickness = 1.5, Transparency = 0})
    Tween(KeyBox, 0.2, {BackgroundColor3 = Color3.fromRGB(15, 15, 25)})
end)
KeyBox.FocusLost:Connect(function()
    Tween(KeyBoxFocus, 0.2, {Thickness = 0, Transparency = 1})
    Tween(KeyBox, 0.2, {BackgroundColor3 = Color3.fromRGB(10, 10, 16)})
end)

local ActivateBtn = Instance.new("TextButton", KeyFrame)
ActivateBtn.Size = UDim2.new(0.85, 0, 0, 46)
ActivateBtn.Position = UDim2.new(0.075, 0, 0, 172)
ActivateBtn.Text = T("activate")
ActivateBtn.BackgroundColor3 = C.Accent
ActivateBtn.TextColor3 = C.Text
ActivateBtn.Font = Enum.Font.GothamBold
ActivateBtn.TextSize = 14
ActivateBtn.BorderSizePixel = 0
ActivateBtn.AutoButtonColor = false
ActivateBtn.ZIndex = 15
Corner(ActivateBtn, 12)
Stroke(ActivateBtn, C.Purple2, 1)

local keyDivider = Instance.new("Frame", KeyFrame)
keyDivider.Size = UDim2.new(0.85, 0, 0, 1)
keyDivider.Position = UDim2.new(0.075, 0, 0, 240)
keyDivider.BackgroundColor3 = C.Border
keyDivider.BorderSizePixel = 0
keyDivider.ZIndex = 15

local genTitle = Instance.new("TextLabel", KeyFrame)
genTitle.Size = UDim2.new(1, 0, 0, 20)
genTitle.Position = UDim2.new(0, 0, 0, 255)
genTitle.BackgroundTransparency = 1
genTitle.ZIndex = 15
genTitle.Text = T("genTitle")
genTitle.TextColor3 = C.SubText
genTitle.Font = Enum.Font.GothamBold
genTitle.TextSize = 11

local durFrame = Instance.new("Frame", KeyFrame)
durFrame.Size = UDim2.new(0.85, 0, 0, 34)
durFrame.Position = UDim2.new(0.075, 0, 0, 285)
durFrame.BackgroundTransparency = 1
durFrame.ZIndex = 15
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
    b.Size = UDim2.new(0, 78, 1, 0)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    b.Text = opt.label
    b.TextColor3 = C.SubText
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.ZIndex = 16
    Corner(b, 8)
    local bs = Stroke(b, C.Border, 1)

    b.MouseButton1Click:Connect(function()
        selectedDuration = opt.value
        for _, other in ipairs(durButtons) do
            Tween(other.btn, 0.2, {BackgroundColor3 = Color3.fromRGB(30, 30, 45)})
            other.btn.TextColor3 = C.SubText
            other.stroke.Color = C.Border
        end
        Tween(b, 0.2, {BackgroundColor3 = C.Accent})
        b.TextColor3 = C.Text
        bs.Color = C.Accent2
        PlayClick()
    end)
    table.insert(durButtons, {btn = b, stroke = bs})
end

durButtons[1].btn.BackgroundColor3 = C.Accent
durButtons[1].btn.TextColor3 = C.Text
durButtons[1].stroke.Color = C.Accent2

local GenBtn = Instance.new("TextButton", KeyFrame)
GenBtn.Size = UDim2.new(0.85, 0, 0, 42)
GenBtn.Position = UDim2.new(0.075, 0, 0, 335)
GenBtn.Text = T("generate")
GenBtn.BackgroundColor3 = C.Success
GenBtn.TextColor3 = C.Text
GenBtn.Font = Enum.Font.GothamBold
GenBtn.TextSize = 13
GenBtn.BorderSizePixel = 0
GenBtn.AutoButtonColor = false
GenBtn.ZIndex = 15
Corner(GenBtn, 12)

local CopyBtn = Instance.new("TextButton", KeyFrame)
CopyBtn.Size = UDim2.new(0.42, 0, 0, 42)
CopyBtn.Position = UDim2.new(0.075, 0, 0, 388)
CopyBtn.Text = T("copyKey")
CopyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
CopyBtn.TextColor3 = C.Accent2
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 12
CopyBtn.BorderSizePixel = 0
CopyBtn.AutoButtonColor = false
CopyBtn.ZIndex = 15
Corner(CopyBtn, 12)
Stroke(CopyBtn, C.Accent2, 1)

local GetScriptBtn = Instance.new("TextButton", KeyFrame)
GetScriptBtn.Size = UDim2.new(0.42, 0, 0, 42)
GetScriptBtn.Position = UDim2.new(0.505, 0, 0, 388)
GetScriptBtn.Text = T("getScript")
GetScriptBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
GetScriptBtn.TextColor3 = C.Accent2
GetScriptBtn.Font = Enum.Font.GothamBold
GetScriptBtn.TextSize = 12
GetScriptBtn.BorderSizePixel = 0
GetScriptBtn.AutoButtonColor = false
GetScriptBtn.ZIndex = 15
Corner(GetScriptBtn, 12)
Stroke(GetScriptBtn, C.Accent2, 1)

ActivateBtn.MouseEnter:Connect(function() Tween(ActivateBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(150, 100, 255)}) end)
ActivateBtn.MouseLeave:Connect(function() Tween(ActivateBtn, 0.2, {BackgroundColor3 = C.Accent}) end)
GenBtn.MouseEnter:Connect(function() Tween(GenBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(20, 210, 140)}) end)
GenBtn.MouseLeave:Connect(function() Tween(GenBtn, 0.2, {BackgroundColor3 = C.Success}) end)
CopyBtn.MouseEnter:Connect(function() Tween(CopyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}) end)
CopyBtn.MouseLeave:Connect(function() Tween(CopyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(30, 30, 45)}) end)
GetScriptBtn.MouseEnter:Connect(function() Tween(GetScriptBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}) end)
GetScriptBtn.MouseLeave:Connect(function() Tween(GetScriptBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(30, 30, 45)}) end)

KeyFrame.Size = UDim2.new(0, 0, 0, 0)
KeyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
task.wait(0.05)
Tween(KeyFrame, 0.5, {
    Size = UDim2.new(0, 420, 0, 550),
    Position = UDim2.new(0.5, -210, 0.5, -275)
}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function CloseKeyGui()
    Tween(KeyFrame, 0.3, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1
    }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.wait(0.35)
    KeyGui:Destroy()
    BuildUI()
end

ActivateBtn.MouseButton1Click:Connect(function()
    if KeyBox.Text == "" then Notify(T("keyInput"), C.Warning) return end
    ActivateBtn.Text = T("checking")
    ActivateBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    PlayClick()
    BurstFrom(ActivateBtn)
    local valid, info = ValidateKey(KeyBox.Text)
    if valid then
        IsAuthenticated = true
        SaveKey(KeyBox.Text)
        Notify(T("accessGranted"), C.Success)
        CloseKeyGui()
    else
        KeyBox.Text = ""
        KeyBox.PlaceholderText = T("keyInvalid")
        ActivateBtn.Text = T("activate")
        ActivateBtn.BackgroundColor3 = C.Accent
        Notify(info or T("invalidKey"), C.Danger)
    end
end)

GenBtn.MouseButton1Click:Connect(function()
    GenBtn.Text = T("generating")
    GenBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    GenBtn.Active = false
    PlayClick()
    BurstFrom(GenBtn)
    task.spawn(function()
        local key = GenerateKeyRemote(selectedDuration)
        if key then
            KeyBox.Text = key
            Notify(T("keyCreated"), C.Success)
            GenBtn.Text = T("done")
            GenBtn.BackgroundColor3 = C.Success
        else
            GenBtn.Text = T("generate")
            GenBtn.BackgroundColor3 = C.Success
            GenBtn.Active = true
        end
    end)
end)

CopyBtn.MouseButton1Click:Connect(function()
    if KeyBox.Text == "" then Notify(T("noKey"), C.Warning) return end
    if setclipboard then
        setclipboard(KeyBox.Text)
        Notify(T("keyCopiedMsg"), C.Success)
        CopyBtn.Text = T("copied")
        PlayClick()
        task.wait(1.2)
        CopyBtn.Text = T("copyKey")
    end
end)

GetScriptBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://fondi-mm-2-auntification.vercel.app/")
        Notify(T("linkCopied"), C.Success)
        GetScriptBtn.Text = T("copied")
        PlayClick()
        task.wait(1.5)
        GetScriptBtn.Text = T("getScript")
    end
end)

task.spawn(function()
    task.wait(0.5)
    local saved = LoadKey()
    if saved then
        KeyBox.Text = saved
        ActivateBtn.Text = T("autologin")
        ActivateBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
        local valid = ValidateKey(saved)
        if valid then
            IsAuthenticated = true
            KeyGui:Destroy()
            ShowLoadingScreen(function()
                BuildUI()
                Notify(T("autologinOk"), C.Success, 3)
            end)
            return
        end
        ClearKey()
    end
end)

do
    local saved = LoadLang()
    if saved then Lang = saved end
end

print("==========================================")
print("[FONDI MM2 V10.1] NEON UI READY")
print("[FONDI MM2] Press L to toggle menu")
print("==========================================")
