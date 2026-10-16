--// ============================================================
--  leakD Hub X Banana [BloxFruit]
--  Tema fixo: Banana  |  Tradução PT/EN  |  Webhook System
-- ============================================================

local HUB_NAME   = "Banana Cat HUB [BLOX FRUITS] premium script"
local OPEN_IMAGE = "rbxassetid://13999190543"
local WindUI

-- ============================================================
-- 1. VERIFICAÇÃO 50s -> KICK
--    (Adicione seu loadstring aqui depois)
-- ============================================================
task.delay(50, function()
    if not getgenv().BananaLoaderExecuted then
        game.Players.LocalPlayer:Kick("Execute the main script first, genius.")
    end
end)

-- ============================================================
-- 2. WEBHOOK SYSTEM
-- ============================================================
function SendMessage(url, message)
    local http = game:GetService("HttpService")
    local headers = { ["Content-Type"] = "application/json" }
    local data = { ["content"] = message }
    local body = http:JSONEncode(data)
    pcall(function()
        request({
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = body
        })
    end)
    print("[Webhook] Sent message")
end

function SendMessageEMBED(url, embed)
    local http = game:GetService("HttpService")
    local headers = { ["Content-Type"] = "application/json" }
    local data = {
        ["embeds"] = {
            {
                ["title"]       = embed.title,
                ["description"] = embed.description,
                ["color"]       = embed.color,
                ["fields"]      = embed.fields,
                ["footer"]      = { ["text"] = embed.footer.text }
            }
        }
    }
    local body = http:JSONEncode(data)
    pcall(function()
        request({
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = body
        })
    end)
    print("[Webhook] Sent embed")
end

getgenv().WebhookURL    = getgenv().WebhookURL or ""
getgenv().AutoSendCrash = false
getgenv().AutoSendHop   = false
getgenv().HopTweenKick  = false

local function GetTimeString()
    local t = os.date("*t")
    return string.format("%02d/%02d/%04d %02d:%02d:%02d",
        t.day, t.month, t.year, t.hour, t.min, t.sec)
end

local function GetServerRegion()
    local code = "Unknown"
    pcall(function()
        code = game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(game.Players.LocalPlayer)
    end)
    return tostring(code)
end

local function GetServerAge()
    local secs = math.floor(workspace.DistributedGameTime)
    local h = math.floor(secs / 3600)
    local m = math.floor((secs % 3600) / 60)
    local s = secs % 60
    return string.format("%02dh %02dm %02ds", h, m, s)
end

-- Gera código de verificação
local function GenerateVerifyCode()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local code = "VFY-"
    for i = 1, 8 do
        local idx = math.random(1, #chars)
        code = code .. string.sub(chars, idx, idx)
    end
    return code
end

-- ============================================================
-- 3. HOOK: KICK DETECTION
-- ============================================================
do
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local TeleportService = game:GetService("TeleportService")

    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args   = { ... }

        if tostring(method) == "Kick" and self == LocalPlayer then
            local reason = args[1] or "No reason provided"

            if getgenv().AutoSendCrash and getgenv().WebhookURL ~= "" then
                task.spawn(function()
                    SendMessage(getgenv().WebhookURL,
                        "**Script or Server crashed** - " .. GetTimeString() ..
                        "\n**Error:** " .. tostring(reason) ..
                        "\n**Game ID:** " .. tostring(game.JobId) ..
                        "\n**Server Region:** " .. GetServerRegion())
                end)
            end

            if getgenv().HopTweenKick then
                task.spawn(function()
                    task.wait(0.5)
                    pcall(function()
                        local servers = game:GetService("HttpService"):JSONDecode(
                            game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
                        )
                        if servers and servers.data then
                            for _, srv in ipairs(servers.data) do
                                if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
                                    TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer)
                                    break
                                end
                            end
                        end
                    end)
                end)
            end
        end

        return oldNamecall(self, ...)
    end)

    setreadonly(mt, true)
end

-- ============================================================
-- 4. HOOK: HOP DETECTION
-- ============================================================
do
    local TeleportService = game:GetService("TeleportService")
    local oldTeleport
    if hookfunction then
        oldTeleport = hookfunction(TeleportService.Teleport, function(self, placeId, player, options)
            if getgenv().AutoSendHop and getgenv().WebhookURL ~= "" then
                task.spawn(function()
                    SendMessage(getgenv().WebhookURL,
                        "**Server Hop Detected**" ..
                        "\n**Local Server:** " .. GetServerRegion() ..
                        "\n**ID Game:** " .. tostring(game.JobId) ..
                        "\n**Time Global Server:** " .. GetServerAge())
                end)
            end
            return oldTeleport(self, placeId, player, options)
        end)
    end
end

-- ============================================================
-- 5. CARREGAR WINDUI
-- ============================================================
do
    local ok, res = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if not ok or not res then
        ok, res = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end)
    end
    WindUI = res
end

-- ============================================================
-- 6. SISTEMA DE TRADUÇÃO (ATUALIZADO)
-- ============================================================
local Lang = "pt"

local Translations = {
    pt = {
        -- Tabs
        tab_info="Info e Status", tab_main="Otimização", tab_setting="Configurações",
        tab_fish="Pesca", tab_quests="Quests e Itens", tab_sea="Eventos do Mar",
        tab_race="Mirage e Raça", tab_prehis="Evento Vulcão", tab_esp="Stats e ESP",
        tab_raids="Frutas e Raid", tab_combat="Jogador Local", tab_travel="Teleporte",
        tab_shop="Loja", tab_misc="Diversos",

        -- Sections
        sec_timezone="Fuso Horário", sec_gametime="Horário do Jogo",
        sec_optimize="Otimização de Performance", sec_fps="Controle de FPS",
        sec_config="Configurações", sec_language="Idioma", sec_uiconfig="Personalização da UI",
        sec_webhook="Sistema de Webhook",

        -- Otimização
        lowtex_title="Low Texture / Sem Névoa",
        lowtex_desc="Remove névoa e aplica texturas simples.",
        opt100_title="Otimização 100%",
        opt100_desc="Remove efeitos visuais e otimiza o ambiente.",
        notif_title="Remover Notificações de Dano",
        notif_desc="Remove pop-ups de dano.",

        -- FPS
        fps_input="Valor do FPS (1-590)",
        fps_input_d="Número entre 1 e 590.", fps_input_ph="Ex: 60",
        fps_lock="Travar FPS", fps_lock_d="Trava o FPS no valor acima.",

        -- Config
        save_title="Salvar Configuração", save_desc="Salva as configurações.",
        reset_title="Resetar Configuração", reset_desc="Reseta as configurações.",
        lang_title="Idioma", lang_desc="Escolha o idioma do hub.",
        trans_title="Transparente", keybind_title="Tecla para Abrir UI",

        -- Webhook
        wh_url="URL do Webhook", wh_url_d="Cole aqui o link do webhook do Discord.",
        wh_url_ph="https://discord.com/api/webhooks/...",
        wh_crash="Auto Send Webhook após Crash",
        wh_crash_d="Envia webhook quando o jogo/servidor crashar.",
        wh_hop="Enviar Webhook após Hop",
        wh_hop_d="Envia webhook quando o player trocar de servidor.",
        wh_kick="Hop Tween Kick",
        wh_kick_d="Ao ser kickado do servidor, pula para outro automaticamente.",
        wh_test="Testar Webhook",
        wh_test_d="Envia um código de verificação para testar o webhook.",
        wh_test_sending="Enviando código de verificação...",
        wh_test_success="Webhook respondeu com sucesso! Código:",
        wh_test_nourl="Defina a URL do webhook primeiro!",
        wh_test_fail="Falha ao enviar. Verifique a URL.",

        -- Notificações
        notif_loaded="Hub carregado com sucesso!", notif_saved="Configuração salva!",
        notif_reset="Configuração resetada!", notif_lang="Idioma alterado.",
        notif_fps_ok="FPS definido para", notif_fps_err="Insira um número entre 1 e 590.",
        notif_wh_ok="Webhook URL salva!", notif_wh_err="URL inválida!",
    },
    en = {
        -- Tabs
        tab_info="Info And Status", tab_main="Optimization", tab_setting="Settings",
        tab_fish="Fishing", tab_quests="Quests And Items", tab_sea="Sea Events",
        tab_race="Mirage And Race", tab_prehis="Volcano Event", tab_esp="Stats And ESP",
        tab_raids="Fruits And Raid", tab_combat="Local Player", tab_travel="Teleport",
        tab_shop="Shop", tab_misc="Miscellaneous",

        -- Sections
        sec_timezone="Time Zone", sec_gametime="Game Time",
        sec_optimize="Performance Optimization", sec_fps="FPS Control",
        sec_config="Settings", sec_language="Language", sec_uiconfig="UI Customization",
        sec_webhook="Webhook System",

        -- Optimization
        lowtex_title="Low Texture / No Fog",
        lowtex_desc="Removes fog and applies simple textures.",
        opt100_title="Optimization 100%",
        opt100_desc="Removes visual effects and optimizes the environment.",
        notif_title="Remove Damage Notifications",
        notif_desc="Removes damage pop-ups.",

        -- FPS
        fps_input="FPS Value (1-590)",
        fps_input_d="Number between 1 and 590.", fps_input_ph="Ex: 60",
        fps_lock="Lock FPS", fps_lock_d="Locks FPS at the value above.",

        -- Config
        save_title="Save Configuration", save_desc="Saves current settings.",
        reset_title="Reset Configuration", reset_desc="Resets settings.",
        lang_title="Language", lang_desc="Choose the hub language.",
        trans_title="Transparent", keybind_title="Toggle UI Key",

        -- Webhook
        wh_url="Webhook URL", wh_url_d="Paste your Discord webhook link here.",
        wh_url_ph="https://discord.com/api/webhooks/...",
        wh_crash="Auto Send Webhook after Crash",
        wh_crash_d="Sends webhook when game/server crashes.",
        wh_hop="Send Webhook after Hop",
        wh_hop_d="Sends webhook when player switches server.",
        wh_kick="Hop Tween Kick",
        wh_kick_d="When kicked, automatically hops to another server.",
        wh_test="Test Webhook",
        wh_test_d="Sends a verification code to test the webhook.",
        wh_test_sending="Sending verification code...",
        wh_test_success="Webhook responded successfully! Code:",
        wh_test_nourl="Set the webhook URL first!",
        wh_test_fail="Failed to send. Check the URL.",

        -- Notifications
        notif_loaded="Hub loaded successfully!", notif_saved="Configuration saved!",
        notif_reset="Configuration reset!", notif_lang="Language changed.",
        notif_fps_ok="FPS set to", notif_fps_err="Enter a number between 1 and 590.",
        notif_wh_ok="Webhook URL saved!", notif_wh_err="Invalid URL!",
    }
}

local function T(key)
    local tbl = Translations[Lang] or Translations.en
    return tbl[key] or key
end

-- ============================================================
-- 7. HELPERS
-- ============================================================
local function safe(cb, ...)
    if type(cb) == "function" then
        local args = table.pack(...)
        task.spawn(function()
            pcall(cb, table.unpack(args, 1, args.n))
        end)
    end
end

local function pick(a, b)
    if type(a) == "string" then return a, (b or {}) end
    return nil, (a or {})
end

local tabIcons = {
    ["Info e Status"]="info", ["Info And Status"]="info",
    ["Otimização"]="zap", ["Optimization"]="zap",
    ["Configurações"]="settings", ["Settings"]="settings",
    ["Pesca"]="fish", ["Fishing"]="fish",
    ["Quests e Itens"]="scroll", ["Quests And Items"]="scroll",
    ["Eventos do Mar"]="anchor", ["Sea Events"]="anchor",
    ["Mirage e Raça"]="eye", ["Mirage And Race"]="eye",
    ["Evento Vulcão"]="flame", ["Volcano Event"]="flame",
    ["Stats e ESP"]="activity", ["Stats And ESP"]="activity",
    ["Frutas e Raid"]="apple", ["Fruits And Raid"]="apple",
    ["Jogador Local"]="user", ["Local Player"]="user",
    ["Teleporte"]="map-pin", ["Teleport"]="map-pin",
    ["Loja"]="shopping-cart", ["Shop"]="shopping-cart",
    ["Diversos"]="layout-grid", ["Miscellaneous"]="layout-grid",
}

-- ============================================================
-- 8. TEMA BANANA (fixo)
-- ============================================================
pcall(function()
    WindUI:AddTheme({
        Name        = "Banana",
        Accent      = Color3.fromHex("#FFC81E"),
        Dialog      = Color3.fromHex("#16140C"),
        Outline     = Color3.fromHex("#FFC81E"),
        Text        = Color3.fromHex("#FFF8E1"),
        Placeholder = Color3.fromHex("#9C8F63"),
        Background  = Color3.fromHex("#0E0C07"),
        Button      = Color3.fromHex("#2A2410"),
        Icon        = Color3.fromHex("#FFC81E"),
    })
end)

-- ============================================================
-- 9. WRAPPER DE ELEMENTOS
-- ============================================================
local function makeGroup(tab, name)
    local container = tab
    local okS, sec = pcall(function()
        return tab:Section({ Title = name, Opened = false })
    end)
    if okS and type(sec) == "table" and type(sec.Toggle) == "function" then
        container = sec
    end

    local group = {}

    function group:AddToggle(a, b)
        local _, cfg = pick(a, b)
        local default = cfg.Default and true or false
        local t = container:Toggle({
            Title    = cfg.Text or "Toggle",
            Desc     = cfg.Description,
            Value    = default,
            Callback = function(v) safe(cfg.Callback, v) end,
        })
        if default then safe(cfg.Callback, true) end
        return t
    end

    function group:AddButton(a, b)
        local _, cfg = pick(a, b)
        local fn = cfg.Func or cfg.Callback
        return container:Button({
            Title    = cfg.Text or "Button",
            Desc     = cfg.Description,
            Callback = function() safe(fn) end,
        })
    end

    function group:AddDropdown(a, b)
        local _, cfg = pick(a, b)
        local values = cfg.Values or {}
        local multi  = cfg.Multi and true or false
        local default = cfg.Default
        local initial
        if multi then
            initial = {}
            if type(default) == "table" then
                for k, v in pairs(default) do
                    if type(k) == "string" and v then
                        table.insert(initial, k)
                    elseif type(k) == "number" and type(v) == "string" then
                        table.insert(initial, v)
                    end
                end
            end
        else
            if type(default) == "number" then initial = values[default]
            elseif type(default) == "string" then initial = default
            else initial = values[1] end
        end

        local d = container:Dropdown({
            Title     = cfg.Text or "Dropdown",
            Desc      = cfg.Description,
            Values    = values,
            Value     = initial,
            Multi     = multi,
            AllowNone = multi,
            Callback  = function(v)
                if multi then
                    local map = {}
                    if type(v) == "table" then
                        for k, val in pairs(v) do
                            if type(val) == "string" then map[val] = true
                            elseif type(k) == "string" and val then map[k] = true end
                        end
                    end
                    safe(cfg.Callback, map)
                else
                    if type(v) == "table" then v = v.Title or v[1] end
                    safe(cfg.Callback, v)
                end
            end,
        })

        if multi then
            local map = {}
            for _, k in ipairs(initial) do map[k] = true end
            safe(cfg.Callback, map)
        elseif initial ~= nil then
            safe(cfg.Callback, initial)
        end
        return d
    end

    function group:AddSlider(a, b)
        local _, cfg = pick(a, b)
        local rounding = cfg.Rounding or 0
        local step = rounding > 0 and (1 / (10 ^ rounding)) or 1
        if rounding == 1 then step = 1 end
        local default = cfg.Default or cfg.Min or 0
        local s = container:Slider({
            Title    = cfg.Text or "Slider",
            Desc     = cfg.Description,
            Step     = step,
            Value    = { Min = cfg.Min or 0, Max = cfg.Max or 100, Default = default },
            Callback = function(v) safe(cfg.Callback, v) end,
        })
        safe(cfg.Callback, default)
        return s
    end

    function group:AddInput(a, b)
        local _, cfg = pick(a, b)
        local i = container:Input({
            Title       = cfg.Text or "Input",
            Desc        = cfg.Description,
            Value       = cfg.Default or "",
            Placeholder = cfg.Placeholder or "",
            Callback    = function(v) safe(cfg.Callback, v) end,
        })
        if cfg.Default and cfg.Default ~= "" then safe(cfg.Callback, cfg.Default) end
        return i
    end

    function group:AddLabel(text)
        local p = container:Paragraph({
            Title = (text and text ~= "") and text or " ",
        })
        local label = {}
        function label:SetText(t)
            t = (t and t ~= "") and t or " "
            pcall(function()
                if p.SetTitle then p:SetTitle(t)
                elseif p.SetDesc then p:SetDesc(t) end
            end)
        end
        return label
    end

    function group:AddDivider()
        pcall(function() container:Divider() end)
    end

    return group
end

-- ============================================================
-- 10. WINDOW
-- ============================================================
local function CreateWindow()
    local window
    local ok = pcall(function()
        window = WindUI:CreateWindow({
            Title = HUB_NAME, Icon = OPEN_IMAGE,
            Author = "Blox Fruits  •  by leakD",
            Folder = "leakD_Banana_BloxFruit",
            Size = UDim2.fromOffset(620, 460),
            Theme = "Banana", Transparent = true, Resizable = true,
            SideBarWidth = 190, HideSearchBar = false, ScrollBarEnabled = true,
            User = { Enabled = true, Anonymous = true, Callback = function() end },
            KeySystem = {
                Key = { "1234", "5678" },
                Note = "Example Key System.",
                Thumbnail = { Image = "rbxassetid://", Title = "Thumbnail" },
                URL = "https://discord.gg/exemplo",
                SaveKey = true,
            },
        })
    end)
    if not ok or not window then
        window = WindUI:CreateWindow({
            Title = HUB_NAME, Icon = OPEN_IMAGE,
            Folder = "leakD_Banana_BloxFruit", Theme = "Banana",
        })
    end

    pcall(function()
        window:EditOpenButton({
            Title = "leakD Hub X Banana", Icon = OPEN_IMAGE,
            CornerRadius = UDim.new(0, 16), StrokeThickness = 2,
            Color = ColorSequence.new(Color3.fromHex("#FFC81E"), Color3.fromHex("#FF7A00")),
            OnlyMobile = false, Enabled = true, Draggable = true,
        })
    end)

    pcall(function()
        window:Tag({ Title = "Banana", Color = Color3.fromHex("#FFC81E") })
    end)

    local winObj = {}
    function winObj:AddTab(name)
        local tab
        local okT = pcall(function()
            tab = window:Tab({ Title = name, Icon = tabIcons[name] or "circle" })
        end)
        if not okT or not tab then tab = window:Tab({ Title = name }) end
        local tabObj = {}
        function tabObj:AddLeftGroupbox(n) return makeGroup(tab, n) end
        tabObj.AddRightGroupbox = tabObj.AddLeftGroupbox
        return tabObj
    end
    return winObj
end

-- ============================================================
-- 11. NOTIFY
-- ============================================================
local function Notify(cfg)
    cfg = cfg or {}
    pcall(function()
        WindUI:Notify({
            Title    = HUB_NAME,
            Content  = cfg.Description or cfg.Content or "",
            Icon     = cfg.Icon or OPEN_IMAGE,
            Duration = cfg.Duration or 5,
        })
    end)
end

-- ============================================================
-- 12. BUILD DAS TABS
-- ============================================================
local Window = CreateWindow()

local Tabs = {
    Info        = Window:AddTab(T("tab_info")),
    Main        = Window:AddTab(T("tab_main")),
    Settings    = Window:AddTab(T("tab_setting")),
    Fish        = Window:AddTab(T("tab_fish")),
    Quests      = Window:AddTab(T("tab_quests")),
    SeaEvent    = Window:AddTab(T("tab_sea")),
    Race        = Window:AddTab(T("tab_race")),
    Prehistoric = Window:AddTab(T("tab_prehis")),
    Esp         = Window:AddTab(T("tab_esp")),
    Raids       = Window:AddTab(T("tab_raids")),
    Combat      = Window:AddTab(T("tab_combat")),
    Travel      = Window:AddTab(T("tab_travel")),
    Shop        = Window:AddTab(T("tab_shop")),
    Misc        = Window:AddTab(T("tab_misc")),
}

-- ============================================================
-- 13. ABA INFO
-- ============================================================
local timeLabel = Tabs.Info:AddLeftGroupbox(T("sec_timezone")):AddLabel("Carregando...")
Tabs.Info:AddLeftGroupbox(T("sec_gametime")):AddLabel("Carregando...")

task.spawn(function()
    while task.wait(1) do
        local t = os.date("*t")
        local h = t.hour % 24
        local ampm = h < 12 and "AM" or "PM"
        local str = string.format("%02i:%02i:%02i %s", (h - 1) % 12 + 1, t.min, t.sec, ampm)
        local date = string.format("%02d/%02d/%04d", t.day, t.month, t.year)

        local code = "Unknown"
        pcall(function()
            code = game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(game.Players.LocalPlayer)
        end)

        timeLabel:SetText(date .. " - " .. str .. " [ " .. code .. " ]")
    end
end)

-- ============================================================
-- 14. ABA OTIMIZAÇÃO
-- ============================================================
local optGroup = Tabs.Main:AddLeftGroupbox(T("sec_optimize"))

optGroup:AddToggle({
    Text = T("lowtex_title"), Description = T("lowtex_desc"), Default = false,
    Callback = function(state)
        if state then
            game.Lighting.FogEnd = 9e9
            game.Lighting.FogStart = 0
            game.Lighting.FogColor = Color3.new(0, 0, 0)
            game.Lighting.Brightness = 0.5
            game.Lighting.GlobalShadows = false
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 1
                elseif obj:IsA("BasePart") then
                    obj.Material = Enum.Material.Plastic
                    obj.Reflectance = 0
                end
            end
            for _, plr in pairs(game.Players:GetChildren()) do
                if plr.Character then
                    for _, part in pairs(plr.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Material = Enum.Material.Plastic
                            part.Reflectance = 0
                        end
                    end
                end
            end
            Notify({ Description = T("lowtex_title") .. ": ON", Icon = "check" })
        else
            game.Lighting.FogEnd = 1000
            game.Lighting.FogStart = 0
            game.Lighting.FogColor = Color3.fromRGB(192, 192, 192)
            game.Lighting.Brightness = 2
            game.Lighting.GlobalShadows = true
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0.1
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 0
                end
            end
            Notify({ Description = T("lowtex_title") .. ": OFF", Icon = "x" })
        end
    end,
})

optGroup:AddToggle({
    Text = T("opt100_title"), Description = T("opt100_desc"), Default = false,
    Callback = function(state)
        if state then
            for _, effect in pairs(game.Lighting:GetChildren()) do
                if effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect")
                or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect")
                or effect:IsA("DepthOfFieldEffect") then
                    effect.Enabled = false
                end
            end
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
                settings().Rendering.ShadowSoftness = 0
                settings().Rendering.GlobalShadows = false
            end)
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Lifetime = NumberRange.new(0)
                elseif obj:IsA("Explosion") then
                    obj.BlastPressure = 1
                    obj.BlastRadius = 1
                elseif obj:IsA("Fire") or obj:IsA("SpotLight")
                or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                    obj.Enabled = false
                end
            end
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 0
            end
            Notify({ Description = T("opt100_title") .. ": ON", Icon = "check" })
        else
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
                settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Automatic
            end)
            for _, effect in pairs(game.Lighting:GetChildren()) do
                if effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect")
                or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect")
                or effect:IsA("DepthOfFieldEffect") then
                    effect.Enabled = true
                end
            end
            Notify({ Description = T("opt100_title") .. ": OFF", Icon = "x" })
        end
    end,
})

optGroup:AddToggle({
    Text = T("notif_title"), Description = T("notif_desc"), Default = false,
    Callback = function(state)
        if state then
            getgenv().RemoveNotifications = true
            task.spawn(function()
                while getgenv().RemoveNotifications do
                    pcall(function()
                        local pg = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
                        if pg then
                            for _, gui in pairs(pg:GetChildren()) do
                                if gui.Name == "DamageIndicator" or gui.Name == "Notification" then
                                    gui:Destroy()
                                end
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
            Notify({ Description = T("notif_title") .. ": ON", Icon = "check" })
        else
            getgenv().RemoveNotifications = false
            Notify({ Description = T("notif_title") .. ": OFF", Icon = "x" })
        end
    end,
})

local fpsGroup = Tabs.Main:AddLeftGroupbox(T("sec_fps"))
local fpsValue = 60

fpsGroup:AddInput({
    Text = T("fps_input"), Description = T("fps_input_d"),
    Placeholder = T("fps_input_ph"), Default = "60",
    Callback = function(input)
        local num = tonumber(input)
        if num and num >= 1 and num <= 590 then
            fpsValue = num
            Notify({ Description = T("notif_fps_ok") .. " " .. fpsValue, Icon = "info" })
        else
            Notify({ Description = T("notif_fps_err"), Icon = "alert-triangle" })
        end
    end,
})

fpsGroup:AddToggle({
    Text = T("fps_lock"), Description = T("fps_lock_d"), Default = false,
    Callback = function(state)
        if state then
            getgenv().FPSLocked = true
            task.spawn(function()
                while getgenv().FPSLocked do
                    task.wait(1 / fpsValue)
                end
            end)
            Notify({ Description = T("fps_lock") .. " (" .. fpsValue .. ")", Icon = "lock" })
        else
            getgenv().FPSLocked = false
            Notify({ Description = T("fps_lock") .. " OFF", Icon = "unlock" })
        end
    end,
})

-- ============================================================
-- 15. ABA CONFIGURAÇÕES - WEBHOOK
-- ============================================================
local whGroup = Tabs.Settings:AddLeftGroupbox(T("sec_webhook"))

whGroup:AddInput({
    Text = T("wh_url"), Description = T("wh_url_d"),
    Placeholder = T("wh_url_ph"),
    Default = getgenv().WebhookURL or "",
    Callback = function(v)
        if v and v ~= "" and string.find(v, "https://") then
            getgenv().WebhookURL = v
            Notify({ Description = T("notif_wh_ok"), Icon = "check" })
        elseif v ~= "" then
            Notify({ Description = T("notif_wh_err"), Icon = "alert-triangle" })
        end
    end,
})

whGroup:AddToggle({
    Text = T("wh_crash"), Description = T("wh_crash_d"), Default = false,
    Callback = function(state)
        getgenv().AutoSendCrash = state
        Notify({ Description = T("wh_crash") .. ": " .. tostring(state), Icon = "flag" })
    end,
})

whGroup:AddToggle({
    Text = T("wh_hop"), Description = T("wh_hop_d"), Default = false,
    Callback = function(state)
        getgenv().AutoSendHop = state
        Notify({ Description = T("wh_hop") .. ": " .. tostring(state), Icon = "flag" })
    end,
})

whGroup:AddToggle({
    Text = T("wh_kick"), Description = T("wh_kick_d"), Default = false,
    Callback = function(state)
        getgenv().HopTweenKick = state
        Notify({ Description = T("wh_kick") .. ": " .. tostring(state), Icon = "flag" })
    end,
})

-- ✅ NOVO: BOTÃO TESTAR WEBHOOK
whGroup:AddButton({
    Text = T("wh_test"),
    Description = T("wh_test_d"),
    Func = function()
        if not getgenv().WebhookURL or getgenv().WebhookURL == "" then
            Notify({ Description = T("wh_test_nourl"), Icon = "alert-triangle", Duration = 5 })
            return
        end

        Notify({ Description = T("wh_test_sending"), Icon = "loader", Duration = 3 })

        task.spawn(function()
            local verifyCode = GenerateVerifyCode()
            local success, err = pcall(function()
                local http = game:GetService("HttpService")
                local payload = {
                    ["content"] = "🔔 **Webhook Verification Test**\n" ..
                                  "**Code:** `" .. verifyCode .. "`\n" ..
                                  "**Time:** " .. GetTimeString() .. "\n" ..
                                  "**User:** " .. game.Players.LocalPlayer.Name .. "\n" ..
                                  "**Game ID:** " .. tostring(game.JobId) .. "\n" ..
                                  "**Server Region:** " .. GetServerRegion()
                }
                request({
                    Url = getgenv().WebhookURL,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = http:JSONEncode(payload)
                })
            end)

            if success then
                Notify({
                    Description = T("wh_test_success") .. " " .. verifyCode,
                    Icon = "check-circle",
                    Duration = 6,
                })
            else
                Notify({
                    Description = T("wh_test_fail") .. " (" .. tostring(err) .. ")",
                    Icon = "x-circle",
                    Duration = 6,
                })
            end
        end)
    end,
})

-- ============================================================
-- 16. ABA CONFIGURAÇÕES - IDIOMA / SAVE / RESET / UI
-- ============================================================
local langGroup = Tabs.Settings:AddLeftGroupbox(T("sec_language"))

langGroup:AddDropdown({
    Text = T("lang_title"), Description = T("lang_desc"),
    Values = { "Português", "English" }, Default = "Português",
    Callback = function(v)
        if v == "Português" then Lang = "pt"
        elseif v == "English" then Lang = "en" end
        Notify({ Description = T("notif_lang"), Icon = "languages" })
    end,
})

local cfgGroup = Tabs.Settings:AddLeftGroupbox(T("sec_config"))

cfgGroup:AddButton({
    Text = T("save_title"), Description = T("save_desc"),
    Func = function()
        local success, err = pcall(function()
            local data = {
                Lang = Lang,
                FPSValue = fpsValue,
                WebhookURL = getgenv().WebhookURL,
                AutoSendCrash = getgenv().AutoSendCrash,
                AutoSendHop = getgenv().AutoSendHop,
                HopTweenKick = getgenv().HopTweenKick,
            }
            writefile("leakD_Banana_Config.json", game:GetService("HttpService"):JSONEncode(data))
        end)
        if success then
            Notify({ Description = T("notif_saved"), Icon = "save" })
        else
            Notify({ Description = "Erro: " .. tostring(err), Icon = "alert-triangle" })
        end
    end,
})

cfgGroup:AddButton({
    Text = T("reset_title"), Description = T("reset_desc"),
    Func = function()
        pcall(function()
            if isfile("leakD_Banana_Config.json") then
                delfile("leakD_Banana_Config.json")
            end
        end)
        Lang = "pt"
        getgenv().WebhookURL = ""
        getgenv().AutoSendCrash = false
        getgenv().AutoSendHop = false
        getgenv().HopTweenKick = false
        Notify({ Description = T("notif_reset"), Icon = "rotate-ccw" })
    end,
})

local uiGroup = Tabs.Settings:AddLeftGroupbox(T("sec_uiconfig"))

uiGroup:AddToggle({
    Text = T("trans_title"), Default = false,
    Callback = function(state)
        pcall(function() Window:ToggleTransparency(state) end)
    end,
})

uiGroup:AddToggle({
    Text = "Background Transparent", Default = false,
    Callback = function(state)
        pcall(function() WindUI:GetTransparency(state) end)
    end,
})

-- ============================================================
-- 17. CARREGAR CONFIG SALVA
-- ============================================================
task.spawn(function()
    task.wait(1)
    if isfile and isfile("leakD_Banana_Config.json") then
        local ok, data = pcall(function()
            return readfile("leakD_Banana_Config.json")
        end)
        if ok and data then
            local decoded = game:GetService("HttpService"):JSONDecode(data)
            if decoded.Lang then Lang = decoded.Lang end
            if decoded.FPSValue then fpsValue = decoded.FPSValue end
            if decoded.WebhookURL then getgenv().WebhookURL = decoded.WebhookURL end
            if decoded.AutoSendCrash then getgenv().AutoSendCrash = decoded.AutoSendCrash end
            if decoded.AutoSendHop then getgenv().AutoSendHop = decoded.AutoSendHop end
            if decoded.HopTweenKick then getgenv().HopTweenKick = decoded.HopTweenKick end
        end
    end
end)

-- ============================================================
-- 18. NOTIFY INICIAL
-- ============================================================
task.spawn(function()
    task.wait(2)
    Notify({
        Title = HUB_NAME,
        Description = T("notif_loaded"),
        Icon = "check-circle",
        Duration = 4,
    })
end)

print(":3 hello m.r logs")
