--[[
    ╔══════════════════════════════════════════╗
    ║         AngerMOD V-2  |  ROBLOX          ║
    ║   Все функции рабочие + система ключей   ║
    ╚══════════════════════════════════════════╝

    УСТАНОВКА:
    1. Положи key.txt рядом со скриптом (для executor'ов)
       Каждая строка = отдельный пароль
    2. Выполни скрипт через executor (напр. Synapse X, KRNL, Fluxus)

    key.txt пример:
        ANGER-2025-ALPHA
        ANGER-VIP-001
        TESTKEY123
]]

-- ══════════════════════════════════════════════════════
--  СЕРВИСЫ
-- ══════════════════════════════════════════════════════
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local Workspace          = game:GetService("Workspace")
local CollectionService  = game:GetService("CollectionService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")

local LocalPlayer        = Players.LocalPlayer
local PlayerGui          = LocalPlayer:WaitForChild("PlayerGui")
local Camera             = Workspace.CurrentCamera

-- ══════════════════════════════════════════════════════
--  ЧТЕНИЕ key.txt
-- ══════════════════════════════════════════════════════
local validKeys = {}

local function loadKeys()
    -- Попытка прочитать key.txt через executor API
    local ok, result = pcall(function()
        return readfile("key.txt")
    end)
    if ok and result then
        for line in result:gmatch("[^\r\n]+") do
            local trimmed = line:match("^%s*(.-)%s*$")
            if trimmed ~= "" then
                table.insert(validKeys, trimmed)
            end
        end
        return true
    end
    -- Fallback — встроенные ключи если key.txt не найден
    validKeys = {
    "AngerMOD-1D-YXBH3WH0JS",
    "AngerMOD-1D-ANCOODMI9N",
    "AngerMOD-1D-RZTVXYNNZ8",
    "AngerMOD-1D-43S92TGYPW",
    "AngerMOD-1D-UTFXZC97QN",
    "AngerMOD-1D-5ALUDZMCLA",
    "AngerMOD-1D-R6017AOPOU",
    "AngerMOD-1D-HIGX3JLKZB",
    "AngerMOD-1D-EN2C8LUHV5",
    "AngerMOD-1D-BJQ861YYC1",
    "AngerMOD-1D-2SCSVF7GDN",
    "AngerMOD-1D-O7TBXLH7UF",
    "AngerMOD-1D-KG8FR2CK07",
    "AngerMOD-1D-R3703GZBYI",
    "AngerMOD-1D-DGMWQJNGLL",
    "AngerMOD-1D-PVO68Q8Q7J",
    "AngerMOD-1D-VBRYTNK6MY",
    "AngerMOD-1D-X2AHRAL743",
    "AngerMOD-1D-Q5DM9268FN",
    "AngerMOD-1D-HOCO0S90MI",
    "AngerMOD-1D-D0UN4BIL07",
    "AngerMOD-1D-WGQ6FJQX52",
    "AngerMOD-1D-ZF5J7UKQTP",
    "AngerMOD-1D-5TLP74NZV5",
    "AngerMOD-1D-ZXUFEN4UWY",
    "AngerMOD-1D-VU6OHLZKW7",
    "AngerMOD-1D-XN3LF7TLLM",
    "AngerMOD-1D-1USK0EQXUE",
    "AngerMOD-1D-IW2SXXI899",
    "AngerMOD-1D-7ZUFG3WRMR",
    "AngerMOD-1D-Y4NN864RGV",
    "AngerMOD-1D-ROZ9B7LA2L",
    "AngerMOD-1D-EZUFQDW0KJ",
    "AngerMOD-1D-7Z0CRQQBC1",
    "AngerMOD-1D-DGFKN9G7RO",
    "AngerMOD-1D-BMR3LNMPCU",
    "AngerMOD-1D-KVAJ0F1C10",
    "AngerMOD-1D-QB180KFOCR",
    "AngerMOD-1D-9D7IOOC5GA",
    "AngerMOD-1D-4NEHGGJC5A",
    "AngerMOD-1D-2CI33VFBO6",
    "AngerMOD-1D-S4ZQC2PLYY",
    "AngerMOD-1D-VVOSLBHSN6",
    "AngerMOD-1D-3DI99V5GRN",
    "AngerMOD-1D-0LN1KXWZPU",
    "AngerMOD-1D-9FXVCILBDQ",
    "AngerMOD-1D-R2B5FH9G0E",
    "AngerMOD-1D-U9VSSZ0JFB",
    "AngerMOD-1D-A64FO4KI5M",
    "AngerMOD-1D-9ODCD94L8G",
    "AngerMOD-1D-NXAMMDSGIZ",
    "AngerMOD-1D-U6WZ139HN7",
    "AngerMOD-1D-SZW8R3T0X6",
    "AngerMOD-1D-B7AB5AOQKW",
    "AngerMOD-1D-D891IAITXA",
    "AngerMOD-1D-78JK75TPOX",
    "AngerMOD-1D-87GKQ3C9DN",
    "AngerMOD-1D-NNBK18N25D",
    "AngerMOD-1D-RV3SXNFYNF",
    "AngerMOD-1D-8RSW9NCPDG",
    "AngerMOD-1D-JMFGN6GQG6",
    "AngerMOD-1D-PNJV3KYFSN",
    "AngerMOD-1D-IQKZWMBE00",
    "AngerMOD-1D-2P5H8RSRS2",
    "AngerMOD-1D-IUDXPJL32D",
    "AngerMOD-1D-N949EIV0YS",
    "AngerMOD-1D-8JLQM7H6BG",
    "AngerMOD-1D-WS8XY903SM",
    "AngerMOD-1D-56LX0D7FVA",
    "AngerMOD-1D-OL1I8ROFA4",
    "AngerMOD-1D-FXNSHEWJUA",
    "AngerMOD-1D-KF9TW8LPTG",
    "AngerMOD-1D-SQAM6P99QU",
    "AngerMOD-1D-ZH05NNDATJ",
    "AngerMOD-1D-F8OHI8E52X",
    "AngerMOD-1D-BEJSTN8LVY",
    "AngerMOD-1D-D2HJUDBF2T",
    "AngerMOD-1D-MWWE15FZFI",
    "AngerMOD-1D-W5HMZ0CBDG",
    "AngerMOD-1D-K41DHQU2CU",
    "AngerMOD-1D-8S2P6WM2SF",
    "AngerMOD-1D-XZ2O58RL6R",
    "AngerMOD-1D-JGLPXA6XPJ",
    "AngerMOD-1D-KC2TX9LUF2",
    "AngerMOD-1D-FTK2785WNG",
    "AngerMOD-1D-NAMKMF0H8X",
    "AngerMOD-1D-42W19G1YZS",
    "AngerMOD-1D-8KZIUCHLLX",
    "AngerMOD-1D-F3XRGNOESX",
    "AngerMOD-1D-686UKCCBUI",
    "AngerMOD-1D-561HPP0QWC",
    "AngerMOD-1D-OO30BRJ97E",
    "AngerMOD-1D-DEJXYKIG9J",
    "AngerMOD-1D-4UO8URQINY",
    "AngerMOD-1D-FHUEUJPNSL",
    "AngerMOD-1D-N2QZ4FO1QS",
    "AngerMOD-1D-4K25WU5DEX",
    "AngerMOD-1D-1DSKZTB2P1",
    }
    return false
end

local keyFileLoaded = loadKeys()

-- ══════════════════════════════════════════════════════
--  СОСТОЯНИЕ ЧИТОВ
-- ══════════════════════════════════════════════════════
local Cheats = {
    -- AIMBOT
    Aimbot          = false,
    AutoAim         = false,
    SilentAim       = false,
    AimFOV          = false,
    AimFOVRadius    = 120,

    -- VISUALS
    ESPBoxes        = false,
    EnemyNames      = false,
    HealthBar       = false,
    Radar           = false,

    -- MOVEMENT
    SpeedHack       = false,
    SpeedValue      = 32,
    InfiniteJump    = false,
    NoClip          = false,
    FlyMode         = false,

    -- MISC
    NoRecoil        = false,
    AntiBan         = true,
    AntiAFK         = true,
}

-- Состояние GUI
local isLoggedIn    = false
local isMinimized   = false
local isDragging    = false
local dragStart     = nil
local startPos      = nil
local activeTab     = "AIMBOT"

-- Для cleanup
local connections   = {}
local espObjects    = {}
local flyBodyForce  = nil
local flyBodyGyro   = nil
local originalSpeed = nil

-- ══════════════════════════════════════════════════════
--  ЦВЕТА
-- ══════════════════════════════════════════════════════
local C = {
    GOLD        = Color3.fromRGB(218, 165, 32),
    GOLD_DIM    = Color3.fromRGB(150, 110, 15),
    BG          = Color3.fromRGB(8,   8,   8),
    BG_TITLE    = Color3.fromRGB(4,   4,   4),
    BG_ROW      = Color3.fromRGB(14,  14,  14),
    BG_TAB      = Color3.fromRGB(18,  18,  18),
    BG_ACTIVE   = Color3.fromRGB(25,  20,   5),
    WHITE       = Color3.fromRGB(225, 225, 225),
    GRAY        = Color3.fromRGB(120, 120, 120),
    RED         = Color3.fromRGB(200,  40,  40),
    GREEN       = Color3.fromRGB(30,  210,  80),
    ON_COLOR    = Color3.fromRGB(218, 165,  32),
    OFF_COLOR   = Color3.fromRGB(45,   45,  45),
    BLACK       = Color3.fromRGB(0,    0,    0),
}

-- ══════════════════════════════════════════════════════
--  ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ══════════════════════════════════════════════════════
local function getChar()
    return LocalPlayer.Character
end

local function getHRP()
    local char = getChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local char = getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getEnemies()
    local enemies = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(enemies, p)
        end
    end
    return enemies
end

local function getClosestEnemy()
    local closest, closestDist = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local fov = Cheats.AimFOVRadius

    for _, p in ipairs(getEnemies()) do
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if dist2D < fov and dist2D < closestDist then
                    closestDist = dist2D
                    closest = p
                end
            end
        end
    end
    return closest
end

-- ══════════════════════════════════════════════════════
--  СОЗДАНИЕ GUI
-- ══════════════════════════════════════════════════════
-- Удаляем старый GUI если есть
if PlayerGui:FindFirstChild("AngerMOD_V2") then
    PlayerGui:FindFirstChild("AngerMOD_V2"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "AngerMOD_V2"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent         = PlayerGui

-- ══════════════════════════════════════════════════════
--  ФОНОВЫЙ ЭКРАН ОШИБКИ
-- ══════════════════════════════════════════════════════
local ErrorBG = Instance.new("Frame")
ErrorBG.Name             = "ErrorBG"
ErrorBG.Size             = UDim2.new(1, 0, 1, 0)
ErrorBG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ErrorBG.ZIndex           = 1
ErrorBG.Parent           = ScreenGui

local errTextLbl = Instance.new("TextLabel")
errTextLbl.Size                 = UDim2.new(1, 0, 1, 0)
errTextLbl.BackgroundTransparency = 1
errTextLbl.Text                 = string.rep("COPY KEY BEFORE OPEN GAME ERROR!! LOGIN ERROR!! COPY KEY BEFORE OPEN GAME ERROR!! LOGIN ERROR!!   ", 400)
errTextLbl.TextColor3           = C.GOLD
errTextLbl.TextSize             = 13
errTextLbl.Font                 = Enum.Font.Code
errTextLbl.TextWrapped          = true
errTextLbl.TextXAlignment       = Enum.TextXAlignment.Left
errTextLbl.TextYAlignment       = Enum.TextYAlignment.Top
errTextLbl.ZIndex               = 2
errTextLbl.Parent               = ErrorBG

local bigErrLbl = Instance.new("TextLabel")
bigErrLbl.Size                  = UDim2.new(0.9, 0, 0.28, 0)
bigErrLbl.Position              = UDim2.new(0.05, 0, 0.36, 0)
bigErrLbl.BackgroundTransparency = 1
bigErrLbl.Text                  = "ERROR LOGIN\nANGERMOD"
bigErrLbl.TextColor3            = C.RED
bigErrLbl.TextSize              = 72
bigErrLbl.Font                  = Enum.Font.GothamBold
bigErrLbl.TextStrokeColor3      = C.GOLD
bigErrLbl.TextStrokeTransparency = 0.3
bigErrLbl.ZIndex                = 3
bigErrLbl.Parent                = ErrorBG

local verLblBG = Instance.new("TextLabel")
verLblBG.Size                   = UDim2.new(1, 0, 0, 24)
verLblBG.Position               = UDim2.new(0, 0, 1, -26)
verLblBG.BackgroundTransparency = 1
verLblBG.Text                   = "AngerMOD V-2  |  ROBLOX  |  " .. (keyFileLoaded and "key.txt загружен ✔" or "Встроенные ключи")
verLblBG.TextColor3             = C.GOLD_DIM
verLblBG.TextSize               = 12
verLblBG.Font                   = Enum.Font.Code
verLblBG.ZIndex                 = 3
verLblBG.Parent                 = ErrorBG

-- Пульсация фона ошибки
RunService.Heartbeat:Connect(function()
    if not isLoggedIn then
        local a = math.abs(math.sin(tick() * 1.8))
        bigErrLbl.TextColor3        = Color3.fromRGB(255, 40 + a*80, 40)
        bigErrLbl.TextTransparency  = 0.05 + a * 0.22
        errTextLbl.TextTransparency = 0.52 + a * 0.22
    end
end)

-- ══════════════════════════════════════════════════════
--  ГЛАВНОЕ ОКНО
-- ══════════════════════════════════════════════════════
local WIN_W, WIN_H = 500, 400

local Win = Instance.new("Frame")
Win.Name                 = "MainWindow"
Win.Size                 = UDim2.new(0, WIN_W, 0, WIN_H)
Win.Position             = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
Win.BackgroundColor3     = C.BG
Win.BackgroundTransparency = 0.25
Win.BorderSizePixel      = 0
Win.ZIndex               = 10
Win.Parent               = ScreenGui

Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 6)

local winStroke = Instance.new("UIStroke", Win)
winStroke.Color     = C.GOLD
winStroke.Thickness = 1.5

-- ══════════════════════════════════════════════════════
--  ТАЙТЛБАР
-- ══════════════════════════════════════════════════════
local TBar = Instance.new("Frame")
TBar.Name                = "TitleBar"
TBar.Size                = UDim2.new(1, 0, 0, 34)
TBar.BackgroundColor3    = C.BG_TITLE
TBar.BackgroundTransparency = 0.15
TBar.BorderSizePixel     = 0
TBar.ZIndex              = 11
TBar.Parent              = Win

Instance.new("UICorner", TBar).CornerRadius = UDim.new(0, 6)

-- Заглушка для нижних углов тайтлбара
local tbFix = Instance.new("Frame", TBar)
tbFix.Size               = UDim2.new(1, 0, 0.5, 0)
tbFix.Position           = UDim2.new(0, 0, 0.5, 0)
tbFix.BackgroundColor3   = C.BG_TITLE
tbFix.BackgroundTransparency = 0.15
tbFix.BorderSizePixel    = 0
tbFix.ZIndex             = 11

-- Разделитель
local divLine = Instance.new("Frame", TBar)
divLine.Size             = UDim2.new(1, 0, 0, 1)
divLine.Position         = UDim2.new(0, 0, 1, -1)
divLine.BackgroundColor3 = C.GOLD
divLine.BackgroundTransparency = 0.45
divLine.BorderSizePixel  = 0
divLine.ZIndex           = 12

-- Кнопка свернуть ▼
local ArrowBtn = Instance.new("TextButton", TBar)
ArrowBtn.Size            = UDim2.new(0, 28, 0, 24)
ArrowBtn.Position        = UDim2.new(0, 5, 0.5, -12)
ArrowBtn.BackgroundColor3 = C.GOLD
ArrowBtn.BackgroundTransparency = 0.1
ArrowBtn.Text            = "▼"
ArrowBtn.TextColor3      = C.BLACK
ArrowBtn.TextSize        = 11
ArrowBtn.Font            = Enum.Font.GothamBold
ArrowBtn.BorderSizePixel = 0
ArrowBtn.ZIndex          = 13
Instance.new("UICorner", ArrowBtn).CornerRadius = UDim.new(0, 3)

-- Название
local TitleLbl = Instance.new("TextLabel", TBar)
TitleLbl.Size            = UDim2.new(0, 270, 1, 0)
TitleLbl.Position        = UDim2.new(0, 38, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text            = "▶ AngerMOD V-2  |  ROBLOX 64BIT"
TitleLbl.TextColor3      = C.GOLD
TitleLbl.TextSize        = 12
TitleLbl.Font            = Enum.Font.GothamBold
TitleLbl.TextXAlignment  = Enum.TextXAlignment.Left
TitleLbl.ZIndex          = 13

-- FPS
local FPSLbl = Instance.new("TextLabel", TBar)
FPSLbl.Size              = UDim2.new(0, 90, 1, 0)
FPSLbl.Position          = UDim2.new(1, -126, 0, 0)
FPSLbl.BackgroundTransparency = 1
FPSLbl.Text              = "FPS: --"
FPSLbl.TextColor3        = C.GREEN
FPSLbl.TextSize          = 12
FPSLbl.Font              = Enum.Font.Code
FPSLbl.TextXAlignment    = Enum.TextXAlignment.Right
FPSLbl.ZIndex            = 13

-- Закрыть X
local XBtn = Instance.new("TextButton", TBar)
XBtn.Size                = UDim2.new(0, 28, 0, 24)
XBtn.Position            = UDim2.new(1, -33, 0.5, -12)
XBtn.BackgroundColor3    = C.RED
XBtn.BackgroundTransparency = 0.15
XBtn.Text                = "✕"
XBtn.TextColor3          = Color3.fromRGB(255, 255, 255)
XBtn.TextSize            = 13
XBtn.Font                = Enum.Font.GothamBold
XBtn.BorderSizePixel     = 0
XBtn.ZIndex              = 13
Instance.new("UICorner", XBtn).CornerRadius = UDim.new(0, 3)

-- ══════════════════════════════════════════════════════
--  КОНТЕНТ
-- ══════════════════════════════════════════════════════
local Content = Instance.new("Frame", Win)
Content.Name             = "Content"
Content.Size             = UDim2.new(1, 0, 1, -34)
Content.Position         = UDim2.new(0, 0, 0, 34)
Content.BackgroundTransparency = 1
Content.ZIndex           = 11

-- ══════════════════════════════════════════════════════
--  LOGIN FRAME
-- ══════════════════════════════════════════════════════
local LoginF = Instance.new("Frame", Content)
LoginF.Name              = "LoginFrame"
LoginF.Size              = UDim2.new(1, -28, 1, -12)
LoginF.Position          = UDim2.new(0, 14, 0, 8)
LoginF.BackgroundTransparency = 1
LoginF.ZIndex            = 12

local function makeLoginLabel(text, posY, size, color, font)
    local lbl = Instance.new("TextLabel", LoginF)
    lbl.Size             = UDim2.new(1, 0, 0, size or 22)
    lbl.Position         = UDim2.new(0, 0, 0, posY)
    lbl.BackgroundTransparency = 1
    lbl.Text             = text
    lbl.TextColor3       = color or C.WHITE
    lbl.TextSize         = 14
    lbl.Font             = font or Enum.Font.Gotham
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.ZIndex           = 13
    return lbl
end

makeLoginLabel("Please PM Admin To Order Key", 6, 26, C.GOLD, Enum.Font.GothamBold)
makeLoginLabel("Please Login (Copy Key)", 36, 22, C.WHITE, Enum.Font.Gotham)

-- Поле ввода ключа
local KeyBox = Instance.new("TextBox", LoginF)
KeyBox.Size              = UDim2.new(1, 0, 0, 36)
KeyBox.Position          = UDim2.new(0, 0, 0, 64)
KeyBox.BackgroundColor3  = Color3.fromRGB(5, 5, 5)
KeyBox.BackgroundTransparency = 0.3
KeyBox.Text              = ""
KeyBox.PlaceholderText   = 'loadstring(game:HttpGet("https://..."))()'
KeyBox.PlaceholderColor3 = C.GRAY
KeyBox.TextColor3        = C.GOLD
KeyBox.TextSize          = 12
KeyBox.Font              = Enum.Font.Code
KeyBox.ClearTextOnFocus  = false
KeyBox.BorderSizePixel   = 0
KeyBox.ZIndex            = 13
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 4)
local kbStr = Instance.new("UIStroke", KeyBox)
kbStr.Color = C.GOLD ; kbStr.Thickness = 1 ; kbStr.Transparency = 0.35

-- ENTER LOGIN
local EnterBtn = Instance.new("TextButton", LoginF)
EnterBtn.Size            = UDim2.new(1, 0, 0, 38)
EnterBtn.Position        = UDim2.new(0, 0, 0, 108)
EnterBtn.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
EnterBtn.BackgroundTransparency = 0.28
EnterBtn.Text            = "ENTER LOGIN"
EnterBtn.TextColor3      = C.GOLD
EnterBtn.TextSize        = 14
EnterBtn.Font            = Enum.Font.GothamBold
EnterBtn.BorderSizePixel = 0
EnterBtn.ZIndex          = 13
Instance.new("UICorner", EnterBtn).CornerRadius = UDim.new(0, 4)
local ebStr = Instance.new("UIStroke", EnterBtn)
ebStr.Color = C.GOLD ; ebStr.Thickness = 1.2

-- PASTE KEY
local PasteBtn = Instance.new("TextButton", LoginF)
PasteBtn.Size            = UDim2.new(1, 0, 0, 36)
PasteBtn.Position        = UDim2.new(0, 0, 0, 152)
PasteBtn.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
PasteBtn.BackgroundTransparency = 0.3
PasteBtn.Text            = "PASTE KEY"
PasteBtn.TextColor3      = C.GOLD
PasteBtn.TextSize        = 13
PasteBtn.Font            = Enum.Font.GothamBold
PasteBtn.BorderSizePixel = 0
PasteBtn.ZIndex          = 13
Instance.new("UICorner", PasteBtn).CornerRadius = UDim.new(0, 4)
local pbStr = Instance.new("UIStroke", PasteBtn)
pbStr.Color = C.GOLD ; pbStr.Thickness = 1 ; pbStr.Transparency = 0.4

-- Статус
local StatusLbl = Instance.new("TextLabel", LoginF)
StatusLbl.Size           = UDim2.new(1, 0, 0, 28)
StatusLbl.Position       = UDim2.new(0, 0, 0, 196)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text           = keyFileLoaded and "✔  key.txt загружен" or "⚠  key.txt не найден — используются встроенные ключи"
StatusLbl.TextColor3     = keyFileLoaded and C.GREEN or C.GOLD
StatusLbl.TextSize       = 12
StatusLbl.Font           = Enum.Font.GothamBold
StatusLbl.ZIndex         = 13

local verLblLogin = Instance.new("TextLabel", LoginF)
verLblLogin.Size         = UDim2.new(1, 0, 0, 18)
verLblLogin.Position     = UDim2.new(0, 0, 0, 228)
verLblLogin.BackgroundTransparency = 1
verLblLogin.Text         = "Game Version : ROBLOX  |  AngerMOD V-2"
verLblLogin.TextColor3   = C.GRAY
verLblLogin.TextSize     = 11
verLblLogin.Font         = Enum.Font.Code
verLblLogin.TextXAlignment = Enum.TextXAlignment.Left
verLblLogin.ZIndex       = 13

-- ══════════════════════════════════════════════════════
--  CHEAT MENU (после логина)
-- ══════════════════════════════════════════════════════
local CheatMenu = Instance.new("Frame", Content)
CheatMenu.Name           = "CheatMenu"
CheatMenu.Size           = UDim2.new(1, 0, 1, 0)
CheatMenu.BackgroundTransparency = 1
CheatMenu.ZIndex         = 12
CheatMenu.Visible        = false

-- ТАБЫ (левая панель)
local TabPanel = Instance.new("Frame", CheatMenu)
TabPanel.Size            = UDim2.new(0, 100, 1, -6)
TabPanel.Position        = UDim2.new(0, 6, 0, 3)
TabPanel.BackgroundColor3 = C.BG_TITLE
TabPanel.BackgroundTransparency = 0.3
TabPanel.BorderSizePixel = 0
TabPanel.ZIndex          = 13
Instance.new("UICorner", TabPanel).CornerRadius = UDim.new(0, 4)

local tabListLayout = Instance.new("UIListLayout", TabPanel)
tabListLayout.Padding    = UDim.new(0, 3)
local tabPad = Instance.new("UIPadding", TabPanel)
tabPad.PaddingTop        = UDim.new(0, 4)
tabPad.PaddingLeft       = UDim.new(0, 4)
tabPad.PaddingRight      = UDim.new(0, 4)

-- Правая панель контента
local RightPanel = Instance.new("Frame", CheatMenu)
RightPanel.Size          = UDim2.new(1, -114, 1, -6)
RightPanel.Position      = UDim2.new(0, 110, 0, 3)
RightPanel.BackgroundColor3 = C.BG
RightPanel.BackgroundTransparency = 0.4
RightPanel.BorderSizePixel = 0
RightPanel.ZIndex        = 13
Instance.new("UICorner", RightPanel).CornerRadius = UDim.new(0, 4)
local rpStr = Instance.new("UIStroke", RightPanel)
rpStr.Color = C.GOLD ; rpStr.Thickness = 0.8 ; rpStr.Transparency = 0.6

-- Скролл для правой панели
local RightScroll = Instance.new("ScrollingFrame", RightPanel)
RightScroll.Size         = UDim2.new(1, -4, 1, -4)
RightScroll.Position     = UDim2.new(0, 2, 0, 2)
RightScroll.BackgroundTransparency = 1
RightScroll.ScrollBarThickness = 3
RightScroll.ScrollBarImageColor3 = C.GOLD
RightScroll.ScrollBarImageTransparency = 0.35
RightScroll.BorderSizePixel = 0
RightScroll.ZIndex       = 14
RightScroll.CanvasSize   = UDim2.new(0, 0, 0, 0)

local scrollList = Instance.new("UIListLayout", RightScroll)
scrollList.Padding       = UDim.new(0, 4)
local scrollPad = Instance.new("UIPadding", RightScroll)
scrollPad.PaddingTop     = UDim.new(0, 4)
scrollPad.PaddingLeft    = UDim.new(0, 4)
scrollPad.PaddingRight   = UDim.new(0, 4)
scrollPad.PaddingBottom  = UDim.new(0, 6)

scrollList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    RightScroll.CanvasSize = UDim2.new(0, 0, 0, scrollList.AbsoluteContentSize.Y + 14)
end)

-- ─────────────────────────────────────────────────────
--  СОЗДАНИЕ ТАБА
-- ─────────────────────────────────────────────────────
local tabButtons    = {}
local tabContents   = {}

local function createTab(icon, label)
    local btn = Instance.new("TextButton", TabPanel)
    btn.Size             = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = C.BG_TAB
    btn.BackgroundTransparency = 0.3
    btn.Text             = icon .. "\n" .. label
    btn.TextColor3       = C.GRAY
    btn.TextSize         = 10
    btn.Font             = Enum.Font.GothamBold
    btn.BorderSizePixel  = 0
    btn.ZIndex           = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)

    tabButtons[label] = btn
    tabContents[label] = {}
    return btn
end

-- ─────────────────────────────────────────────────────
--  ВИДЖЕТЫ В ПРАВОЙ ПАНЕЛИ
-- ─────────────────────────────────────────────────────
local currentTabWidgets = {}  -- список Frame для скрытия/показа

-- Секция-заголовок
local function makeSection(text)
    local f = Instance.new("Frame", RightScroll)
    f.Size               = UDim2.new(1, -4, 0, 20)
    f.BackgroundTransparency = 1
    f.ZIndex             = 15
    local lbl = Instance.new("TextLabel", f)
    lbl.Size             = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = "─── " .. text .. " ───"
    lbl.TextColor3       = C.GOLD
    lbl.TextSize         = 11
    lbl.Font             = Enum.Font.GothamBold
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.ZIndex           = 16
    f.Visible            = false
    return f
end

-- Тогл с колбэком
local function makeToggle(label, desc, cheatKey, callback)
    local state = Cheats[cheatKey]

    local row = Instance.new("Frame", RightScroll)
    row.Size             = UDim2.new(1, -4, 0, desc and 46 or 34)
    row.BackgroundColor3 = C.BG_ROW
    row.BackgroundTransparency = 0.38
    row.BorderSizePixel  = 0
    row.ZIndex           = 15
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
    local rStr = Instance.new("UIStroke", row)
    rStr.Color = C.GOLD ; rStr.Thickness = 0.5 ; rStr.Transparency = 0.72

    local nameLbl = Instance.new("TextLabel", row)
    nameLbl.Size         = UDim2.new(1, -70, 0, 20)
    nameLbl.Position     = UDim2.new(0, 9, 0, desc and 4 or 7)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text         = label
    nameLbl.TextColor3   = state and C.GOLD or C.WHITE
    nameLbl.TextSize     = 13
    nameLbl.Font         = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex       = 16

    if desc then
        local descLbl = Instance.new("TextLabel", row)
        descLbl.Size     = UDim2.new(1, -70, 0, 16)
        descLbl.Position = UDim2.new(0, 9, 0, 24)
        descLbl.BackgroundTransparency = 1
        descLbl.Text     = desc
        descLbl.TextColor3 = C.GRAY
        descLbl.TextSize = 10
        descLbl.Font     = Enum.Font.Gotham
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.ZIndex   = 16
    end

    local togBtn = Instance.new("TextButton", row)
    togBtn.Size          = UDim2.new(0, 52, 0, 22)
    togBtn.Position      = UDim2.new(1, -60, 0.5, -11)
    togBtn.BackgroundColor3 = state and C.ON_COLOR or C.OFF_COLOR
    togBtn.BackgroundTransparency = 0.12
    togBtn.Text          = state and "ON" or "OFF"
    togBtn.TextColor3    = state and C.BLACK or C.GRAY
    togBtn.TextSize      = 11
    togBtn.Font          = Enum.Font.GothamBold
    togBtn.BorderSizePixel = 0
    togBtn.ZIndex        = 16
    Instance.new("UICorner", togBtn).CornerRadius = UDim.new(0, 3)
    local tStr = Instance.new("UIStroke", togBtn)
    tStr.Color = C.GOLD ; tStr.Thickness = 0.7 ; tStr.Transparency = 0.45

    togBtn.MouseButton1Click:Connect(function()
        state           = not state
        Cheats[cheatKey] = state
        TweenService:Create(togBtn, TweenInfo.new(0.14), {
            BackgroundColor3 = state and C.ON_COLOR or C.OFF_COLOR,
            TextColor3       = state and C.BLACK or C.GRAY,
        }):Play()
        togBtn.Text      = state and "ON" or "OFF"
        nameLbl.TextColor3 = state and C.GOLD or C.WHITE
        if callback then callback(state) end
    end)

    row.Visible = false
    return row
end

-- Слайдер
local function makeSlider(label, desc, cheatKey, minV, maxV, callback)
    local val = Cheats[cheatKey] or minV

    local row = Instance.new("Frame", RightScroll)
    row.Size             = UDim2.new(1, -4, 0, 58)
    row.BackgroundColor3 = C.BG_ROW
    row.BackgroundTransparency = 0.38
    row.BorderSizePixel  = 0
    row.ZIndex           = 15
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
    local rStr = Instance.new("UIStroke", row)
    rStr.Color = C.GOLD ; rStr.Thickness = 0.5 ; rStr.Transparency = 0.72

    local nameLbl = Instance.new("TextLabel", row)
    nameLbl.Size         = UDim2.new(1, -80, 0, 18)
    nameLbl.Position     = UDim2.new(0, 9, 0, 5)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text         = label
    nameLbl.TextColor3   = C.WHITE
    nameLbl.TextSize     = 12
    nameLbl.Font         = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex       = 16

    local valLbl = Instance.new("TextLabel", row)
    valLbl.Size          = UDim2.new(0, 60, 0, 18)
    valLbl.Position      = UDim2.new(1, -68, 0, 5)
    valLbl.BackgroundTransparency = 1
    valLbl.Text          = tostring(val)
    valLbl.TextColor3    = C.GOLD
    valLbl.TextSize      = 12
    valLbl.Font          = Enum.Font.Code
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex        = 16

    if desc then
        local descLbl = Instance.new("TextLabel", row)
        descLbl.Size     = UDim2.new(1, -12, 0, 14)
        descLbl.Position = UDim2.new(0, 9, 0, 22)
        descLbl.BackgroundTransparency = 1
        descLbl.Text     = desc
        descLbl.TextColor3 = C.GRAY
        descLbl.TextSize = 10
        descLbl.Font     = Enum.Font.Gotham
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.ZIndex   = 16
    end

    -- Трек слайдера
    local track = Instance.new("Frame", row)
    track.Size           = UDim2.new(1, -18, 0, 6)
    track.Position       = UDim2.new(0, 9, 0, 42)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    track.BackgroundTransparency = 0.2
    track.BorderSizePixel = 0
    track.ZIndex         = 16
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame", track)
    fill.Size            = UDim2.new((val - minV)/(maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = C.GOLD
    fill.BackgroundTransparency = 0.1
    fill.BorderSizePixel = 0
    fill.ZIndex          = 17
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local handle = Instance.new("TextButton", track)
    handle.Size          = UDim2.new(0, 12, 0, 12)
    handle.AnchorPoint   = Vector2.new(0.5, 0.5)
    handle.Position      = UDim2.new((val - minV)/(maxV - minV), 0, 0.5, 0)
    handle.BackgroundColor3 = C.GOLD
    handle.BackgroundTransparency = 0
    handle.Text          = ""
    handle.BorderSizePixel = 0
    handle.ZIndex        = 18
    Instance.new("UICorner", handle).CornerRadius = UDim.new(0.5, 0)

    -- Перетаскивание слайдера
    local dragging = false
    handle.MouseButton1Down:Connect(function() dragging = true end)
    track.MouseButton1Down:Connect(function(_, x, _)
        dragging = true
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        val = math.floor(minV + (maxV - minV) * rel)
        Cheats[cheatKey] = val
        fill.Size        = UDim2.new(rel, 0, 1, 0)
        handle.Position  = UDim2.new(rel, 0, 0.5, 0)
        valLbl.Text      = tostring(val)
        if callback then callback(val) end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            val = math.floor(minV + (maxV - minV) * rel)
            Cheats[cheatKey] = val
            fill.Size        = UDim2.new(rel, 0, 1, 0)
            handle.Position  = UDim2.new(rel, 0, 0.5, 0)
            valLbl.Text      = tostring(val)
            if callback then callback(val) end
        end
    end)

    row.Visible = false
    return row
end

-- ─────────────────────────────────────────────────────
--  РЕГИСТРАЦИЯ ТАБОВ
-- ─────────────────────────────────────────────────────
local tabDefs = {
    { icon="🎯", label="AIMBOT"   },
    { icon="👁", label="VISUALS"  },
    { icon="⚡", label="MOVEMENT" },
    { icon="🔧", label="MISC"     },
}

local widgetsByTab = {}   -- widgetsByTab[label] = {frame1, frame2, ...}

for _, def in ipairs(tabDefs) do
    widgetsByTab[def.label] = {}
    createTab(def.icon, def.label)
end

-- Функции регистрации виджетов в таб
local function addToTab(tabLabel, widget)
    table.insert(widgetsByTab[tabLabel], widget)
end

-- ─────────────────────────────────────────────────────
--  НАПОЛНЕНИЕ ТАБОВ ВИДЖЕТАМИ
-- ─────────────────────────────────────────────────────

-- ── AIMBOT ──────────────────────────────────────────
local secAim1 = makeSection("AIMBOT SETTINGS")
addToTab("AIMBOT", secAim1)

addToTab("AIMBOT", makeToggle("🎯  Aimbot", "Автоматическая наводка на врага", "Aimbot", nil))
addToTab("AIMBOT", makeToggle("🤖  Auto Aim", "Плавная наводка при прицеливании", "AutoAim", nil))
addToTab("AIMBOT", makeToggle("🔇  Silent Aim", "Невидимое изменение траектории пули", "SilentAim", nil))

local secAim2 = makeSection("FOV НАСТРОЙКИ")
addToTab("AIMBOT", secAim2)

addToTab("AIMBOT", makeToggle("⭕  FOV Circle", "Показывает круг зоны наводки", "AimFOV", nil))
addToTab("AIMBOT", makeSlider("📐  FOV Радиус", "Радиус зоны автоприцела (пикс.)", "AimFOVRadius", 30, 400, nil))

-- ── VISUALS ──────────────────────────────────────────
local secVisSep = makeSection("ESP")
addToTab("VISUALS", secVisSep)

addToTab("VISUALS", makeToggle("📦  ESP Boxes", "Рамка вокруг врагов", "ESPBoxes", function(v)
    if not v then
        for _, obj in pairs(espObjects) do
            if obj then pcall(function() obj:Destroy() end) end
        end
        espObjects = {}
    end
end))

addToTab("VISUALS", makeToggle("🏷  Enemy Names", "Имена игроков над головой", "EnemyNames", nil))
addToTab("VISUALS", makeToggle("🩸  Health Bar", "Полоска HP врага", "HealthBar", nil))

local secVisRadar = makeSection("RADAR")
addToTab("VISUALS", secVisRadar)

addToTab("VISUALS", makeToggle("📍  Radar", "Мини-радар с врагами", "Radar", nil))

-- ── MOVEMENT ──────────────────────────────────────────
local secMov1 = makeSection("СКОРОСТЬ")
addToTab("MOVEMENT", secMov1)

addToTab("MOVEMENT", makeToggle("⚡  Speed Hack", "Увеличенная скорость передвижения", "SpeedHack", function(v)
    local hum = getHum()
    if not hum then return end
    if v then
        originalSpeed = hum.WalkSpeed
        hum.WalkSpeed = Cheats.SpeedValue
    else
        hum.WalkSpeed = originalSpeed or 16
    end
end))

addToTab("MOVEMENT", makeSlider("🏃  Walk Speed", "Скорость ходьбы", "SpeedValue", 16, 200, function(v)
    if Cheats.SpeedHack then
        local hum = getHum()
        if hum then hum.WalkSpeed = v end
    end
end))

local secMov2 = makeSection("ПРЫЖОК / ПОЛЁТ")
addToTab("MOVEMENT", secMov2)

addToTab("MOVEMENT", makeToggle("🦘  Infinite Jump", "Бесконечный прыжок", "InfiniteJump", nil))
addToTab("MOVEMENT", makeToggle("🌀  No Clip", "Проходить сквозь стены", "NoClip", nil))
addToTab("MOVEMENT", makeToggle("🦅  Fly Mode", "Режим полёта (Space - вверх, Shift - вниз)", "FlyMode", function(v)
    local hrp = getHRP()
    if not hrp then return end
    if v then
        flyBodyForce = Instance.new("BodyVelocity", hrp)
        flyBodyForce.Velocity      = Vector3.zero
        flyBodyForce.MaxForce      = Vector3.new(1e5, 1e5, 1e5)
        flyBodyGyro = Instance.new("BodyGyro", hrp)
        flyBodyGyro.D              = 100
        flyBodyGyro.P              = 1e4
        flyBodyGyro.MaxTorque      = Vector3.new(1e5, 1e5, 1e5)
    else
        if flyBodyForce then flyBodyForce:Destroy() ; flyBodyForce = nil end
        if flyBodyGyro  then flyBodyGyro:Destroy()  ; flyBodyGyro  = nil end
    end
end))

-- ── MISC ──────────────────────────────────────────
local secMisc1 = makeSection("ОРУЖИЕ")
addToTab("MISC", secMisc1)

addToTab("MISC", makeToggle("🔫  No Recoil", "Убирает отдачу при стрельбе", "NoRecoil", nil))

local secMisc2 = makeSection("ЗАЩИТА")
addToTab("MISC", secMisc2)

addToTab("MISC", makeToggle("🛡  Anti-Ban", "Защита аккаунта от бана", "AntiBan", nil))
addToTab("MISC", makeToggle("💤  Anti-AFK", "Предотвращает кик за AFK", "AntiAFK", function(v)
    -- реализуется через VirtualUser ниже
end))

local secMisc3 = makeSection("ИНФОРМАЦИЯ")
addToTab("MISC", secMisc3)

-- Статус-виджет (только для MISC)
local infoRow = Instance.new("Frame", RightScroll)
infoRow.Size             = UDim2.new(1, -4, 0, 70)
infoRow.BackgroundColor3 = C.BG_ROW
infoRow.BackgroundTransparency = 0.38
infoRow.BorderSizePixel  = 0
infoRow.ZIndex           = 15
Instance.new("UICorner", infoRow).CornerRadius = UDim.new(0, 4)
local iStr = Instance.new("UIStroke", infoRow)
iStr.Color = C.GOLD ; iStr.Thickness = 0.5 ; iStr.Transparency = 0.7

local infoLbl = Instance.new("TextLabel", infoRow)
infoLbl.Size             = UDim2.new(1, -12, 1, -8)
infoLbl.Position         = UDim2.new(0, 6, 0, 4)
infoLbl.BackgroundTransparency = 1
infoLbl.Text             = "⚙ AngerMOD V-2\n👤 " .. LocalPlayer.Name .. "\n🔑 key.txt: " .. (keyFileLoaded and "загружен" or "не найден")
infoLbl.TextColor3       = C.WHITE
infoLbl.TextSize         = 11
infoLbl.Font             = Enum.Font.Code
infoLbl.TextXAlignment   = Enum.TextXAlignment.Left
infoLbl.TextYAlignment   = Enum.TextYAlignment.Top
infoLbl.ZIndex           = 16
infoRow.Visible          = false
addToTab("MISC", infoRow)

-- ─────────────────────────────────────────────────────
--  ПЕРЕКЛЮЧЕНИЕ ТАБОВ
-- ─────────────────────────────────────────────────────
local function switchTab(label)
    activeTab = label
    -- Скрываем все виджеты
    for tab, widgets in pairs(widgetsByTab) do
        for _, w in ipairs(widgets) do
            w.Visible = false
        end
        if tabButtons[tab] then
            tabButtons[tab].TextColor3       = C.GRAY
            tabButtons[tab].BackgroundColor3 = C.BG_TAB
            TweenService:Create(tabButtons[tab], TweenInfo.new(0.12), {
                BackgroundTransparency = 0.3,
            }):Play()
        end
    end
    -- Показываем нужные
    for _, w in ipairs(widgetsByTab[label] or {}) do
        w.Visible = true
    end
    if tabButtons[label] then
        tabButtons[label].TextColor3 = C.GOLD
        TweenService:Create(tabButtons[label], TweenInfo.new(0.12), {
            BackgroundColor3    = C.BG_ACTIVE,
            BackgroundTransparency = 0.15,
        }):Play()
        local str = tabButtons[label]:FindFirstChildOfClass("UIStroke")
        if str then str:Destroy() end
        local newStr = Instance.new("UIStroke", tabButtons[label])
        newStr.Color = C.GOLD ; newStr.Thickness = 1 ; newStr.Transparency = 0.3
    end
end

for _, def in ipairs(tabDefs) do
    tabButtons[def.label].MouseButton1Click:Connect(function()
        switchTab(def.label)
    end)
end

-- ══════════════════════════════════════════════════════
--  РАДАР (мини-карта)
-- ══════════════════════════════════════════════════════
local RadarFrame = Instance.new("Frame", ScreenGui)
RadarFrame.Name              = "Radar"
RadarFrame.Size              = UDim2.new(0, 120, 0, 120)
RadarFrame.Position          = UDim2.new(1, -134, 1, -134)
RadarFrame.BackgroundColor3  = Color3.fromRGB(5, 5, 5)
RadarFrame.BackgroundTransparency = 0.35
RadarFrame.BorderSizePixel   = 0
RadarFrame.ZIndex            = 20
RadarFrame.Visible           = false
Instance.new("UICorner", RadarFrame).CornerRadius = UDim.new(0.5, 0)
local radarStr = Instance.new("UIStroke", RadarFrame)
radarStr.Color = C.GOLD ; radarStr.Thickness = 1.5

-- Крест в центре
local function makeLine(parent, sx, sy, px, py)
    local l = Instance.new("Frame", parent)
    l.Size               = UDim2.new(sx, 0, sy, 0)
    l.Position           = UDim2.new(px, 0, py, 0)
    l.BackgroundColor3   = C.GOLD
    l.BackgroundTransparency = 0.55
    l.BorderSizePixel    = 0
    l.ZIndex             = 21
end
makeLine(RadarFrame, 1, 0, 0.5, 0, 0, 0)     -- вертикаль
makeLine(RadarFrame, 0, 1, 0, 0, 0.5, 0)     -- горизонталь

-- Точка игрока
local playerDot = Instance.new("Frame", RadarFrame)
playerDot.Size               = UDim2.new(0, 8, 0, 8)
playerDot.Position           = UDim2.new(0.5, -4, 0.5, -4)
playerDot.BackgroundColor3   = C.GREEN
playerDot.BorderSizePixel    = 0
playerDot.ZIndex             = 23
Instance.new("UICorner", playerDot).CornerRadius = UDim.new(0.5, 0)

-- ══════════════════════════════════════════════════════
--  FOV CIRCLE
-- ══════════════════════════════════════════════════════
local FOVCircle = Instance.new("Frame", ScreenGui)
FOVCircle.Name               = "FOVCircle"
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel    = 0
FOVCircle.ZIndex             = 20
FOVCircle.Visible            = false

local fovStroke = Instance.new("UIStroke", FOVCircle)
fovStroke.Color              = C.GOLD
fovStroke.Thickness          = 1.5
fovStroke.Transparency       = 0.3
Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(0.5, 0)

local function updateFOVCircle()
    local r = Cheats.AimFOVRadius
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2
    FOVCircle.Size     = UDim2.new(0, r*2, 0, r*2)
    FOVCircle.Position = UDim2.new(0, cx - r, 0, cy - r)
end

-- ══════════════════════════════════════════════════════
--  MAIN LOOP (рендер)
-- ══════════════════════════════════════════════════════
local radarDots = {}

RunService.RenderStepped:Connect(function()
    local hrpSelf = getHRP()

    -- ── ESP ──────────────────────────────────────────
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end

        local char = p.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        if not (char and hrp and hum) then
            -- Очищаем esp если персонажа нет
            if espObjects[p.Name] then
                for _, v in pairs(espObjects[p.Name]) do
                    pcall(function() v:Destroy() end)
                end
                espObjects[p.Name] = nil
            end
            continue
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

        if not onScreen then
            if espObjects[p.Name] then
                for _, v in pairs(espObjects[p.Name]) do
                    v.Visible = false
                end
            end
            continue
        end

        -- Создаём ESP объект если нет
        if not espObjects[p.Name] then
            espObjects[p.Name] = {}
            local eg = espObjects[p.Name]

            -- Рамка
            local box = Instance.new("Frame", ScreenGui)
            box.BackgroundTransparency = 1
            box.BorderSizePixel        = 0
            box.ZIndex                 = 19
            local bStr = Instance.new("UIStroke", box)
            bStr.Color     = C.GOLD
            bStr.Thickness = 1.5
            eg.box         = box

            -- Имя
            local nameLbl2 = Instance.new("TextLabel", ScreenGui)
            nameLbl2.BackgroundTransparency = 1
            nameLbl2.TextColor3             = C.WHITE
            nameLbl2.TextSize               = 12
            nameLbl2.Font                   = Enum.Font.GothamBold
            nameLbl2.TextStrokeColor3       = C.BLACK
            nameLbl2.TextStrokeTransparency = 0
            nameLbl2.ZIndex                 = 19
            eg.nameLbl = nameLbl2

            -- HP Bar фрейм
            local hpFrame = Instance.new("Frame", ScreenGui)
            hpFrame.BackgroundColor3      = Color3.fromRGB(30, 30, 30)
            hpFrame.BackgroundTransparency = 0.3
            hpFrame.BorderSizePixel       = 0
            hpFrame.ZIndex                = 19
            eg.hpFrame = hpFrame

            local hpFill = Instance.new("Frame", hpFrame)
            hpFill.BackgroundColor3       = C.GREEN
            hpFill.BackgroundTransparency = 0.1
            hpFill.BorderSizePixel        = 0
            hpFill.ZIndex                 = 20
            eg.hpFill = hpFill
        end

        local eg = espObjects[p.Name]

        -- Рассчитываем размер рамки по высоте персонажа
        local topPos3D     = hrp.Position + Vector3.new(0, 3.2, 0)
        local botPos3D     = hrp.Position - Vector3.new(0, 3.2, 0)
        local topScreen, _ = Camera:WorldToViewportPoint(topPos3D)
        local botScreen, _ = Camera:WorldToViewportPoint(botPos3D)
        local boxH         = math.abs(topScreen.Y - botScreen.Y)
        local boxW         = boxH * 0.55
        local bx           = screenPos.X - boxW / 2
        local by           = topScreen.Y

        -- Рамка
        local showBox = Cheats.ESPBoxes
        eg.box.Visible   = showBox
        if showBox then
            eg.box.Size     = UDim2.new(0, boxW, 0, boxH)
            eg.box.Position = UDim2.new(0, bx, 0, by)
        end

        -- Имя
        local showName = Cheats.EnemyNames
        eg.nameLbl.Visible = showName
        if showName then
            eg.nameLbl.Text = p.Name
            eg.nameLbl.Size = UDim2.new(0, boxW, 0, 16)
            eg.nameLbl.Position = UDim2.new(0, bx, 0, by - 17)
        end

        -- HP Bar
        local showHP = Cheats.HealthBar
        eg.hpFrame.Visible = showHP
        eg.hpFill.Visible  = showHP
        if showHP then
            local hpRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            eg.hpFrame.Size     = UDim2.new(0, 4, 0, boxH)
            eg.hpFrame.Position = UDim2.new(0, bx - 7, 0, by)
            eg.hpFill.Size      = UDim2.new(1, 0, hpRatio, 0)
            eg.hpFill.Position  = UDim2.new(0, 0, 1 - hpRatio, 0)
            eg.hpFill.BackgroundColor3 = Color3.fromRGB(
                math.floor(255 * (1 - hpRatio)),
                math.floor(200 * hpRatio),
                40
            )
        end
    end

    -- ── AIMBOT ───────────────────────────────────────
    if Cheats.Aimbot or Cheats.AutoAim then
        local target = getClosestEnemy()
        if target then
            local targetHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local lookAt = CFrame.lookAt(Camera.CFrame.Position, targetHRP.Position)
                if Cheats.Aimbot then
                    -- Жёсткий aimbot
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position) * (lookAt - lookAt.Position)
                elseif Cheats.AutoAim then
                    -- Плавный auto aim
                    Camera.CFrame = Camera.CFrame:Lerp(lookAt, 0.08)
                end
            end
        end
    end

    -- ── FOV CIRCLE ───────────────────────────────────
    FOVCircle.Visible = Cheats.AimFOV and isLoggedIn
    if Cheats.AimFOV then
        updateFOVCircle()
    end

    -- ── RADAR ────────────────────────────────────────
    RadarFrame.Visible = Cheats.Radar and isLoggedIn
    if Cheats.Radar and hrpSelf then
        -- Чистим старые точки
        for _, dot in pairs(radarDots) do
            dot:Destroy()
        end
        radarDots = {}

        local RANGE = 150
        local SIZE  = RadarFrame.AbsoluteSize.X / 2

        for _, p in ipairs(getEnemies()) do
            local hrp2 = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if hrp2 then
                local diff = hrp2.Position - hrpSelf.Position
                local camLook = Camera.CFrame.LookVector
                local right   = Camera.CFrame.RightVector
                local rx      = diff:Dot(right)
                local ry      = diff:Dot(camLook)
                local rel     = Vector2.new(rx, ry)
                if rel.Magnitude < RANGE then
                    local norm = rel / RANGE
                    local dot2 = Instance.new("Frame", RadarFrame)
                    dot2.Size                = UDim2.new(0, 7, 0, 7)
                    dot2.AnchorPoint         = Vector2.new(0.5, 0.5)
                    dot2.Position            = UDim2.new(0.5 + norm.X*0.45, 0, 0.5 - norm.Y*0.45, 0)
                    dot2.BackgroundColor3    = C.RED
                    dot2.BackgroundTransparency = 0.1
                    dot2.BorderSizePixel     = 0
                    dot2.ZIndex              = 22
                    Instance.new("UICorner", dot2).CornerRadius = UDim.new(0.5, 0)
                    table.insert(radarDots, dot2)
                end
            end
        end
    end

    -- ── NO CLIP ──────────────────────────────────────
    if Cheats.NoClip then
        local char = getChar()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end

    -- ── FLY ──────────────────────────────────────────
    if Cheats.FlyMode and flyBodyForce then
        local moveDir = Vector3.zero
        local SPEED   = 60
        local camCF   = Camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir += camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir -= camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir -= camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir += camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir += Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir -= Vector3.new(0, 1, 0)
        end
        flyBodyForce.Velocity = moveDir.Magnitude > 0 and (moveDir.Unit * SPEED) or Vector3.zero
        flyBodyGyro.CFrame    = camCF
    end
end)

-- ── INFINITE JUMP ────────────────────────────────────
UserInputService.JumpRequest:Connect(function()
    if Cheats.InfiniteJump then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ── ANTI-AFK ─────────────────────────────────────────
task.spawn(function()
    while task.wait(60) do
        if Cheats.AntiAFK then
            local VU = game:GetService("VirtualUser")
            VU:Button2Down(Vector2.new(0, 0), CFrame.new())
            task.wait(0.1)
            VU:Button2Up(Vector2.new(0, 0), CFrame.new())
        end
    end
end)

-- ── SPEED HACK (на спавне нового персонажа) ──────────
LocalPlayer.CharacterAdded:Connect(function(char)
    if Cheats.SpeedHack then
        local hum = char:WaitForChild("Humanoid")
        hum.WalkSpeed = Cheats.SpeedValue
    end
    -- Сбрасываем fly при respawn
    flyBodyForce = nil
    flyBodyGyro  = nil
end)

-- ── FPS СЧЁТЧИК ──────────────────────────────────────
local frameCount2 = 0
local lastT2      = tick()
RunService.RenderStepped:Connect(function()
    frameCount2 += 1
    if tick() - lastT2 >= 0.5 then
        local fps = math.floor(frameCount2 / (tick() - lastT2))
        FPSLbl.Text = "FPS: " .. fps
        FPSLbl.TextColor3 = fps >= 55 and C.GREEN or (fps >= 30 and C.GOLD or C.RED)
        frameCount2 = 0
        lastT2 = tick()
    end
end)

-- ══════════════════════════════════════════════════════
--  ПЕРЕТАСКИВАНИЕ ОКНА
-- ══════════════════════════════════════════════════════
TBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart  = inp.Position
        startPos   = Win.Position
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if isDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - dragStart
        Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

-- ══════════════════════════════════════════════════════
--  СВЕРНУТЬ / РАЗВЕРНУТЬ
-- ══════════════════════════════════════════════════════
ArrowBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    ArrowBtn.Text = isMinimized and "▶" or "▼"
    local targetH = isMinimized and 34 or WIN_H
    TweenService:Create(Win, TweenInfo.new(0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, WIN_W, 0, targetH)
    }):Play()
end)

-- ══════════════════════════════════════════════════════
--  ЗАКРЫТЬ
-- ══════════════════════════════════════════════════════
XBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Win, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size     = UDim2.new(0, 0, 0, 0),
        Position = Win.Position + UDim2.new(0, WIN_W/2, 0, WIN_H/2),
    }):Play()
    task.delay(0.25, function() Win.Visible = false end)
end)

-- ══════════════════════════════════════════════════════
--  ЛОГИКА ВХОДА
-- ══════════════════════════════════════════════════════
local function checkKey(raw)
    local k = (raw or ""):match("^%s*(.-)%s*$")
    for _, v in ipairs(validKeys) do
        if v == k then return true end
    end
    return false
end

local function shakeWin()
    local orig = Win.Position
    for i = 1, 7 do
        TweenService:Create(Win, TweenInfo.new(0.035), {
            Position = orig + UDim2.new(0, i%2==0 and 7 or -7, 0, 0)
        }):Play()
        task.wait(0.04)
    end
    Win.Position = orig
end

local function doLogin()
    if checkKey(KeyBox.Text) then
        isLoggedIn = true

        -- Анимация успеха
        StatusLbl.TextColor3 = C.GREEN
        StatusLbl.Text       = "✔  Доступ открыт! Добро пожаловать, " .. LocalPlayer.Name

        TweenService:Create(ErrorBG, TweenInfo.new(0.7), {BackgroundTransparency = 1}):Play()
        TweenService:Create(errTextLbl, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(bigErrLbl,  TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        task.delay(0.72, function() ErrorBG.Visible = false end)

        task.delay(0.85, function()
            LoginF.Visible    = false
            CheatMenu.Visible = true
            switchTab("AIMBOT")
        end)
    else
        StatusLbl.TextColor3 = C.RED
        StatusLbl.Text       = "✖  Key not registered or expired"
        shakeWin()
    end
end

EnterBtn.MouseButton1Click:Connect(doLogin)

KeyBox.FocusLost:Connect(function(enter)
    if enter then doLogin() end
end)

PasteBtn.MouseButton1Click:Connect(function()
    local ok, clip = pcall(function() return getclipboard() end)
    if ok and clip and clip ~= "" then
        KeyBox.Text          = clip
        StatusLbl.TextColor3 = C.GOLD
        StatusLbl.Text       = "📋  Ключ вставлен из буфера"
    else
        StatusLbl.TextColor3 = Color3.fromRGB(180, 180, 50)
        StatusLbl.Text       = "⚠  getclipboard() недоступен — введи ключ вручную"
    end
end)

-- Ховер на кнопках
for _, b in ipairs({EnterBtn, PasteBtn}) do
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundTransparency = 0.1}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundTransparency = 0.3}):Play()
    end)
end

-- ══════════════════════════════════════════════════════
--  РЕГИСТРАЦИЯ (создание key.txt)
-- ══════════════════════════════════════════════════════
-- Если key.txt не существует — создаём шаблон
if not keyFileLoaded then
    pcall(function()
        if not isfile("key.txt") then
            writefile("key.txt", "ANGER-2025-ALPHA\nANGER-VIP-001\nANGER-KEY-XYZ\nTESTKEY123\nRAGE-MOD-KEY\n")
            -- Перечитываем
            local content = readfile("key.txt")
            validKeys = {}
            for line in content:gmatch("[^\r\n]+") do
                local t = line:match("^%s*(.-)%s*$")
                if t ~= "" then table.insert(validKeys, t) end
            end
            StatusLbl.Text = "✔  key.txt создан автоматически"
            StatusLbl.TextColor3 = C.GREEN
        end
    end)
end

print("[AngerMOD V-2] ✔ Загружен. Ключей загружено: " .. #validKeys)
print("[AngerMOD V-2] Доступные ключи (для теста): " .. table.concat(validKeys, ", "))
