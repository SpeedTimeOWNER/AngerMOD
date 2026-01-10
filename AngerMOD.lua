-- [[ ⛧ AngerPC ⛧ V126 REC-FIX ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

-- [[ DELTA COMPATIBILITY ]] --
local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local getcustomasset = getcustomasset or getsynasset

-- [[ SESSION INFO ]] --
local SessionID = string.upper(HttpService:GenerateGUID(false):sub(1, 8))

-- [[ MEMORY SYSTEM (AI) ]] --
local ChatHistory = {
    {
        role = "system",
        content = "Ты — AngerPC, крутой ИИ-бот в Roblox. Создатель: AngerPC-DEV. Характер: дерзкий, краткий."
    }
}

-- [[ THEME SYSTEM ]] --
local Themes = { "RGB", "БЕЛЫЙ", "СЕРЫЙ", "ГОЛУБОЙ", "ФИОЛЕТОВЫЙ", "НЕОБЫЧНЫЙ", "РОЗОВЫЙ", "КРАСНЫЙ" }
local ThemeColors = {
    ["БЕЛЫЙ"] = Color3.new(1, 1, 1), ["СЕРЫЙ"] = Color3.fromRGB(120, 120, 120),
    ["ГОЛУБОЙ"] = Color3.fromRGB(0, 190, 255), ["ФИОЛЕТОВЫЙ"] = Color3.fromRGB(170, 0, 255),
    ["НЕОБЫЧНЫЙ"] = Color3.fromRGB(255, 170, 0), ["РОЗОВЫЙ"] = Color3.fromRGB(255, 105, 180),
    ["КРАСНЫЙ"] = Color3.fromRGB(255, 0, 0)
}
local CurrentThemeIndex = 1 

-- [[ 1. GUI SETUP ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AngerGUI_V126"
ScreenGui.ResetOnSpawn = false 

if Player:FindFirstChild("PlayerGui") then
    ScreenGui.Parent = Player.PlayerGui
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

-- DEATH SCREEN
local DeathScreen = Instance.new("ScreenGui", ScreenGui.Parent)
DeathScreen.Name = "AngerDeath"; DeathScreen.Enabled = false
local DeathLabel = Instance.new("TextLabel", DeathScreen); DeathLabel.Size = UDim2.new(1, 0, 1, 0); DeathLabel.BackgroundTransparency = 1; DeathLabel.Text = "WASTED"; DeathLabel.Font = Enum.Font.Creepster; DeathLabel.TextSize = 100; DeathLabel.TextColor3 = Color3.fromRGB(255, 0, 0); DeathLabel.TextStrokeTransparency = 0

-- LISTS & VARS
local RGB_Objects = {} 
local Movable_Objects = {} 
local RecordedPath = {}
local UI_Unlocked = false 

local function style(obj, radius, thickness)
    local uiC = Instance.new("UICorner", obj); uiC.CornerRadius = UDim.new(0, radius or 6)
    local uiS = Instance.new("UIStroke", obj); uiS.Color = Color3.fromRGB(60, 60, 60); uiS.Thickness = thickness or 1
    table.insert(RGB_Objects, {Type = "Stroke", Instance = uiS})
    return uiS
end

-- [[ NOTIFICATION SYSTEM ]] --
local NotifyContainer = Instance.new("Frame", ScreenGui)
NotifyContainer.Size = UDim2.new(0, 250, 0.4, 0)
NotifyContainer.Position = UDim2.new(1, -260, 0.55, 0) -- Bottom Right
NotifyContainer.BackgroundTransparency = 1
local NotifyLayout = Instance.new("UIListLayout", NotifyContainer)
NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifyLayout.Padding = UDim.new(0, 5)

local function Notify(text)
    local f = Instance.new("Frame", NotifyContainer)
    f.Size = UDim2.new(1, 0, 0, 35)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    f.BackgroundTransparency = 0.2
    style(f, 4, 1)
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -10, 1, 0)
    l.Position = UDim2.new(0, 5, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.new(1, 1, 1)
    l.Font = Enum.Font.SciFi
    l.TextSize = 14
    l.TextXAlignment = Enum.TextXAlignment.Left
    
    f.BackgroundTransparency = 1
    l.TextTransparency = 1
    TweenService:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 0.2}):Play()
    TweenService:Create(l, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    
    task.delay(3, function()
        TweenService:Create(f, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(l, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        task.wait(0.5)
        f:Destroy()
    end)
end

-- // MAIN MENU // --
local Main = Instance.new("Frame", ScreenGui); Main.Size = UDim2.new(0, 480, 0, 550); Main.Position = UDim2.new(0.1, 0, 0.2, 0); Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Main.Visible = true; Main.Active = true; Main.Draggable = true; style(Main, 8, 2); table.insert(Movable_Objects, Main)

-- TABS
local TabFrame = Instance.new("Frame", Main); TabFrame.Size = UDim2.new(1, -20, 0, 30); TabFrame.Position = UDim2.new(0, 10, 0, 50); TabFrame.BackgroundTransparency = 1
local layoutTabs = Instance.new("UIListLayout", TabFrame); layoutTabs.FillDirection=Enum.FillDirection.Horizontal; layoutTabs.Padding=UDim.new(0,5)

local function MakeTab(text)
    local b = Instance.new("TextButton", TabFrame); b.Size=UDim2.new(0.19,0,1,0); b.BackgroundColor3=Color3.fromRGB(20,20,20); b.Text=text; b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.SciFi; style(b); b.TextScaled = true
    return b
end
local btnTabMain = MakeTab("MAIN"); local btnTabInfo = MakeTab("INFO"); local btnTabAI = MakeTab("AI"); local btnTabWorld = MakeTab("WORLD"); local btnTabUI = MakeTab("UI")

-- TITLE
local Title = Instance.new("TextLabel", Main); Title.Size=UDim2.new(1,0,0,45); Title.BackgroundTransparency=1; Title.Text="AngerPC V126 (REC FIXED)"; Title.Font=Enum.Font.SciFi; Title.TextSize=24; Title.TextColor3=Color3.new(1,1,1); table.insert(RGB_Objects, {Type="Text", Instance=Title})

-- // PAGES // --
local PageMain = Instance.new("ScrollingFrame", Main); PageMain.Size=UDim2.new(1,-20,0.78,0); PageMain.Position=UDim2.new(0,10,0.18,0); PageMain.BackgroundTransparency=1; PageMain.ScrollBarThickness=2; PageMain.Visible=true; Instance.new("UIListLayout", PageMain).Padding=UDim.new(0,8)
local PageInfo = Instance.new("Frame", Main); PageInfo.Size=UDim2.new(1,-20,0.78,0); PageInfo.Position=UDim2.new(0,10,0.18,0); PageInfo.BackgroundTransparency=1; PageInfo.Visible=false
local PageAI = Instance.new("Frame", Main); PageAI.Size=UDim2.new(1,-20,0.78,0); PageAI.Position=UDim2.new(0,10,0.18,0); PageAI.BackgroundTransparency=1; PageAI.Visible=false
local PageWorld = Instance.new("Frame", Main); PageWorld.Size=UDim2.new(1,-20,0.78,0); PageWorld.Position=UDim2.new(0,10,0.18,0); PageWorld.BackgroundTransparency=1; PageWorld.Visible=false
local PageUI = Instance.new("Frame", Main); PageUI.Size=UDim2.new(1,-20,0.78,0); PageUI.Position=UDim2.new(0,10,0.18,0); PageUI.BackgroundTransparency=1; PageUI.Visible=false

btnTabMain.MouseButton1Click:Connect(function() PageMain.Visible=true; PageInfo.Visible=false; PageAI.Visible=false; PageWorld.Visible=false; PageUI.Visible=false end)
btnTabInfo.MouseButton1Click:Connect(function() PageMain.Visible=false; PageInfo.Visible=true; PageAI.Visible=false; PageWorld.Visible=false; PageUI.Visible=false end)
btnTabAI.MouseButton1Click:Connect(function() PageMain.Visible=false; PageInfo.Visible=false; PageAI.Visible=true; PageWorld.Visible=false; PageUI.Visible=false end)
btnTabWorld.MouseButton1Click:Connect(function() PageMain.Visible=false; PageInfo.Visible=false; PageAI.Visible=false; PageWorld.Visible=true; PageUI.Visible=false end)
btnTabUI.MouseButton1Click:Connect(function() PageMain.Visible=false; PageInfo.Visible=false; PageAI.Visible=false; PageWorld.Visible=false; PageUI.Visible=true end)

-- INFO PAGE
local InfoLabel = Instance.new("TextLabel", PageInfo); InfoLabel.Size = UDim2.new(1,0,1,0); InfoLabel.BackgroundTransparency = 1; InfoLabel.TextColor3 = Color3.new(1,1,1); InfoLabel.TextSize = 18; InfoLabel.TextYAlignment = Enum.TextYAlignment.Top; InfoLabel.Text = "Loading stats..."

-- // WORLD PAGE // --
local FogBtn = Instance.new("TextButton", PageWorld); FogBtn.Size = UDim2.new(1, 0, 0, 40); FogBtn.Position=UDim2.new(0,0,0,0); FogBtn.Text = "REMOVE FOG: OFF"; FogBtn.BackgroundColor3 = Color3.fromRGB(30, 10, 10); FogBtn.TextColor3 = Color3.new(1, 1, 1); style(FogBtn)
local AmbientBtn = Instance.new("TextButton", PageWorld); AmbientBtn.Size = UDim2.new(1, 0, 0, 40); AmbientBtn.Position=UDim2.new(0,0,0.1,0); AmbientBtn.Text = "AMBIENT SYNC: OFF"; AmbientBtn.BackgroundColor3 = Color3.fromRGB(30, 10, 10); AmbientBtn.TextColor3 = Color3.new(1, 1, 1); style(AmbientBtn)
local SkyBox = Instance.new("TextBox", PageWorld); SkyBox.Size = UDim2.new(1, 0, 0, 40); SkyBox.Position=UDim2.new(0,0,0.25,0); SkyBox.PlaceholderText = "CUSTOM SKY ID"; SkyBox.Text = ""; SkyBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20); SkyBox.TextColor3 = Color3.new(1, 1, 1); style(SkyBox)
local SetSkyBtn = Instance.new("TextButton", PageWorld); SetSkyBtn.Size = UDim2.new(1, 0, 0, 40); SetSkyBtn.Position=UDim2.new(0,0,0.35,0); SetSkyBtn.Text = "APPLY CUSTOM SKY"; SetSkyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); SetSkyBtn.TextColor3 = Color3.new(1, 1, 1); style(SetSkyBtn)
local SpaceSkyBtn = Instance.new("TextButton", PageWorld); SpaceSkyBtn.Size = UDim2.new(1, 0, 0, 40); SpaceSkyBtn.Position=UDim2.new(0,0,0.45,0); SpaceSkyBtn.Text = "SET SPACE SKY"; SpaceSkyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40); SpaceSkyBtn.TextColor3 = Color3.new(1, 1, 1); style(SpaceSkyBtn)

-- // AI PAGE // --
local AIKeyBox = Instance.new("TextBox", PageAI); AIKeyBox.Size = UDim2.new(1, 0, 0, 40); AIKeyBox.Position = UDim2.new(0,0,0,0); AIKeyBox.PlaceholderText = "OPENAI KEY"; AIKeyBox.Text = ""; AIKeyBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20); AIKeyBox.TextColor3 = Color3.new(1, 1, 1); style(AIKeyBox)
local AIToggleBtn = Instance.new("TextButton", PageAI); AIToggleBtn.Size = UDim2.new(1, 0, 0, 40); AIToggleBtn.Position = UDim2.new(0, 0, 0.1, 0); AIToggleBtn.Text = "AI AUTOREPLY: OFF"; AIToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 10, 10); AIToggleBtn.TextColor3 = Color3.new(1, 1, 1); style(AIToggleBtn)
local FriendBtn = Instance.new("TextButton", PageAI); FriendBtn.Size = UDim2.new(1, 0, 0, 40); FriendBtn.Position = UDim2.new(0, 0, 0.2, 0); FriendBtn.Text = "FRIEND BOT: OFF"; FriendBtn.BackgroundColor3 = Color3.fromRGB(30, 10, 10); FriendBtn.TextColor3 = Color3.new(1, 1, 1); style(FriendBtn)
local RecBtn = Instance.new("TextButton", PageAI); RecBtn.Size = UDim2.new(0.48, 0, 0, 40); RecBtn.Position = UDim2.new(0, 0, 0.4, 0); RecBtn.Text = "RECORD"; RecBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 10); RecBtn.TextColor3 = Color3.new(1, 1, 1); style(RecBtn)
local PlayBtn = Instance.new("TextButton", PageAI); PlayBtn.Size = UDim2.new(0.48, 0, 0, 40); PlayBtn.Position = UDim2.new(0.52, 0, 0.4, 0); PlayBtn.Text = "PLAY"; PlayBtn.BackgroundColor3 = Color3.fromRGB(10, 40, 10); PlayBtn.TextColor3 = Color3.new(1, 1, 1); style(PlayBtn)
local LoopBtn = Instance.new("TextButton", PageAI); LoopBtn.Size = UDim2.new(1, 0, 0, 40); LoopBtn.Position = UDim2.new(0, 0, 0.5, 0); LoopBtn.Text = "LOOP PLAYBACK: OFF"; LoopBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); LoopBtn.TextColor3 = Color3.new(1, 1, 1); style(LoopBtn)
local AIStatus = Instance.new("TextLabel", PageAI); AIStatus.Size = UDim2.new(1, 0, 0, 30); AIStatus.Position = UDim2.new(0, 0, 0.62, 0); AIStatus.BackgroundTransparency = 1; AIStatus.Text = "STATUS: IDLE"; AIStatus.TextColor3 = Color3.fromRGB(150, 150, 150); style(AIStatus, 0, 0)

-- // UI PAGE // --
local UnlockBtn = Instance.new("TextButton", PageUI); UnlockBtn.Size = UDim2.new(1, 0, 0, 40); UnlockBtn.Position = UDim2.new(0,0,0,0); UnlockBtn.Text = "UNLOCK MOVING: OFF"; UnlockBtn.BackgroundColor3 = Color3.fromRGB(30,10,10); UnlockBtn.TextColor3 = Color3.new(1,1,1); style(UnlockBtn)
local SaveBtn = Instance.new("TextButton", PageUI); SaveBtn.Size = UDim2.new(1, 0, 0, 40); SaveBtn.Position = UDim2.new(0,0,0.12,0); SaveBtn.Text = "SAVE CONFIG"; SaveBtn.BackgroundColor3 = Color3.fromRGB(20,20,40); SaveBtn.TextColor3 = Color3.new(1,1,1); style(SaveBtn)

-- FLY BUTTONS
local btnUp = Instance.new("TextButton", PageWorld); btnUp.Size = UDim2.new(0.45, 0, 0, 40); btnUp.Position = UDim2.new(0, 0, 0.6, 0); btnUp.Text = "FLY UP"; btnUp.BackgroundColor3 = Color3.fromRGB(20,20,20); btnUp.TextColor3 = Color3.new(1,1,1); style(btnUp)
local btnDn = Instance.new("TextButton", PageWorld); btnDn.Size = UDim2.new(0.45, 0, 0, 40); btnDn.Position = UDim2.new(0.5, 0, 0.6, 0); btnDn.Text = "FLY DOWN"; btnDn.BackgroundColor3 = Color3.fromRGB(20,20,20); btnDn.TextColor3 = Color3.new(1,1,1); style(btnDn)

local SideBtn = Instance.new("TextButton", ScreenGui); SideBtn.Name = "ToggleMenu"; SideBtn.Size = UDim2.new(0, 50, 0, 50); SideBtn.Position = UDim2.new(0, 10, 0.5, 0); SideBtn.Text = "O/C"; SideBtn.BackgroundColor3 = Color3.fromRGB(20,20,20); SideBtn.TextColor3 = Color3.new(1,1,1); style(SideBtn, 16); table.insert(Movable_Objects, SideBtn)

-- [[ 2. LOGIC ]] --
local States = { 
    Watermark = true, Aim = false, Hitbox = false, AntiKnockback = false, UnlockAll = false,
    SpdBypass = false, Fly = false, Spd = false, Jump = false, Circle = false, UsePentagram = false,
    Ghosts = false, Esp = false, RGB = false, Fullbright = false, InfJump = false, AntiAfk = true,
    NoFog = false, AmbientSync = false, AI = false, FriendBot = false, IsFollowing = true, 
    IsRecording = false, IsPlaying = false, LoopPlay = false
} 
local valSmooth, valHitbox, valFlySpeed, valSpeed, valBypassSpeed, valJumpPower, valRipple, valGhostRate = 0.15, 5, 5, 50, 0.11, 100, 15, 0.05
local up, down = false, false

local function EmergencyBrake()
    local char = Player.Character; if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.Velocity = Vector3.new(0,0,0); char.HumanoidRootPart.RotVelocity = Vector3.new(0,0,0) end
end

-- [[ FIXED REPLAY MOVEMENT ]] --
local function SmartMove(targetCF)
    local char = Player.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    local car = nil; if hum.SeatPart then car = hum.SeatPart.Parent end
    if car and car:IsA("Model") then 
        local mainPart = car.PrimaryPart or hum.SeatPart
        mainPart.Velocity = Vector3.new(0,0,0)
        mainPart.CFrame = targetCF 
    else 
        root.CFrame = targetCF
        root.Velocity = Vector3.new(0,0,0) -- Force stop physics
    end
end

local function SendChat(msg)
    if game:GetService("TextChatService").ChatVersion == Enum.ChatVersion.TextChatService then
        pcall(function() game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(msg) end)
    else
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
    end
end

btnUp.MouseButton1Down:Connect(function() up = true end); btnUp.MouseButton1Up:Connect(function() up = false end)
btnDn.MouseButton1Down:Connect(function() down = true end); btnDn.MouseButton1Up:Connect(function() down = false end)

local function makeBind(name, callback)
    local hb = Instance.new("TextButton", ScreenGui); hb.Name="Bind_"..name; hb.Size=UDim2.new(0,50,0,50); hb.Position=UDim2.new(0.85,0,0.4,0); hb.BackgroundColor3=Color3.fromRGB(15,15,15); hb.Text=name:sub(1,3); hb.TextColor3=Color3.new(1,1,1); hb.Visible=false
    hb.Active = UI_Unlocked; hb.Draggable = UI_Unlocked
    style(hb,25); hb.MouseButton1Click:Connect(callback); table.insert(Movable_Objects, hb); return hb
end

local btnTheme = Instance.new("TextButton", PageMain); btnTheme.Size = UDim2.new(1, 0, 0, 40); btnTheme.BackgroundColor3 = Color3.fromRGB(25, 25, 25); btnTheme.Text = "THEME: " .. Themes[CurrentThemeIndex]; btnTheme.TextColor3 = Color3.new(1,1,1); btnTheme.Font = Enum.Font.SciFi; btnTheme.TextSize = 16; style(btnTheme)
btnTheme.MouseButton1Click:Connect(function() CurrentThemeIndex = CurrentThemeIndex + 1; if CurrentThemeIndex > #Themes then CurrentThemeIndex = 1 end; btnTheme.Text = "THEME: " .. Themes[CurrentThemeIndex] end)

local function addOption(name, key, useInput, defaultInputVal, inputCallback)
    local f = Instance.new("Frame", PageMain); f.Size = UDim2.new(1, 0, 0, 40); f.BackgroundTransparency = 1
    local btnSize = useInput and 0.5 or 0.75
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(btnSize, -5, 1, 0); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(20, 20, 20); b.TextColor3 = Color3.new(1,1,1); style(b)
    if States[key] then b.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
    
    local function Toggle()
        States[key] = not States[key]
        b.BackgroundColor3 = States[key] and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(20, 20, 20)
        Notify(name .. (States[key] and " [ON]" or " [OFF]"))
    end
    
    local hk = makeBind(name, Toggle)
    b.MouseButton1Click:Connect(Toggle)
    
    local bb = Instance.new("TextButton", f); bb.Size = UDim2.new(0.25, 0, 1, 0); bb.Position = UDim2.new(0.75, 0, 0, 0); bb.Text = "BIND"; style(bb)
    bb.MouseButton1Click:Connect(function() hk.Visible = not hk.Visible end)
    
    if useInput then
        local inp = Instance.new("TextBox", f); inp.Size = UDim2.new(0.25, -5, 1, 0); inp.Position = UDim2.new(0.5, 0, 0, 0); inp.Text = tostring(defaultInputVal); inp.BackgroundColor3 = Color3.fromRGB(15,15,15); inp.TextColor3 = Color3.new(1,1,1); style(inp)
        inp.FocusLost:Connect(function() local n = tonumber(inp.Text); if n then inputCallback(n) else inp.Text = tostring(defaultInputVal) end end)
    end
end

-- [ OPTIONS ] --
addOption("SHOW LOGO", "Watermark", false) 
addOption("HUMAN AIM", "Aim", true, valSmooth, function(v) valSmooth = math.clamp(v, 0.01, 1) end)
addOption("ANTI KNOCKBACK", "AntiKnockback", false) 
addOption("INF ZOOM", "UnlockAll", false) 
addOption("SPEED BYPASS", "SpdBypass", true, valBypassSpeed, function(v) valBypassSpeed = v end)
addOption("KILL AURA", "KillAura", false)
addOption("BIG HITBOX", "Hitbox", true, valHitbox, function(v) valHitbox = v end)
addOption("FLY BYPASS", "Fly", true, valFlySpeed, function(v) valFlySpeed = v end)
addOption("RAGE SPEED", "Spd", true, valSpeed, function(v) valSpeed = v end)
addOption("SUPER JUMP", "Jump", true, valJumpPower, function(v) valJumpPower = v end)
addOption("JUMP RIPPLE", "Circle", true, valRipple, function(v) valRipple = v end)
addOption("PENTAGRAM MODE", "UsePentagram", false) 
addOption("GHOST TRAIL", "Ghosts", true, valGhostRate, function(v) valGhostRate = math.clamp(v, 0.01, 2) end) 
addOption("ESP HIGHLIGHT", "Esp", false)
addOption("SKIN COLOR", "RGB", false) 
addOption("FULLBRIGHT", "Fullbright", false) 
addOption("INF JUMP", "InfJump", false)

SideBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- [[ UI EDITOR & SAVE ]] --
UnlockBtn.MouseButton1Click:Connect(function()
    UI_Unlocked = not UI_Unlocked
    UnlockBtn.Text = UI_Unlocked and "UNLOCK MOVING: ON" or "UNLOCK MOVING: OFF"
    UnlockBtn.BackgroundColor3 = UI_Unlocked and Color3.fromRGB(10,50,10) or Color3.fromRGB(30,10,10)
    for _, obj in pairs(Movable_Objects) do obj.Active = UI_Unlocked; obj.Draggable = UI_Unlocked end
end)
local ConfigName = "AngerConfig_V126.json"
SaveBtn.MouseButton1Click:Connect(function()
    local data = {}; for _, obj in pairs(Movable_Objects) do data[obj.Name] = {X_S=obj.Position.X.Scale, X_O=obj.Position.X.Offset, Y_S=obj.Position.Y.Scale, Y_O=obj.Position.Y.Offset} end
    if writefile then writefile(ConfigName, game:GetService("HttpService"):JSONEncode(data)); SaveBtn.Text="SAVED!"; task.wait(1); SaveBtn.Text="SAVE CONFIG" end
end)
task.spawn(function() if isfile and isfile(ConfigName) then local data = game:GetService("HttpService"):JSONDecode(readfile(ConfigName)); for _, obj in pairs(Movable_Objects) do if data[obj.Name] then obj.Position = UDim2.new(data[obj.Name].X_S, data[obj.Name].X_O, data[obj.Name].Y_S, data[obj.Name].Y_O) end end end end)

-- [[ WORLD FUNCTIONS ]] --
FogBtn.MouseButton1Click:Connect(function()
    States.NoFog = not States.NoFog
    FogBtn.Text = States.NoFog and "REMOVE FOG: ON" or "REMOVE FOG: OFF"
    FogBtn.BackgroundColor3 = States.NoFog and Color3.fromRGB(10, 50, 10) or Color3.fromRGB(30, 10, 10)
    if not States.NoFog then Lighting.FogEnd = 1000 end
    Notify("NO FOG" .. (States.NoFog and " [ON]" or " [OFF]"))
end)
AmbientBtn.MouseButton1Click:Connect(function()
    States.AmbientSync = not States.AmbientSync
    AmbientBtn.Text = States.AmbientSync and "AMBIENT SYNC: ON" or "AMBIENT SYNC: OFF"
    AmbientBtn.BackgroundColor3 = States.AmbientSync and Color3.fromRGB(10, 50, 10) or Color3.fromRGB(30, 10, 10)
    Notify("AMBIENT" .. (States.AmbientSync and " [ON]" or " [OFF]"))
end)
local function SetSky(id)
    local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
    local tex = "rbxassetid://" .. id
    sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt, sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = tex, tex, tex, tex, tex, tex
    Notify("CUSTOM SKY APPLIED")
end
SetSkyBtn.MouseButton1Click:Connect(function() if SkyBox.Text ~= "" then SetSky(SkyBox.Text) end end)
SpaceSkyBtn.MouseButton1Click:Connect(function() SetSky("159454299") end) 

-- [[ MACRO LOGIC (FIXED) ]] --
RecBtn.MouseButton1Click:Connect(function()
    States.IsRecording = not States.IsRecording
    if States.IsRecording then 
        States.IsPlaying = false
        RecordedPath = {} 
        RecBtn.Text = "STOP REC"
        RecBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        AIStatus.Text = "STATUS: RECORDING..."
        Notify("RECORDING STARTED") 
    else 
        RecBtn.Text = "RECORD"
        RecBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
        AIStatus.Text = "STATUS: SAVED " .. #RecordedPath .. " FRAMES"
        Notify("RECORDING STOPPED") 
    end
end)

local function StartPlayback()
    if #RecordedPath == 0 then AIStatus.Text = "ERROR: NO RECORDING"; States.IsPlaying = false; return end
    
    -- ANCHOR LOGIC START
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if root and hum then
        hum.PlatformStand = true -- Отключаем анимации и физику
        root.Anchored = true     -- Жестко фиксируем для плавности
    end

    task.spawn(function()
        while States.IsPlaying do
            for i, frame in ipairs(RecordedPath) do
                if not States.IsPlaying then break end
                SmartMove(frame.CF)
                RunService.Heartbeat:Wait()
            end
            if not States.LoopPlay then 
                States.IsPlaying = false
                PlayBtn.Text = "PLAY"
                PlayBtn.BackgroundColor3 = Color3.fromRGB(10, 40, 10)
                Notify("PLAYBACK ENDED")
                break 
            end
        end
        -- ANCHOR LOGIC END
        if Player.Character then
            local r = Player.Character:FindFirstChild("HumanoidRootPart")
            local h = Player.Character:FindFirstChild("Humanoid")
            if r then r.Anchored = false r.Velocity = Vector3.zero end
            if h then h.PlatformStand = false end
        end
        AIStatus.Text = "STATUS: IDLE"
    end)
end

PlayBtn.MouseButton1Click:Connect(function()
    States.IsPlaying = not States.IsPlaying
    if States.IsPlaying then 
        States.IsRecording = false
        RecBtn.Text = "RECORD"
        RecBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
        PlayBtn.Text = "STOP PLAY"
        PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        Notify("PLAYBACK STARTED")
        StartPlayback() 
    else 
        PlayBtn.Text = "PLAY"
        PlayBtn.BackgroundColor3 = Color3.fromRGB(10, 40, 10)
        EmergencyBrake()
        Notify("PLAYBACK STOPPED") 
    end
end)

LoopBtn.MouseButton1Click:Connect(function()
    States.LoopPlay = not States.LoopPlay
    LoopBtn.Text = States.LoopPlay and "LOOP PLAYBACK: ON" or "LOOP PLAYBACK: OFF"
    LoopBtn.BackgroundColor3 = States.LoopPlay and Color3.fromRGB(10, 50, 10) or Color3.fromRGB(30, 30, 30)
    Notify("LOOP" .. (States.LoopPlay and " [ON]" or " [OFF]"))
end)

-- [[ AI LOGIC ]] --
local AI_Debounce = false
AIToggleBtn.MouseButton1Click:Connect(function() 
    States.AI = not States.AI
    AIToggleBtn.Text = States.AI and "AI AUTOREPLY: ON" or "AI AUTOREPLY: OFF"
    AIToggleBtn.BackgroundColor3 = States.AI and Color3.fromRGB(10, 50, 10) or Color3.fromRGB(30, 10, 10)
    Notify("AI CHAT" .. (States.AI and " [ON]" or " [OFF]"))
    if States.AI then SendChat("AngerMOD: Модуль чата активен.") end
end)
FriendBtn.MouseButton1Click:Connect(function() 
    States.FriendBot = not States.FriendBot
    FriendBtn.Text = States.FriendBot and "FRIEND BOT: ON" or "FRIEND BOT: OFF"
    FriendBtn.BackgroundColor3 = States.FriendBot and Color3.fromRGB(10, 50, 10) or Color3.fromRGB(30, 10, 10) 
    Notify("FRIEND BOT" .. (States.FriendBot and " [ON]" or " [OFF]"))
    if States.FriendBot then SendChat("Я теперь твой хвостик!") end
end)

local function ExecuteCommand(msg)
    local m = string.lower(msg); local char = Player.Character; local hum = char and char:FindFirstChild("Humanoid")
    if string.find(m, "сядь") then if hum then hum.Sit = true end; return true
    elseif string.find(m, "встань") then if hum then hum.Sit = false; hum.Jump = true end; return true
    elseif string.find(m, "стой") then States.IsFollowing = false; EmergencyBrake(); return true
    elseif string.find(m, "ко мне") then States.IsFollowing = true; return true end
    return false
end

local function ProcessAI(msg, senderName)
    if AI_Debounce then return end
    if States.FriendBot and ExecuteCommand(msg) then return end 
    if not States.AI then return end
    AI_Debounce = true; AIStatus.Text = "STATUS: THINKING..."
    local apiKey = AIKeyBox.Text; if apiKey == "" then AIStatus.Text = "ERROR: NO KEY"; AI_Debounce = false; return end
    table.insert(ChatHistory, {role = "user", content = senderName .. ": " .. msg})
    if #ChatHistory > 10 then table.remove(ChatHistory, 2) end
    local success, response = pcall(function()
        if request then return request({ Url = "https://api.openai.com/v1/chat/completions", Method = "POST", Headers = {["Content-Type"] = "application/json", ["Authorization"] = "Bearer " .. apiKey}, Body = HttpService:JSONEncode({ model = "gpt-4o-mini", messages = ChatHistory, max_tokens = 60 }) }) end
    end)
    if success and response and response.Body then 
        local data = HttpService:JSONDecode(response.Body)
        if data.choices and data.choices[1] then local reply = data.choices[1].message.content; SendChat(reply); table.insert(ChatHistory, {role = "assistant", content = reply}); AIStatus.Text = "STATUS: REPLIED" else AIStatus.Text = "ERROR: API FAIL" end
    else AIStatus.Text = "ERROR: REQUEST FAIL" end
    task.wait(2); AI_Debounce = false; task.wait(1); AIStatus.Text = "STATUS: WAITING..."
end
for _, p in pairs(Players:GetPlayers()) do p.Chatted:Connect(function(msg) if p ~= Player then ProcessAI(msg, p.Name) end end) end
Players.PlayerAdded:Connect(function(p) p.Chatted:Connect(function(msg) if p ~= Player then ProcessAI(msg, p.Name) end end) end)

-- [[ VISUALS ]] --
local function SpawnRipple()
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = Player.Character.HumanoidRootPart; local ray = workspace:Raycast(root.Position, Vector3.new(0, -10, 0), RaycastParams.new())
    local spawnPos = ray and ray.Position or (root.Position - Vector3.new(0, 2.8, 0)); local p = Instance.new("Part", workspace); p.Name = "AngerRipple"; p.Anchored = true; p.CanCollide = false
    if States.UsePentagram then
        p.Transparency = 1; p.Size = Vector3.new(1, 0.05, 1); p.CFrame = CFrame.new(spawnPos); local sg = Instance.new("SurfaceGui", p); sg.Face = Enum.NormalId.Top; sg.LightInfluence = 0; sg.AlwaysOnTop = false; local img = Instance.new("ImageLabel", sg); img.Size = UDim2.new(1, 0, 1, 0); img.BackgroundTransparency = 1; img.ImageColor3 = Color3.new(1, 1, 1); 
        local s, a = pcall(function() return getcustomasset("Anger_Pentagram_Circle1.png") end)
        if s then img.Image = a else img.Image = "rbxassetid://0" end; 
        table.insert(RGB_Objects, {Type = "Image", Instance = img}); TweenService:Create(p, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(valRipple, 0.05, valRipple)}):Play(); TweenService:Create(img, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {ImageTransparency = 1}):Play(); Debris:AddItem(p, 1.5)
    else
        p.Shape = Enum.PartType.Cylinder; p.Material = Enum.Material.Neon; p.Size = Vector3.new(0.1, 1, 1); p.CFrame = CFrame.new(spawnPos) * CFrame.Angles(0, 0, math.rad(90)); p.Color = Color3.new(1,1,1); table.insert(RGB_Objects, {Type = "Part", Instance = p}); TweenService:Create(p, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(0.1, valRipple, valRipple), Transparency = 1}):Play(); Debris:AddItem(p, 1)
    end
end

local function GetClosestPlayer()
    local target = nil; local dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do 
        if v ~= Player and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then 
            local d = (v.Character.Head.Position - Camera.CFrame.Position).Magnitude
            if d < dist then dist = d; target = v.Character end 
        end 
    end; return target
end

Player.CharacterAdded:Connect(function(char) 
    DeathScreen.Enabled = false
    char:WaitForChild("Humanoid").Died:Connect(function() DeathScreen.Enabled = true end)
end)

-- [[ RENDER LOOP ]] --
local lastGhostTime = 0
RunService.RenderStepped:Connect(function()
    pcall(function() 
        local tickTime = tick()
        local currentThemeName = Themes[CurrentThemeIndex]
        local activeColor = Color3.new(1,1,1)
        if currentThemeName == "RGB" then activeColor = Color3.fromHSV(tickTime % 3 / 3, 1, 1) elseif ThemeColors[currentThemeName] then activeColor = ThemeColors[currentThemeName] end
        
        if States.AmbientSync then Lighting.OutdoorAmbient = activeColor; Lighting.Ambient = activeColor end
        if States.NoFog then Lighting.FogEnd = 1000000; Lighting.FogStart = 1000000 end

        DeathLabel.TextColor3 = activeColor
        for i, obj in pairs(RGB_Objects) do 
            if obj.Instance and obj.Instance.Parent then 
                if obj.Type == "Stroke" then obj.Instance.Color = activeColor elseif obj.Type == "Text" then obj.Instance.TextColor3 = activeColor elseif obj.Type == "Image" then obj.Instance.ImageColor3 = activeColor elseif obj.Type == "Part" then obj.Instance.Color = activeColor end 
            else table.remove(RGB_Objects, i) end 
        end
        
        local wm = ScreenGui.Parent:FindFirstChild("AngerWatermark"); if wm then wm.Enabled = States.Watermark end
        if PageInfo.Visible then InfoLabel.Text = string.format("SESSION:\nUser: %s\nID: %s\nFPS: %d\nPing: %d ms", Player.Name, SessionID, math.floor(workspace:GetRealPhysicsFPS()), math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) end

        local char = Player.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hum = char:FindFirstChild("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart")

        -- [[ ANTI KNOCKBACK FIX ]] --
        if States.AntiKnockback then
             if root.Velocity.Magnitude > 25 then
                 if hum.MoveDirection.Magnitude > 0 then
                    root.Velocity = hum.MoveDirection * hum.WalkSpeed
                 else
                    root.Velocity = Vector3.new(0,0,0)
                 end
                 root.RotVelocity = Vector3.new(0,0,0)
             end
        end

        -- [[ AIMBOT LOGIC ]] --
        if States.Aim then
            local target = GetClosestPlayer()
            if target and target:FindFirstChild("Head") then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Head.Position), valSmooth)
            end
        end
        
        -- [[ RECORDING LOGIC (MOVED HERE SAFE) ]] --
        if States.IsRecording then 
             local pos = root.CFrame
             if hum and hum.SeatPart then pos = hum.SeatPart.CFrame end
             table.insert(RecordedPath, {CF = pos}) 
        end

        -- [[ INF ZOOM FIX ]] --
        if States.UnlockAll then 
            Player.CameraMaxZoomDistance = 100000
            Player.CameraMinZoomDistance = 0 
            if Player.CameraMode ~= Enum.CameraMode.Classic then Player.CameraMode = Enum.CameraMode.Classic end
        end

        if States.SpdBypass and hum.MoveDirection.Magnitude > 0 then root.CFrame = root.CFrame + (hum.MoveDirection * valBypassSpeed) end
        if States.Fly and root and hum then root.Velocity = Vector3.new(0, 0.1, 0); if hum.MoveDirection.Magnitude > 0 then root.CFrame = root.CFrame + (hum.MoveDirection * valFlySpeed) end; if up then root.CFrame = root.CFrame * CFrame.new(0, valFlySpeed, 0) end; if down then root.CFrame = root.CFrame * CFrame.new(0, -valFlySpeed, 0) end end
        if States.KillAura then local tool = char:FindFirstChildOfClass("Tool"); if tool and tool:FindFirstChild("Handle") then for _, v in pairs(game.Players:GetPlayers()) do if v ~= Player and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then local dist = (v.Character.Head.Position - root.Position).Magnitude; if dist < 50 then tool.Handle.CFrame = v.Character.Head.CFrame; tool:Activate(); pcall(function() firetouchinterest(tool.Handle, v.Character.Head, 0); firetouchinterest(tool.Handle, v.Character.Head, 1) end); break end end end end end
        if States.Ghosts and tick() - lastGhostTime > valGhostRate then lastGhostTime = tick(); for _, v in pairs(char:GetChildren()) do if v:IsA("BasePart") and v.Transparency < 1 then local g = v:Clone(); g.Parent = workspace; g.Anchored = true; g.CanCollide = false; g.CFrame = v.CFrame; g.Color = activeColor; g.Material = Enum.Material.Neon; g:ClearAllChildren(); TweenService:Create(g, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency=1, CFrame=g.CFrame*CFrame.Angles(math.rad(math.random(-180,180)),math.rad(math.random(-180,180)),0), Size=g.Size*1.1}):Play(); Debris:AddItem(g, 0.5) end end end
        if States.Spd and hum.MoveDirection.Magnitude > 0 then root.CFrame += (hum.MoveDirection * (0.5 * valSpeed)) end
        if States.Jump then hum.UseJumpPower = true; hum.JumpPower = valJumpPower else hum.JumpPower = 50 end

        if States.Esp then
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= Player and v.Character then
                    if not v.Character:FindFirstChild("AngerESP") then
                        local hl = Instance.new("Highlight", v.Character); hl.Name = "AngerESP"; hl.FillTransparency = 0.5; hl.OutlineTransparency = 0
                    else
                        v.Character.AngerESP.FillColor = activeColor
                    end
                end
            end
        else
            for _, v in pairs(game.Players:GetPlayers()) do if v.Character and v.Character:FindFirstChild("AngerESP") then v.Character.AngerESP:Destroy() end end
        end

        -- [[ HITBOX FIX ]] --
        for _, v in pairs(game.Players:GetPlayers()) do 
            if v ~= Player and v.Character and v.Character:FindFirstChild("Head") then 
                local head = v.Character.Head
                if States.Hitbox then
                    head.Size = Vector3.new(valHitbox, valHitbox, valHitbox)
                    head.Transparency = 0.7
                    head.CanCollide = false
                    head.Color = activeColor
                    head.Material = Enum.Material.Neon
                else
                    head.Size = Vector3.new(1,1,1)
                    head.Transparency = 0
                end
            end 
        end
    end)
end)

UserInputService.JumpRequest:Connect(function() if States.InfJump and Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end; if States.Circle then SpawnRipple() end end)
Player.Idled:Connect(function() if States.AntiAfk then VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end end)

-- ASSET LOADING
task.spawn(function()
    local urlLogo = "https://raw.githubusercontent.com/AngerPC-DEV/AngerMOD/main/AngerMOD.png"
    local fileLogo = "AngerMOD_Logo_V104.png"
    if writefile and readfile then pcall(function() if not isfile(fileLogo) then writefile(fileLogo, game:HttpGet(urlLogo)) end end) end
    local lg = Instance.new("ScreenGui", ScreenGui.Parent); lg.Name = "AngerWatermark"; local im = Instance.new("ImageLabel", lg); im.Size = UDim2.new(0, 200, 0, 100); im.Position = UDim2.new(0, 10, 0, 10); im.BackgroundTransparency = 1; im.BorderSizePixel = 0; local stroke = Instance.new("UIStroke", im); stroke.Thickness = 3; stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; stroke.Color = Color3.new(1, 0, 0); table.insert(RGB_Objects, {Type = "Stroke", Instance = stroke})
    local s, a = pcall(function() return getcustomasset(fileLogo) end); if s then im.Image = a else im.Image = urlLogo end
end)

task.spawn(function()
    local pentagramUrl = "https://raw.githubusercontent.com/AngerPC-DEV/AngerMOD/main/circle1.png"
    local pentagramName = "Anger_Pentagram_Circle1.png"
    if writefile and readfile and isfile then pcall(function() if not isfile(pentagramName) then writefile(pentagramName, game:HttpGet(pentagramUrl)) end end) end
end)
