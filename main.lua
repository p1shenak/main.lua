--[[
    FONDI MM2 V8.0 // ORION UI EDITION
    - Aimbot для Sheriff (видимый, по RMB)
    - Reveal Murderer (уведомление + чат)
    - Auto-Pickup оружия
    - Kill All (только с ножом)
    - Fling (выброс за карту)
    - Anti-Kick уведомление
    - Fly / Noclip / Bhop / Anti-Fling / Kill Aura / Farm
    - ESP / Outline / Tracers / Names / Roles
    - RU/EN
    - UI: Orion Library
]]

--==================================================
-- SERVICES
--==================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local LP = Players.LocalPlayer
local pg = LP:WaitForChild("PlayerGui")

--==================================================
-- ORION UI
--==================================================
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Qanuir/orion-ui/refs/heads/main/source.lua"))()

--==================================================
-- CONFIG
--==================================================
local AUTH_URL = "https://fondi-mm-2-auntification.vercel.app/api/validate"
local GENERATE_URL = "https://fondi-mm-2-auntification.vercel.app/api/generate"
local KEY_FILE = "fondi_key.txt"
local LANG_FILE = "fondi_lang.txt"

local IsAuthenticated = false
local Lang = "ru"
local Settings = {
    ESP = false, Outline = true, Tracers = true, ShowNames = true, ShowRoles = true,
    Fly = false, Noclip = false, Bhop = false, AntiFling = false, FlySpeed = 55,
    Aimbot = false, RevealMurderer = false, AutoPickup = false,
    KillAll = false, KillAuraRange = 15, Farm = false, Notifications = true
}

--==================================================
-- I18N
--==================================================
local I18N = {
    ru = {
        menu = "FONDI MM2", esp = "ESP", outline = "Контур", tracers = "Трассеры",
        names = "Имена", roles = "Роли", fly = "Полёт", noclip = "Noclip",
        bhop = "Bhop", antifling = "Anti-Fling", aimbot = "Aimbot (Sheriff)",
        reveal = "Reveal Murderer", pickup = "Auto-Pickup", killall = "Kill All",
        range = "Радиус Kill Aura", farm = "Farm (Монеты)", notif = "Уведомления",
        langBtn = "EN", keyInput = "Введите ключ", activate = "Активировать",
        checking = "Проверка...", autologin = "Автовход...", accessOk = "Доступ разрешён",
        keyInvalid = "Неверный ключ", keyExpired = "Сессия истекла",
        genKey = "Сгенерировать ключ", gen = "Сгенерировать", genTitle = "Генерация",
        copyKey = "Скопировать ключ", getScript = "Получить скрипт",
        copied = "Скопировано!", linkCopied = "Ссылка скопирована!",
        murderer = "MURDERER", sheriff = "SHERIFF", wasKilled = "был убит",
        becameM = "стал MURDERER", becameS = "стал SHERIFF", noPlayers = "Нет игроков",
        noWeapon = "Нет оружия", flingTarget = "Выбросить игрока",
        flingAll = "Выбросить всех", flingRadius = "Радиус выброса",
        on = "ВКЛ", off = "ВЫКЛ", welcome = "FONDI MM2 Загружен!"
    },
    en = {
        menu = "FONDI MM2", esp = "ESP", outline = "Outline", tracers = "Tracers",
        names = "Names", roles = "Roles", fly = "Fly", noclip = "Noclip",
        bhop = "Bhop", antifling = "Anti-Fling", aimbot = "Aimbot (Sheriff)",
        reveal = "Reveal Murderer", pickup = "Auto-Pickup", killall = "Kill All",
        range = "Kill Aura Range", farm = "Farm (Coins)", notif = "Notifications",
        langBtn = "RU", keyInput = "Enter key", activate = "Activate",
        checking = "Checking...", autologin = "Auto-login...", accessOk = "Access granted",
        keyInvalid = "Invalid key", keyExpired = "Session expired",
        genKey = "Generate key", gen = "Generate", genTitle = "Generation",
        copyKey = "Copy key", getScript = "Get script",
        copied = "Copied!", linkCopied = "Link copied!",
        murderer = "MURDERER", sheriff = "SHERIFF", wasKilled = "was killed",
        becameM = "became MURDERER", becameS = "became SHERIFF", noPlayers = "No players",
        noWeapon = "No weapon", flingTarget = "Fling player",
        flingAll = "Fling all", flingRadius = "Fling radius",
        on = "ON", off = "OFF", welcome = "FONDI MM2 Loaded!"
    }
}
local function T(k) return (I18N[Lang] and I18N[Lang][k]) or k end

--==================================================
-- HTTP / AUTH
--==================================================
local function HttpPost(url, body)
    local json = HttpService:JSONEncode(body)
    local ok, res = pcall(function()
        if request then return request({Url=url, Method="POST", Headers={["Content-Type"]="application/json"}, Body=json}) end
        if syn and syn.request then return syn.request({Url=url, Method="POST", Headers={["Content-Type"]="application/json"}, Body=json}) end
        if http_request then return http_request({Url=url, Method="POST", Headers={["Content-Type"]="application/json"}, Body=json}) end
        error("No HTTP")
    end)
    if not ok or not res then return nil, "HTTP failed" end
    local ok2, data = pcall(function() return HttpService:JSONDecode(res.Body or res) end)
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
    return false, data.reason or T("keyInvalid")
end

local function GenerateKeyRemote(dur)
    local data, err = HttpPost(GENERATE_URL, {duration=dur, userId=tostring(LP.UserId), lang=Lang})
    if not data then return nil, err end
    if data.error then return nil, data.error end
    return data.key, data
end

local function SaveKey(k) pcall(function() if writefile then writefile(KEY_FILE, k) end end) end
local function LoadKey()
    local ok, c = pcall(function()
        if readfile and isfile and isfile(KEY_FILE) then return readfile(KEY_FILE) end
    end)
    if ok and c and c ~= "" then return c end
end
local function ClearKey() pcall(function() if delfile and isfile and isfile(KEY_FILE) then delfile(KEY_FILE) end end) end
local function SaveLang(l) pcall(function() if writefile then writefile(LANG_FILE, l) end end) end
local function LoadLang()
    local ok, c = pcall(function()
        if readfile and isfile and isfile(LANG_FILE) then return readfile(LANG_FILE) end
    end)
    if ok and (c == "ru" or c == "en") then return c end
end

--==================================================
-- NOTIFY (Orion)
--==================================================
local function Notify(title, content, duration)
    OrionLib:MakeNotification({
        Name = tostring(title),
        Content = tostring(content or ""),
        Image = "rbxassetid://4483345998",
        Time = duration or 3
    })
end

--==================================================
-- ROLE
--==================================================
local COLORS = {
    Murderer = Color3.fromRGB(255, 60, 60),
    Sheriff = Color3.fromRGB(60, 140, 255),
    Innocent = Color3.fromRGB(60, 255, 120),
    Dead = Color3.fromRGB(130, 130, 130)
}

local function GetRole(pl)
    if not pl then return "Innocent" end
    local c, b = pl.Character, pl:FindFirstChildOfClass("Backpack")
    local function H(t, n) return t and t:FindFirstChild(n) ~= nil end
    if H(c, "Knife") or H(b, "Knife") then return "Murderer" end
    if H(c, "Gun") or H(b, "Gun") or H(c, "Revolver") or H(b, "Revolver") then return "Sheriff" end
    return "Innocent"
end

--==================================================
-- ESP
--==================================================
local ESPObjects, Connections = {}, {}
local lastRoles = {}

local function RemoveESP(pl)
    local d = ESPObjects[pl]
    if not d then return end
    for _, k in ipairs({"HL","BB","Beam","A0","A1"}) do
        if d[k] then pcall(function() d[k]:Destroy() end) end
    end
    ESPObjects[pl] = nil
end

local function CreateESP(pl)
    if pl == LP or not pl.Parent then return end
    local c = pl.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    RemoveESP(pl)
    local root = c.HumanoidRootPart
    local d = {Char = c, Root = root}

    local hl = Instance.new("Highlight")
    hl.Name = "FondiHL"; hl.Adornee = c
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = 0.78
    hl.Parent = c
    d.HL = hl

    local bb = Instance.new("BillboardGui")
    bb.Name = "FondiBB"; bb.Adornee = root
    bb.Size = UDim2.new(0, 220, 0, 50); bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true; bb.MaxDistance = 10000; bb.Parent = root
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
    lbl.TextStrokeTransparency = 0; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 14
    lbl.Parent = bb
    d.BB = bb; d.Lbl = lbl

    local a1 = Instance.new("Attachment"); a1.Name = "FondiA1"; a1.Parent = root
    d.A1 = a1
    local beam = Instance.new("Beam")
    beam.Name = "FondiBeam"; beam.FaceCamera = true
    beam.Width0 = 0.04; beam.Width1 = 0.04
    beam.Transparency = NumberSequence.new(0.15)
    beam.Attachment1 = a1; beam.Parent = root
    d.Beam = beam

    ESPObjects[pl] = d
end

local function UpdateESP(pl)
    if pl == LP then return end
    local d = ESPObjects[pl]; if not d then return end
    local c = pl.Character
    if not c then RemoveESP(pl); return end
    if d.Char ~= c then CreateESP(pl); return end

    local role = GetRole(pl)
    local rc = COLORS[role] or COLORS.Innocent

    if d.HL and d.HL.Parent then
        d.HL.Adornee = c
        d.HL.Enabled = Settings.ESP
        d.HL.FillColor = rc; d.HL.OutlineColor = rc
        d.HL.OutlineTransparency = Settings.Outline and 0 or 1
    end
    if d.BB and d.BB.Parent and d.Lbl then
        d.BB.Adornee = d.Root
        d.BB.Enabled = Settings.ESP and Settings.ShowNames
        d.Lbl.Text = Settings.ShowRoles and (pl.DisplayName .. "\n" .. role) or pl.DisplayName
        d.Lbl.TextColor3 = rc
    end
    if d.Beam and d.Beam.Parent then
        d.Beam.Enabled = Settings.ESP and Settings.Tracers
        d.Beam.Color = ColorSequence.new(rc)
        if d.A1 and d.A1.Parent ~= d.Root then d.A1.Parent = d.Root end
        d.Beam.Attachment1 = d.A1
        local my = LP.Character
        if my then
            local mr = my:FindFirstChild("HumanoidRootPart")
            if mr then
                if not d.A0 or not d.A0.Parent then
                    local a0 = Instance.new("Attachment"); a0.Name = "FondiA0"; a0.Parent = mr
                    d.A0 = a0
                elseif d.A0.Parent ~= mr then d.A0.Parent = mr end
                d.Beam.Attachment0 = d.A0
            end
        end
    end
end

local function SetupPlayer(pl)
    if pl == LP then return end
    if Connections[pl] then
        for _, c in ipairs(Connections[pl]) do pcall(function() c:Disconnect() end) end
    end
    Connections[pl] = {}

    local ca = pl.CharacterAdded:Connect(function(c)
        RemoveESP(pl)
        c:WaitForChild("HumanoidRootPart", 10)
        task.wait(0.25)
        if pl.Character == c and Settings.ESP then CreateESP(pl) end
    end)
    table.insert(Connections[pl], ca)

    local cr = pl.CharacterRemoving:Connect(function(c)
        local d = ESPObjects[pl]
        if d and d.Char == c then RemoveESP(pl) end
    end)
    table.insert(Connections[pl], cr)

    if pl.Character then
        task.spawn(function()
            local c = pl.Character
            c:WaitForChild("HumanoidRootPart", 5)
            if pl.Character == c and Settings.ESP then task.wait(0.2); CreateESP(pl) end
        end)
    end
end

for _, pl in ipairs(Players:GetPlayers()) do
    if pl ~= LP then SetupPlayer(pl) end
end
Players.PlayerAdded:Connect(SetupPlayer)
Players.PlayerRemoving:Connect(function(pl)
    RemoveESP(pl)
    lastRoles[pl] = nil
    if Connections[pl] then
        for _, c in ipairs(Connections[pl]) do pcall(function() c:Disconnect() end) end
        Connections[pl] = nil
    end
end)

--==================================================
-- REVEAL MURDERER
--==================================================
task.spawn(function()
    while task.wait(0.3) do
        if IsAuthenticated and Settings.RevealMurderer then
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LP then
                    local role = GetRole(pl)
                    local last = lastRoles[pl]
                    if role ~= last then
                        lastRoles[pl] = role
                        if role == "Murderer" and last ~= "Murderer" then
                            Notify(T("murderer"), pl.DisplayName .. " " .. T("becameM"), 4)
                        elseif role == "Sheriff" and last ~= "Sheriff" then
                            Notify(T("sheriff"), pl.DisplayName .. " " .. T("becameS"), 4)
                        end
                    end
                end
            end
        end
    end
end)

--==================================================
-- NOCLIP
--==================================================
local noclipConn = nil
local function StopNoclip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    local c = LP.Character
    if c then
        for _, o in ipairs(c:GetDescendants()) do
            if o:IsA("BasePart") then pcall(function() o.CanCollide = true end) end
        end
    end
end
local function StartNoclip()
    StopNoclip()
    noclipConn = RunService.Stepped:Connect(function()
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
local flyConn, flyActive = nil, false
local function StopFly()
    flyActive = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local c = LP.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then pcall(function() h.PlatformStand = false end) end
    end
end
local function StartFly()
    StopFly()
    flyActive = true
    flyConn = RunService.RenderStepped:Connect(function(dt)
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

--==================================================
-- BHOP
--==================================================
local bhopConn = nil
local function StopBhop()
    if bhopConn then bhopConn:Disconnect(); bhopConn = nil end
end
local function StartBhop()
    StopBhop()
    bhopConn = RunService.Heartbeat:Connect(function()
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
-- ANTI-FLING
--==================================================
local afConn = nil
local function StopAntiFling()
    if afConn then afConn:Disconnect(); afConn = nil end
end
local function StartAntiFling()
    StopAntiFling()
    afConn = RunService.Heartbeat:Connect(function()
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

--==================================================
-- AIMBOT (Sheriff)
--==================================================
local aimbotConn = nil
local function StopAimbot()
    if aimbotConn then aimbotConn:Disconnect(); aimbotConn = nil end
end
local function StartAimbot()
    StopAimbot()
    aimbotConn = RunService.RenderStepped:Connect(function()
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
        if closest then
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, closest.Character.Head.Position), 0.2)
        end
    end)
end

--==================================================
-- AUTO-PICKUP
--==================================================
local pickupConn = nil
local function StopPickup()
    if pickupConn then pickupConn:Disconnect(); pickupConn = nil end
end
local function StartPickup()
    StopPickup()
    pickupConn = RunService.Heartbeat:Connect(function()
        if not IsAuthenticated or not Settings.AutoPickup then return end
        local c = LP.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("gun") or obj.Name:lower():find("revolver") or obj.Name:lower():find("dropped")) then
                if (obj.Position - r.Position).Magnitude < 50 then
                    r.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                end
            end
        end
    end)
end

--==================================================
-- KILL ALL
--==================================================
local killAllConn = nil
local function GetWeapon()
    local c = LP.Character
    if not c then return nil end
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") and (t.Name == "Knife" or t.Name == "Gun" or t.Name == "Revolver") then
            return t
        end
    end
end
local function StopKillAll()
    if killAllConn then killAllConn:Disconnect(); killAllConn = nil end
end
local function StartKillAll()
    StopKillAll()
    killAllConn = RunService.Heartbeat:Connect(function()
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

--==================================================
-- FLING
--==================================================
local function FlingPlayer(target)
    if not target or not target.Character then return end
    local tr = target.Character:FindFirstChild("HumanoidRootPart")
    if not tr then return end
    local bv = Instance.new("BodyVelocity", tr)
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.new(99999, 99999, 99999)
    task.delay(0.15, function() pcall(function() bv:Destroy() end) end)
    Notify("FLING", target.DisplayName, 2)
end

--==================================================
-- FARM (Coins)
--==================================================
local farmConn = nil
local function StopFarm()
    if farmConn then farmConn:Disconnect(); farmConn = nil end
end
local function StartFarm()
    StopFarm()
    farmConn = RunService.Heartbeat:Connect(function()
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
        if closest then
            r.CFrame = CFrame.new(closest.Position + Vector3.new(0, 2, 0))
        end
    end)
end

--==================================================
-- ANTI-KICK WARNING
--==================================================
local oldKick = hookfunction or hookfunc
if oldKick and LP.Kick then
    pcall(function()
        oldKick(LP.Kick, function(self, msg)
            Notify("ANTI-KICK", "Попытка кика: " .. tostring(msg), 10)
            task.wait(0.1)
            return LP.Kick(self, msg)
        end)
    end)
end

--==================================================
-- BUILD UI
--==================================================
local Window = OrionLib:MakeWindow({
    Name = T("menu"),
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "FondiConfig",
    IntroEnabled = true,
    IntroText = "FONDI MM2",
    IntroIcon = "rbxassetid://4483345998"
})

local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})
local CombatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})
local FarmTab = Window:MakeTab({Name = "Farm", Icon = "rbxassetid://4483345998"})
local MiscTab = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://4483345998"})
local SettingsTab = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://4483345998"})

-- MAIN TAB
local MainSec = MainTab:AddSection({Name = "ESP"})
MainSec:AddToggle({Name = T("esp"), Default = false, Flag = "esp", Save = true, Callback = function(v)
    Settings.ESP = v
    if v then for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then CreateESP(p) end end
    else for p, _ in pairs(ESPObjects) do RemoveESP(p) end end
end})
MainSec:AddToggle({Name = T("outline"), Default = true, Flag = "outline", Save = true, Callback = function(v) Settings.Outline = v end})
MainSec:AddToggle({Name = T("tracers"), Default = true, Flag = "tracers", Save = true, Callback = function(v) Settings.Tracers = v end})
MainSec:AddToggle({Name = T("names"), Default = true, Flag = "names", Save = true, Callback = function(v) Settings.ShowNames = v end})
MainSec:AddToggle({Name = T("roles"), Default = true, Flag = "roles", Save = true, Callback = function(v) Settings.ShowRoles = v end})

local MoveSec = MainTab:AddSection({Name = "Movement"})
MoveSec:AddToggle({Name = T("fly"), Default = false, Flag = "fly", Save = true, Callback = function(v) Settings.Fly = v; if v then StartFly() else StopFly() end end})
MoveSec:AddSlider({Name = "Fly Speed", Min = 20, Max = 150, Default = 55, Increment = 5, Flag = "flyspeed", Save = true, Callback = function(v) Settings.FlySpeed = v end})
MoveSec:AddToggle({Name = T("noclip"), Default = false, Flag = "noclip", Save = true, Callback = function(v) Settings.Noclip = v; if v then StartNoclip() else StopNoclip() end end})
MoveSec:AddToggle({Name = T("bhop"), Default = false, Flag = "bhop", Save = true, Callback = function(v) Settings.Bhop = v; if v then StartBhop() else StopBhop() end end})
MoveSec:AddToggle({Name = T("antifling"), Default = false, Flag = "antifling", Save = true, Callback = function(v) Settings.AntiFling = v; if v then StartAntiFling() else StopAntiFling() end end})

-- COMBAT TAB
local CombatSec = CombatTab:AddSection({Name = "Combat"})
CombatSec:AddToggle({Name = T("aimbot"), Default = false, Flag = "aimbot", Save = true, Callback = function(v) Settings.Aimbot = v; if v then StartAimbot() else StopAimbot() end end})
CombatSec:AddToggle({Name = T("killall"), Default = false, Flag = "killall", Save = true, Callback = function(v) Settings.KillAll = v; if v then StartKillAll() else StopKillAll() end end})
CombatSec:AddSlider({Name = T("range"), Min = 5, Max = 50, Default = 15, Increment = 1, Flag = "killrange", Save = true, Callback = function(v) Settings.KillAuraRange = v end})
CombatSec:AddToggle({Name = T("pickup"), Default = false, Flag = "pickup", Save = true, Callback = function(v) Settings.AutoPickup = v; if v then StartPickup() else StopPickup() end end})
CombatSec:AddToggle({Name = T("reveal"), Default = false, Flag = "reveal", Save = true, Callback = function(v) Settings.RevealMurderer = v end})

local FlingSec = CombatTab:AddSection({Name = "FLING"})
local flingDropdown = FlingSec:AddDropdown({
    Name = T("flingTarget"), Default = "None",
    Options = {"None"},
    Flag = "flingtarget", Save = false,
    Callback = function(v) end
})
task.spawn(function()
    while task.wait(3) do
        local opts = {"None"}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then table.insert(opts, p.DisplayName) end
        end
        pcall(function() flingDropdown:Refresh(opts, flingDropdown.Value or "None") end)
    end
end)

FlingSec:AddButton({
    Name = "FLING SELECTED",
    Callback = function()
        local name = flingDropdown.Value
        if name == "None" then Notify("FLING", "Выбери игрока", 2); return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.DisplayName == name then FlingPlayer(p); break end
        end
    end
})

FlingSec:AddButton({
    Name = T("flingAll"),
    Callback = function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then FlingPlayer(p) end
        end
    end
})

-- FARM TAB
local FarmSec = FarmTab:AddSection({Name = "Coins"})
FarmSec:AddToggle({Name = T("farm"), Default = false, Flag = "farm", Save = true, Callback = function(v) Settings.Farm = v; if v then StartFarm() else StopFarm() end end})

-- MISC TAB
local MiscSec = MiscTab:AddSection({Name = "Notifications"})
MiscSec:AddToggle({Name = T("notif"), Default = true, Flag = "notif", Save = true, Callback = function(v) Settings.Notifications = v end})

-- SETTINGS TAB
local SettingsSec = SettingsTab:AddSection({Name = "Language"})
SettingsSec:AddButton({
    Name = "Switch Language / Сменить язык",
    Callback = function()
        Lang = (Lang == "ru") and "en" or "ru"
        SaveLang(Lang)
        Notify("LANG", "Changed to " .. Lang, 2)
        task.wait(0.5)
        Window:Destroy()
        -- перезапуск всего скрипта — просто вызовем loadstring заново
        local src = game:HttpGet("https://raw.githubusercontent.com/p1shenak/main.lua/refs/heads/main/main.lua")
        loadstring(src)()
    end
})

SettingsSec:AddButton({
    Name = "Reset Key (Выйти из сессии)",
    Callback = function()
        ClearKey()
        Notify("SESSION", "Ключ удалён, перезапусти скрипт", 3)
    end
})

OrionLib:Init()

--==================================================
-- HOTKEYS
--==================================================
UIS.InputBegan:Connect(function(input, gp)
    if gp or not IsAuthenticated then return end
    if input.KeyCode == Enum.KeyCode.F then
        Settings.Fly = not Settings.Fly
        if Settings.Fly then StartFly() else StopFly() end
        Notify("FLY", Settings.Fly and T("on") or T("off"), 1.5)
    elseif input.KeyCode == Enum.KeyCode.N then
        Settings.Noclip = not Settings.Noclip
        if Settings.Noclip then StartNoclip() else StopNoclip() end
        Notify("NOCLIP", Settings.Noclip and T("on") or T("off"), 1.5)
    end
end)

--==================================================
-- AUTOLOGIN
--==================================================
task.spawn(function()
    task.wait(1.5)
    local saved = LoadKey()
    if saved then
        local valid = ValidateKey(saved)
        if valid then
            IsAuthenticated = true
            Notify(T("accessOk"), "FONDI MM2", 2)
            return
        end
        ClearKey()
    end

    -- Если нет ключа — показываем окно ввода через Orion (или можно обычным GUI)
    -- Поскольку Orion не умеет в prompt, используем простой GUI
    local sg = Instance.new("ScreenGui", pg)
    sg.Name = "FondiKeyPrompt"
    sg.ResetOnSpawn = false

    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 400, 0, 260)
    frame.Position = UDim2.new(0.5, -200, 0.5, -130)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(124, 58, 237)
    stroke.Thickness = 1.5

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 15)
    title.BackgroundTransparency = 1
    title.Text = T("menu")
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.85, 0, 0, 44)
    box.Position = UDim2.new(0.075, 0, 0, 70)
    box.PlaceholderText = T("keyInput")
    box.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
    box.TextColor3 = Color3.new(1,1,1)
    box.Font = Enum.Font.Code
    box.TextSize = 14
    box.ClearTextOnFocus = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.85, 0, 0, 44)
    btn.Position = UDim2.new(0.075, 0, 0, 130)
    btn.Text = T("activate")
    btn.BackgroundColor3 = Color3.fromRGB(124, 58, 237)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local genBtn = Instance.new("TextButton", frame)
    genBtn.Size = UDim2.new(0.85, 0, 0, 36)
    genBtn.Position = UDim2.new(0.075, 0, 0, 185)
    genBtn.Text = T("genKey")
    genBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
    genBtn.TextColor3 = Color3.new(1,1,1)
    genBtn.Font = Enum.Font.GothamBold
    genBtn.TextSize = 13
    Instance.new("UICorner", genBtn).CornerRadius = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(function()
        if box.Text == "" then return end
        btn.Text = T("checking")
        local valid = ValidateKey(box.Text)
        if valid then
            IsAuthenticated = true
            SaveKey(box.Text)
            sg:Destroy()
            Notify(T("accessOk"), "FONDI MM2", 2)
        else
            box.Text = ""
            box.PlaceholderText = T("keyInvalid")
            btn.Text = T("activate")
        end
    end)

    genBtn.MouseButton1Click:Connect(function()
        genBtn.Text = "..."
        task.spawn(function()
            local key = GenerateKeyRemote("1d")
            if key then box.Text = key; Notify("KEY", T("genTitle"), 2) end
            genBtn.Text = T("genKey")
        end)
    end)
end)

print("==========================================")
print("[FONDI MM2 V8.0] ORION UI READY")
print("[FONDI MM2] Press L to toggle menu")
print("==========================================")
