--[[
    ██████████████████████████████████████████
    ██                                      ██
    ██        AngerMOD V-2  |  ROBLOX       ██
    ██     Черно-красный стиль | Delta      ██
    ██                                      ██
    ██████████████████████████████████████████

    УСТАНОВКА:
    1. Загрузи на GitHub как RAW файл
    2. В key.txt (тоже на GitHub или локально) каждая строка = пароль
    3. Выполни через Delta executor

    key.txt пример:
    ANGER-KEY-001
    ANGER-KEY-002
    MYPASSWORD
]]

-- ═══════════════════════════════════════════════
-- СЕРВИСЫ
-- ═══════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")

local LP    = Players.LocalPlayer
local PGui  = LP:WaitForChild("PlayerGui")
local Cam   = workspace.CurrentCamera

-- ═══════════════════════════════════════════════
-- КЛЮЧИ — читаем key.txt
-- ═══════════════════════════════════════════════
local KEYS = {}
local KEY_STATUS = "fallback"

-- Delta хранит файлы в workspace папке executor
-- Пробуем все возможные пути
local KEY_PATHS = {
    "key.txt",
    "AngerMOD/key.txt",
    "scripts/key.txt",
    "delta/key.txt",
}

local function loadKeys()
    KEYS = {}
    for _, path in ipairs(KEY_PATHS) do
        local ok, data = pcall(readfile, path)
        if ok and type(data) == "string" and #data > 0 then
            for line in (data .. "\n"):gmatch("([^\n\r]*)\r?\n") do
                local trimmed = line:match("^%s*(.-)%s*$")
                if #trimmed > 0 then
                    table.insert(KEYS, trimmed)
                end
            end
            if #KEYS > 0 then
                KEY_STATUS = "loaded:" .. path
                return true
            end
        end
    end
    -- Встроенные ключи если файл не найден
    KEYS = {
        "ANGER-KEY-001",
        "ANGER-KEY-002",
        "ANGER-VIP-2025",
        "TESTKEY",
        "RAGE-MOD",
    }
    KEY_STATUS = "fallback"
    return false
end

local KEY_FILE_FOUND = loadKeys()

-- Создаём key.txt если нет
pcall(function()
    if not isfile("key.txt") then
        writefile("key.txt",
            "ANGER-KEY-001\n" ..
            "ANGER-KEY-002\n" ..
            "ANGER-VIP-2025\n" ..
            "TESTKEY\n" ..
            "RAGE-MOD\n"
        )
        loadKeys()
    end
end)

local function checkKey(input)
    local k = (input or ""):match("^%s*(.-)%s*$")
    if #k == 0 then return false end
    for _, v in ipairs(KEYS) do
        if v == k then return true end
    end
    return false
end

-- ═══════════════════════════════════════════════
-- СОСТОЯНИЕ ЧИТОВ
-- ═══════════════════════════════════════════════
local CH = {
    -- AIMBOT
    Aimbot       = false,
    AutoAim      = false,
    SilentAim    = false,
    FOVShow      = false,
    FOVRadius    = 150,
    -- ESP
    ESPBox       = false,
    ESPName      = false,
    ESPHP        = false,
    ESPTracer    = false,
    Radar        = false,
    -- MOVEMENT
    Speed        = false,
    SpeedVal     = 32,
    InfJump      = false,
    NoClip       = false,
    Fly          = false,
    -- MISC
    NoRecoil     = false,
    AntiBan      = true,
    AntiAFK      = true,
    FullBright   = false,
}

-- ═══════════════════════════════════════════════
-- ПЕРЕМЕННЫЕ
-- ═══════════════════════════════════════════════
local LOGGED_IN  = false
local MINIMIZED  = false
local DRAGGING   = false
local DRAG_OFF   = Vector2.zero
local espCache   = {}
local flyVel, flyGyro = nil, nil
local origWS     = 16
local radarPool  = {}
local activeTab  = nil

-- ═══════════════════════════════════════════════
-- ЦВЕТА (чёрный + красный)
-- ═══════════════════════════════════════════════
local R = {
    RED        = Color3.fromRGB(200, 20, 20),
    RED_BRIGHT = Color3.fromRGB(240, 50, 50),
    RED_DARK   = Color3.fromRGB(100, 10, 10),
    BLACK      = Color3.fromRGB(0, 0, 0),
    DARK1      = Color3.fromRGB(8, 8, 8),
    DARK2      = Color3.fromRGB(14, 14, 14),
    DARK3      = Color3.fromRGB(20, 20, 20),
    WHITE      = Color3.fromRGB(230, 230, 230),
    GRAY       = Color3.fromRGB(110, 110, 110),
    GREEN      = Color3.fromRGB(30, 200, 70),
    ON         = Color3.fromRGB(200, 20, 20),
    OFF        = Color3.fromRGB(35, 35, 35),
}

-- ═══════════════════════════════════════════════
-- ВСПОМОГАТЕЛЬНЫЕ
-- ═══════════════════════════════════════════════
local function getChar()  return LP.Character end
local function getHRP()   local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()   local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

local function getEnemies()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(t, p)
        end
    end
    return t
end

local function getNearest()
    local best, bestD = nil, math.huge
    local cx = Cam.ViewportSize.X / 2
    local cy = Cam.ViewportSize.Y / 2
    for _, p in ipairs(getEnemies()) do
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local sp, vis = Cam:WorldToViewportPoint(hrp.Position)
            if vis then
                local d = Vector2.new(sp.X - cx, sp.Y - cy).Magnitude
                if d < CH.FOVRadius and d < bestD then
                    bestD = d; best = p
                end
            end
        end
    end
    return best
end

local function tw(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad), props):Play()
end

-- ═══════════════════════════════════════════════
-- ОЧИСТКА СТАРОГО GUI
-- ═══════════════════════════════════════════════
if PGui:FindFirstChild("AngerMOD") then
    PGui:FindFirstChild("AngerMOD"):Destroy()
end

-- ═══════════════════════════════════════════════
-- КОРЕНЬ GUI
-- ═══════════════════════════════════════════════
local Root = Instance.new("ScreenGui")
Root.Name           = "AngerMOD"
Root.ResetOnSpawn   = false
Root.IgnoreGuiInset = true
Root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Root.Parent         = PGui

-- ═══════════════════════════════════════════════
-- ФОНОВЫЙ ЭКРАН ОШИБКИ
-- ═══════════════════════════════════════════════
local EBG = Instance.new("Frame", Root)
EBG.Size            = UDim2.new(1, 0, 1, 0)
EBG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
EBG.ZIndex          = 1

-- Текст-спам на фоне
local ErrTxt = Instance.new("TextLabel", EBG)
ErrTxt.Size         = UDim2.new(1, 0, 1, 0)
ErrTxt.BackgroundTransparency = 1
ErrTxt.Text         = string.rep(
    "COPY KEY BEFORE OPEN GAME  ERROR!! LOGIN ERROR!!  COPY KEY BEFORE OPEN GAME  ERROR!! LOGIN ERROR!!   ",
    600
)
ErrTxt.TextColor3   = Color3.fromRGB(180, 0, 0)
ErrTxt.TextSize     = 13
ErrTxt.Font         = Enum.Font.Code
ErrTxt.TextWrapped  = true
ErrTxt.TextXAlignment = Enum.TextXAlignment.Left
ErrTxt.TextYAlignment = Enum.TextYAlignment.Top
ErrTxt.ZIndex       = 2

-- Большая надпись
local BigErr = Instance.new("TextLabel", EBG)
BigErr.Size         = UDim2.new(1, 0, 0, 180)
BigErr.Position     = UDim2.new(0, 0, 0.33, 0)
BigErr.BackgroundTransparency = 1
BigErr.Text         = "ERROR LOGIN\nANGERMOD"
BigErr.TextColor3   = Color3.fromRGB(220, 20, 20)
BigErr.TextSize     = 78
BigErr.Font         = Enum.Font.GothamBold
BigErr.TextStrokeColor3 = Color3.fromRGB(100, 0, 0)
BigErr.TextStrokeTransparency = 0.2
BigErr.ZIndex       = 3

-- Пульсация фона
RunService.Heartbeat:Connect(function()
    if not LOGGED_IN then
        local s = math.abs(math.sin(tick() * 2.2))
        BigErr.TextColor3      = Color3.fromRGB(255, 15 + s*35, 15)
        BigErr.TextTransparency = s * 0.28
        ErrTxt.TextTransparency = 0.48 + s * 0.25
    end
end)

-- ═══════════════════════════════════════════════
-- ГЛАВНОЕ ОКНО
-- ═══════════════════════════════════════════════
local WW, WH = 490, 420

local Win = Instance.new("Frame", Root)
Win.Name            = "Win"
Win.Size            = UDim2.new(0, WW, 0, WH)
Win.Position        = UDim2.new(0.5, -WW/2, 0.5, -WH/2)
Win.BackgroundColor3 = R.DARK1
Win.BackgroundTransparency = 0.18
Win.BorderSizePixel = 0
Win.ZIndex          = 10
Win.ClipsDescendants = true
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 6)

local WinStroke = Instance.new("UIStroke", Win)
WinStroke.Color     = R.RED
WinStroke.Thickness = 2

-- ═══════════════════════════════════════════════
-- ТАЙТЛБАР
-- ═══════════════════════════════════════════════
local TBar = Instance.new("Frame", Win)
TBar.Name           = "TBar"
TBar.Size           = UDim2.new(1, 0, 0, 36)
TBar.BackgroundColor3 = R.BLACK
TBar.BackgroundTransparency = 0.05
TBar.BorderSizePixel = 0
TBar.ZIndex         = 11

-- Красная полоска снизу тайтлбара
local TLine = Instance.new("Frame", TBar)
TLine.Size          = UDim2.new(1, 0, 0, 2)
TLine.Position      = UDim2.new(0, 0, 1, -2)
TLine.BackgroundColor3 = R.RED
TLine.BackgroundTransparency = 0.1
TLine.BorderSizePixel = 0
TLine.ZIndex        = 12

-- Кнопка ▼/▶ (свернуть)
local BtnMin = Instance.new("TextButton", TBar)
BtnMin.Size         = UDim2.new(0, 28, 0, 24)
BtnMin.Position     = UDim2.new(0, 5, 0.5, -12)
BtnMin.BackgroundColor3 = R.RED_DARK
BtnMin.BackgroundTransparency = 0
BtnMin.Text         = "▼"
BtnMin.TextColor3   = R.RED_BRIGHT
BtnMin.TextSize     = 12
BtnMin.Font         = Enum.Font.GothamBold
BtnMin.BorderSizePixel = 0
BtnMin.ZIndex       = 13
Instance.new("UICorner", BtnMin).CornerRadius = UDim.new(0, 3)
Instance.new("UIStroke", BtnMin).Color = R.RED

-- Название + FPS
local TitleLbl = Instance.new("TextLabel", TBar)
TitleLbl.Size       = UDim2.new(0, 240, 1, 0)
TitleLbl.Position   = UDim2.new(0, 38, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text       = "▶  AngerMOD V-2  |  ROBLOX"
TitleLbl.TextColor3 = R.RED_BRIGHT
TitleLbl.TextSize   = 12
TitleLbl.Font       = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex     = 13

local FPSLbl = Instance.new("TextLabel", TBar)
FPSLbl.Size         = UDim2.new(0, 80, 1, 0)
FPSLbl.Position     = UDim2.new(1, -114, 0, 0)
FPSLbl.BackgroundTransparency = 1
FPSLbl.Text         = "FPS: --"
FPSLbl.TextColor3   = R.GREEN
FPSLbl.TextSize     = 12
FPSLbl.Font         = Enum.Font.Code
FPSLbl.TextXAlignment = Enum.TextXAlignment.Right
FPSLbl.ZIndex       = 13

-- Кнопка X (закрыть)
local BtnX = Instance.new("TextButton", TBar)
BtnX.Size           = UDim2.new(0, 28, 0, 24)
BtnX.Position       = UDim2.new(1, -33, 0.5, -12)
BtnX.BackgroundColor3 = R.RED
BtnX.BackgroundTransparency = 0
BtnX.Text           = "✕"
BtnX.TextColor3     = Color3.fromRGB(255, 255, 255)
BtnX.TextSize       = 13
BtnX.Font           = Enum.Font.GothamBold
BtnX.BorderSizePixel = 0
BtnX.ZIndex         = 13
Instance.new("UICorner", BtnX).CornerRadius = UDim.new(0, 3)

-- ═══════════════════════════════════════════════
-- ТЕЛО ОКНА
-- ═══════════════════════════════════════════════
local Body = Instance.new("Frame", Win)
Body.Size           = UDim2.new(1, 0, 1, -36)
Body.Position       = UDim2.new(0, 0, 0, 36)
Body.BackgroundTransparency = 1
Body.ZIndex         = 11

-- ═══════════════════════════════════════════════
-- ── LOGIN FRAME ──────────────────────────────
-- ═══════════════════════════════════════════════
local LF = Instance.new("Frame", Body)
LF.Size             = UDim2.new(1, -30, 1, -14)
LF.Position         = UDim2.new(0, 15, 0, 7)
LF.BackgroundTransparency = 1
LF.ZIndex           = 12
LF.Visible          = true

-- "Please PM Admin..."
local L1 = Instance.new("TextLabel", LF)
L1.Size             = UDim2.new(1, 0, 0, 30)
L1.Position         = UDim2.new(0, 0, 0, 5)
L1.BackgroundTransparency = 1
L1.Text             = "Please PM Admin To Order Key"
L1.TextColor3       = R.RED_BRIGHT
L1.TextSize         = 17
L1.Font             = Enum.Font.GothamBold
L1.TextXAlignment   = Enum.TextXAlignment.Left
L1.ZIndex           = 13

local L2 = Instance.new("TextLabel", LF)
L2.Size             = UDim2.new(1, 0, 0, 22)
L2.Position         = UDim2.new(0, 0, 0, 38)
L2.BackgroundTransparency = 1
L2.Text             = "Please Login (Copy Key)"
L2.TextColor3       = R.WHITE
L2.TextSize         = 13
L2.Font             = Enum.Font.Gotham
L2.TextXAlignment   = Enum.TextXAlignment.Left
L2.ZIndex           = 13

-- Поле ввода
local KeyBox = Instance.new("TextBox", LF)
KeyBox.Size         = UDim2.new(1, 0, 0, 40)
KeyBox.Position     = UDim2.new(0, 0, 0, 68)
KeyBox.BackgroundColor3 = R.BLACK
KeyBox.BackgroundTransparency = 0.1
KeyBox.Text         = ""
KeyBox.PlaceholderText = 'loadstring(game:HttpGet("https://raw.github..."))()'
KeyBox.PlaceholderColor3 = R.GRAY
KeyBox.TextColor3   = R.RED_BRIGHT
KeyBox.TextSize     = 12
KeyBox.Font         = Enum.Font.Code
KeyBox.ClearTextOnFocus = false
KeyBox.BorderSizePixel = 0
KeyBox.ZIndex       = 13
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 4)
local KBS = Instance.new("UIStroke", KeyBox)
KBS.Color = R.RED; KBS.Thickness = 1.5; KBS.Transparency = 0.3

-- ENTER LOGIN
local BtnEnter = Instance.new("TextButton", LF)
BtnEnter.Size       = UDim2.new(1, 0, 0, 42)
BtnEnter.Position   = UDim2.new(0, 0, 0, 116)
BtnEnter.BackgroundColor3 = R.RED_DARK
BtnEnter.BackgroundTransparency = 0
BtnEnter.Text       = "ENTER LOGIN"
BtnEnter.TextColor3 = R.RED_BRIGHT
BtnEnter.TextSize   = 15
BtnEnter.Font       = Enum.Font.GothamBold
BtnEnter.BorderSizePixel = 0
BtnEnter.ZIndex     = 13
Instance.new("UICorner", BtnEnter).CornerRadius = UDim.new(0, 4)
local EnterS = Instance.new("UIStroke", BtnEnter)
EnterS.Color = R.RED; EnterS.Thickness = 1.5

-- PASTE KEY
local BtnPaste = Instance.new("TextButton", LF)
BtnPaste.Size       = UDim2.new(1, 0, 0, 38)
BtnPaste.Position   = UDim2.new(0, 0, 0, 164)
BtnPaste.BackgroundColor3 = R.DARK3
BtnPaste.BackgroundTransparency = 0.2
BtnPaste.Text       = "PASTE KEY"
BtnPaste.TextColor3 = R.RED_BRIGHT
BtnPaste.TextSize   = 13
BtnPaste.Font       = Enum.Font.GothamBold
BtnPaste.BorderSizePixel = 0
BtnPaste.ZIndex     = 13
Instance.new("UICorner", BtnPaste).CornerRadius = UDim.new(0, 4)
local PasteS = Instance.new("UIStroke", BtnPaste)
PasteS.Color = R.RED; PasteS.Thickness = 1; PasteS.Transparency = 0.5

-- Статус
local StatusLbl = Instance.new("TextLabel", LF)
StatusLbl.Size      = UDim2.new(1, 0, 0, 28)
StatusLbl.Position  = UDim2.new(0, 0, 0, 210)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text      = KEY_FILE_FOUND
    and ("✔  key.txt загружен  [" .. #KEYS .. " ключей]")
    or  ("⚠  key.txt создан автоматически  [" .. #KEYS .. " ключей]")
StatusLbl.TextColor3 = KEY_FILE_FOUND and R.GREEN or R.RED_BRIGHT
StatusLbl.TextSize  = 12
StatusLbl.Font      = Enum.Font.GothamBold
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.ZIndex    = 13

local VerLbl = Instance.new("TextLabel", LF)
VerLbl.Size         = UDim2.new(1, 0, 0, 18)
VerLbl.Position     = UDim2.new(0, 0, 0, 242)
VerLbl.BackgroundTransparency = 1
VerLbl.Text         = "Game Version : ROBLOX  |  AngerMOD V-2"
VerLbl.TextColor3   = R.GRAY
VerLbl.TextSize     = 11
VerLbl.Font         = Enum.Font.Code
VerLbl.TextXAlignment = Enum.TextXAlignment.Left
VerLbl.ZIndex       = 13

-- ═══════════════════════════════════════════════
-- ── CHEAT MENU ───────────────────────────────
-- ═══════════════════════════════════════════════
local CM = Instance.new("Frame", Body)
CM.Size             = UDim2.new(1, 0, 1, 0)
CM.BackgroundTransparency = 1
CM.ZIndex           = 12
CM.Visible          = false

-- Левая панель табов
local TabP = Instance.new("Frame", CM)
TabP.Size           = UDim2.new(0, 92, 1, -8)
TabP.Position       = UDim2.new(0, 5, 0, 4)
TabP.BackgroundColor3 = R.BLACK
TabP.BackgroundTransparency = 0.1
TabP.BorderSizePixel = 0
TabP.ZIndex         = 13
Instance.new("UICorner", TabP).CornerRadius = UDim.new(0, 5)
local TPS = Instance.new("UIStroke", TabP)
TPS.Color = R.RED; TPS.Thickness = 1.5; TPS.Transparency = 0.5

local TabLayout = Instance.new("UIListLayout", TabP)
TabLayout.Padding   = UDim.new(0, 3)
local TabPad2 = Instance.new("UIPadding", TabP)
TabPad2.PaddingTop  = UDim.new(0, 5)
TabPad2.PaddingLeft = UDim.new(0, 4)
TabPad2.PaddingRight = UDim.new(0, 4)

-- Правая панель
local RightP = Instance.new("Frame", CM)
RightP.Size         = UDim2.new(1, -104, 1, -8)
RightP.Position     = UDim2.new(0, 100, 0, 4)
RightP.BackgroundColor3 = R.BLACK
RightP.BackgroundTransparency = 0.12
RightP.BorderSizePixel = 0
RightP.ZIndex       = 13
Instance.new("UICorner", RightP).CornerRadius = UDim.new(0, 5)
local RPS = Instance.new("UIStroke", RightP)
RPS.Color = R.RED; RPS.Thickness = 1.5; RPS.Transparency = 0.5

-- Скролл
local Scroll = Instance.new("ScrollingFrame", RightP)
Scroll.Size         = UDim2.new(1, -2, 1, -2)
Scroll.Position     = UDim2.new(0, 1, 0, 1)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = R.RED
Scroll.ScrollBarImageTransparency = 0.3
Scroll.BorderSizePixel = 0
Scroll.ZIndex       = 14
Scroll.CanvasSize   = UDim2.new(0, 0, 0, 0)

local ScrLayout = Instance.new("UIListLayout", Scroll)
ScrLayout.Padding   = UDim.new(0, 3)
local ScrPad2 = Instance.new("UIPadding", Scroll)
ScrPad2.PaddingTop  = UDim.new(0, 5)
ScrPad2.PaddingLeft = UDim.new(0, 5)
ScrPad2.PaddingRight = UDim.new(0, 5)
ScrPad2.PaddingBottom = UDim.new(0, 6)

ScrLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, ScrLayout.AbsoluteContentSize.Y + 14)
end)

-- ═══════════════════════════════════════════════
-- ФАБРИКА ВИДЖЕТОВ
-- ═══════════════════════════════════════════════

local function mkSection(txt)
    local f = Instance.new("Frame")
    f.Name          = "section_" .. txt
    f.Size          = UDim2.new(1, -2, 0, 20)
    f.BackgroundTransparency = 1
    f.ZIndex        = 15

    -- Линия
    local line = Instance.new("Frame", f)
    line.Size       = UDim2.new(1, 0, 0, 1)
    line.Position   = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = R.RED_DARK
    line.BackgroundTransparency = 0.2
    line.BorderSizePixel = 0
    line.ZIndex     = 16

    local lbl = Instance.new("TextLabel", f)
    lbl.Size        = UDim2.new(0, 0, 1, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.Position    = UDim2.new(0, 6, 0, 0)
    lbl.BackgroundColor3 = R.DARK1
    lbl.BackgroundTransparency = 0.18
    lbl.Text        = "  " .. txt .. "  "
    lbl.TextColor3  = R.RED_BRIGHT
    lbl.TextSize    = 11
    lbl.Font        = Enum.Font.GothamBold
    lbl.ZIndex      = 17

    return f
end

local function mkToggle(icon, name, desc, key, cb)
    local on = CH[key]

    local row = Instance.new("Frame")
    row.Name        = "toggle_" .. key
    row.Size        = UDim2.new(1, -2, 0, desc and 46 or 34)
    row.BackgroundColor3 = R.DARK2
    row.BackgroundTransparency = 0.25
    row.BorderSizePixel = 0
    row.ZIndex      = 15
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

    local rStr = Instance.new("UIStroke", row)
    rStr.Color = on and R.RED or Color3.fromRGB(35, 35, 35)
    rStr.Thickness = 1
    rStr.Transparency = on and 0.3 or 0.1

    local nLbl = Instance.new("TextLabel", row)
    nLbl.Size       = UDim2.new(1, -68, 0, 18)
    nLbl.Position   = UDim2.new(0, 9, 0, desc and 5 or 8)
    nLbl.BackgroundTransparency = 1
    nLbl.Text       = icon .. "  " .. name
    nLbl.TextColor3 = on and R.RED_BRIGHT or R.WHITE
    nLbl.TextSize   = 13
    nLbl.Font       = Enum.Font.GothamBold
    nLbl.TextXAlignment = Enum.TextXAlignment.Left
    nLbl.ZIndex     = 16

    if desc then
        local dLbl = Instance.new("TextLabel", row)
        dLbl.Size   = UDim2.new(1, -68, 0, 14)
        dLbl.Position = UDim2.new(0, 9, 0, 24)
        dLbl.BackgroundTransparency = 1
        dLbl.Text   = desc
        dLbl.TextColor3 = R.GRAY
        dLbl.TextSize = 10
        dLbl.Font   = Enum.Font.Gotham
        dLbl.TextXAlignment = Enum.TextXAlignment.Left
        dLbl.ZIndex = 16
    end

    local togBtn = Instance.new("TextButton", row)
    togBtn.Size     = UDim2.new(0, 48, 0, 22)
    togBtn.Position = UDim2.new(1, -56, 0.5, -11)
    togBtn.BackgroundColor3 = on and R.ON or R.OFF
    togBtn.BackgroundTransparency = 0.05
    togBtn.Text     = on and "ON" or "OFF"
    togBtn.TextColor3 = on and Color3.fromRGB(255, 255, 255) or R.GRAY
    togBtn.TextSize = 11
    togBtn.Font     = Enum.Font.GothamBold
    togBtn.BorderSizePixel = 0
    togBtn.ZIndex   = 16
    Instance.new("UICorner", togBtn).CornerRadius = UDim.new(0, 3)

    togBtn.MouseButton1Click:Connect(function()
        on         = not on
        CH[key]    = on
        tw(togBtn, {
            BackgroundColor3 = on and R.ON or R.OFF,
            TextColor3 = on and Color3.fromRGB(255,255,255) or R.GRAY,
        })
        togBtn.Text = on and "ON" or "OFF"
        nLbl.TextColor3 = on and R.RED_BRIGHT or R.WHITE
        rStr.Color = on and R.RED or Color3.fromRGB(35,35,35)
        rStr.Transparency = on and 0.3 or 0.1
        if cb then cb(on) end
    end)

    return row
end

local function mkSlider(icon, name, key, minV, maxV, cb)
    local val = CH[key] or minV

    local row = Instance.new("Frame")
    row.Name        = "slider_" .. key
    row.Size        = UDim2.new(1, -2, 0, 54)
    row.BackgroundColor3 = R.DARK2
    row.BackgroundTransparency = 0.25
    row.BorderSizePixel = 0
    row.ZIndex      = 15
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
    local rStr = Instance.new("UIStroke", row)
    rStr.Color = Color3.fromRGB(35,35,35); rStr.Thickness=1; rStr.Transparency=0.1

    local nLbl = Instance.new("TextLabel", row)
    nLbl.Size       = UDim2.new(1, -70, 0, 18)
    nLbl.Position   = UDim2.new(0, 9, 0, 5)
    nLbl.BackgroundTransparency = 1
    nLbl.Text       = icon .. "  " .. name
    nLbl.TextColor3 = R.WHITE
    nLbl.TextSize   = 12
    nLbl.Font       = Enum.Font.GothamBold
    nLbl.TextXAlignment = Enum.TextXAlignment.Left
    nLbl.ZIndex     = 16

    local vLbl = Instance.new("TextLabel", row)
    vLbl.Size       = UDim2.new(0, 55, 0, 18)
    vLbl.Position   = UDim2.new(1, -63, 0, 5)
    vLbl.BackgroundTransparency = 1
    vLbl.Text       = tostring(val)
    vLbl.TextColor3 = R.RED_BRIGHT
    vLbl.TextSize   = 12
    vLbl.Font       = Enum.Font.Code
    vLbl.TextXAlignment = Enum.TextXAlignment.Right
    vLbl.ZIndex     = 16

    local track = Instance.new("Frame", row)
    track.Size      = UDim2.new(1, -18, 0, 5)
    track.Position  = UDim2.new(0, 9, 0, 38)
    track.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    track.BackgroundTransparency = 0.1
    track.BorderSizePixel = 0
    track.ZIndex    = 16
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame", track)
    fill.Size       = UDim2.new((val-minV)/(maxV-minV), 0, 1, 0)
    fill.BackgroundColor3 = R.RED
    fill.BackgroundTransparency = 0.05
    fill.BorderSizePixel = 0
    fill.ZIndex     = 17
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local knob = Instance.new("TextButton", track)
    knob.Size       = UDim2.new(0, 13, 0, 13)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position   = UDim2.new((val-minV)/(maxV-minV), 0, 0.5, 0)
    knob.BackgroundColor3 = R.RED_BRIGHT
    knob.Text       = ""
    knob.BorderSizePixel = 0
    knob.ZIndex     = 18
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0.5, 0)

    local slDragging = false

    local function setSlVal(absX)
        local rel = math.clamp((absX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        val        = math.floor(minV + (maxV - minV) * rel)
        CH[key]    = val
        fill.Size  = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        vLbl.Text  = tostring(val)
        if cb then cb(val) end
    end

    knob.MouseButton1Down:Connect(function() slDragging = true end)
    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            slDragging = true
            setSlVal(inp.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if slDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            setSlVal(inp.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            slDragging = false
        end
    end)

    return row
end

-- ═══════════════════════════════════════════════
-- СИСТЕМА ТАБОВ
-- ═══════════════════════════════════════════════
local TABS = {}  -- TABS[name] = {btn, widgets=[]}

local TAB_LIST = {
    {i="🎯", n="AIMBOT"},
    {i="👁",  n="VISUALS"},
    {i="⚡", n="MOVEMENT"},
    {i="🔧", n="MISC"},
}

for _, def in ipairs(TAB_LIST) do
    local btn = Instance.new("TextButton", TabP)
    btn.Name        = "tab_" .. def.n
    btn.Size        = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = R.DARK3
    btn.BackgroundTransparency = 0.3
    btn.Text        = def.i .. "\n" .. def.n
    btn.TextColor3  = R.GRAY
    btn.TextSize    = 10
    btn.Font        = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.ZIndex      = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    TABS[def.n]     = {btn = btn, widgets = {}}

    btn.MouseButton1Click:Connect(function()
        -- Сбросить все табы
        for tN, tD in pairs(TABS) do
            tD.btn.TextColor3 = R.GRAY
            tD.btn.BackgroundColor3 = R.DARK3
            tD.btn.BackgroundTransparency = 0.3
            local s = tD.btn:FindFirstChildOfClass("UIStroke")
            if s then s:Destroy() end
            for _, w in ipairs(tD.widgets) do
                w.Parent = nil
            end
        end
        -- Активировать нужный
        activeTab = def.n
        btn.TextColor3 = R.RED_BRIGHT
        btn.BackgroundColor3 = R.RED_DARK
        btn.BackgroundTransparency = 0.1
        local ns = Instance.new("UIStroke", btn)
        ns.Color = R.RED; ns.Thickness = 1.5; ns.Transparency = 0.2
        for _, w in ipairs(TABS[def.n].widgets) do
            w.Parent = Scroll
        end
        Scroll.CanvasPosition = Vector2.zero
    end)
end

local function addW(tabName, widget)
    table.insert(TABS[tabName].widgets, widget)
    widget.Parent = nil
end

-- ═══════════════════════════════════════════════
-- ЗАПОЛНЕНИЕ ТАБОВ
-- ═══════════════════════════════════════════════

-- ── AIMBOT ───────────────────────────
addW("AIMBOT", mkSection("AIMBOT"))
addW("AIMBOT", mkToggle("🎯","Aimbot","Мгновенная наводка на ближайшего врага","Aimbot",nil))
addW("AIMBOT", mkToggle("🤖","Auto Aim","Плавная наводка (менее заметна)","AutoAim",nil))
addW("AIMBOT", mkToggle("🔇","Silent Aim","Невидимая коррекция пули","SilentAim",nil))
addW("AIMBOT", mkSection("FOV"))
addW("AIMBOT", mkToggle("⭕","FOV Circle","Круг зоны автоприцела на экране","FOVShow",nil))
addW("AIMBOT", mkSlider("📐","FOV Radius","FOVRadius",30,400,nil))

-- ── VISUALS ──────────────────────────
addW("VISUALS", mkSection("ESP"))
addW("VISUALS", mkToggle("📦","ESP Boxes","Рамка вокруг врагов","ESPBox",function(v)
    if not v then
        for _, e in pairs(espCache) do
            for _, obj in pairs(e) do pcall(function() obj:Destroy() end) end
        end
        espCache = {}
    end
end))
addW("VISUALS", mkToggle("🏷","Names","Имена игроков","ESPName",nil))
addW("VISUALS", mkToggle("🩸","Health","Полоска HP","ESPHP",nil))
addW("VISUALS", mkToggle("📏","Tracers","Линия от низа экрана к врагу","ESPTracer",nil))
addW("VISUALS", mkSection("RADAR"))
addW("VISUALS", mkToggle("📍","Mini Radar","Круглый радар с врагами","Radar",nil))

-- ── MOVEMENT ─────────────────────────
addW("MOVEMENT", mkSection("СКОРОСТЬ"))
addW("MOVEMENT", mkToggle("⚡","Speed Hack","Увеличить скорость ходьбы","Speed",function(v)
    local hum = getHum()
    if not hum then return end
    if v then origWS = hum.WalkSpeed; hum.WalkSpeed = CH.SpeedVal
    else hum.WalkSpeed = origWS end
end))
addW("MOVEMENT", mkSlider("🏃","Walk Speed","SpeedVal",16,250,function(v)
    if CH.Speed then local hum=getHum(); if hum then hum.WalkSpeed=v end end
end))
addW("MOVEMENT", mkSection("ПРЫЖОК / ПОЛЁТ"))
addW("MOVEMENT", mkToggle("🦘","Infinite Jump","Прыгать без ограничений","InfJump",nil))
addW("MOVEMENT", mkToggle("🌀","No Clip","Проходить сквозь стены","NoClip",nil))
addW("MOVEMENT", mkToggle("🦅","Fly Mode","WASD+Space(вверх)+Shift(вниз)","Fly",function(v)
    local hrp = getHRP()
    if not hrp then return end
    if v then
        flyVel = Instance.new("BodyVelocity", hrp)
        flyVel.Velocity  = Vector3.zero
        flyVel.MaxForce  = Vector3.new(1e5,1e5,1e5)
        flyGyro = Instance.new("BodyGyro", hrp)
        flyGyro.D        = 100
        flyGyro.P        = 1e4
        flyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
    else
        if flyVel  then flyVel:Destroy();  flyVel=nil  end
        if flyGyro then flyGyro:Destroy(); flyGyro=nil end
    end
end))

-- ── MISC ─────────────────────────────
addW("MISC", mkSection("ОРУЖИЕ"))
addW("MISC", mkToggle("🔫","No Recoil","Убирает отдачу","NoRecoil",nil))
addW("MISC", mkSection("ЗАЩИТА"))
addW("MISC", mkToggle("🛡","Anti-Ban","Защита от обнаружения","AntiBan",nil))
addW("MISC", mkToggle("💤","Anti-AFK","Авто-движение vs кик","AntiAFK",nil))
addW("MISC", mkSection("ВИЗУАЛ"))
addW("MISC", mkToggle("☀","Full Bright","Максимальная яркость","FullBright",function(v)
    Lighting.Brightness     = v and 10 or 1
    Lighting.GlobalShadows  = not v
    Lighting.FogEnd         = v and 1e6 or 100000
end))
addW("MISC", mkSection("О ПРОГРАММЕ"))

-- Инфо-виджет
local infoW = Instance.new("Frame")
infoW.Name = "info_widget"
infoW.Size = UDim2.new(1, -2, 0, 64)
infoW.BackgroundColor3 = R.DARK2
infoW.BackgroundTransparency = 0.25
infoW.BorderSizePixel = 0
infoW.ZIndex = 15
Instance.new("UICorner", infoW).CornerRadius = UDim.new(0, 4)
local iS = Instance.new("UIStroke", infoW)
iS.Color = R.RED_DARK; iS.Thickness=1; iS.Transparency=0.4

local iLbl = Instance.new("TextLabel", infoW)
iLbl.Size           = UDim2.new(1,-12,1,-8)
iLbl.Position       = UDim2.new(0,6,0,4)
iLbl.BackgroundTransparency = 1
iLbl.Text           = "⚙  AngerMOD V-2  |  ROBLOX\n" ..
                      "👤  " .. LP.Name .. "\n" ..
                      "🔑  key.txt: " .. (KEY_FILE_FOUND and ("✔ [" .. #KEYS .. " ключей]") or "⚠ создан") .. "\n" ..
                      "📁  " .. KEY_STATUS
iLbl.TextColor3     = R.WHITE
iLbl.TextSize       = 11
iLbl.Font           = Enum.Font.Code
iLbl.TextXAlignment = Enum.TextXAlignment.Left
iLbl.TextYAlignment = Enum.TextYAlignment.Top
iLbl.ZIndex         = 16
addW("MISC", infoW)

-- ═══════════════════════════════════════════════
-- ВНЕШНИЕ ЭЛЕМЕНТЫ (поверх всего)
-- ═══════════════════════════════════════════════

-- FOV Circle
local FOVCirc = Instance.new("Frame", Root)
FOVCirc.BackgroundTransparency = 1
FOVCirc.BorderSizePixel = 0
FOVCirc.ZIndex = 20
FOVCirc.Visible = false
Instance.new("UICorner", FOVCirc).CornerRadius = UDim.new(0.5, 0)
local FOVS = Instance.new("UIStroke", FOVCirc)
FOVS.Color = R.RED; FOVS.Thickness = 2; FOVS.Transparency = 0.2

-- Radar
local RadF = Instance.new("Frame", Root)
RadF.Size           = UDim2.new(0, 120, 0, 120)
RadF.Position       = UDim2.new(1, -134, 1, -134)
RadF.BackgroundColor3 = Color3.fromRGB(4, 0, 0)
RadF.BackgroundTransparency = 0.25
RadF.BorderSizePixel = 0
RadF.ZIndex         = 20
RadF.Visible        = false
Instance.new("UICorner", RadF).CornerRadius = UDim.new(0.5, 0)
local RS = Instance.new("UIStroke", RadF)
RS.Color = R.RED; RS.Thickness = 2

-- Крест радара
for _, cfg in ipairs({
    {UDim2.new(0.5,0,0,0), UDim2.new(0,1,1,0)},
    {UDim2.new(0,0,0.5,0), UDim2.new(1,0,0,1)},
}) do
    local l = Instance.new("Frame", RadF)
    l.Position = cfg[1]; l.Size = cfg[2]
    l.BackgroundColor3 = R.RED_DARK
    l.BackgroundTransparency = 0.4
    l.BorderSizePixel = 0
    l.ZIndex = 21
end

local SelfDot = Instance.new("Frame", RadF)
SelfDot.Size        = UDim2.new(0,8,0,8)
SelfDot.Position    = UDim2.new(0.5,-4,0.5,-4)
SelfDot.BackgroundColor3 = R.GREEN
SelfDot.BorderSizePixel = 0
SelfDot.ZIndex      = 23
Instance.new("UICorner", SelfDot).CornerRadius = UDim.new(0.5,0)

-- ═══════════════════════════════════════════════
-- RENDER LOOP
-- ═══════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not LOGGED_IN then return end

    local selfHRP = getHRP()
    local anyESP  = CH.ESPBox or CH.ESPName or CH.ESPHP or CH.ESPTracer

    -- ── ESP ──────────────────────────────────
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        local char = p.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        if not (char and hrp and hum) then
            if espCache[p] then
                for _, v in pairs(espCache[p]) do pcall(function() v:Destroy() end) end
                espCache[p] = nil
            end
            continue
        end

        local sp, vis = Cam:WorldToViewportPoint(hrp.Position)

        if not anyESP then
            if espCache[p] then for _, v in pairs(espCache[p]) do v.Visible = false end end
            continue
        end

        -- Создаём кэш ESP
        if not espCache[p] then
            local e = {}
            e.box = Instance.new("Frame", Root)
            e.box.BackgroundTransparency = 1
            e.box.BorderSizePixel = 0
            e.box.ZIndex = 19
            local bS = Instance.new("UIStroke", e.box)
            bS.Color = R.RED_BRIGHT; bS.Thickness = 1.8

            e.nameL = Instance.new("TextLabel", Root)
            e.nameL.BackgroundTransparency = 1
            e.nameL.TextColor3 = R.RED_BRIGHT
            e.nameL.TextSize = 12
            e.nameL.Font = Enum.Font.GothamBold
            e.nameL.TextStrokeColor3 = R.BLACK
            e.nameL.TextStrokeTransparency = 0
            e.nameL.ZIndex = 19

            e.hpF = Instance.new("Frame", Root)
            e.hpF.BackgroundColor3 = Color3.fromRGB(20,0,0)
            e.hpF.BackgroundTransparency = 0.2
            e.hpF.BorderSizePixel = 0
            e.hpF.ZIndex = 19

            e.hpFill = Instance.new("Frame", e.hpF)
            e.hpFill.BackgroundColor3 = R.RED_BRIGHT
            e.hpFill.BackgroundTransparency = 0.1
            e.hpFill.BorderSizePixel = 0
            e.hpFill.ZIndex = 20

            e.tracer = Instance.new("Frame", Root)
            e.tracer.BackgroundColor3 = R.RED
            e.tracer.BackgroundTransparency = 0.25
            e.tracer.BorderSizePixel = 0
            e.tracer.AnchorPoint = Vector2.new(0.5, 0)
            e.tracer.ZIndex = 18

            espCache[p] = e
        end

        local e = espCache[p]

        if not vis then
            for _, v in pairs(e) do v.Visible = false end
            continue
        end

        local topS = Cam:WorldToViewportPoint(hrp.Position + Vector3.new(0,3.4,0))
        local botS = Cam:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
        local bH   = math.abs(topS.Y - botS.Y)
        local bW   = bH * 0.52
        local bX   = sp.X - bW/2
        local bY   = topS.Y

        e.box.Visible  = CH.ESPBox
        if CH.ESPBox then
            e.box.Size     = UDim2.new(0,bW,0,bH)
            e.box.Position = UDim2.new(0,bX,0,bY)
        end

        e.nameL.Visible = CH.ESPName
        if CH.ESPName then
            e.nameL.Text = p.Name
            e.nameL.Size = UDim2.new(0,bW+20,0,16)
            e.nameL.Position = UDim2.new(0,bX-10,0,bY-17)
        end

        e.hpF.Visible   = CH.ESPHP
        e.hpFill.Visible = CH.ESPHP
        if CH.ESPHP then
            local ratio = math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
            e.hpF.Size      = UDim2.new(0,4,0,bH)
            e.hpF.Position  = UDim2.new(0,bX-7,0,bY)
            e.hpFill.Size   = UDim2.new(1,0,ratio,0)
            e.hpFill.Position = UDim2.new(0,0,1-ratio,0)
            e.hpFill.BackgroundColor3 = Color3.fromRGB(
                math.floor(200 + 55*ratio), math.floor(20*ratio), 20
            )
        end

        e.tracer.Visible = CH.ESPTracer
        if CH.ESPTracer then
            local cx2 = Cam.ViewportSize.X/2
            local cy2 = Cam.ViewportSize.Y
            local dx   = sp.X - cx2
            local dy   = sp.Y - cy2
            local len  = math.sqrt(dx*dx+dy*dy)
            e.tracer.Size     = UDim2.new(0,1,0,len)
            e.tracer.Position = UDim2.new(0,cx2,0,cy2)
            e.tracer.Rotation = math.deg(math.atan2(dy,dx))+90
        end
    end

    -- ── AIMBOT ───────────────────────────────
    if CH.Aimbot or CH.AutoAim then
        local tgt = getNearest()
        if tgt then
            local tHRP = tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart")
            if tHRP then
                local look = CFrame.lookAt(Cam.CFrame.Position, tHRP.Position)
                if CH.Aimbot then
                    Cam.CFrame = look
                else
                    Cam.CFrame = Cam.CFrame:Lerp(look, 0.07)
                end
            end
        end
    end

    -- ── FOV CIRCLE ───────────────────────────
    FOVCirc.Visible = CH.FOVShow
    if CH.FOVShow then
        local r  = CH.FOVRadius
        local cx3 = Cam.ViewportSize.X/2
        local cy3 = Cam.ViewportSize.Y/2
        FOVCirc.Size     = UDim2.new(0,r*2,0,r*2)
        FOVCirc.Position = UDim2.new(0,cx3-r,0,cy3-r)
    end

    -- ── RADAR ────────────────────────────────
    RadF.Visible = CH.Radar
    if CH.Radar and selfHRP then
        for _, d in pairs(radarPool) do d:Destroy() end
        radarPool = {}
        local RANGE = 160
        local HALF  = 58
        for _, p in ipairs(getEnemies()) do
            local hrp2 = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if hrp2 then
                local diff = hrp2.Position - selfHRP.Position
                local rx   = diff:Dot(Cam.CFrame.RightVector)
                local ry   = diff:Dot(Cam.CFrame.LookVector)
                if Vector2.new(rx,ry).Magnitude < RANGE then
                    local d = Instance.new("Frame", RadF)
                    d.Size          = UDim2.new(0,7,0,7)
                    d.AnchorPoint   = Vector2.new(0.5,0.5)
                    d.Position      = UDim2.new(0, HALF + (rx/RANGE)*HALF*0.9, 0, HALF - (ry/RANGE)*HALF*0.9)
                    d.BackgroundColor3 = R.RED_BRIGHT
                    d.BackgroundTransparency = 0
                    d.BorderSizePixel = 0
                    d.ZIndex        = 22
                    Instance.new("UICorner", d).CornerRadius = UDim.new(0.5, 0)
                    table.insert(radarPool, d)
                end
            end
        end
    end

    -- ── NO CLIP ──────────────────────────────
    if CH.NoClip then
        local char = getChar()
        if char then
            for _, p2 in ipairs(char:GetDescendants()) do
                if p2:IsA("BasePart") then p2.CanCollide = false end
            end
        end
    end

    -- ── FLY ──────────────────────────────────
    if CH.Fly and flyVel then
        local dir = Vector3.zero
        local SPD = 70
        local cf  = Cam.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir += cf.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir -= cf.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir -= cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir += cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir += Vector3.yAxis  end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis  end
        flyVel.Velocity  = dir.Magnitude > 0 and (dir.Unit * SPD) or Vector3.zero
        if flyGyro then flyGyro.CFrame = cf end
    end
end)

-- ── INFINITE JUMP ────────────────────────────
UserInputService.JumpRequest:Connect(function()
    if CH.InfJump then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ── ANTI-AFK ─────────────────────────────────
task.spawn(function()
    while true do
        task.wait(55)
        if CH.AntiAFK then
            pcall(function()
                local VU = game:GetService("VirtualUser")
                VU:Button2Down(Vector2.new(0,0), CFrame.new())
                task.wait(0.1)
                VU:Button2Up(Vector2.new(0,0), CFrame.new())
            end)
        end
    end
end)

-- ── RESPAWN ──────────────────────────────────
LP.CharacterAdded:Connect(function(char)
    flyVel = nil; flyGyro = nil
    if CH.Speed then
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then hum.WalkSpeed = CH.SpeedVal end
    end
end)

-- ═══════════════════════════════════════════════
-- FPS СЧЁТЧИК
-- ═══════════════════════════════════════════════
local fC, fT = 0, tick()
RunService.RenderStepped:Connect(function()
    fC += 1
    if tick() - fT >= 0.5 then
        local fps = math.floor(fC / (tick() - fT))
        FPSLbl.Text = "FPS: " .. fps
        FPSLbl.TextColor3 = fps >= 55 and R.GREEN
                         or fps >= 30 and Color3.fromRGB(218,165,32)
                         or             R.RED_BRIGHT
        fC = 0; fT = tick()
    end
end)

-- ═══════════════════════════════════════════════
-- ПЕРЕТАСКИВАНИЕ
-- ═══════════════════════════════════════════════
TBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        DRAGGING = true
        DRAG_OFF = Vector2.new(
            inp.Position.X - Win.AbsolutePosition.X,
            inp.Position.Y - Win.AbsolutePosition.Y
        )
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if DRAGGING and inp.UserInputType == Enum.UserInputType.MouseMovement then
        Win.Position = UDim2.new(0, inp.Position.X - DRAG_OFF.X, 0, inp.Position.Y - DRAG_OFF.Y)
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then DRAGGING = false end
end)

-- ═══════════════════════════════════════════════
-- СВЕРНУТЬ
-- ═══════════════════════════════════════════════
BtnMin.MouseButton1Click:Connect(function()
    MINIMIZED = not MINIMIZED
    BtnMin.Text = MINIMIZED and "▶" or "▼"
    tw(Win, {Size = UDim2.new(0, WW, 0, MINIMIZED and 36 or WH)}, 0.22)
end)

-- ═══════════════════════════════════════════════
-- ЗАКРЫТЬ
-- ═══════════════════════════════════════════════
BtnX.MouseButton1Click:Connect(function()
    local cx = Win.AbsolutePosition.X + WW/2
    local cy = Win.AbsolutePosition.Y + WH/2
    tw(Win, {Size=UDim2.new(0,0,0,0), Position=UDim2.new(0,cx,0,cy)}, 0.18)
    task.delay(0.2, function() Win.Visible = false end)
end)

-- ═══════════════════════════════════════════════
-- ОТКРЫТЬ ТАБ СРАЗУ
-- ═══════════════════════════════════════════════
local function openTab(name)
    for tN, tD in pairs(TABS) do
        tD.btn.TextColor3 = R.GRAY
        tD.btn.BackgroundColor3 = R.DARK3
        tD.btn.BackgroundTransparency = 0.3
        local s = tD.btn:FindFirstChildOfClass("UIStroke")
        if s then s:Destroy() end
        for _, w in ipairs(tD.widgets) do w.Parent = nil end
    end
    activeTab = name
    local btn = TABS[name].btn
    btn.TextColor3 = R.RED_BRIGHT
    btn.BackgroundColor3 = R.RED_DARK
    btn.BackgroundTransparency = 0.1
    local ns = Instance.new("UIStroke", btn)
    ns.Color = R.RED; ns.Thickness = 1.5; ns.Transparency = 0.2
    for _, w in ipairs(TABS[name].widgets) do w.Parent = Scroll end
    Scroll.CanvasPosition = Vector2.zero
end

-- ═══════════════════════════════════════════════
-- ЛОГИН
-- ═══════════════════════════════════════════════
local function shakeWin()
    local orig = Win.Position
    for i = 1, 8 do
        Win.Position = orig + UDim2.new(0, i%2==0 and 9 or -9, 0, 0)
        task.wait(0.033)
    end
    Win.Position = orig
end

local function doLogin()
    -- Перечитываем key.txt при каждой попытке (актуально)
    loadKeys()

    local key = KeyBox.Text:match("^%s*(.-)%s*$")

    if checkKey(key) then
        LOGGED_IN = true
        StatusLbl.TextColor3 = R.GREEN
        StatusLbl.Text = "✔  Доступ открыт!  Привет, " .. LP.Name

        -- Гасим фон
        tw(EBG, {BackgroundTransparency = 1}, 0.6)
        tw(ErrTxt, {TextTransparency = 1}, 0.45)
        tw(BigErr, {TextTransparency = 1}, 0.35)
        task.delay(0.65, function() EBG.Visible = false end)

        -- Открываем меню
        task.delay(0.8, function()
            LF.Visible = false
            CM.Visible = true
            openTab("AIMBOT")
        end)
    else
        StatusLbl.TextColor3 = R.RED_BRIGHT
        StatusLbl.Text = "✖  Key not registered or expired"
        task.spawn(shakeWin)
    end
end

BtnEnter.MouseButton1Click:Connect(doLogin)
KeyBox.FocusLost:Connect(function(enter) if enter then doLogin() end end)

BtnPaste.MouseButton1Click:Connect(function()
    local ok, clip = pcall(getclipboard)
    if ok and type(clip) == "string" and #clip > 0 then
        KeyBox.Text = clip
        StatusLbl.TextColor3 = R.RED_BRIGHT
        StatusLbl.Text = "📋  Ключ вставлен — нажми ENTER LOGIN"
    else
        StatusLbl.TextColor3 = Color3.fromRGB(180,130,0)
        StatusLbl.Text = "⚠  Буфер недоступен — введи ключ вручную"
    end
end)

-- Ховер кнопок
BtnEnter.MouseEnter:Connect(function() tw(BtnEnter, {BackgroundTransparency=0}) end)
BtnEnter.MouseLeave:Connect(function() tw(BtnEnter, {BackgroundTransparency=0.1}) end)
BtnPaste.MouseEnter:Connect(function()  tw(BtnPaste, {BackgroundTransparency=0.05}) end)
BtnPaste.MouseLeave:Connect(function()  tw(BtnPaste, {BackgroundTransparency=0.2}) end)

-- ═══════════════════════════════════════════════
-- ГОТОВО
-- ═══════════════════════════════════════════════
print("[AngerMOD V-2] ✔ Загружен")
print("[AngerMOD V-2] Ключей: " .. #KEYS .. " | Статус: " .. KEY_STATUS)
print("[AngerMOD V-2] Тестовые ключи: ANGER-KEY-001, TESTKEY")
