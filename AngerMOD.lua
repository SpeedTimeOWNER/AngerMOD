-- [[ ⛧ AngerPC ⛧ V112 FRIENDLY AI BOT ]] --

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

-- [[ SESSION INFO ]] --
local SessionID = string.upper(HttpService:GenerateGUID(false):sub(1, 8))
local StartTime = tick()

-- [[ THEME SYSTEM ]] --
local Themes = {
    "RGB", "БЕЛЫЙ", "СЕРЫЙ", "ГОЛУБОЙ", "ФИОЛЕТОВЫЙ", "НЕОБЫЧНЫЙ", "РОЗОВЫЙ", "КРАСНЫЙ"
}
local ThemeColors = {
    ["БЕЛЫЙ"] = Color3.new(1, 1, 1),
    ["СЕРЫЙ"] = Color3.fromRGB(120, 120, 120),
    ["ГОЛУБОЙ"] = Color3.fromRGB(0, 190, 255),
    ["ФИОЛЕТОВЫЙ"] = Color3.fromRGB(170, 0, 255),
    ["НЕОБЫЧНЫЙ"] = Color3.fromRGB(255, 170, 0),
    ["РОЗОВЫЙ"] = Color3.fromRGB(255, 105, 180),
    ["КРАСНЫЙ"] = Color3.fromRGB(255, 0, 0)
}
local CurrentThemeIndex = 1 

-- [[ 1. GUI SETUP ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AngerGUI_V112"
if game.CoreGui:FindFirstChild("RobloxGui") then
    ScreenGui.Parent = game.CoreGui 
else
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

-- DEATH SCREEN
local DeathScreen = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
DeathScreen.Name = "AngerDeath"
DeathScreen.Enabled = false
local DeathLabel = Instance.new("TextLabel", DeathScreen)
DeathLabel.Size = UDim2.new(1, 0, 1, 0)
DeathLabel.BackgroundTransparency = 1
DeathLabel.Text = "HAHA DIED"
DeathLabel.Font = Enum.Font.Creepster
DeathLabel.TextSize = 100
DeathLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
DeathLabel.TextStrokeTransparency = 0

-- LISTS
local RGB_Objects = {} 
local Movable_Objects = {} 

local function style(obj, radius, thickness)
    local uiC = Instance.new("UICorner", obj); uiC.CornerRadius = UDim.new(0, radius or 6)
    local uiS = Instance.new("UIStroke", obj); uiS.Color = Color3.fromRGB(60, 60, 60); uiS.Thickness = thickness or 1
    table.insert(RGB_Objects, {Type = "Stroke", Instance = uiS})
    return uiS
end

-- // MAIN MENU // --
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 420, 0, 500) 
Main.Position = UDim2.new(0.1, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.Visible = false 
Main.Active = true
Main.Draggable = true
style(Main, 8, 2)
table.insert(Movable_Objects, Main)

-- TABS
local TabFrame = Instance.new("Frame", Main)
TabFrame.Size = UDim2.new(1, -20, 0, 30)
TabFrame.Position = UDim2.new(0, 10, 0, 50)
TabFrame.BackgroundTransparency = 1
local layoutTabs = Instance.new("UIListLayout", TabFrame); layoutTabs.FillDirection=Enum.FillDirection.Horizontal; layoutTabs.Padding=UDim.new(0,5)

local function MakeTab(text)
    local b = Instance.new("TextButton", TabFrame); b.Size=UDim2.new(0.23,0,1,0); b.BackgroundColor3=Color3.fromRGB(20,20,20); b.Text=text; b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.SciFi; style(b)
    return b
end
local btnTabMain = MakeTab("MAIN")
local btnTabInfo = MakeTab("INFO")
local btnTabAI = MakeTab("AI CHAT") 
local btnTabUI = MakeTab("UI EDIT")

-- TITLE
local Title = Instance.new("TextLabel", Main); Title.Size=UDim2.new(1,0,0,45); Title.BackgroundTransparency=1; Title.Text="AngerPC V112 AI"; Title.Font=Enum.Font.SciFi; Title.TextSize=24; Title.TextColor3=Color3.new(1,1,1); table.insert(RGB_Objects, {Type="Text", Instance=Title})

-- // PAGES // --
local PageMain = Instance.new("ScrollingFrame", Main); PageMain.Size=UDim2.new(1,-20,0.78,0); PageMain.Position=UDim2.new(0,10,0.18,0); PageMain.BackgroundTransparency=1; PageMain.ScrollBarThickness=2; PageMain.Visible=true; Instance.new("UIListLayout", PageMain).Padding=UDim.new(0,8)
local PageInfo = Instance.new("Frame", Main); PageInfo.Size=UDim2.new(1,-20,0.78,0); PageInfo.Position=UDim2.new(0,10,0.18,0); PageInfo.BackgroundTransparency=1; PageInfo.Visible=false
local PageAI = Instance.new("Frame", Main); PageAI.Size=UDim2.new(1,-20,0.78,0); PageAI.Position=UDim2.new(0,10,0.18,0); PageAI.BackgroundTransparency=1; PageAI.Visible=false
local PageUI = Instance.new("Frame", Main); PageUI.Size=UDim2.new(1,-20,0.78,0); PageUI.Position=UDim2.new(0,10,0.18,0); PageUI.BackgroundTransparency=1; PageUI.Visible=false

btnTabMain.MouseButton1Click:Connect(function() PageMain.Visible=true; PageInfo.Visible=false; PageAI.Visible=false; PageUI.Visible=false end)
btnTabInfo.MouseButton1Click:Connect(function() PageMain.Visible=false; PageInfo.Visible=true; PageAI.Visible=false; PageUI.Visible=false end)
btnTabAI.MouseButton1Click:Connect(function() PageMain.Visible=false; PageInfo.Visible=false; PageAI.Visible=true; PageUI.Visible=false end)
btnTabUI.MouseButton1Click:Connect(function() PageMain.Visible=false; PageInfo.Visible=false; PageAI.Visible=false; PageUI.Visible=true end)

-- // INFO PAGE // --
local InfoLabel = Instance.new("TextLabel", PageInfo); InfoLabel.Size=UDim2.new(1,0,1,0); InfoLabel.BackgroundTransparency=1; InfoLabel.TextXAlignment=Enum.TextXAlignment.Left; InfoLabel.TextYAlignment=Enum.TextYAlignment.Top; InfoLabel.TextColor3=Color3.fromRGB(0,255,0); InfoLabel.Font=Enum.Font.Code; InfoLabel.TextSize=14

-- // AI PAGE SETUP // --
local AIKeyBox = Instance.new("TextBox", PageAI)
AIKeyBox.Size = UDim2.new(1, 0, 0, 40)
AIKeyBox.PlaceholderText = "PASTE OPENAI API KEY HERE (sk-...)"
AIKeyBox.Text = ""
AIKeyBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
AIKeyBox.TextColor3 = Color3.new(1, 1, 1)
AIKeyBox.ClearTextOnFocus = false
style(AIKeyBox)

local AIToggleBtn = Instance.new("TextButton", PageAI)
AIToggleBtn.Size = UDim2.new(1, 0, 0, 40)
AIToggleBtn.Position = UDim2.new(0, 0, 0.12, 0)
AIToggleBtn.Text = "AI AUTOREPLY: OFF"
AIToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
AIToggleBtn.TextColor3 = Color3.new(1, 1, 1)
style(AIToggleBtn)

local FriendBtn = Instance.new("TextButton", PageAI)
FriendBtn.Size = UDim2.new(1, 0, 0, 40)
FriendBtn.Position = UDim2.new(0, 0, 0.24, 0)
FriendBtn.Text = "FRIEND BOT (FOLLOW): OFF"
FriendBtn.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
FriendBtn.TextColor3 = Color3.new(1, 1, 1)
style(FriendBtn)

local AIStatus = Instance.new("TextLabel", PageAI)
AIStatus.Size = UDim2.new(1, 0, 0, 30)
AIStatus.Position = UDim2.new(0, 0, 0.38, 0)
AIStatus.BackgroundTransparency = 1
AIStatus.Text = "STATUS: WAITING..."
AIStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
style(AIStatus, 0, 0)

-- // UI EDIT PAGE // --
local UnlockBtn = Instance.new("TextButton", PageUI); UnlockBtn.Size=UDim2.new(1,0,0,50); UnlockBtn.BackgroundColor3=Color3.fromRGB(30,10,10); UnlockBtn.Text="UNLOCK MOVING: OFF"; UnlockBtn.TextColor3=Color3.new(1,1,1); style(UnlockBtn)
local SaveBtn = Instance.new("TextButton", PageUI); SaveBtn.Size=UDim2.new(1,0,0,50); SaveBtn.Position=UDim2.new(0,0,0.15,0); SaveBtn.BackgroundColor3=Color3.fromRGB(10,30,10); SaveBtn.Text="SAVE CONFIG"; SaveBtn.TextColor3=Color3.new(1,1,1); style(SaveBtn)

-- // SIDE BUTTON // --
local SideBtn = Instance.new("TextButton", ScreenGui); SideBtn.Name="SideBtn"; SideBtn.Size=UDim2.new(0,140,0,40); SideBtn.Position=UDim2.new(0,10,0.3,0); SideBtn.BackgroundColor3=Color3.fromRGB(15,15,15); SideBtn.Text="AngerMOD"; SideBtn.Font=Enum.Font.SciFi; SideBtn.TextSize=18; SideBtn.TextColor3=Color3.new(1,1,1); SideBtn.Visible=false; style(SideBtn,12,2); table.insert(RGB_Objects, {Type="Text", Instance=SideBtn}); table.insert(Movable_Objects, SideBtn)

-- // FLY GUI // --
local FlyGui = Instance.new("Frame", ScreenGui); FlyGui.Name="FlyGui"; FlyGui.Size=UDim2.new(0,60,0,150); FlyGui.Position=UDim2.new(0.9,0,0.5,0); FlyGui.BackgroundTransparency=1; FlyGui.Visible=false; table.insert(Movable_Objects, FlyGui)
local btnUp = Instance.new("TextButton", FlyGui); btnUp.Size=UDim2.new(1,0,0,60); btnUp.Position=UDim2.new(0,0,0,0); btnUp.BackgroundColor3=Color3.fromRGB(20,20,20); btnUp.Text="UP"; btnUp.TextColor3=Color3.new(1,1,1); style(btnUp)
local btnDn = Instance.new("TextButton", FlyGui); btnDn.Size=UDim2.new(1,0,0,60); btnDn.Position=UDim2.new(0,0,0.5,0); btnDn.BackgroundColor3=Color3.fromRGB(20,20,20); btnDn.Text="DN"; btnDn.TextColor3=Color3.new(1,1,1); style(btnDn)

-- // LOGIN FRAME // --
local LFrame = Instance.new("Frame", ScreenGui); LFrame.Size=UDim2.new(0,300,0,150); LFrame.Position=UDim2.new(0.5,-150,0.5,-75); LFrame.BackgroundColor3=Color3.fromRGB(12,12,12); style(LFrame,8,2)
local LI = Instance.new("TextBox", LFrame); LI.Size=UDim2.new(0.8,0,0,40); LI.Position=UDim2.new(0.1,0,0.2,0); LI.BackgroundColor3=Color3.fromRGB(20,20,20); LI.TextColor3=Color3.new(1,1,1); LI.Text=""; LI.PlaceholderText="AngerPC V112"; style(LI)
local LB = Instance.new("TextButton", LFrame); LB.Size=UDim2.new(0.5,0,0,40); LB.Position=UDim2.new(0.25,0,0.6,0); LB.BackgroundColor3=Color3.fromRGB(25,25,25); LB.Text="LOGIN"; LB.TextColor3=Color3.new(1,1,1); style(LB)

-- [[ 2. LOGIC ]] --
local States = {AI = false, Watermark = true, FriendBot = false} 
local valSmooth, valHitbox, valFlySpeed, valSpeed, valBypassSpeed, valJumpPower, valRipple, valGhostRate = 0.1, 5, 5, 50, 0.11, 100, 15, 0.05
local up, down = false, false

btnUp.MouseButton1Down:Connect(function() up = true end); btnUp.MouseButton1Up:Connect(function() up = false end)
btnDn.MouseButton1Down:Connect(function() down = true end); btnDn.MouseButton1Up:Connect(function() down = false end)

local function makeBind(name, callback)
    local hb = Instance.new("TextButton", ScreenGui); hb.Name="Bind_"..name; hb.Size=UDim2.new(0,50,0,50); hb.Position=UDim2.new(0.85,0,0.4,0); hb.BackgroundColor3=Color3.fromRGB(15,15,15); hb.Text=name:sub(1,3); hb.TextColor3=Color3.new(1,1,1); hb.Visible=false; hb.Draggable=true; style(hb,25); hb.MouseButton1Click:Connect(callback); table.insert(Movable_Objects, hb); return hb
end

local btnTheme = Instance.new("TextButton", PageMain)
btnTheme.Size = UDim2.new(1, 0, 0, 40)
btnTheme.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
btnTheme.Text = "THEME: " .. Themes[CurrentThemeIndex]
btnTheme.TextColor3 = Color3.new(1,1,1)
btnTheme.Font = Enum.Font.SciFi
btnTheme.TextSize = 16
style(btnTheme)

btnTheme.MouseButton1Click:Connect(function()
    CurrentThemeIndex = CurrentThemeIndex + 1
    if CurrentThemeIndex > #Themes then CurrentThemeIndex = 1 end
    btnTheme.Text = "THEME: " .. Themes[CurrentThemeIndex]
end)

local function addOption(name, key, useInput, defaultInputVal, inputCallback)
    local f = Instance.new("Frame", PageMain); f.Size = UDim2.new(1, 0, 0, 40); f.BackgroundTransparency = 1
    local btnSize = useInput and 0.5 or 0.75
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(btnSize, -5, 1, 0); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(20, 20, 20); b.TextColor3 = Color3.new(1,1,1); style(b)
    
    if States[key] then b.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end

    local hk = makeBind(name, function() States[key] = not States[key]; if key == "Fly" then FlyGui.Visible = States.Fly end end)
    b.MouseButton1Click:Connect(function() States[key] = not States[key]; b.BackgroundColor3 = States[key] and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(20, 20, 20); if key == "Fly" then FlyGui.Visible = States.Fly end end)
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
addOption("SPEED BYPASS", "SpdBypass", true, valBypassSpeed, function(v) valBypassSpeed = v end)
addOption("UNLOCK CAM", "UnlockAll", false)
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

-- LOGIN
LB.MouseButton1Click:Connect(function() if LI.Text == "AngerPC" then LFrame:Destroy(); Main.Visible = true; SideBtn.Visible = true else LI.Text = "WRONG KEY"; task.wait(1); LI.Text = "" end end)
SideBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- [[ UI EDITOR & SAVE ]] --
local isUnlocked = false
UnlockBtn.MouseButton1Click:Connect(function()
    isUnlocked = not isUnlocked
    UnlockBtn.Text = isUnlocked and "UNLOCK MOVING: ON" or "UNLOCK MOVING: OFF"
    UnlockBtn.BackgroundColor3 = isUnlocked and Color3.fromRGB(10,50,10) or Color3.fromRGB(30,10,10)
    for _, obj in pairs(Movable_Objects) do
        obj.Active = isUnlocked
        obj.Draggable = isUnlocked
    end
end)

local ConfigName = "AngerConfig_V112.json"
SaveBtn.MouseButton1Click:Connect(function()
    local data = {}
    for _, obj in pairs(Movable_Objects) do data[obj.Name] = {X_S=obj.Position.X.Scale, X_O=obj.Position.X.Offset, Y_S=obj.Position.Y.Scale, Y_O=obj.Position.Y.Offset} end
    if writefile then writefile(ConfigName, game:GetService("HttpService"):JSONEncode(data)); SaveBtn.Text="SAVED!"; task.wait(1); SaveBtn.Text="SAVE CONFIG" end
end)
task.spawn(function()
    if isfile and isfile(ConfigName) then
        local data = game:GetService("HttpService"):JSONDecode(readfile(ConfigName))
        for _, obj in pairs(Movable_Objects) do if data[obj.Name] then obj.Position = UDim2.new(data[obj.Name].X_S, data[obj.Name].X_O, data[obj.Name].Y_S, data[obj.Name].Y_O) end end
    end
end)

-- [[ AI LOGIC ]] --
local AI_Debounce = false
AIToggleBtn.MouseButton1Click:Connect(function()
    States.AI = not States.AI
    AIToggleBtn.Text = States.AI and "AI AUTOREPLY: ON" or "AI AUTOREPLY: OFF"
    AIToggleBtn.BackgroundColor3 = States.AI and Color3.fromRGB(10, 50, 10) or Color3.fromRGB(30, 10, 10)
end)

FriendBtn.MouseButton1Click:Connect(function()
    States.FriendBot = not States.FriendBot
    FriendBtn.Text = States.FriendBot and "FRIEND BOT (FOLLOW): ON" or "FRIEND BOT (FOLLOW): OFF"
    FriendBtn.BackgroundColor3 = States.FriendBot and Color3.fromRGB(10, 50, 10) or Color3.fromRGB(30, 10, 10)
end)

local function SendChat(msg)
    if game:GetService("TextChatService").ChatVersion == Enum.ChatVersion.TextChatService then
        game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(msg)
    else
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
    end
end

local function ProcessAI(msg, senderName)
    if AI_Debounce then return end
    AI_Debounce = true
    AIStatus.Text = "STATUS: THINKING..."
    
    local apiKey = AIKeyBox.Text
    if apiKey == "" then AIStatus.Text = "ERROR: NO KEY"; AI_Debounce = false; return end

    local success, response = pcall(function()
        return request({
            Url = "https://api.openai.com/v1/chat/completions",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json", ["Authorization"] = "Bearer " .. apiKey},
            Body = HttpService:JSONEncode({
                model = "gpt-4o-mini", 
                messages = {{role = "system", content = "You are a friendly Roblox bot named AngerPC. You follow players and help them. Be funny and kind."}, {role = "user", content = senderName .. " said: " .. msg}},
                max_tokens = 60
            })
        })
    end)
    
    if success and response.Body then
        local data = HttpService:JSONDecode(response.Body)
        if data.choices and data.choices[1] then SendChat(data.choices[1].message.content); AIStatus.Text = "STATUS: REPLIED" else AIStatus.Text = "ERROR: API FAIL" end
    else AIStatus.Text = "ERROR: REQUEST FAIL" end
    
    task.wait(2); AI_Debounce = false; task.wait(1); AIStatus.Text = "STATUS: WAITING..."
end

for _, p in pairs(Players:GetPlayers()) do p.Chatted:Connect(function(msg) if States.AI and p ~= Player then ProcessAI(msg, p.Name) end end) end
Players.PlayerAdded:Connect(function(p) p.Chatted:Connect(function(msg) if States.AI and p ~= Player then ProcessAI(msg, p.Name) end end) end)

-- [[ RIPPLE LOGIC (SWITCHABLE) ]] --
local function SpawnRipple()
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = Player.Character.HumanoidRootPart
    local ray = workspace:Raycast(root.Position, Vector3.new(0, -10, 0), RaycastParams.new())
    local spawnPos = ray and ray.Position or (root.Position - Vector3.new(0, 2.8, 0))
    
    local p = Instance.new("Part", workspace)
    p.Name = "AngerRipple"
    p.Anchored = true
    p.CanCollide = false
    
    if States.UsePentagram then
        p.Transparency = 1; p.Size = Vector3.new(1, 0.05, 1); p.CFrame = CFrame.new(spawnPos)
        local sg = Instance.new("SurfaceGui", p); sg.Face = Enum.NormalId.Top; sg.LightInfluence = 0; sg.AlwaysOnTop = false 
        local img = Instance.new("ImageLabel", sg); img.Size = UDim2.new(1, 0, 1, 0); img.BackgroundTransparency = 1; img.ImageColor3 = Color3.new(1, 1, 1) 
        local s, a = pcall(function() return getcustomasset("Anger_Pentagram_Circle1.png") end); if s then img.Image = a else img.Image = "rbxassetid://0" end
        table.insert(RGB_Objects, {Type = "Image", Instance = img})
        TweenService:Create(p, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(valRipple, 0.05, valRipple)}):Play()
        TweenService:Create(img, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {ImageTransparency = 1}):Play()
        Debris:AddItem(p, 1.5)
    else
        p.Shape = Enum.PartType.Cylinder
        p.Material = Enum.Material.Neon
        p.Size = Vector3.new(0.1, 1, 1)
        p.CFrame = CFrame.new(spawnPos) * CFrame.Angles(0, 0, math.rad(90))
        p.Color = Color3.new(1,1,1) 
        table.insert(RGB_Objects, {Type = "Part", Instance = p}) 
        TweenService:Create(p, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(0.1, valRipple, valRipple), Transparency = 1}):Play()
        Debris:AddItem(p, 1)
    end
end

local function GetClosestTarget()
    local t = nil; local closestToCenter = 500
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < closestToCenter then closestToCenter = dist; t = v.Character.Head end
            end
        end
    end
    return t
end

-- HELPER FOR FRIEND BOT
local function GetClosestPlayer()
    local target = nil
    local dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local d = (v.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                target = v.Character.HumanoidRootPart
            end
        end
    end
    return target
end

Player.CharacterAdded:Connect(function(char)
    DeathScreen.Enabled = false
    char:WaitForChild("Humanoid").Died:Connect(function() DeathScreen.Enabled = true end)
end)

-- [[ RENDER LOOP ]] --
local lastGhostTime = 0
RunService.RenderStepped:Connect(function()
    local tickTime = tick()
    local currentThemeName = Themes[CurrentThemeIndex]
    local activeColor = Color3.new(1,1,1)
    if currentThemeName == "RGB" then activeColor = Color3.fromHSV(tickTime % 3 / 3, 1, 1)
    elseif ThemeColors[currentThemeName] then activeColor = ThemeColors[currentThemeName] end
    
    DeathLabel.TextColor3 = activeColor
    for i, obj in pairs(RGB_Objects) do 
        if obj.Instance and obj.Instance.Parent then 
            if obj.Type == "Stroke" then obj.Instance.Color = activeColor 
            elseif obj.Type == "Text" then obj.Instance.TextColor3 = activeColor 
            elseif obj.Type == "Image" then obj.Instance.ImageColor3 = activeColor
            elseif obj.Type == "Part" then obj.Instance.Color = activeColor 
            end 
        else table.remove(RGB_Objects, i) end 
    end
    
    local wm = ScreenGui.Parent:FindFirstChild("AngerWatermark")
    if wm then wm.Enabled = States.Watermark end

    if PageInfo.Visible then InfoLabel.Text = string.format("SESSION:\nUser: %s\nID: %s\nFPS: %d\nPing: %d ms", Player.Name, SessionID, math.floor(workspace:GetRealPhysicsFPS()), math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) end

    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hum = char:FindFirstChild("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart")

    if States.UnlockAll then Player.CameraMaxZoomDistance = 100000; Player.CameraMinZoomDistance = 0; Player.CameraMode = Enum.CameraMode.Classic end
    if States.SpdBypass and hum.MoveDirection.Magnitude > 0 then root.CFrame = root.CFrame + (hum.MoveDirection * valBypassSpeed) end

    if States.Aim then
        local target = GetClosestTarget()
        if target then 
            local shakeX = math.random(-2, 2) / 100; local shakeY = math.random(-2, 2) / 100
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position + Vector3.new(shakeX, shakeY, 0)), valSmooth) 
        end
    end

    if States.Esp then for _, v in pairs(game.Players:GetPlayers()) do if v ~= Player and v.Character then local hl = v.Character:FindFirstChild("AngerESP") or Instance.new("Highlight", v.Character); hl.Name="AngerESP"; hl.FillTransparency=0.5; hl.OutlineTransparency=0; hl.FillColor=activeColor; hl.OutlineColor=Color3.new(1,1,1) end end else for _, v in pairs(game.Players:GetPlayers()) do if v.Character and v.Character:FindFirstChild("AngerESP") then v.Character.AngerESP:Destroy() end end end

    if States.RGB then for _,v in pairs(char:GetDescendants()) do if v:IsA("BasePart") or v:IsA("MeshPart") then v.Color=activeColor; v.Material=Enum.Material.Neon; if v:IsA("MeshPart") then v.TextureID="" end; if v:IsA("Decal") then v:Destroy() end end end end
    if States.Fullbright then Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.FogEnd=100000; Lighting.GlobalShadows=false end

    if States.Fly and root and hum then
        root.Velocity = Vector3.new(0, 0.1, 0) 
        if hum.MoveDirection.Magnitude > 0 then root.CFrame = root.CFrame + (hum.MoveDirection * valFlySpeed) end
        if up then root.CFrame = root.CFrame * CFrame.new(0, valFlySpeed, 0) end
        if down then root.CFrame = root.CFrame * CFrame.new(0, -valFlySpeed, 0) end
    end
    
    if States.KillAura then
        local tool = char:FindFirstChildOfClass("Tool"); if tool and tool:FindFirstChild("Handle") then for _, v in pairs(game.Players:GetPlayers()) do if v ~= Player and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then local dist = (v.Character.Head.Position - root.Position).Magnitude; if dist < 50 then tool.Handle.CFrame = v.Character.Head.CFrame; tool:Activate(); pcall(function() firetouchinterest(tool.Handle, v.Character.Head, 0); firetouchinterest(tool.Handle, v.Character.Head, 1) end); break end end end end
    end

    if States.Ghosts and tick() - lastGhostTime > valGhostRate then lastGhostTime = tick(); for _, v in pairs(char:GetChildren()) do if v:IsA("BasePart") and v.Transparency < 1 then local g = v:Clone(); g.Parent = workspace; g.Anchored = true; g.CanCollide = false; g.CFrame = v.CFrame; g.Color = activeColor; g.Material = Enum.Material.Neon; g:ClearAllChildren(); TweenService:Create(g, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency=1, CFrame=g.CFrame*CFrame.Angles(math.rad(math.random(-180,180)),math.rad(math.random(-180,180)),0), Size=g.Size*1.1}):Play(); Debris:AddItem(g, 0.5) end end end
    
    if States.Spd and hum.MoveDirection.Magnitude > 0 then root.CFrame += (hum.MoveDirection * (0.5 * valSpeed)) end
    if States.Jump then hum.UseJumpPower = true; hum.JumpPower = valJumpPower else hum.JumpPower = 50 end
    
    -- FRIEND BOT LOGIC (ХВОСТИК)
    if States.FriendBot then
        local targetRoot = GetClosestPlayer()
        if targetRoot then
            local distance = (targetRoot.Position - root.Position).Magnitude
            if distance > 6 then hum:MoveTo(targetRoot.Position) else hum:Move(Vector3.new(0,0,0)) end
            local targetHum = targetRoot.Parent:FindFirstChild("Humanoid")
            if targetHum and targetHum:GetState() == Enum.HumanoidStateType.Jumping then hum.Jump = true end
        end
    end

    for _, v in pairs(game.Players:GetPlayers()) do if v ~= Player and v.Character and v.Character:FindFirstChild("Head") then local head = v.Character.Head; head.Size = States.Hitbox and Vector3.new(valHitbox, valHitbox, valHitbox) or Vector3.new(1,1,1); head.Transparency = States.Hitbox and 0.7 or 0; head.CanCollide = false; if States.Hitbox then head.Color = activeColor; head.Material = Enum.Material.Neon end end end
end)

UserInputService.JumpRequest:Connect(function() if States.InfJump and Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end; if States.Circle then SpawnRipple() end end)
Player.Idled:Connect(function() if States.AntiAfk then VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end end)

task.spawn(function()
    local urlLogo = "https://raw.githubusercontent.com/AngerPC-DEV/AngerMOD/main/AngerMOD.png"
    local fileLogo = "AngerMOD_Logo_V104.png"
    if writefile and readfile and getcustomasset then
        pcall(function() if not isfile(fileLogo) then writefile(fileLogo, game:HttpGet(urlLogo)) end end)
        local lg = Instance.new("ScreenGui", ScreenGui.Parent); lg.Name = "AngerWatermark"; local im = Instance.new("ImageLabel", lg); im.Size = UDim2.new(0, 200, 0, 100); im.Position = UDim2.new(0, 10, 0, 10); im.BackgroundTransparency = 1; im.BorderSizePixel = 0; local stroke = Instance.new("UIStroke", im); stroke.Thickness = 3; stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; stroke.Color = Color3.new(1, 0, 0); table.insert(RGB_Objects, {Type = "Stroke", Instance = stroke}); local s, a = pcall(function() return getcustomasset(fileLogo) end); if s then im.Image = a else im.Image = urlLogo end
    end
end)

task.spawn(function()
    local pentagramUrl = "https://raw.githubusercontent.com/AngerPC-DEV/AngerMOD/main/circle1.png"
    local pentagramName = "Anger_Pentagram_Circle1.png"
    if writefile and readfile and isfile then pcall(function() if not isfile(pentagramName) then writefile(pentagramName, game:HttpGet(pentagramUrl)) end end) end
end)