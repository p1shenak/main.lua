--[[
    FONDI MM2 V11.3 // NETWORK EDITION
    - Fix Fling: prediction + попытка SetNetworkOwner
    - Silent Aim (namecall hook)
    - Radar / Minimap
    - Item ESP (Knife/Gun/Coins)
    - Kill Feed
    - Config Save/Load
    - Fix Damage Indicator (реальное направление)
    - Fix Anti-Fling threshold
    - Fix FlingAll (массив флингов)
    - Все фичи V11.2 сохранены
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local pg = LP:WaitForChild("PlayerGui")

local AUTH_URL = "https://fondi-mm-2-auntification.vercel.app/api/validate"
local GENERATE_URL = "https://fondi-mm-2-auntification.vercel.app/api/generate"
local KEY_FILE = "fondi_key.txt"
local LANG_FILE = "fondi_lang.txt"
local CONFIG_FILE = "fondi_config.json"

local VERSION = "V11.3"

local IsAuthenticated = false
local Lang = "ru"

local DefaultSettings = {
    ESP=false, Outline=true, Tracers=true, ShowNames=true, ShowRoles=true,
    Fly=false, Noclip=false, Bhop=false, AntiFling=false, FlySpeed=55,
    Aimbot=false, SilentAim=false, RevealMurderer=false, AutoPickup=false,
    KillAll=false, KillAuraRange=15, Farm=false, Notifications=true,
    KillSound=true, Hitmarker=true, DamageIndicator=true,
    Watermark=true, FpsGraph=true, Crosshair=true,
    KillEffect=true, KillNotif=true, RainbowTrail=false,
    Radar=false, ItemESP=false, KillFeed=true,
    FlingSpeed=350, FlingSpin=600,
    FlingUseNetworkOwner=true, FlingPrediction=true
}
local Settings = {}
for k, v in pairs(DefaultSettings) do Settings[k] = v end

local C = {
    Murderer = Color3.fromRGB(255, 60, 60),
    Sheriff  = Color3.fromRGB(60, 140, 255),
    Innocent = Color3.fromRGB(60, 255, 120),
    Accent   = Color3.fromRGB(139, 92, 246),
    Accent2  = Color3.fromRGB(34, 211, 238),
    Bg       = Color3.fromRGB(10, 10, 15),
    Card     = Color3.fromRGB(18, 18, 26),
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
        silentaim="Silent Aim", killall="Kill All", pickup="Auto-Pickup",
        reveal="Reveal Murderer", range="Радиус", farm="Farm", notif="Уведомления",
        flingTitle="FLING", flingBtn="ВЫБРОСИТЬ", flingAll="ВЫБРОСИТЬ ВСЕХ",
        flingSpeed="Скорость", flingSpin="Вращение",
        flingNetOwner="Network Owner", flingPredict="Prediction",
        playerList="СПИСОК ИГРОКОВ",
        keyInput="Введите ключ", keyInvalid="Неверный ключ",
        activate="АКТИВИРОВАТЬ", checking="ПРОВЕРКА...", autologin="АВТОВХОД...",
        genTitle="Генерация ключа", generate="СГЕНЕРИРОВАТЬ",
        generating="ГЕНЕРАЦИЯ...", done="ГОТОВО",
        copyKey="СКОПИРОВАТЬ", copied="СКОПИРОВАНО",
        getScript="ССЫЛКА", linkCopied="Ссылка скопирована!",
        accessGranted="Доступ разрешён", autologinOk="Автовход выполнен",
        keyCreated="Ключ создан", keyCopiedMsg="Ключ скопирован!",
        noKey="Нет ключа", noPlayers="Нет игроков", invalidKey="Неверный ключ",
        langBtn="EN", becameM=" стал MURDERER", becameS=" стал SHERIFF",
        catMain="ГЛАВНОЕ", catMove="ДВИЖЕНИЕ", catCombat="БОЙ",
        catFarm="ФАРМ", catMisc="РАЗНОЕ", catVisual="ВИЗУАЛЫ",
        selectPlayer="ВЫБРАТЬ ИГРОКА", selected="ВЫБРАН: ",
        loading="ЗАГРУЗКА", ready="ГОТОВО",
        visKillSound="Звук убийства", visHitmarker="Хитмаркер",
        visDamage="Индикатор урона", visWatermark="Watermark",
        visFps="График FPS", visCrosshair="Прицел",
        visKillEffect="Эффект убийства", visKillNotif="Уведомление убийства",
        visTrail="Радужный след", visRadar="Радар", visItemESP="ESP предметов",
        visKillFeed="Лог убийств",
        saveCfg="СОХРАНИТЬ", loadCfg="ЗАГРУЗИТЬ", cfgSaved="Конфиг сохранён", cfgLoaded="Конфиг загружен"
    },
    en = {
        menu="FONDI MM2", esp="ESP", outline="Outline", tracers="Tracers",
        names="Names", roles="Roles", fly="Fly", noclip="Noclip",
        bhop="Bhop", antifling="Anti-Fling", aimbot="Aimbot",
        silentaim="Silent Aim", killall="Kill All", pickup="Auto-Pickup",
        reveal="Reveal Murderer", range="Range", farm="Farm", notif="Notifications",
        flingTitle="FLING", flingBtn="FLING", flingAll="FLING ALL",
        flingSpeed="Speed", flingSpin="Spin",
        flingNetOwner="Network Owner", flingPredict="Prediction",
        playerList="PLAYER LIST",
        keyInput="Enter key", keyInvalid="Invalid key",
        activate="ACTIVATE", checking="CHECKING...", autologin="AUTO-LOGIN...",
        genTitle="Generate key", generate="GENERATE",
        generating="GENERATING...", done="DONE",
        copyKey="COPY", copied="COPIED",
        getScript="LINK", linkCopied="Link copied!",
        accessGranted="Access granted", autologinOk="Auto-login OK",
        keyCreated="Key created", keyCopiedMsg="Key copied!",
        noKey="No key", noPlayers="No players", invalidKey="Invalid key",
        langBtn="RU", becameM=" became MURDERER", becameS=" became SHERIFF",
        catMain="MAIN", catMove="MOVEMENT", catCombat="COMBAT",
        catFarm="FARM", catMisc="MISC", catVisual="VISUALS",
        selectPlayer="SELECT PLAYER", selected="SELECTED: ",
        loading="LOADING", ready="READY",
        visKillSound="Kill Sound", visHitmarker="Hitmarker",
        visDamage="Damage Indicator", visWatermark="Watermark",
        visFps="FPS Graph", visCrosshair="Crosshair",
        visKillEffect="Kill Effect", visKillNotif="Kill Notification",
        visTrail="Rainbow Trail", visRadar="Radar", visItemESP="Item ESP",
        visKillFeed="Kill Feed",
        saveCfg="SAVE", loadCfg="LOAD", cfgSaved="Config saved", cfgLoaded="Config loaded"
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

--==================================================
-- CONFIG SAVE/LOAD
--==================================================
local function SaveConfig()
    pcall(function()
        if writefile then
            writefile(CONFIG_FILE, HttpService:JSONEncode(Settings))
        end
    end)
end
local function LoadConfig()
    pcall(function()
        if readfile and isfile and isfile(CONFIG_FILE) then
            local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
            for k, v in pairs(data) do
                if Settings[k] ~= nil then Settings[k] = v end
            end
        end
    end)
end

--==================================================
-- HTTP / AUTH
--==================================================
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

--==================================================
-- NOTIFY
--==================================================
local lastNotifyTime = 0
local function Notify(text, color, duration)
    -- rate limit 0.3s
    if os.clock() - lastNotifyTime < 0.3 then return end
    lastNotifyTime = os.clock()

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
    frame.ZIndex = 5
    frame.Parent = sg
    Corner(frame, 12)
    local st = Stroke(frame, color, 1.5)

    local glow = Instance.new("Frame", frame)
    glow.Size = UDim2.new(1, 8, 1, 8)
    glow.Position = UDim2.new(0, -4, 0, -4)
    glow.BackgroundColor3 = color
    glow.BackgroundTransparency = 0.85
    glow.BorderSizePixel = 0
    glow.ZIndex = 4
    Corner(glow, 14)

    local accent = Instance.new("Frame", frame)
    accent.Size = UDim2.new(0, 3, 1, -12)
    accent.Position = UDim2.new(0, 6, 0, 6)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    accent.ZIndex = 6
    Corner(accent, 3)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.BackgroundTransparency = 1
    label.ZIndex = 6
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
        p.ZIndex = 10
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

local KillSound = Instance.new("Sound")
KillSound.SoundId = "rbxassetid://136998941171548"
KillSound.Volume = 1
KillSound.Parent = SoundService

local function PlayClick()
    pcall(function()
        ToggleSound:Stop()
        ToggleSound.TimePosition = 0
        ToggleSound:Play()
    end)
end

local function PlayKillSound()
    if not Settings.KillSound then return end
    pcall(function()
        KillSound:Stop()
        KillSound.TimePosition = 0
        KillSound:Play()
    end)
end

--==================================================
-- ROLE
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
local function RoleColor(r) return C[r] or C.Innocent end

--==================================================
-- KILL TRACKER
--==================================================
local hitTimestamps = {}

local function RegisterHit(player)
    if player and player ~= LP then
        hitTimestamps[player] = os.clock()
    end
end

local function WasOurKill(player)
    local t = hitTimestamps[player]
    if not t then return false end
    return (os.clock() - t) < 1.5
end

--==================================================
-- KILL FEED
--==================================================
local killFeedEntries = {}
local KillFeedGui, KillFeedContainer

local function InitKillFeed()
    KillFeedGui = Instance.new("ScreenGui")
    KillFeedGui.Name = "Fondi_KillFeed"
    KillFeedGui.ResetOnSpawn = false
    KillFeedGui.IgnoreGuiInset = true
    KillFeedGui.DisplayOrder = 400
    KillFeedGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    KillFeedGui.Parent = pg

    KillFeedContainer = Instance.new("Frame", KillFeedGui)
    KillFeedContainer.Size = UDim2.new(0, 280, 0, 200)
    KillFeedContainer.Position = UDim2.new(1, -300, 0, 100)
    KillFeedContainer.BackgroundTransparency = 1
    KillFeedContainer.ZIndex = 10

    local layout = Instance.new("UIListLayout", KillFeedContainer)
    layout.Padding = UDim.new(0, 4)
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
end

local function AddKillFeed(killer, victim)
    if not Settings.KillFeed then return end
    local time = os.date("%H:%M")
    local text = "[" .. time .. "] " .. killer .. "  ☠  " .. victim

    local frame = Instance.new("Frame", KillFeedContainer)
    frame.Size = UDim2.new(1, 0, 0, 26)
    frame.BackgroundColor3 = C.Card
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.ZIndex = 11
    Corner(frame, 6)
    Stroke(frame, C.Danger, 1, 0.3)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -12, 1, 0)
    lbl.Position = UDim2.new(0, 6, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.ZIndex = 12
    lbl.Text = text
    lbl.TextColor3 = C.Text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    table.insert(killFeedEntries, frame)
    if #killFeedEntries > 5 then
        local old = table.remove(killFeedEntries, 1)
        if old then old:Destroy() end
    end

    task.delay(8, function()
        if frame and frame.Parent then
            Tween(frame, 0.3, {BackgroundTransparency = 1})
            Tween(lbl, 0.3, {TextTransparency = 1})
            task.wait(0.35)
            frame:Destroy()
            for i, f in ipairs(killFeedEntries) do
                if f == frame then table.remove(killFeedEntries, i) break end
            end
        end
    end)
end

--==================================================
-- SILENT AIM (namecall hook)
--==================================================
local SilentAimTarget = nil

local function GetClosestEnemy(maxDist)
    maxDist = maxDist or 300
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local closest, minDist = nil, maxDist
    local mousePos = UIS:GetMouseLocation()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP and pl.Character then
            local role = GetRole(pl)
            if role == "Murderer" or role == "Sheriff" or Settings.SilentAimAll then
                local head = pl.Character:FindFirstChild("Head")
                if head then
                    local pos, vis = cam:WorldToViewportPoint(head.Position)
                    if vis then
                        local d = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if d < minDist then minDist = d; closest = pl end
                    end
                end
            end
        end
    end
    return closest
end

local function InstallSilentAim()
    if not Settings.SilentAim then return end
    if not hookmetamethod or not getrawmetatable then return end

    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if Settings.SilentAim and method == "FireServer" then
            local name = self.Name
            if name == "Knife" or name == "Gun" or name == "Revolver" then
                SilentAimTarget = GetClosestEnemy(300)
                if SilentAimTarget and SilentAimTarget.Character then
                    local head = SilentAimTarget.Character:FindFirstChild("Head")
                    if head then
                        local args = {...}
                        -- заменяем первый аргумент (обычно позиция/объект) на цель
                        if #args >= 1 then
                            args[1] = head
                        end
                        RegisterHit(SilentAimTarget)
                        return oldNamecall(self, table.unpack(args))
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

--==================================================
-- ESP
--==================================================
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

local function OnPlayerDied(player, killer)
    if player == LP then return end

    -- Kill Feed
    if killer then
        AddKillFeed(killer.DisplayName or "?", player.DisplayName or "?")
    else
        AddKillFeed("?", player.DisplayName or "?")
    end

    if WasOurKill(player) then
        PlayKillSound()
        if Settings.KillNotif then
            KillNotification(player.DisplayName)
        end
        if Settings.KillEffect then
            ShowKillEffect()
        end
    end
    hitTimestamps[player] = nil
end

local function SetupPlayer(player)
    if player == LP then return end
    DisconnectPlayer(player)
    PlayerConnections[player] = {}

    local function watchHumanoid(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local dc = hum.Died:Connect(function()
                OnPlayerDied(player, hum:GetAttribute("FondiKiller"))
            end)
            table.insert(PlayerConnections[player], dc)
        end
    end

    local ca = player.CharacterAdded:Connect(function(char)
        RemoveESP(player)
        char:WaitForChild("HumanoidRootPart", 10)
        watchHumanoid(char)
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
            watchHumanoid(char)
            if player.Character == char and Settings.ESP then
                task.wait(0.2); CreateESP(player)
            end
        end)
    end
end

for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then SetupPlayer(p) end end
Players.PlayerAdded:Connect(SetupPlayer)
Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p); DisconnectPlayer(p); lastRoles[p] = nil; hitTimestamps[p] = nil
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

--==================================================
-- ITEM ESP
--==================================================
local ItemESPObjects = {}

local function ClearItemESP()
    for obj, data in pairs(ItemESPObjects) do
        for _, inst in ipairs(data) do
            pcall(function() inst:Destroy() end)
        end
    end
    ItemESPObjects = {}
end

local function CreateItemESP(obj, color)
    if ItemESPObjects[obj] then return end
    local hl = Instance.new("Highlight")
    hl.Name = "FondiItemHL"
    hl.Adornee = obj
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = obj

    local bb = Instance.new("BillboardGui", obj)
    bb.Size = UDim2.new(0, 100, 0, 20)
    bb.StudsOffset = Vector3.new(0, 2, 0)
    bb.AlwaysOnTop = true
    local lbl = Instance.new("TextLabel", bb)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = obj.Name
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12

    ItemESPObjects[obj] = {hl, bb}
end

task.spawn(function()
    while task.wait(1) do
        if not IsAuthenticated then continue end
        if not Settings.ItemESP then
            if next(ItemESPObjects) then ClearItemESP() end
            continue
        end
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Tool") or obj:IsA("Model") then
                local n = obj.Name:lower()
                if n:find("knife") then
                    CreateItemESP(obj, C.Murderer)
                elseif n:find("gun") or n:find("revolver") then
                    CreateItemESP(obj, C.Sheriff)
                elseif n:find("coin") or n:find("gem") or n:find("money") then
                    CreateItemESP(obj, C.Warning)
                end
            end
        end
    end
end)

--==================================================
-- RADAR
--==================================================
local RadarGui, RadarFrame, RadarDotContainer
local RADAR_SIZE = 150
local RADAR_RANGE = 200

local function InitRadar()
    RadarGui = Instance.new("ScreenGui")
    RadarGui.Name = "Fondi_Radar"
    RadarGui.ResetOnSpawn = false
    RadarGui.IgnoreGuiInset = true
    RadarGui.DisplayOrder = 450
    RadarGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    RadarGui.Parent = pg

    RadarFrame = Instance.new("Frame", RadarGui)
    RadarFrame.Size = UDim2.new(0, RADAR_SIZE, 0, RADAR_SIZE)
    RadarFrame.Position = UDim2.new(0, 12, 1, -RADAR_SIZE - 12)
    RadarFrame.BackgroundColor3 = C.Card
    RadarFrame.BackgroundTransparency = 0.35
    RadarFrame.BorderSizePixel = 0
    RadarFrame.ZIndex = 100
    Corner(RadarFrame, RADAR_SIZE/2)
    Stroke(RadarFrame, C.Accent, 2)

    RadarDotContainer = Instance.new("Frame", RadarFrame)
    RadarDotContainer.Size = UDim2.new(1, 0, 1, 0)
    RadarDotContainer.BackgroundTransparency = 1
    RadarDotContainer.ClipsDescendants = true
    RadarDotContainer.ZIndex = 101
    Corner(RadarDotContainer, RADAR_SIZE/2)

    local cross1 = Instance.new("Frame", RadarFrame)
    cross1.Size = UDim2.new(1, -20, 0, 1)
    cross1.Position = UDim2.new(0, 10, 0.5, 0)
    cross1.BackgroundColor3 = C.Border
    cross1.BackgroundTransparency = 0.5
    cross1.BorderSizePixel = 0
    cross1.ZIndex = 102

    local cross2 = Instance.new("Frame", RadarFrame)
    cross2.Size = UDim2.new(0, 1, 1, -20)
    cross2.Position = UDim2.new(0.5, 0, 0, 10)
    cross2.BackgroundColor3 = C.Border
    cross2.BackgroundTransparency = 0.5
    cross2.BorderSizePixel = 0
    cross2.ZIndex = 102

    RadarFrame.Visible = false
end

local radarDots = {}

local function UpdateRadar()
    if not RadarFrame then return end
    RadarFrame.Visible = Settings.Radar
    if not Settings.Radar then return end

    local myChar = LP.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local myCF = myRoot.CFrame
    local center = Vector2.new(RADAR_SIZE/2, RADAR_SIZE/2)
    local scale = (RADAR_SIZE/2) / RADAR_RANGE

    -- очистка мёртвых
    for pl, dot in pairs(radarDots) do
        if not pl.Parent or not pl.Character then
            if dot then dot:Destroy() end
            radarDots[pl] = nil
        end
    end

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP and pl.Character then
            local root = pl.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local rel = myCF:PointToObjectSpace(root.Position)
                local dx = rel.X * scale
                local dz = -rel.Z * scale  -- Z инвертируем

                local dist = math.sqrt(dx*dx + dz*dz)
                if dist > RADAR_SIZE/2 - 4 then
                    -- выходит за границы — не рисуем
                    if radarDots[pl] then radarDots[pl].Visible = false end
                else
                    local dot = radarDots[pl]
                    if not dot then
                        dot = Instance.new("Frame", RadarDotContainer)
                        dot.Size = UDim2.new(0, 6, 0, 6)
                        dot.BorderSizePixel = 0
                        dot.ZIndex = 103
                        Corner(dot, 3)
                        radarDots[pl] = dot
                    end
                    dot.Visible = true
                    dot.BackgroundColor3 = RoleColor(GetRole(pl))
                    dot.Position = UDim2.new(0, center.X + dx - 3, 0, center.Y + dz - 3)
                end
            end
        end
    end

    -- игрок в центре
    if not radarDots[LP] then
        local me = Instance.new("Frame", RadarDotContainer)
        me.Size = UDim2.new(0, 6, 0, 6)
        me.BorderSizePixel = 0
        me.ZIndex = 104
        me.BackgroundColor3 = C.Accent2
        Corner(me, 3)
        radarDots[LP] = me
    end
    radarDots[LP].Position = UDim2.new(0, center.X - 3, 0, center.Y - 3)
end

--==================================================
-- VISUALS: HUD GUI
--==================================================
local HudGui = Instance.new("ScreenGui")
HudGui.Name = "Fondi_Hud"
HudGui.ResetOnSpawn = false
HudGui.IgnoreGuiInset = true
HudGui.DisplayOrder = 500
HudGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
HudGui.Parent = pg

-- Crosshair
local crosshair = Instance.new("Frame", HudGui)
crosshair.Size = UDim2.new(0, 20, 0, 20)
crosshair.Position = UDim2.new(0.5, -10, 0.5, -10)
crosshair.BackgroundTransparency = 1
crosshair.ZIndex = 100

local function makeCrossLine(size, pos)
    local l = Instance.new("Frame", crosshair)
    l.Size = size
    l.Position = pos
    l.BackgroundColor3 = C.Accent2
    l.BorderSizePixel = 0
    l.ZIndex = 100
    return l
end

makeCrossLine(UDim2.new(0, 2, 0, 6), UDim2.new(0.5, -1, 0, 0))
makeCrossLine(UDim2.new(0, 2, 0, 6), UDim2.new(0.5, -1, 1, -6))
makeCrossLine(UDim2.new(0, 6, 0, 2), UDim2.new(0, 0, 0.5, -1))
makeCrossLine(UDim2.new(0, 6, 0, 2), UDim2.new(1, -6, 0.5, -1))

local crossDot = Instance.new("Frame", crosshair)
crossDot.Size = UDim2.new(0, 2, 0, 2)
crossDot.Position = UDim2.new(0.5, -1, 0.5, -1)
crossDot.BackgroundColor3 = C.Accent
crossDot.BorderSizePixel = 0
crossDot.ZIndex = 100

crosshair.Visible = false

-- Watermark
local watermark = Instance.new("Frame", HudGui)
watermark.Size = UDim2.new(0, 260, 0, 26)
watermark.Position = UDim2.new(0, 12, 0, 12)
watermark.BackgroundColor3 = C.Card
watermark.BackgroundTransparency = 0.15
watermark.BorderSizePixel = 0
watermark.ZIndex = 100
Corner(watermark, 8)
Stroke(watermark, C.Accent, 1)

local wmLabel = Instance.new("TextLabel", watermark)
wmLabel.Size = UDim2.new(1, -12, 1, 0)
wmLabel.Position = UDim2.new(0, 6, 0, 0)
wmLabel.BackgroundTransparency = 1
wmLabel.ZIndex = 101
wmLabel.Text = "FONDI MM2 " .. VERSION
wmLabel.TextColor3 = C.Text
wmLabel.Font = Enum.Font.GothamBold
wmLabel.TextSize = 11
wmLabel.TextXAlignment = Enum.TextXAlignment.Left

watermark.Visible = false

-- FPS Graph
local fpsGraphBg = Instance.new("Frame", HudGui)
fpsGraphBg.Size = UDim2.new(0, 220, 0, 60)
fpsGraphBg.Position = UDim2.new(0, 12, 0, 44)
fpsGraphBg.BackgroundColor3 = C.Card
fpsGraphBg.BackgroundTransparency = 0.2
fpsGraphBg.BorderSizePixel = 0
fpsGraphBg.ZIndex = 100
Corner(fpsGraphBg, 8)
Stroke(fpsGraphBg, C.Accent2, 1)

local fpsGraph = Instance.new("Frame", fpsGraphBg)
fpsGraph.Size = UDim2.new(1, -12, 1, -12)
fpsGraph.Position = UDim2.new(0, 6, 0, 6)
fpsGraph.BackgroundTransparency = 1
fpsGraph.ClipsDescendants = true
fpsGraph.ZIndex = 101

-- пул баров
local FPS_BARS = 40
local fpsBars = {}
for i = 1, FPS_BARS do
    local bar = Instance.new("Frame", fpsGraph)
    bar.Size = UDim2.new(0, 0, 0, 0)
    bar.AnchorPoint = Vector2.new(0, 1)
    bar.BorderSizePixel = 0
    bar.ZIndex = 102
    fpsBars[i] = bar
end

local fpsValues = {}
for i = 1, FPS_BARS do fpsValues[i] = 60 end
local fpsAccum = 0
local fpsFrames = 0

fpsGraphBg.Visible = false

-- Hitmarker
local hitmarker = Instance.new("Frame", HudGui)
hitmarker.Size = UDim2.new(0, 30, 0, 30)
hitmarker.Position = UDim2.new(0.5, -15, 0.5, -15)
hitmarker.BackgroundTransparency = 1
hitmarker.ZIndex = 200
hitmarker.Visible = false

local function makeHitLine(size, pos, rot)
    local l = Instance.new("Frame", hitmarker)
    l.Size = size
    l.Position = pos
    l.BackgroundColor3 = Color3.new(1, 1, 1)
    l.BorderSizePixel = 0
    l.Rotation = rot
    l.ZIndex = 200
    return l
end
makeHitLine(UDim2.new(0, 2, 0, 8), UDim2.new(0, 4, 0, 4), 45)
makeHitLine(UDim2.new(0, 2, 0, 8), UDim2.new(1, -6, 0, 4), -45)
makeHitLine(UDim2.new(0, 2, 0, 8), UDim2.new(0, 4, 1, -12), -45)
makeHitLine(UDim2.new(0, 2, 0, 8), UDim2.new(1, -6, 1, -12), 45)

-- Kill Notification
local killNotif = Instance.new("Frame", HudGui)
killNotif.Size = UDim2.new(0, 320, 0, 50)
killNotif.Position = UDim2.new(0.5, -160, 0, -70)
killNotif.BackgroundColor3 = C.Card
killNotif.BackgroundTransparency = 0.05
killNotif.BorderSizePixel = 0
killNotif.ZIndex = 300
Corner(killNotif, 10)
Stroke(killNotif, C.Danger, 2)

local killNotifAccent = Instance.new("Frame", killNotif)
killNotifAccent.Size = UDim2.new(0, 4, 1, -12)
killNotifAccent.Position = UDim2.new(0, 6, 0, 6)
killNotifAccent.BackgroundColor3 = C.Danger
killNotifAccent.BorderSizePixel = 0
killNotifAccent.ZIndex = 301
Corner(killNotifAccent, 3)

local killNotifLabel = Instance.new("TextLabel", killNotif)
killNotifLabel.Size = UDim2.new(1, -30, 1, 0)
killNotifLabel.Position = UDim2.new(0, 20, 0, 0)
killNotifLabel.BackgroundTransparency = 1
killNotifLabel.ZIndex = 301
killNotifLabel.Text = ""
killNotifLabel.TextColor3 = C.Text
killNotifLabel.Font = Enum.Font.GothamBold
killNotifLabel.TextSize = 14
killNotifLabel.TextXAlignment = Enum.TextXAlignment.Left

killNotif.Visible = false

function KillNotification(victimName)
    killNotifLabel.Text = "☠  YOU KILLED  " .. victimName
    killNotif.Visible = true
    killNotif.Position = UDim2.new(0.5, -160, 0, -70)
    killNotif.BackgroundTransparency = 1
    killNotifLabel.TextTransparency = 1

    Tween(killNotif, 0.4, {
        Position = UDim2.new(0.5, -160, 0, 20),
        BackgroundTransparency = 0.05
    }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Tween(killNotifLabel, 0.3, {TextTransparency = 0})

    task.delay(2.5, function()
        Tween(killNotif, 0.3, {
            Position = UDim2.new(0.5, -160, 0, -70),
            BackgroundTransparency = 1
        }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        Tween(killNotifLabel, 0.3, {TextTransparency = 1})
        task.wait(0.35)
        killNotif.Visible = false
    end)
end

-- Kill Effect
local killEffect = Instance.new("Frame", HudGui)
killEffect.Size = UDim2.new(0, 200, 0, 200)
killEffect.Position = UDim2.new(0.5, -100, 0.5, -100)
killEffect.BackgroundColor3 = C.Danger
killEffect.BackgroundTransparency = 1
killEffect.BorderSizePixel = 0
killEffect.ZIndex = 250
Corner(killEffect, 100)

function ShowKillEffect()
    killEffect.BackgroundTransparency = 0.6
    killEffect.Size = UDim2.new(0, 50, 0, 50)
    killEffect.Position = UDim2.new(0.5, -25, 0.5, -25)

    Tween(killEffect, 0.4, {
        Size = UDim2.new(0, 300, 0, 300),
        Position = UDim2.new(0.5, -150, 0.5, -150),
        BackgroundTransparency = 1
    }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
end

function ShowHitmarker()
    if not Settings.Hitmarker then return end
    hitmarker.Visible = true
    hitmarker.Size = UDim2.new(0, 30, 0, 30)
    hitmarker.Position = UDim2.new(0.5, -15, 0.5, -15)

    for _, child in ipairs(hitmarker:GetChildren()) do
        if child:IsA("Frame") then
            child.BackgroundColor3 = Color3.new(1, 1, 1)
        end
    end

    Tween(hitmarker, 0.3, {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0.5, -20, 0.5, -20)
    }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    task.delay(0.25, function()
        hitmarker.Visible = false
    end)
end

-- Damage Indicator (fix: реальное направление)
local function GetAttackerDirection()
    local myChar = LP.Character
    if not myChar then return 0 end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return 0 end
    local closest, minD = nil, 100
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local role = GetRole(p)
            if role == "Murderer" or role == "Sheriff" then
                local tr = p.Character:FindFirstChild("HumanoidRootPart")
                if tr then
                    local d = (tr.Position - myRoot.Position).Magnitude
                    if d < minD then minD = d; closest = tr end
                end
            end
        end
    end
    if not closest then return 0 end
    local dir = (closest.Position - myRoot.Position).Unit
    local look = myRoot.CFrame.LookVector
    return math.atan2(dir.Z, dir.X) - math.atan2(look.Z, look.X)
end

local function ShowDamageDirection(angle)
    if not Settings.DamageIndicator then return end
    local arrow = Instance.new("Frame", HudGui)
    arrow.Size = UDim2.new(0, 30, 0, 30)
    arrow.BackgroundColor3 = C.Danger
    arrow.BackgroundTransparency = 0.3
    arrow.BorderSizePixel = 0
    arrow.Rotation = math.deg(angle)
    arrow.ZIndex = 220
    Corner(arrow, 6)

    local cx = 0.5 + math.cos(angle) * 0.15
    local cy = 0.5 + math.sin(angle) * 0.15
    arrow.Position = UDim2.new(cx, -15, cy, -15)

    Tween(arrow, 1, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    task.delay(1.05, function() arrow:Destroy() end)
end

-- Rainbow Trail
local trailAttachments = {}
local trailColors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(255, 150, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 200, 255),
    Color3.fromRGB(150, 0, 255),
    Color3.fromRGB(255, 0, 200)
}

local function ClearTrail()
    for _, a in ipairs(trailAttachments) do
        pcall(function() a:Destroy() end)
    end
    trailAttachments = {}
end

local function CreateTrail()
    ClearTrail()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local prev = nil
    for i = 1, 6 do
        local a = Instance.new("Attachment", hrp)
        a.Name = "FondiTrail_" .. i
        table.insert(trailAttachments, a)
        if prev then
            local beam = Instance.new("Beam")
            beam.Attachment0 = prev
            beam.Attachment1 = a
            beam.Width0 = 2
            beam.Width1 = 2
            beam.FaceCamera = true
            beam.Color = ColorSequence.new(trailColors[i % #trailColors + 1])
            beam.Transparency = NumberSequence.new(0.3)
            beam.Parent = hrp
            table.insert(trailAttachments, beam)
        end
        prev = a
    end
end

--==================================================
-- UPDATE LOOP FOR HUD
--==================================================
RunService.RenderStepped:Connect(function(dt)
    fpsAccum = fpsAccum + dt
    fpsFrames = fpsFrames + 1
end)

task.spawn(function()
    while task.wait(0.5) do
        if Settings.Watermark then
            watermark.Visible = true
            local fps = fpsFrames > 0 and math.floor(fpsFrames / fpsAccum) or 0
            fpsAccum = 0; fpsFrames = 0
            local ping = 0
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            local playerCount = #Players:GetPlayers()
            wmLabel.Text = string.format("FONDI %s | %d FPS | %d ms | %d players",
                VERSION, fps, ping, playerCount)
        else
            watermark.Visible = false
        end

        if Settings.FpsGraph then
            fpsGraphBg.Visible = true
            local fps = fpsFrames > 0 and math.floor(fpsFrames / fpsAccum) or 60
            table.remove(fpsValues, 1)
            table.insert(fpsValues, fps)

            local barW = fpsGraph.AbsoluteSize.X / FPS_BARS
            for i, val in ipairs(fpsValues) do
                local bar = fpsBars[i]
                local h = math.clamp(val / 120, 0, 1)
                bar.Size = UDim2.new(0, math.max(barW - 1, 1), h, 0)
                bar.Position = UDim2.new(0, (i-1) * barW, 1, 0)
                bar.BackgroundColor3 = val >= 50 and C.Green or (val >= 30 and C.Warning or C.Danger)
            end
        else
            fpsGraphBg.Visible = false
        end

        crosshair.Visible = Settings.Crosshair

        if Settings.RainbowTrail then
            if #trailAttachments == 0 then CreateTrail() end
        else
            if #trailAttachments > 0 then ClearTrail() end
        end

        UpdateRadar()
    end
end)

LP.CharacterAdded:Connect(function()
    task.wait(1)
    if Settings.RainbowTrail then CreateTrail() end
end)

--==================================================
-- NOCLIP
--==================================================
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

--==================================================
-- FLY
--==================================================
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
        local cam = Workspace.CurrentCamera
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

--==================================================
-- BHOP
--==================================================
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

--==================================================
-- ANTI-FLING (fix threshold)
--==================================================
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
        -- понижен порог: 80 / 30
        if r.Velocity.Magnitude > 80 or r.RotVelocity.Magnitude > 30 then
            r.Velocity = Vector3.zero
            r.RotVelocity = Vector3.zero
        end
    end)
end

--==================================================
-- AIMBOT
--==================================================
local aimbotConnection = nil
local function StopAimbot()
    if aimbotConnection then aimbotConnection:Disconnect(); aimbotConnection = nil end
end
local function StartAimbot()
    StopAimbot()
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not IsAuthenticated or not Settings.Aimbot then return end
        if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
        local cam = Workspace.CurrentCamera
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

--==================================================
-- AUTO-PICKUP
--==================================================
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

        for _, obj in ipairs(Workspace:GetChildren()) do
            local targetPart = nil

            if obj:IsA("Tool") then
                local n = obj.Name:lower()
                if n:find("gun") or n:find("revolver") or n:find("knife") then
                    targetPart = obj:FindFirstChild("Handle")
                end
            elseif obj:IsA("Model") then
                local n = obj.Name:lower()
                if n:find("gun") or n:find("revolver") or n:find("knife") then
                    targetPart = obj:FindFirstChild("Handle")
                        or obj:FindFirstChildWhichIsA("BasePart")
                end
            end

            if targetPart then
                local dist = (targetPart.Position - r.Position).Magnitude
                if dist < 120 then
                    r.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 3, 0))
                    return
                end
            end
        end
    end)
end

--==================================================
-- KILL ALL
--==================================================
local killAllConnection = nil
local lastKillTime = 0

local function GetWeapon()
    local c = LP.Character
    if not c then return nil end
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") and (t.Name == "Knife" or t.Name == "Gun" or t.Name == "Revolver") then
            return t
        end
    end
    return nil
end

local function StopKillAll()
    if killAllConnection then killAllConnection:Disconnect(); killAllConnection = nil end
end

local function StartKillAll()
    StopKillAll()
    killAllConnection = RunService.Heartbeat:Connect(function()
        if not IsAuthenticated or not Settings.KillAll then return end
        if os.clock() - lastKillTime < 0.2 then return end

        local c = LP.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not r or not hum then return end

        local target, targetDist = nil, Settings.KillAuraRange
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and pl.Character then
                local tr = pl.Character:FindFirstChild("HumanoidRootPart")
                local th = pl.Character:FindFirstChildOfClass("Humanoid")
                if tr and th and th.Health > 0 then
                    local d = (tr.Position - r.Position).Magnitude
                    if d < targetDist then targetDist = d; target = pl end
                end
            end
        end

        if not target then return end
        local tr = target.Character.HumanoidRootPart
        local th = target.Character:FindFirstChildOfClass("Humanoid")

        -- телепорт вплотную + атака
        r.CFrame = CFrame.new(tr.Position - tr.CFrame.LookVector * 2 + Vector3.new(0, 1, 0),
                              Vector3.new(tr.Position.X, r.Position.Y, tr.Position.Z))

        local w = GetWeapon()
        if w then
            pcall(function() w:Activate() end)
        end
        -- fallback: прямое убийство через Health (работает если сервер не валидирует)
        if th then
            pcall(function()
                local killer = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if killer then
                    th:TakeDamage(th.Health, killer, w)
                end
            end)
        end

        RegisterHit(target)
        ShowHitmarker()
        lastKillTime = os.clock()
    end)
end

--==================================================
-- FLING (V11.3: Network Owner + Prediction)
--==================================================
local activeFlings = {}  -- [player] = connection
local flingParams = {}   -- [player] = {target, startTime}

local function StopFlingFor(targetPlayer)
    local con = activeFlings[targetPlayer]
    if con then
        pcall(function() con:Disconnect() end)
        activeFlings[targetPlayer] = nil
    end
    flingParams[targetPlayer] = nil
end

local function StopAllFlings()
    for pl, _ in pairs(activeFlings) do
        StopFlingFor(pl)
    end
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.AutoRotate = true
        end
    end
end

-- Пытаемся забрать network ownership у цели (работает только если executor имеет доступ)
local function TrySetNetworkOwner(targetRoot)
    if not Settings.FlingUseNetworkOwner then return false end
    local ok = pcall(function()
        if setnetworkowner then
            setnetworkowner(targetRoot, nil)
        elseif targetRoot.SetNetworkOwner then
            targetRoot:SetNetworkOwner(nil)
        else
            error("no method")
        end
    end)
    return ok
end

local function StartFling(target)
    if not target or not target.Character then return end
    StopFlingFor(target)

    local myChar = LP.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    if not myRoot or not myHum then return end

    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    -- Network owner attempt
    local netOwned = TrySetNetworkOwner(targetRoot)

    flingParams[target] = {startTime = os.clock(), netOwned = netOwned}

    activeFlings[target] = RunService.Heartbeat:Connect(function(dt)
        local params = flingParams[target]
        if not params then StopFlingFor(target) return end
        if os.clock() - params.startTime > 5 then
            -- возвращаем владельца
            pcall(function()
                if targetRoot and targetRoot.Parent then
                    targetRoot:SetNetworkOwner(target)
                end
            end)
            StopFlingFor(target)
            return
        end

        local myC = LP.Character
        if not myC then StopFlingFor(target) return end
        local myR = myC:FindFirstChild("HumanoidRootPart")
        local myH = myC:FindFirstChildOfClass("Humanoid")
        if not myR or not myH then StopFlingFor(target) return end

        local tC = target.Character
        if not tC then StopFlingFor(target) return end
        local tR = tC:FindFirstChild("HumanoidRootPart")
        if not tR then StopFlingFor(target) return end

        myH.PlatformStand = true
        myH.AutoRotate = false

        -- Prediction: учитываем velocity цели
        local predictedPos = tR.Position
        if Settings.FlingPrediction then
            local tv = tR.AssemblyLinearVelocity
            predictedPos = tR.Position + tv * 0.15  -- на 150мс вперёд
        end

        local dir = (predictedPos - myR.Position)
        local dist = dir.Magnitude
        if dist < 0.01 then dir = Vector3.new(1,0,0) else dir = dir.Unit end

        -- Телепорт вплотную
        myR.CFrame = CFrame.new(predictedPos - dir * 2 + Vector3.new(0, 1, 0), predictedPos)

        -- Импульс
        myR.AssemblyLinearVelocity = dir * Settings.FlingSpeed

        -- Огромная угловая скорость
        myR.AssemblyAngularVelocity = Vector3.new(
            Settings.FlingSpin, Settings.FlingSpin, Settings.FlingSpin
        )

        -- Микротолчки
        myR.AssemblyLinearVelocity = myR.AssemblyLinearVelocity + Vector3.new(
            math.random(-30, 30), math.random(-30, 30), math.random(-30, 30)
        )

        -- Если удалось забрать network ownership — долбим цель напрямую
        if params.netOwned then
            pcall(function()
                tR.AssemblyLinearVelocity = Vector3.new(
                    math.random(-500, 500), 200, math.random(-500, 500)
                )
                tR.AssemblyAngularVelocity = Vector3.new(500, 500, 500)
            end)
        end
    end)

    Notify("FLING → " .. target.DisplayName .. (netOwned and " [NET]" or " [SPIN]"), C.Pink, 2)
end

local function FlingAll()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP and pl.Character then
            task.spawn(function()
                StartFling(pl)
            end)
        end
    end
end

--==================================================
-- FARM
--==================================================
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
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("gem") or obj.Name:lower():find("money")) then
                local d = (obj.Position - r.Position).Magnitude
                if d < minDist then minDist = d; closest = obj end
            end
        end
        if closest then r.CFrame = CFrame.new(closest.Position + Vector3.new(0, 2, 0)) end
    end)
end

--==================================================
-- ANTI-KICK
--==================================================
pcall(function()
    if hookfunction and LP.Kick then
        hookfunction(LP.Kick, function(self, msg)
            Notify("ANTI-KICK: " .. tostring(msg), C.Danger, 5)
            return nil
        end)
    end
end)

--==================================================
-- DAMAGE DETECTION (fix: реальное направление)
--==================================================
task.spawn(function()
    while task.wait(0.1) do
        if not IsAuthenticated then continue end
        local char = LP.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local lastHP = hum:GetAttribute("FondiLastHP") or hum.MaxHealth
            if hum.Health < lastHP then
                if Settings.DamageIndicator then
                    ShowDamageDirection(GetAttackerDirection())
                end
            end
            hum:SetAttribute("FondiLastHP", hum.Health)
        end
    end
end)

--==================================================
-- LOADING SCREEN
--==================================================
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
    logo2.Text = "MM2 " .. VERSION
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
    Tween(barBg, 0.5, {BackgroundTransparency = 0})
    Tween(statusText, 0.6, {TextTransparency = 0})

    task.spawn(function()
        local stages = {
            {T("loading") .. " UI...", 25},
            {T("loading") .. " Visuals...", 55},
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

--==================================================
-- MAIN UI
--==================================================
local MainGui, MainFrame

function BuildUI()
    if MainGui then pcall(function() MainGui:Destroy() end) end
    MainGui = Instance.new("ScreenGui")
    MainGui.Name = "Fondi_V11"
    MainGui.ResetOnSpawn = false
    MainGui.IgnoreGuiInset = true
    MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainGui.Parent = pg

    MainFrame = Instance.new("Frame", MainGui)
    MainFrame.Size = UDim2.new(0, 500, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    MainFrame.BackgroundColor3 = C.Card
    MainFrame.BackgroundTransparency = 0.02
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ZIndex = 10
    Corner(MainFrame, 20)
    Stroke(MainFrame, C.Accent, 1.5)

    local header = Instance.new("Frame", MainFrame)
    header.Size = UDim2.new(1, 0, 0, 70)
    header.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
    header.BackgroundTransparency = 0.2
    header.BorderSizePixel = 0
    header.ZIndex = 11
    Corner(header, 20)

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
    subTitle.Text = VERSION .. " • " .. (LP.DisplayName or "User")
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

    close.MouseButton1Click:Connect(function()
        PlayClick()
        Tween(MainFrame, 0.3, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.3)
        MainFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 500, 0, 600)
        MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
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
    tabLayout.Padding = UDim.new(0, 3)
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
        {id = "visual", label = T("catVisual")},
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
            if tabContents[id] then tabContents[id].Visible = true end
        end
    end

    for _, t in ipairs(tabData) do
        local btn = Instance.new("TextButton", tabBar)
        btn.Size = UDim2.new(0, 68, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
        btn.BackgroundTransparency = 1
        btn.Text = t.label
        btn.TextColor3 = C.SubText
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
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
        btn.Size = UDim2.new(1, -5, 0, 42)
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
        lbl.TextSize = 12
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

        btn.MouseButton1Click:Connect(function()
            Settings[setting] = not Settings[setting]
            local on = Settings[setting]
            PlayClick()
            BurstFrom(btn)
            Tween(btn, 0.25, {BackgroundColor3 = on and Color3.fromRGB(30, 30, 48) or Color3.fromRGB(22, 22, 32)})
            Tween(bs, 0.25, {Color = on and color or C.Border})
            Tween(lbl, 0.25, {TextColor3 = on and color or C.Text})
            Tween(pill, 0.25, {BackgroundColor3 = on and color or Color3.fromRGB(50, 50, 70)})
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

    -- MAIN TAB
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

    -- MOVE TAB
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

    -- COMBAT TAB
    CreateToggle(tabContents["combat"], T("aimbot"), "Aimbot", C.Danger, function(on)
        if on then StartAimbot() else StopAimbot() end
    end)
    CreateToggle(tabContents["combat"], T("silentaim"), "SilentAim", C.Murderer, function(on)
        if on then InstallSilentAim() end
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

    local flingTitle = Instance.new("TextLabel", tabContents["combat"])
    flingTitle.Size = UDim2.new(1, -5, 0, 20)
    flingTitle.BackgroundTransparency = 1
    flingTitle.ZIndex = 15
    flingTitle.Text = T("flingTitle")
    flingTitle.TextColor3 = C.Accent2
    flingTitle.Font = Enum.Font.GothamBold
    flingTitle.TextSize = 11
    flingTitle.TextXAlignment = Enum.TextXAlignment.Left

    CreateSlider(tabContents["combat"], T("flingSpeed"), 100, 800, Settings.FlingSpeed, C.Danger, function(v)
        Settings.FlingSpeed = v
    end)
    CreateSlider(tabContents["combat"], T("flingSpin"), 100, 1500, Settings.FlingSpin, C.Pink, function(v)
        Settings.FlingSpin = v
    end)
    CreateToggle(tabContents["combat"], T("flingNetOwner"), "FlingUseNetworkOwner", C.Success)
    CreateToggle(tabContents["combat"], T("flingPredict"), "FlingPrediction", C.Blue)

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
                row.MouseButton1Click:Connect(function()
                    selectedFlingTarget = pl
                    playerBtn.Text = T("selected") .. pl.DisplayName
                    dropdown.Visible = false
                    PlayClick()
                end)
            end
        end
    end

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
    flingBtn.MouseButton1Click:Connect(function()
        if not selectedFlingTarget then return end
        PlayClick()
        BurstFrom(flingBtn)
        StartFling(selectedFlingTarget)
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
    flingAllBtn.MouseButton1Click:Connect(function()
        PlayClick()
        BurstFrom(flingAllBtn)
        FlingAll()
    end)

    -- VISUAL TAB
    CreateToggle(tabContents["visual"], T("visKillSound"), "KillSound", C.Danger)
    CreateToggle(tabContents["visual"], T("visHitmarker"), "Hitmarker", C.Accent2)
    CreateToggle(tabContents["visual"], T("visDamage"), "DamageIndicator", C.Warning)
    CreateToggle(tabContents["visual"], T("visWatermark"), "Watermark", C.Purple2)
    CreateToggle(tabContents["visual"], T("visFps"), "FpsGraph", C.Green)
    CreateToggle(tabContents["visual"], T("visCrosshair"), "Crosshair", C.Accent)
    CreateToggle(tabContents["visual"], T("visKillEffect"), "KillEffect", C.Pink)
    CreateToggle(tabContents["visual"], T("visKillNotif"), "KillNotif", C.Blue)
    CreateToggle(tabContents["visual"], T("visTrail"), "RainbowTrail", C.Orange)
    CreateToggle(tabContents["visual"], T("visRadar"), "Radar", C.Accent2)
    CreateToggle(tabContents["visual"], T("visItemESP"), "ItemESP", C.Warning)
    CreateToggle(tabContents["visual"], T("visKillFeed"), "KillFeed", C.Danger)

    -- FARM TAB
    CreateToggle(tabContents["farm"], T("farm"), "Farm", Color3.fromRGB(255, 200, 50), function(on)
        if on then StartFarm() else StopFarm() end
    end)

    -- MISC TAB
    CreateToggle(tabContents["misc"], T("notif"), "Notifications", Color3.fromRGB(100, 200, 255))

    local saveBtn = Instance.new("TextButton", tabContents["misc"])
    saveBtn.Size = UDim2.new(0.48, -5, 0, 42)
    saveBtn.BackgroundColor3 = C.Success
    saveBtn.Text = T("saveCfg")
    saveBtn.TextColor3 = Color3.new(1,1,1)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 12
    saveBtn.BorderSizePixel = 0
    saveBtn.AutoButtonColor = false
    saveBtn.ZIndex = 15
    Corner(saveBtn, 12)
    saveBtn.MouseButton1Click:Connect(function()
        SaveConfig()
        PlayClick()
        BurstFrom(saveBtn)
        Notify(T("cfgSaved"), C.Success)
    end)

    local loadBtn = Instance.new("TextButton", tabContents["misc"])
    loadBtn.Size = UDim2.new(0.48, -5, 0, 42)
    loadBtn.BackgroundColor3 = C.Blue
    loadBtn.Text = T("loadCfg")
    loadBtn.TextColor3 = Color3.new(1,1,1)
    loadBtn.Font = Enum.Font.GothamBold
    loadBtn.TextSize = 12
    loadBtn.BorderSizePixel = 0
    loadBtn.AutoButtonColor = false
    loadBtn.ZIndex = 15
    Corner(loadBtn, 12)
    loadBtn.MouseButton1Click:Connect(function()
        LoadConfig()
        PlayClick()
        BurstFrom(loadBtn)
        Notify(T("cfgLoaded"), C.Success)
        if MainGui then pcall(function() MainGui:Destroy() end) end
        BuildUI()
    end)

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
    task.wait(0.05)
    Tween(MainFrame, 0.5, {
        Size = UDim2.new(0, 500, 0, 600),
        Position = UDim2.new(0.5, -250, 0.5, -300)
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
        Tween(MainFrame, 0.4, {
            Size = UDim2.new(0, 500, 0, 600),
            Position = UDim2.new(0.5, -250, 0.5, -300)
        }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        Tween(MainFrame, 0.3, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.3)
        MainFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 500, 0, 600)
        MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    end
end

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not IsAuthenticated then return end
    if input.KeyCode == Enum.KeyCode.L then ToggleMenu()
    elseif input.KeyCode == Enum.KeyCode.F then
        Settings.Fly = not Settings.Fly
        if Settings.Fly then StartFly() else StopFly() end
    elseif input.KeyCode == Enum.KeyCode.N then
        Settings.Noclip = not Settings.Noclip
        if Settings.Noclip then StartNoclip() else StopNoclip() end
    elseif input.KeyCode == Enum.KeyCode.B then
        Settings.Bhop = not Settings.Bhop
        if Settings.Bhop then StartBhop() else StopBhop() end
    elseif input.KeyCode == Enum.KeyCode.K then
        Settings.KillAll = not Settings.KillAll
        if Settings.KillAll then StartKillAll() else StopKillAll() end
    elseif input.KeyCode == Enum.KeyCode.G then
        Settings.Farm = not Settings.Farm
        if Settings.Farm then StartFarm() else StopFarm() end
    end
end)

--==================================================
-- INIT EXTRAS
--==================================================
InitKillFeed()
InitRadar()

--==================================================
-- KEY GUI
--==================================================
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
Stroke(KeyFrame, C.Accent, 1.5)

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
keySub.Text = VERSION .. " • NETWORK"
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
keyLangBtn.MouseButton1Click:Connect(function()
    Lang = (Lang == "ru") and "en" or "ru"
    SaveLang(Lang)
    PlayClick()
    KeyGui:Destroy()
    if getgenv then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/p1shenak/main.lua/refs/heads/main/main.lua"))()
    end
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

local divider = Instance.new("Frame", KeyFrame)
divider.Size = UDim2.new(0.85, 0, 0, 1)
divider.Position = UDim2.new(0.075, 0, 0, 240)
divider.BackgroundColor3 = C.Border
divider.BorderSizePixel = 0
divider.ZIndex = 15

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
    {label = "1D", value = "1d"}, {label = "7D", value = "7d"},
    {label = "30D", value = "30d"}, {label = "∞", value = "inf"}
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

KeyFrame.Size = UDim2.new(0, 0, 0, 0)
KeyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
task.wait(0.05)
Tween(KeyFrame, 0.5, {
    Size = UDim2.new(0, 420, 0, 550),
    Position = UDim2.new(0.5, -210, 0.5, -275)
}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

ActivateBtn.MouseButton1Click:Connect(function()
    if KeyBox.Text == "" then Notify(T("keyInput"), C.Warning) return end
    ActivateBtn.Text = T("checking")
    ActivateBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    PlayClick()
    BurstFrom(ActivateBtn)
    local valid = ValidateKey(KeyBox.Text)
    if valid then
        IsAuthenticated = true
        SaveKey(KeyBox.Text)
        Notify(T("accessGranted"), C.Success)
        Tween(KeyFrame, 0.3, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.35)
        KeyGui:Destroy()
        ShowLoadingScreen(function() BuildUI() end)
    else
        KeyBox.Text = ""
        KeyBox.PlaceholderText = T("keyInvalid")
        ActivateBtn.Text = T("activate")
        ActivateBtn.BackgroundColor3 = C.Accent
        Notify(T("invalidKey"), C.Danger)
    end
end)

GenBtn.MouseButton1Click:Connect(function()
    GenBtn.Text = T("generating")
    GenBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    GenBtn.Active = false
    PlayClick()
    BurstFrom(GenBtn)
    task.spawn(function()
        local key, err = GenerateKeyRemote(selectedDuration)
        if key then
            KeyBox.Text = key
            Notify(T("keyCreated"), C.Success)
            GenBtn.Text = T("done")
            GenBtn.BackgroundColor3 = C.Success
        else
            Notify(err or "Generate failed", C.Danger)
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

--==================================================
-- AUTOLOGIN
--==================================================
do
    local saved = LoadLang()
    if saved then Lang = saved end
    LoadConfig()
end

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

print("==========================================")
print("[FONDI MM2 " .. VERSION .. "] NETWORK EDITION READY")
print("[FONDI MM2] Press L to toggle menu")
print("[FONDI MM2] Fix: Fling (netowner + prediction), DamageIndicator, Anti-Fling threshold, FlingAll")
print("[FONDI MM2] New: SilentAim, Radar, ItemESP, KillFeed, Config save/load")
print("==========================================")
