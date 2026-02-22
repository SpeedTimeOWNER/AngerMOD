--[[
████████████████████████████████████████████████████████
█                                                      █
█           AngerMOD V-2  |  ROBLOX EXECUTOR           █
█                                                      █
████████████████████████████████████████████████████████

  УСТАНОВКА:
  1. Положи key.txt в папку workspace executor'а
     (рядом с .exe файлом, например Synapse/KRNL)
  2. В key.txt каждая строка = один пароль
  3. Запусти скрипт через executor в любой игре Roblox

  ТЕСТОВЫЕ КЛЮЧИ (если key.txt не найден):
     ANGER-2025-ALPHA
     ANGER-VIP-001
     TESTKEY123
]]

-- ════════════════════════════════════════════
--  СЕРВИСЫ
-- ════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Camera           = workspace.CurrentCamera

local LP               = Players.LocalPlayer
local PGui             = LP:WaitForChild("PlayerGui")

-- ════════════════════════════════════════════
--  ЧТЕНИЕ key.txt
-- ════════════════════════════════════════════
local KEYS = {}
local keyFileStatus = "not_found"

local function reloadKeys()
    KEYS = {}
    -- Пробуем разные пути где может лежать key.txt
    local paths = {
        "key.txt",
        "AngerMOD/key.txt",
        "scripts/key.txt",
    }
    for _, path in ipairs(paths) do
        local ok, content = pcall(readfile, path)
        if ok and content and #content > 0 then
            for line in (content .. "\n"):gmatch("([^\r\n]*)\r?\n") do
                line = line:match("^%s*(.-)%s*$")
                if line ~= "" then
                    table.insert(KEYS, line)
                end
            end
            if #KEYS > 0 then
                keyFileStatus = "loaded_" .. path
                return true
            end
        end
    end
    -- Fallback встроенные ключи
    KEYS = {"ANGER-2025-ALPHA", "ANGER-VIP-001", "ANGER-KEY-XYZ", "TESTKEY123", "RAGE-MOD-KEY"}
    keyFileStatus = "fallback"
    return false
end

local keyFileFound = reloadKeys()

local function isValidKey(input)
    local k = (input or ""):match("^%s*(.-)%s*$")
    if k == "" then return false end
    for _, v in ipairs(KEYS) do
        if v == k then return true end
    end
    return false
end

-- ════════════════════════════════════════════
--  СОСТОЯНИЕ ЧИТОВ
-- ════════════════════════════════════════════
local CH = {
    Aimbot        = false,
    AutoAim       = false,
    SilentAim     = false,
    FOVCircle     = false,
    FOVRadius     = 150,

    ESPBoxes      = false,
    ESPNames      = false,
    ESPHealth     = false,
    ESPTracer     = false,
    Radar         = false,

    SpeedHack     = false,
    WalkSpeed     = 32,
    InfJump       = false,
    NoClip        = false,
    Fly           = false,

    NoRecoil      = false,
    AntiBan       = true,
    AntiAFK       = true,
    FullBright    = false,
}

-- ════════════════════════════════════════════
--  ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
-- ════════════════════════════════════════════
local isLoggedIn  = false
local isMinimized = false
local isDragging  = false
local dragOffset  = Vector2.zero

local espCache    = {}     -- espCache[player] = {box, nameLbl, hpBar, hpFill, tracer}
local flyVel      = nil
local flyGyro     = nil
local origSpeed   = 16
local radarDots   = {}

-- ════════════════════════════════════════════
--  УТИЛИТЫ
-- ════════════════════════════════════════════
local function getChar()  return LP.Character end
local function getHRP()   local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()   local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

local function getEnemies()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(list, p)
        end
    end
    return list
end

local function getNearestEnemy()
    local best, bestDist = nil, math.huge
    local cx = Camera.ViewportSize.X/2
    local cy = Camera.ViewportSize.Y/2
    for _, p in ipairs(getEnemies()) do
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local sp, vis = Camera:WorldToViewportPoint(hrp.Position)
            if vis then
                local d = Vector2.new(sp.X - cx, sp.Y - cy).Magnitude
                if d < CH.FOVRadius and d < bestDist then
                    bestDist = d
                    best = p
                end
            end
        end
    end
    return best
end

local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad), props):Play()
end

-- ════════════════════════════════════════════
--  GUI ROOT
-- ════════════════════════════════════════════
if PGui:FindFirstChild("AngerMOD") then PGui:FindFirstChild("AngerMOD"):Destroy() end

local Root = Instance.new("ScreenGui")
Root.Name            = "AngerMOD"
Root.ResetOnSpawn    = false
Root.IgnoreGuiInset  = true
Root.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
Root.Parent          = PGui

-- ════════════════════════════════════════════
--  ФОНОВЫЙ ЭКРАН ОШИБКИ
-- ════════════════════════════════════════════
local EBG = Instance.new("Frame", Root)
EBG.Size              = UDim2.new(1,0,1,0)
EBG.BackgroundColor3  = Color3.fromRGB(0,0,0)
EBG.ZIndex            = 1

local ErrText = Instance.new("TextLabel", EBG)
ErrText.Size          = UDim2.new(1,0,1,0)
ErrText.BackgroundTransparency = 1
ErrText.Text          = string.rep("COPY KEY BEFORE OPEN GAME  ERROR!! LOGIN ERROR!!  COPY KEY BEFORE OPEN GAME  ERROR!! LOGIN ERROR!!   ", 500)
ErrText.TextColor3    = Color3.fromRGB(218,165,32)
ErrText.TextSize      = 13
ErrText.Font          = Enum.Font.Code
ErrText.TextWrapped   = true
ErrText.TextXAlignment = Enum.TextXAlignment.Left
ErrText.TextYAlignment = Enum.TextYAlignment.Top
ErrText.ZIndex        = 2

local BigErr = Instance.new("TextLabel", EBG)
BigErr.Size           = UDim2.new(1,0,0,160)
BigErr.Position       = UDim2.new(0,0,0.35,0)
BigErr.BackgroundTransparency = 1
BigErr.Text           = "ERROR LOGIN\nANGERMOD"
BigErr.TextColor3     = Color3.fromRGB(220,40,40)
BigErr.TextSize       = 74
BigErr.Font           = Enum.Font.GothamBold
BigErr.TextStrokeColor3 = Color3.fromRGB(218,165,32)
BigErr.TextStrokeTransparency = 0.4
BigErr.ZIndex         = 3

-- Пульсация
RunService.Heartbeat:Connect(function()
    if not isLoggedIn then
        local s = math.abs(math.sin(tick() * 2))
        BigErr.TextColor3       = Color3.fromRGB(255, 40+s*70, 40)
        BigErr.TextTransparency = s * 0.3
        ErrText.TextTransparency = 0.5 + s*0.2
    end
end)

-- ════════════════════════════════════════════
--  ГЛАВНОЕ ОКНО  500 × 420
-- ════════════════════════════════════════════
local W, H = 500, 420

local Win = Instance.new("Frame", Root)
Win.Name              = "Win"
Win.Size              = UDim2.new(0,W,0,H)
Win.Position          = UDim2.new(0.5,-W/2,0.5,-H/2)
Win.BackgroundColor3  = Color3.fromRGB(10,10,10)
Win.BackgroundTransparency = 0.22
Win.BorderSizePixel   = 0
Win.ZIndex            = 10
Win.ClipsDescendants  = true
Instance.new("UICorner",Win).CornerRadius = UDim.new(0,6)

local WinStroke = Instance.new("UIStroke",Win)
WinStroke.Color       = Color3.fromRGB(218,165,32)
WinStroke.Thickness   = 1.5

-- ════════════════════════════════════════════
--  TITLEBAR
-- ════════════════════════════════════════════
local TBar = Instance.new("Frame", Win)
TBar.Name             = "TBar"
TBar.Size             = UDim2.new(1,0,0,34)
TBar.BackgroundColor3 = Color3.fromRGB(5,5,5)
TBar.BackgroundTransparency = 0.1
TBar.BorderSizePixel  = 0
TBar.ZIndex           = 11

-- Золотая линия под тайтлбаром
local TLine = Instance.new("Frame", TBar)
TLine.Size            = UDim2.new(1,0,0,1)
TLine.Position        = UDim2.new(0,0,1,-1)
TLine.BackgroundColor3 = Color3.fromRGB(218,165,32)
TLine.BackgroundTransparency = 0.35
TLine.BorderSizePixel = 0
TLine.ZIndex          = 12

-- Кнопка ▼ / ▶
local BtnArrow = Instance.new("TextButton", TBar)
BtnArrow.Size         = UDim2.new(0,26,0,22)
BtnArrow.Position     = UDim2.new(0,5,0.5,-11)
BtnArrow.BackgroundColor3 = Color3.fromRGB(218,165,32)
BtnArrow.BackgroundTransparency = 0
BtnArrow.Text         = "▼"
BtnArrow.TextColor3   = Color3.fromRGB(0,0,0)
BtnArrow.TextSize     = 11
BtnArrow.Font         = Enum.Font.GothamBold
BtnArrow.BorderSizePixel = 0
BtnArrow.ZIndex       = 13
Instance.new("UICorner",BtnArrow).CornerRadius = UDim.new(0,3)

-- Название
local TitleLbl = Instance.new("TextLabel", TBar)
TitleLbl.Size         = UDim2.new(0,260,1,0)
TitleLbl.Position     = UDim2.new(0,36,0,0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text         = "▶  AngerMOD V-2  |  ROBLOX 64BIT"
TitleLbl.TextColor3   = Color3.fromRGB(218,165,32)
TitleLbl.TextSize     = 12
TitleLbl.Font         = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex       = 13

-- FPS
local FPSLbl = Instance.new("TextLabel", TBar)
FPSLbl.Size           = UDim2.new(0,80,1,0)
FPSLbl.Position       = UDim2.new(1,-112,0,0)
FPSLbl.BackgroundTransparency = 1
FPSLbl.Text           = "FPS: --"
FPSLbl.TextColor3     = Color3.fromRGB(30,210,80)
FPSLbl.TextSize       = 12
FPSLbl.Font           = Enum.Font.Code
FPSLbl.TextXAlignment = Enum.TextXAlignment.Right
FPSLbl.ZIndex         = 13

-- Кнопка X
local BtnX = Instance.new("TextButton", TBar)
BtnX.Size             = UDim2.new(0,26,0,22)
BtnX.Position         = UDim2.new(1,-31,0.5,-11)
BtnX.BackgroundColor3 = Color3.fromRGB(180,30,30)
BtnX.BackgroundTransparency = 0.1
BtnX.Text             = "✕"
BtnX.TextColor3       = Color3.fromRGB(255,255,255)
BtnX.TextSize         = 12
BtnX.Font             = Enum.Font.GothamBold
BtnX.BorderSizePixel  = 0
BtnX.ZIndex           = 13
Instance.new("UICorner",BtnX).CornerRadius = UDim.new(0,3)

-- ════════════════════════════════════════════
--  КОНТЕНТ (под тайтлбаром)
-- ════════════════════════════════════════════
local Body = Instance.new("Frame", Win)
Body.Name             = "Body"
Body.Size             = UDim2.new(1,0,1,-34)
Body.Position         = UDim2.new(0,0,0,34)
Body.BackgroundTransparency = 1
Body.ZIndex           = 11

-- ════════════════════════════════════════════
--  LOGIN FRAME
-- ════════════════════════════════════════════
local LoginF = Instance.new("Frame", Body)
LoginF.Size           = UDim2.new(1,-24,1,-10)
LoginF.Position       = UDim2.new(0,12,0,6)
LoginF.BackgroundTransparency = 1
LoginF.ZIndex         = 12
LoginF.Visible        = true

-- Заголовок "Please PM Admin..."
local L1 = Instance.new("TextLabel", LoginF)
L1.Size               = UDim2.new(1,0,0,28)
L1.Position           = UDim2.new(0,0,0,6)
L1.BackgroundTransparency = 1
L1.Text               = "Please PM Admin To Order Key"
L1.TextColor3         = Color3.fromRGB(218,165,32)
L1.TextSize           = 16
L1.Font               = Enum.Font.GothamBold
L1.TextXAlignment     = Enum.TextXAlignment.Left
L1.ZIndex             = 13

local L2 = Instance.new("TextLabel", LoginF)
L2.Size               = UDim2.new(1,0,0,22)
L2.Position           = UDim2.new(0,0,0,38)
L2.BackgroundTransparency = 1
L2.Text               = "Please Login (Copy Key)"
L2.TextColor3         = Color3.fromRGB(200,200,200)
L2.TextSize           = 13
L2.Font               = Enum.Font.Gotham
L2.TextXAlignment     = Enum.TextXAlignment.Left
L2.ZIndex             = 13

-- Поле ввода
local KeyBox = Instance.new("TextBox", LoginF)
KeyBox.Size           = UDim2.new(1,0,0,38)
KeyBox.Position       = UDim2.new(0,0,0,66)
KeyBox.BackgroundColor3 = Color3.fromRGB(4,4,4)
KeyBox.BackgroundTransparency = 0.25
KeyBox.Text           = ""
KeyBox.PlaceholderText = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/..."))()'
KeyBox.PlaceholderColor3 = Color3.fromRGB(80,80,80)
KeyBox.TextColor3     = Color3.fromRGB(218,165,32)
KeyBox.TextSize       = 11
KeyBox.Font           = Enum.Font.Code
KeyBox.ClearTextOnFocus = false
KeyBox.BorderSizePixel = 0
KeyBox.ZIndex         = 13
Instance.new("UICorner",KeyBox).CornerRadius = UDim.new(0,4)
local KBStroke = Instance.new("UIStroke",KeyBox)
KBStroke.Color        = Color3.fromRGB(218,165,32)
KBStroke.Thickness    = 1
KBStroke.Transparency = 0.4

-- ENTER LOGIN
local BtnEnter = Instance.new("TextButton", LoginF)
BtnEnter.Size         = UDim2.new(1,0,0,40)
BtnEnter.Position     = UDim2.new(0,0,0,112)
BtnEnter.BackgroundColor3 = Color3.fromRGB(6,6,6)
BtnEnter.BackgroundTransparency = 0.2
BtnEnter.Text         = "ENTER LOGIN"
BtnEnter.TextColor3   = Color3.fromRGB(218,165,32)
BtnEnter.TextSize     = 14
BtnEnter.Font         = Enum.Font.GothamBold
BtnEnter.BorderSizePixel = 0
BtnEnter.ZIndex       = 13
Instance.new("UICorner",BtnEnter).CornerRadius = UDim.new(0,4)
local EnterStroke = Instance.new("UIStroke",BtnEnter)
EnterStroke.Color     = Color3.fromRGB(218,165,32)
EnterStroke.Thickness = 1.3

-- PASTE KEY
local BtnPaste = Instance.new("TextButton", LoginF)
BtnPaste.Size         = UDim2.new(1,0,0,38)
BtnPaste.Position     = UDim2.new(0,0,0,158)
BtnPaste.BackgroundColor3 = Color3.fromRGB(6,6,6)
BtnPaste.BackgroundTransparency = 0.3
BtnPaste.Text         = "PASTE KEY"
BtnPaste.TextColor3   = Color3.fromRGB(218,165,32)
BtnPaste.TextSize     = 13
BtnPaste.Font         = Enum.Font.GothamBold
BtnPaste.BorderSizePixel = 0
BtnPaste.ZIndex       = 13
Instance.new("UICorner",BtnPaste).CornerRadius = UDim.new(0,4)
local PasteStroke = Instance.new("UIStroke",BtnPaste)
PasteStroke.Color     = Color3.fromRGB(218,165,32)
PasteStroke.Thickness = 1
PasteStroke.Transparency = 0.45

-- Статус
local StatusLbl = Instance.new("TextLabel", LoginF)
StatusLbl.Size        = UDim2.new(1,0,0,26)
StatusLbl.Position    = UDim2.new(0,0,0,204)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text        = keyFileFound
    and ("✔  key.txt загружен  [" .. #KEYS .. " ключей]")
    or  ("⚠  key.txt не найден — используются встроенные ключи (" .. #KEYS .. " шт.)")
StatusLbl.TextColor3  = keyFileFound and Color3.fromRGB(30,210,80) or Color3.fromRGB(218,165,32)
StatusLbl.TextSize    = 12
StatusLbl.Font        = Enum.Font.GothamBold
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.ZIndex      = 13

local VerLbl = Instance.new("TextLabel", LoginF)
VerLbl.Size           = UDim2.new(1,0,0,18)
VerLbl.Position       = UDim2.new(0,0,0,234)
VerLbl.BackgroundTransparency = 1
VerLbl.Text           = "Game Version : ROBLOX  |  AngerMOD V-2"
VerLbl.TextColor3     = Color3.fromRGB(100,100,100)
VerLbl.TextSize       = 11
VerLbl.Font           = Enum.Font.Code
VerLbl.TextXAlignment = Enum.TextXAlignment.Left
VerLbl.ZIndex         = 13

-- ════════════════════════════════════════════
--  CHEAT MENU FRAME
-- ════════════════════════════════════════════
local CheatF = Instance.new("Frame", Body)
CheatF.Size           = UDim2.new(1,0,1,0)
CheatF.BackgroundTransparency = 1
CheatF.ZIndex         = 12
CheatF.Visible        = false

-- ── ЛЕВАЯ ПАНЕЛЬ (ТАБЫ) ──────────────────────
local TabPanel = Instance.new("Frame", CheatF)
TabPanel.Size         = UDim2.new(0,96,1,-8)
TabPanel.Position     = UDim2.new(0,6,0,4)
TabPanel.BackgroundColor3 = Color3.fromRGB(5,5,5)
TabPanel.BackgroundTransparency = 0.25
TabPanel.BorderSizePixel = 0
TabPanel.ZIndex       = 13
Instance.new("UICorner",TabPanel).CornerRadius = UDim.new(0,5)
local TPStroke = Instance.new("UIStroke",TabPanel)
TPStroke.Color        = Color3.fromRGB(218,165,32)
TPStroke.Thickness    = 1
TPStroke.Transparency = 0.65

local TabList = Instance.new("UIListLayout", TabPanel)
TabList.Padding       = UDim.new(0,2)
local TabPad = Instance.new("UIPadding", TabPanel)
TabPad.PaddingTop     = UDim.new(0,4)
TabPad.PaddingLeft    = UDim.new(0,4)
TabPad.PaddingRight   = UDim.new(0,4)

-- ── ПРАВАЯ ПАНЕЛЬ (контент) ──────────────────
local ContentPanel = Instance.new("Frame", CheatF)
ContentPanel.Size     = UDim2.new(1,-110,1,-8)
ContentPanel.Position = UDim2.new(0,106,0,4)
ContentPanel.BackgroundColor3 = Color3.fromRGB(7,7,7)
ContentPanel.BackgroundTransparency = 0.3
ContentPanel.BorderSizePixel = 0
ContentPanel.ZIndex   = 13
Instance.new("UICorner",ContentPanel).CornerRadius = UDim.new(0,5)
local CPStroke = Instance.new("UIStroke",ContentPanel)
CPStroke.Color        = Color3.fromRGB(218,165,32)
CPStroke.Thickness    = 1
CPStroke.Transparency = 0.65

-- Скролл
local Scroll = Instance.new("ScrollingFrame", ContentPanel)
Scroll.Size           = UDim2.new(1,-2,1,-2)
Scroll.Position       = UDim2.new(0,1,0,1)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(218,165,32)
Scroll.ScrollBarImageTransparency = 0.4
Scroll.BorderSizePixel = 0
Scroll.ZIndex         = 14
Scroll.CanvasSize     = UDim2.new(0,0,0,0)

local ScrList = Instance.new("UIListLayout", Scroll)
ScrList.Padding       = UDim.new(0,3)
local ScrPad = Instance.new("UIPadding", Scroll)
ScrPad.PaddingTop     = UDim.new(0,5)
ScrPad.PaddingLeft    = UDim.new(0,5)
ScrPad.PaddingRight   = UDim.new(0,5)
ScrPad.PaddingBottom  = UDim.new(0,6)

ScrList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0,0,0,ScrList.AbsoluteContentSize.Y + 14)
end)

-- ════════════════════════════════════════════
--  ФАБРИКА ВИДЖЕТОВ
-- ════════════════════════════════════════════

-- Заголовок секции
local function mkSection(txt)
    local f = Instance.new("Frame")
    f.Size              = UDim2.new(1,-2,0,18)
    f.BackgroundTransparency = 1
    f.ZIndex            = 15
    local l = Instance.new("TextLabel",f)
    l.Size              = UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 1
    l.Text              = "── " .. txt .. " ──"
    l.TextColor3        = Color3.fromRGB(218,165,32)
    l.TextSize          = 11
    l.Font              = Enum.Font.GothamBold
    l.TextXAlignment    = Enum.TextXAlignment.Left
    l.ZIndex            = 16
    return f
end

-- Тогл с подписью и колбэком
local function mkToggle(icon, name, desc, key, cb)
    local on = CH[key]

    local row = Instance.new("Frame")
    row.Size            = UDim2.new(1,-2,0, desc and 44 or 32)
    row.BackgroundColor3 = Color3.fromRGB(12,12,12)
    row.BackgroundTransparency = 0.35
    row.BorderSizePixel = 0
    row.ZIndex          = 15
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,4)
    local rStr = Instance.new("UIStroke",row)
    rStr.Color          = Color3.fromRGB(218,165,32)
    rStr.Thickness      = 0.6
    rStr.Transparency   = 0.78

    local nameLbl = Instance.new("TextLabel",row)
    nameLbl.Size        = UDim2.new(1,-68,0,18)
    nameLbl.Position    = UDim2.new(0,8,0,desc and 4 or 7)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text        = icon .. "  " .. name
    nameLbl.TextColor3  = on and Color3.fromRGB(218,165,32) or Color3.fromRGB(210,210,210)
    nameLbl.TextSize    = 13
    nameLbl.Font        = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex      = 16

    if desc then
        local dLbl = Instance.new("TextLabel",row)
        dLbl.Size       = UDim2.new(1,-68,0,14)
        dLbl.Position   = UDim2.new(0,8,0,22)
        dLbl.BackgroundTransparency = 1
        dLbl.Text       = desc
        dLbl.TextColor3 = Color3.fromRGB(100,100,100)
        dLbl.TextSize   = 10
        dLbl.Font       = Enum.Font.Gotham
        dLbl.TextXAlignment = Enum.TextXAlignment.Left
        dLbl.ZIndex     = 16
    end

    local btn = Instance.new("TextButton",row)
    btn.Size            = UDim2.new(0,50,0,20)
    btn.Position        = UDim2.new(1,-58,0.5,-10)
    btn.BackgroundColor3 = on and Color3.fromRGB(218,165,32) or Color3.fromRGB(40,40,40)
    btn.BackgroundTransparency = 0.1
    btn.Text            = on and "ON" or "OFF"
    btn.TextColor3      = on and Color3.fromRGB(0,0,0) or Color3.fromRGB(110,110,110)
    btn.TextSize        = 11
    btn.Font            = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.ZIndex          = 16
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,3)
    local bStr = Instance.new("UIStroke",btn)
    bStr.Color          = Color3.fromRGB(218,165,32)
    bStr.Thickness      = 0.8
    bStr.Transparency   = 0.5

    btn.MouseButton1Click:Connect(function()
        on         = not on
        CH[key]    = on
        tween(btn, {
            BackgroundColor3 = on and Color3.fromRGB(218,165,32) or Color3.fromRGB(40,40,40),
            TextColor3       = on and Color3.fromRGB(0,0,0) or Color3.fromRGB(110,110,110),
        })
        btn.Text        = on and "ON" or "OFF"
        nameLbl.TextColor3 = on and Color3.fromRGB(218,165,32) or Color3.fromRGB(210,210,210)
        if cb then cb(on) end
    end)

    return row
end

-- Слайдер
local function mkSlider(icon, name, key, minV, maxV, cb)
    local val = CH[key] or minV

    local row = Instance.new("Frame")
    row.Size            = UDim2.new(1,-2,0,52)
    row.BackgroundColor3 = Color3.fromRGB(12,12,12)
    row.BackgroundTransparency = 0.35
    row.BorderSizePixel = 0
    row.ZIndex          = 15
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,4)
    local rStr = Instance.new("UIStroke",row)
    rStr.Color          = Color3.fromRGB(218,165,32)
    rStr.Thickness      = 0.6
    rStr.Transparency   = 0.78

    local nameLbl = Instance.new("TextLabel",row)
    nameLbl.Size        = UDim2.new(1,-70,0,18)
    nameLbl.Position    = UDim2.new(0,8,0,5)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text        = icon .. "  " .. name
    nameLbl.TextColor3  = Color3.fromRGB(210,210,210)
    nameLbl.TextSize    = 12
    nameLbl.Font        = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex      = 16

    local valLbl = Instance.new("TextLabel",row)
    valLbl.Size         = UDim2.new(0,60,0,18)
    valLbl.Position     = UDim2.new(1,-66,0,5)
    valLbl.BackgroundTransparency = 1
    valLbl.Text         = tostring(val)
    valLbl.TextColor3   = Color3.fromRGB(218,165,32)
    valLbl.TextSize     = 12
    valLbl.Font         = Enum.Font.Code
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex       = 16

    local track = Instance.new("Frame",row)
    track.Size          = UDim2.new(1,-16,0,5)
    track.Position      = UDim2.new(0,8,0,36)
    track.BackgroundColor3 = Color3.fromRGB(35,35,35)
    track.BackgroundTransparency = 0.2
    track.BorderSizePixel = 0
    track.ZIndex        = 16
    Instance.new("UICorner",track).CornerRadius = UDim.new(0,3)

    local fill = Instance.new("Frame",track)
    fill.Size           = UDim2.new((val-minV)/(maxV-minV),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(218,165,32)
    fill.BackgroundTransparency = 0.05
    fill.BorderSizePixel = 0
    fill.ZIndex         = 17
    Instance.new("UICorner",fill).CornerRadius = UDim.new(0,3)

    local knob = Instance.new("TextButton",track)
    knob.Size           = UDim2.new(0,11,0,11)
    knob.AnchorPoint    = Vector2.new(0.5,0.5)
    knob.Position       = UDim2.new((val-minV)/(maxV-minV),0,0.5,0)
    knob.BackgroundColor3 = Color3.fromRGB(218,165,32)
    knob.Text           = ""
    knob.BorderSizePixel = 0
    knob.ZIndex         = 18
    Instance.new("UICorner",knob).CornerRadius = UDim.new(0.5,0)

    local dragging = false

    local function setVal(absX)
        local rel = math.clamp((absX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        val             = math.floor(minV + (maxV-minV)*rel)
        CH[key]         = val
        fill.Size       = UDim2.new(rel,0,1,0)
        knob.Position   = UDim2.new(rel,0,0.5,0)
        valLbl.Text     = tostring(val)
        if cb then cb(val) end
    end

    knob.MouseButton1Down:Connect(function() dragging = true end)
    track.MouseButton1Down:Connect(function() dragging = true end)

    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            setVal(inp.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return row
end

-- ════════════════════════════════════════════
--  СИСТЕМА ТАБОВ
-- ════════════════════════════════════════════
local tabs     = {}   -- tabs[name] = {btn, widgets={}}
local activeTab = nil

local TAB_DEFS = {
    {icon="🎯", name="AIMBOT"},
    {icon="👁",  name="VISUALS"},
    {icon="⚡", name="MOVEMENT"},
    {icon="🔧", name="MISC"},
}

for _, def in ipairs(TAB_DEFS) do
    -- Кнопка таба
    local btn = Instance.new("TextButton", TabPanel)
    btn.Size            = UDim2.new(1,0,0,38)
    btn.BackgroundColor3 = Color3.fromRGB(12,12,12)
    btn.BackgroundTransparency = 0.3
    btn.Text            = def.icon .. "\n" .. def.name
    btn.TextColor3      = Color3.fromRGB(100,100,100)
    btn.TextSize        = 10
    btn.Font            = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.ZIndex          = 14
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,4)

    tabs[def.name] = {btn=btn, widgets={}}

    btn.MouseButton1Click:Connect(function()
        -- Деактивируем все
        for tname, tdata in pairs(tabs) do
            tdata.btn.TextColor3 = Color3.fromRGB(100,100,100)
            tween(tdata.btn, {BackgroundTransparency=0.3, BackgroundColor3=Color3.fromRGB(12,12,12)})
            local s = tdata.btn:FindFirstChildOfClass("UIStroke")
            if s then s:Destroy() end
            for _, w in ipairs(tdata.widgets) do w.Parent = nil end
        end
        -- Активируем нужный
        activeTab = def.name
        btn.TextColor3 = Color3.fromRGB(218,165,32)
        tween(btn, {BackgroundTransparency=0.1, BackgroundColor3=Color3.fromRGB(22,17,3)})
        local ns = Instance.new("UIStroke",btn)
        ns.Color = Color3.fromRGB(218,165,32); ns.Thickness=1; ns.Transparency=0.35
        for _, w in ipairs(tabs[def.name].widgets) do
            w.Parent = Scroll
        end
        Scroll.CanvasPosition = Vector2.zero
    end)
end

local function addWidget(tabName, widget)
    table.insert(tabs[tabName].widgets, widget)
    widget.Parent = nil  -- скрыто пока не активен таб
end

-- ════════════════════════════════════════════
--  ЗАПОЛНЕНИЕ ТАБОВ
-- ════════════════════════════════════════════

-- ── AIMBOT ──────────────────────────────────
addWidget("AIMBOT", mkSection("AIMBOT"))
addWidget("AIMBOT", mkToggle("🎯","Aimbot","Жёсткая мгновенная наводка на ближайшего врага","Aimbot",nil))
addWidget("AIMBOT", mkToggle("🤖","Auto Aim","Плавная наводка камеры при стрельбе","AutoAim",nil))
addWidget("AIMBOT", mkToggle("🔇","Silent Aim","Пуля летит в врага без видимого поворота","SilentAim",nil))
addWidget("AIMBOT", mkSection("FOV"))
addWidget("AIMBOT", mkToggle("⭕","FOV Circle","Показывает круг зоны автоприцела","FOVCircle",nil))
addWidget("AIMBOT", mkSlider("📐","FOV Radius","FOVRadius",30,400,nil))

-- ── VISUALS ─────────────────────────────────
addWidget("VISUALS", mkSection("ESP"))
addWidget("VISUALS", mkToggle("📦","ESP Boxes","Золотая рамка вокруг врагов","ESPBoxes",function(v)
    if not v then
        for _, obj in pairs(espCache) do
            for _, item in pairs(obj) do pcall(function() item:Destroy() end) end
        end
        espCache = {}
    end
end))
addWidget("VISUALS", mkToggle("🏷","Enemy Names","Имена игроков над рамкой","ESPNames",nil))
addWidget("VISUALS", mkToggle("🩸","Health Bar","Полоска HP слева от рамки","ESPHealth",nil))
addWidget("VISUALS", mkToggle("📏","Tracers","Линия от низа экрана к врагу","ESPTracer",nil))
addWidget("VISUALS", mkSection("RADAR"))
addWidget("VISUALS", mkToggle("📍","Mini Radar","Круглый радар с точками врагов","Radar",nil))

-- ── MOVEMENT ────────────────────────────────
addWidget("MOVEMENT", mkSection("СКОРОСТЬ"))
addWidget("MOVEMENT", mkToggle("⚡","Speed Hack","Повышенная скорость персонажа","SpeedHack",function(v)
    local hum = getHum()
    if not hum then return end
    if v then origSpeed=hum.WalkSpeed; hum.WalkSpeed=CH.WalkSpeed
    else hum.WalkSpeed=origSpeed end
end))
addWidget("MOVEMENT", mkSlider("🏃","Walk Speed","WalkSpeed",16,250,function(v)
    if CH.SpeedHack then local hum=getHum(); if hum then hum.WalkSpeed=v end end
end))
addWidget("MOVEMENT", mkSection("ПРЫЖОК / ПОЛЁТ"))
addWidget("MOVEMENT", mkToggle("🦘","Infinite Jump","Прыгать без ограничений","InfJump",nil))
addWidget("MOVEMENT", mkToggle("🌀","No Clip","Проходить сквозь стены","NoClip",nil))
addWidget("MOVEMENT", mkToggle("🦅","Fly Mode","WASD = направление | Space = вверх | Shift = вниз","Fly",function(v)
    local hrp = getHRP()
    if not hrp then return end
    if v then
        flyVel = Instance.new("BodyVelocity",hrp)
        flyVel.Velocity   = Vector3.zero
        flyVel.MaxForce   = Vector3.new(1e5,1e5,1e5)
        flyGyro = Instance.new("BodyGyro",hrp)
        flyGyro.D         = 100
        flyGyro.P         = 1e4
        flyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
    else
        if flyVel  then flyVel:Destroy();  flyVel=nil end
        if flyGyro then flyGyro:Destroy(); flyGyro=nil end
    end
end))

-- ── MISC ────────────────────────────────────
addWidget("MISC", mkSection("ОРУЖИЕ"))
addWidget("MISC", mkToggle("🔫","No Recoil","Убирает отдачу при стрельбе","NoRecoil",nil))
addWidget("MISC", mkSection("ЗАЩИТА"))
addWidget("MISC", mkToggle("🛡","Anti-Ban","Базовая защита от обнаружения","AntiBan",nil))
addWidget("MISC", mkToggle("💤","Anti-AFK","Предотвращает кик за AFK","AntiAFK",nil))
addWidget("MISC", mkSection("ВИЗУАЛ"))
addWidget("MISC", mkToggle("☀","Full Bright","Максимальная яркость окружения","FullBright",function(v)
    local lighting = game:GetService("Lighting")
    lighting.Brightness = v and 10 or 1
    lighting.GlobalShadows = not v
end))
addWidget("MISC", mkSection("ИНФОРМАЦИЯ"))

local infoRow = Instance.new("Frame")
infoRow.Size            = UDim2.new(1,-2,0,58)
infoRow.BackgroundColor3 = Color3.fromRGB(12,12,12)
infoRow.BackgroundTransparency = 0.35
infoRow.BorderSizePixel = 0
infoRow.ZIndex          = 15
Instance.new("UICorner",infoRow).CornerRadius = UDim.new(0,4)
local iStr = Instance.new("UIStroke",infoRow)
iStr.Color=Color3.fromRGB(218,165,32); iStr.Thickness=0.6; iStr.Transparency=0.75

local iLbl = Instance.new("TextLabel",infoRow)
iLbl.Size               = UDim2.new(1,-12,1,-8)
iLbl.Position           = UDim2.new(0,6,0,4)
iLbl.BackgroundTransparency = 1
iLbl.Text               = "⚙  AngerMOD V-2  |  ROBLOX\n👤  " .. LP.Name ..
                          "\n🔑  key.txt: " .. (keyFileFound and ("загружен [" .. #KEYS .. " ключей]") or "не найден (fallback)")
iLbl.TextColor3         = Color3.fromRGB(200,200,200)
iLbl.TextSize           = 11
iLbl.Font               = Enum.Font.Code
iLbl.TextXAlignment     = Enum.TextXAlignment.Left
iLbl.TextYAlignment     = Enum.TextYAlignment.Top
iLbl.ZIndex             = 16

addWidget("MISC", infoRow)

-- ════════════════════════════════════════════
--  ВНЕШНИЕ ЭЛЕМЕНТЫ (поверх игры)
-- ════════════════════════════════════════════

-- FOV Circle
local FOVFrame = Instance.new("Frame",Root)
FOVFrame.BackgroundTransparency = 1
FOVFrame.BorderSizePixel = 0
FOVFrame.ZIndex         = 20
FOVFrame.Visible        = false
Instance.new("UICorner",FOVFrame).CornerRadius = UDim.new(0.5,0)
local FOVStr = Instance.new("UIStroke",FOVFrame)
FOVStr.Color            = Color3.fromRGB(218,165,32)
FOVStr.Thickness        = 1.5
FOVStr.Transparency     = 0.3

-- Radar
local RadFrame = Instance.new("Frame",Root)
RadFrame.Size           = UDim2.new(0,115,0,115)
RadFrame.Position       = UDim2.new(1,-128,1,-128)
RadFrame.BackgroundColor3 = Color3.fromRGB(4,4,4)
RadFrame.BackgroundTransparency = 0.3
RadFrame.BorderSizePixel = 0
RadFrame.ZIndex         = 20
RadFrame.Visible        = false
Instance.new("UICorner",RadFrame).CornerRadius = UDim.new(0.5,0)
local RadStr = Instance.new("UIStroke",RadFrame)
RadStr.Color            = Color3.fromRGB(218,165,32)
RadStr.Thickness        = 1.5

-- Крест радара
for _,cfg in ipairs({{UDim2.new(0.5,0,0,0),UDim2.new(0,1,1,0)},{UDim2.new(0,0,0.5,0),UDim2.new(1,0,0,1)}}) do
    local l = Instance.new("Frame",RadFrame)
    l.Position          = cfg[1]; l.Size=cfg[2]
    l.BackgroundColor3  = Color3.fromRGB(218,165,32)
    l.BackgroundTransparency = 0.6
    l.BorderSizePixel   = 0
    l.ZIndex            = 21
end

local SelfDot = Instance.new("Frame",RadFrame)
SelfDot.Size            = UDim2.new(0,8,0,8)
SelfDot.Position        = UDim2.new(0.5,-4,0.5,-4)
SelfDot.BackgroundColor3 = Color3.fromRGB(30,210,80)
SelfDot.BorderSizePixel = 0
SelfDot.ZIndex          = 23
Instance.new("UICorner",SelfDot).CornerRadius = UDim.new(0.5,0)

-- ════════════════════════════════════════════
--  RENDER LOOP
-- ════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not isLoggedIn then return end

    local selfHRP = getHRP()

    -- ── ESP ──────────────────────────────────
    local anyESP = CH.ESPBoxes or CH.ESPNames or CH.ESPHealth or CH.ESPTracer

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

        local sp, vis = Camera:WorldToViewportPoint(hrp.Position)

        if not anyESP then
            if espCache[p] then
                for _, v in pairs(espCache[p]) do v.Visible = false end
            end
            continue
        end

        -- Инициализация ESP объектов
        if not espCache[p] then
            espCache[p] = {}
            local e = espCache[p]

            e.box = Instance.new("Frame",Root)
            e.box.BackgroundTransparency = 1
            e.box.BorderSizePixel = 0
            e.box.ZIndex = 19
            local bs = Instance.new("UIStroke",e.box)
            bs.Color = Color3.fromRGB(218,165,32); bs.Thickness=1.5

            e.nameLbl = Instance.new("TextLabel",Root)
            e.nameLbl.BackgroundTransparency = 1
            e.nameLbl.TextColor3 = Color3.fromRGB(255,255,255)
            e.nameLbl.TextSize   = 12
            e.nameLbl.Font       = Enum.Font.GothamBold
            e.nameLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
            e.nameLbl.TextStrokeTransparency = 0
            e.nameLbl.ZIndex     = 19

            e.hpFrame = Instance.new("Frame",Root)
            e.hpFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
            e.hpFrame.BackgroundTransparency = 0.3
            e.hpFrame.BorderSizePixel = 0
            e.hpFrame.ZIndex = 19

            e.hpFill = Instance.new("Frame",e.hpFrame)
            e.hpFill.BackgroundColor3 = Color3.fromRGB(30,210,80)
            e.hpFill.BackgroundTransparency = 0.1
            e.hpFill.BorderSizePixel = 0
            e.hpFill.ZIndex = 20

            e.tracer = Instance.new("Frame",Root)
            e.tracer.BackgroundColor3 = Color3.fromRGB(218,165,32)
            e.tracer.BackgroundTransparency = 0.3
            e.tracer.BorderSizePixel = 0
            e.tracer.AnchorPoint = Vector2.new(0.5,0)
            e.tracer.ZIndex = 18
        end

        local e = espCache[p]

        if not vis then
            for _, v in pairs(e) do v.Visible = false end
            continue
        end

        -- Размеры рамки
        local topSP = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,3.5,0))
        local botSP = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
        local bH = math.abs(topSP.Y - botSP.Y)
        local bW = bH * 0.52
        local bx = sp.X - bW/2
        local by = topSP.Y

        -- Рамка
        e.box.Visible   = CH.ESPBoxes
        if CH.ESPBoxes then
            e.box.Size     = UDim2.new(0,bW,0,bH)
            e.box.Position = UDim2.new(0,bx,0,by)
        end

        -- Имя
        e.nameLbl.Visible = CH.ESPNames
        if CH.ESPNames then
            e.nameLbl.Text = p.Name
            e.nameLbl.Size = UDim2.new(0,bW+20,0,16)
            e.nameLbl.Position = UDim2.new(0,bx-10,0,by-17)
        end

        -- HP
        e.hpFrame.Visible = CH.ESPHealth
        e.hpFill.Visible  = CH.ESPHealth
        if CH.ESPHealth then
            local ratio = math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
            e.hpFrame.Size     = UDim2.new(0,4,0,bH)
            e.hpFrame.Position = UDim2.new(0,bx-7,0,by)
            e.hpFill.Size      = UDim2.new(1,0,ratio,0)
            e.hpFill.Position  = UDim2.new(0,0,1-ratio,0)
            e.hpFill.BackgroundColor3 = Color3.fromRGB(math.floor(220*(1-ratio)),math.floor(200*ratio),40)
        end

        -- Трейсер
        e.tracer.Visible = CH.ESPTracer
        if CH.ESPTracer then
            local cx2 = Camera.ViewportSize.X/2
            local cy2 = Camera.ViewportSize.Y
            local dx = sp.X - cx2
            local dy = sp.Y - cy2
            local len = math.sqrt(dx*dx + dy*dy)
            local angle = math.atan2(dy,dx)
            e.tracer.Size     = UDim2.new(0,1,0,len)
            e.tracer.Position = UDim2.new(0,cx2,0,cy2)
            e.tracer.Rotation = math.deg(angle) + 90
        end
    end

    -- ── AIMBOT ───────────────────────────────
    if CH.Aimbot or CH.AutoAim then
        local target = getNearestEnemy()
        if target then
            local tHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if tHRP then
                local lookCF = CFrame.lookAt(Camera.CFrame.Position, tHRP.Position)
                if CH.Aimbot then
                    Camera.CFrame = lookCF
                elseif CH.AutoAim then
                    Camera.CFrame = Camera.CFrame:Lerp(lookCF, 0.07)
                end
            end
        end
    end

    -- ── FOV CIRCLE ───────────────────────────
    FOVFrame.Visible = CH.FOVCircle
    if CH.FOVCircle then
        local r = CH.FOVRadius
        local cx3 = Camera.ViewportSize.X/2
        local cy3 = Camera.ViewportSize.Y/2
        FOVFrame.Size     = UDim2.new(0,r*2,0,r*2)
        FOVFrame.Position = UDim2.new(0,cx3-r,0,cy3-r)
    end

    -- ── RADAR ────────────────────────────────
    RadFrame.Visible = CH.Radar
    if CH.Radar and selfHRP then
        for _,d in pairs(radarDots) do d:Destroy() end
        radarDots = {}
        local RANGE = 160
        local half  = 57
        for _, p in ipairs(getEnemies()) do
            local hrp2 = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if hrp2 then
                local diff  = hrp2.Position - selfHRP.Position
                local rx    = diff:Dot(Camera.CFrame.RightVector)
                local ry    = diff:Dot(Camera.CFrame.LookVector)
                if Vector2.new(rx,ry).Magnitude < RANGE then
                    local nx = rx/RANGE
                    local ny = ry/RANGE
                    local dot = Instance.new("Frame",RadFrame)
                    dot.Size  = UDim2.new(0,7,0,7)
                    dot.AnchorPoint = Vector2.new(0.5,0.5)
                    dot.Position    = UDim2.new(0,half + nx*half*0.9,0,half - ny*half*0.9)
                    dot.BackgroundColor3 = Color3.fromRGB(220,40,40)
                    dot.BackgroundTransparency = 0.05
                    dot.BorderSizePixel = 0
                    dot.ZIndex          = 22
                    Instance.new("UICorner",dot).CornerRadius = UDim.new(0.5,0)
                    table.insert(radarDots,dot)
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
        local cf  = Camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir += cf.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir -= cf.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir -= cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir += cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir += Vector3.yAxis  end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis  end
        flyVel.Velocity = dir.Magnitude > 0 and (dir.Unit * SPD) or Vector3.zero
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

-- ── RESPAWN FIX ──────────────────────────────
LP.CharacterAdded:Connect(function(char)
    flyVel  = nil
    flyGyro = nil
    if CH.SpeedHack then
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then hum.WalkSpeed = CH.WalkSpeed end
    end
end)

-- ════════════════════════════════════════════
--  FPS СЧЁТЧИК
-- ════════════════════════════════════════════
local fCount, fLast = 0, tick()
RunService.RenderStepped:Connect(function()
    fCount += 1
    if tick() - fLast >= 0.5 then
        local fps = math.floor(fCount / (tick() - fLast))
        FPSLbl.Text      = "FPS: " .. fps
        FPSLbl.TextColor3 = fps>=55 and Color3.fromRGB(30,210,80)
                         or fps>=30 and Color3.fromRGB(218,165,32)
                         or            Color3.fromRGB(220,40,40)
        fCount = 0
        fLast  = tick()
    end
end)

-- ════════════════════════════════════════════
--  ПЕРЕТАСКИВАНИЕ ОКНА
-- ════════════════════════════════════════════
TBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragOffset = Vector2.new(
            inp.Position.X - Win.AbsolutePosition.X,
            inp.Position.Y - Win.AbsolutePosition.Y
        )
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if isDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        Win.Position = UDim2.new(0, inp.Position.X - dragOffset.X, 0, inp.Position.Y - dragOffset.Y)
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
end)

-- ════════════════════════════════════════════
--  СВЕРНУТЬ / РАЗВЕРНУТЬ
-- ════════════════════════════════════════════
BtnArrow.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    BtnArrow.Text = isMinimized and "▶" or "▼"
    tween(Win, {Size = UDim2.new(0,W,0, isMinimized and 34 or H)}, 0.25)
end)

-- ════════════════════════════════════════════
--  ЗАКРЫТЬ
-- ════════════════════════════════════════════
BtnX.MouseButton1Click:Connect(function()
    local cx4 = Win.AbsolutePosition.X + W/2
    local cy4 = Win.AbsolutePosition.Y + H/2
    tween(Win, {Size=UDim2.new(0,0,0,0), Position=UDim2.new(0,cx4,0,cy4)}, 0.2)
    task.delay(0.22, function() Win.Visible = false end)
end)

-- ════════════════════════════════════════════
--  ЛОГИКА ВХОДА
-- ════════════════════════════════════════════
local function shakeWin()
    local orig = Win.Position
    for i = 1, 8 do
        Win.Position = orig + UDim2.new(0, i%2==0 and 8 or -8, 0, 0)
        task.wait(0.035)
    end
    Win.Position = orig
end

local function doLogin()
    local key = KeyBox.Text:match("^%s*(.-)%s*$")
    if isValidKey(key) then
        isLoggedIn = true
        StatusLbl.TextColor3 = Color3.fromRGB(30,210,80)
        StatusLbl.Text       = "✔  Добро пожаловать, " .. LP.Name .. "!"

        -- Убираем фон
        tween(EBG,     {BackgroundTransparency=1}, 0.7)
        tween(ErrText, {TextTransparency=1},        0.5)
        tween(BigErr,  {TextTransparency=1},        0.4)
        task.delay(0.75, function() EBG.Visible = false end)

        -- Показываем чит меню
        task.delay(0.85, function()
            LoginF.Visible  = false
            CheatF.Visible  = true
            -- Активируем первый таб
            tabs["AIMBOT"].btn:FindFirstChildOfClass and nil
            tabs["AIMBOT"].btn.MouseButton1Click:Fire()
        end)
    else
        StatusLbl.TextColor3 = Color3.fromRGB(220,40,40)
        StatusLbl.Text       = "✖  Key not registered or expired"
        task.spawn(shakeWin)
    end
end

BtnEnter.MouseButton1Click:Connect(doLogin)
KeyBox.FocusLost:Connect(function(enter) if enter then doLogin() end end)

BtnPaste.MouseButton1Click:Connect(function()
    local ok, clip = pcall(getclipboard)
    if ok and clip and #clip > 0 then
        KeyBox.Text = clip
        StatusLbl.TextColor3 = Color3.fromRGB(218,165,32)
        StatusLbl.Text = "📋  Ключ вставлен — нажми ENTER LOGIN"
    else
        StatusLbl.TextColor3 = Color3.fromRGB(180,180,50)
        StatusLbl.Text = "⚠  Буфер недоступен — введи ключ вручную"
    end
end)

-- Ховер на кнопках входа
for _, b in ipairs({BtnEnter, BtnPaste}) do
    b.MouseEnter:Connect(function()  tween(b,{BackgroundTransparency=0.05}) end)
    b.MouseLeave:Connect(function()  tween(b,{BackgroundTransparency=0.22}) end)
end

-- ════════════════════════════════════════════
--  СОЗДАТЬ key.txt если нет
-- ════════════════════════════════════════════
task.spawn(function()
    pcall(function()
        if not isfile("key.txt") then
            writefile("key.txt",
                "ANGER-2025-ALPHA\n"..
                "ANGER-VIP-001\n"..
                "ANGER-KEY-XYZ\n"..
                "TESTKEY123\n"..
                "RAGE-MOD-KEY\n"
            )
            -- После создания — перечитываем
            reloadKeys()
        end
    end)
end)

-- ════════════════════════════════════════════
--  АКТИВИРУЕМ ПЕРВЫЙ ТАБ ПОСЛЕ ЛОГИНА
-- ════════════════════════════════════════════
-- (вызывается через MouseButton1Click:Fire() выше)
-- Дополнительно вешаем прямой вызов
local function openFirstTab()
    activeTab = "AIMBOT"
    for tname, tdata in pairs(tabs) do
        tdata.btn.TextColor3 = Color3.fromRGB(100,100,100)
        tdata.btn.BackgroundColor3 = Color3.fromRGB(12,12,12)
        tdata.btn.BackgroundTransparency = 0.3
        local s = tdata.btn:FindFirstChildOfClass("UIStroke")
        if s then s:Destroy() end
        for _, w in ipairs(tdata.widgets) do w.Parent = nil end
    end
    local btn = tabs["AIMBOT"].btn
    btn.TextColor3 = Color3.fromRGB(218,165,32)
    btn.BackgroundColor3 = Color3.fromRGB(22,17,3)
    btn.BackgroundTransparency = 0.1
    local ns = Instance.new("UIStroke",btn)
    ns.Color=Color3.fromRGB(218,165,32); ns.Thickness=1; ns.Transparency=0.35
    for _, w in ipairs(tabs["AIMBOT"].widgets) do w.Parent = Scroll end
end

-- Патчим doLogin чтобы вызывал openFirstTab напрямую
local _origLogin = doLogin
doLogin = function()
    local key = KeyBox.Text:match("^%s*(.-)%s*$")
    if isValidKey(key) then
        isLoggedIn = true
        StatusLbl.TextColor3 = Color3.fromRGB(30,210,80)
        StatusLbl.Text       = "✔  Добро пожаловать, " .. LP.Name .. "!"
        tween(EBG,     {BackgroundTransparency=1}, 0.7)
        tween(ErrText, {TextTransparency=1},        0.5)
        tween(BigErr,  {TextTransparency=1},        0.4)
        task.delay(0.75, function() EBG.Visible = false end)
        task.delay(0.85, function()
            LoginF.Visible  = false
            CheatF.Visible  = true
            openFirstTab()
        end)
    else
        StatusLbl.TextColor3 = Color3.fromRGB(220,40,40)
        StatusLbl.Text       = "✖  Key not registered or expired"
        task.spawn(shakeWin)
    end
end

BtnEnter.MouseButton1Click:Connect(doLogin)
KeyBox.FocusLost:Connect(function(enter) if enter then doLogin() end end)

print("[AngerMOD V-2] ✔ Загружен успешно!")
print("[AngerMOD V-2] Ключей в системе: " .. #KEYS)
print("[AngerMOD V-2] Статус key.txt: " .. keyFileStatus)
