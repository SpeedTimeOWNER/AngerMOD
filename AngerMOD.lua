-- [[ ⛧ AngerPC ⛧ V124 TITAN EDITION ]] --

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
local Mouse = Player:GetMouse()

-- [[ DELTA & EXECUTOR COMPATIBILITY ]] --
local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local getcustomasset = getcustomasset or getsynasset
local queue_on_teleport = queue_on_teleport or syn.queue_on_teleport

-- [[ SESSION & MEMORY ]] --
local SessionID = string.upper(HttpService:GenerateGUID(false):sub(1, 8))
local ChatHistory = { { role = "system", content = "Ты — AngerPC, дерзкий AI в Roblox." } }

-- [[ THEME SYSTEM ]] --
local Themes = { "RGB", "КРАСНЫЙ", "ФИОЛЕТОВЫЙ", "ГОЛУБОЙ", "ТОКСИК", "ЧЕРНЫЙ" }
local ThemeColors = {
    ["КРАСНЫЙ"] = Color3.fromRGB(255, 0, 0), ["ФИОЛЕТОВЫЙ"] = Color3.fromRGB(170, 0, 255),
    ["ГОЛУБОЙ"] = Color3.fromRGB(0, 190, 255), ["ТОКСИК"] = Color3.fromRGB(100, 255, 0),
    ["ЧЕРНЫЙ"] = Color3.fromRGB(50, 50, 50)
}
local CurrentThemeIndex = 1 

-- [[ 1. GUI SETUP ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AngerGUI_V124_TITAN"
ScreenGui.ResetOnSpawn = false -- Меню не пропадает при смерти

if Player:FindFirstChild("PlayerGui") then
    ScreenGui.Parent = Player.PlayerGui
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

-- DEATH SCREEN
local DeathScreen = Instance.new("ScreenGui", ScreenGui.Parent); DeathScreen.Name = "AngerDeath"; DeathScreen.Enabled = false
local DeathLabel = Instance.new("TextLabel", DeathScreen); DeathLabel.Size = UDim2.new(1, 0, 1, 0); DeathLabel.BackgroundTransparency = 1; DeathLabel.Text = "ELIMINATED"; DeathLabel.Font = Enum.Font.GothamBlack; DeathLabel.TextSize = 80; DeathLabel.TextColor3 = Color3.fromRGB(255, 0, 0); DeathLabel.TextStrokeTransparency = 0

-- LISTS
local RGB_Objects = {} 
local Movable_Objects = {} 
local RecordedPath = {}

local function style(obj, radius, thickness)
    local uiC = Instance.new("UICorner", obj); uiC.CornerRadius = UDim.new(0, radius or 6)
    local uiS = Instance.new("UIStroke", obj); uiS.Color = Color3.fromRGB(60, 60, 60); uiS.Thickness = thickness or 1
    table.insert(RGB_Objects, {Type = "Stroke", Instance = uiS})
    return uiS
end

-- // MAIN FRAME // --
local Main = Instance.new("Frame", ScreenGui); Main.Size = UDim2.new(0, 500, 0, 600); Main.Position = UDim2.new(0.1, 0, 0.15, 0); Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12); Main.Visible = true; Main.Active = true; Main.Draggable = true; style(Main, 8, 2); table.insert(Movable_Objects, Main)

-- TABS CONTAINER
local TabFrame = Instance.new("Frame", Main); TabFrame.Size = UDim2.new(1, -20, 0, 35); TabFrame.Position = UDim2.new(0, 10, 0, 50); TabFrame.BackgroundTransparency = 1
local layoutTabs = Instance.new("UIListLayout", TabFrame); layoutTabs.FillDirection=Enum.FillDirection.Horizontal; layoutTabs.Padding=UDim.new(0,5)

local function MakeTab(text)
    local b = Instance.new("TextButton", TabFrame); b.Size=UDim2.new(0.19,0,1,0); b.BackgroundColor3=Color3.fromRGB(20,20,20); b.Text=text; b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.SciFi; style(b); b.TextScaled = true
    return b
end
local btnTabMain = MakeTab("MAIN"); local btnTabAim = MakeTab("AIM"); local btnTabWorld = MakeTab("WORLD"); local btnTabAI = MakeTab("AI"); local btnTabUI = MakeTab("CFG")

-- TITLE
local Title = Instance.new("TextLabel", Main); Title.Size=UDim2.new(1,0,0,45); Title.BackgroundTransparency=1; Title.Text="AngerPC V124 TITAN"; Title.Font=Enum.Font.SciFi; Title.TextSize=26; Title.TextColor3=Color3.new(1,1,1); table.insert(RGB_Objects, {Type="Text", Instance=Title})

-- // PAGES // --
local PageMain = Instance.new("ScrollingFrame", Main); PageMain.Size=UDim2.new(1,-20,0.8,0); PageMain.Position=UDim2.new(0,10,0.18,0); PageMain.BackgroundTransparency=1; PageMain.ScrollBarThickness=2; PageMain.Visible=true; Instance.new("UIListLayout", PageMain).Padding=UDim.new(0,8)
local PageAim = Instance.new("Frame", Main); PageAim.Size=UDim2.new(1,-20,0.8,0); PageAim.Position=UDim2.new(0,10,0.18,0); PageAim.BackgroundTransparency=1; PageAim.Visible=false
local PageWorld = Instance.new("Frame", Main); PageWorld.Size=UDim2.new(1,-20,0.8,0); PageWorld.Position=UDim2.new(0,10,0.18,0); PageWorld.BackgroundTransparency=1; PageWorld.Visible=false
local PageAI = Instance.new("Frame", Main); PageAI.Size=UDim2.new(1,-20,0.8,0); PageAI.Position=UDim2.new(0,10,0.18,0); PageAI.BackgroundTransparency=1; PageAI.Visible=false
local PageUI = Instance.new("Frame", Main); PageUI.Size=UDim2.new(1,-20,0.8,0); PageUI.Position=UDim2.new(0,10,0.18,0); PageUI.BackgroundTransparency=1; PageUI.Visible=false

btnTabMain.MouseButton1Click:Connect(function() PageMain.Visible=true; PageAim.Visible=false; PageWorld.Visible=false; PageAI.Visible=false; PageUI.Visible=false end)
btnTabAim.MouseButton1Click:Connect(function() PageMain.Visible=false; PageAim.Visible=true; PageWorld.Visible=false; PageAI.Visible=false; PageUI.Visible=false end)
btnTabWorld.MouseButton1Click:Connect(function() PageMain.Visible=false; PageAim.Visible=false; PageWorld.Visible=true; PageAI.Visible=false; PageUI.Visible=false end)
btnTabAI.MouseButton1Click:Connect(function() PageMain.Visible=false; PageAim.Visible=false; PageWorld.Visible=false; PageAI.Visible=true; PageUI.Visible=false end)
btnTabUI.MouseButton1Click:Connect(function() PageMain.Visible=false; PageAim.Visible=false; PageWorld.Visible=false; PageAI.Visible=false; PageUI.Visible=true end)

-- // WORLD PAGE CONTENT // --
local btnUp = Instance.new("TextButton", PageWorld); btnUp.Size = UDim2.new(0.45, 0, 0, 40); btnUp.Position = UDim2.new(0, 0, 0.7, 0); btnUp.Text = "FLY UP"; btnUp.BackgroundColor3 = Color3.fromRGB(20,20,20); btnUp.TextColor3 = Color3.new(1,1,1); style(btnUp)
local btnDn = Instance.new("TextButton", PageWorld); btnDn.Size = UDim2.new(0.45, 0, 0, 40); btnDn.Position = UDim2.new(0.5, 0, 0.7, 0); btnDn.Text = "FLY DOWN"; btnDn.BackgroundColor3 = Color3.fromRGB(20,20,20); btnDn.TextColor3 = Color3.new(1,1,1); style(btnDn)

-- // AIM PAGE CONTENT // --
local AimStatus = Instance.new("TextLabel", PageAim); AimStatus.Size=UDim2.new(1,0,0,30); AimStatus.Position=UDim2.new(0,0,0.6,0); AimStatus.Text="TARGET: SEARCHING..."; AimStatus.TextColor3=Color3.fromRGB(150,150,150); AimStatus.BackgroundTransparency=1; style(AimStatus, 0, 0)

-- // AI PAGE CONTENT // --
local AIKeyBox = Instance.new("TextBox", PageAI); AIKeyBox.Size = UDim2.new(1, 0, 0, 40); AIKeyBox.Position = UDim2.new(0,0,0,0); AIKeyBox.PlaceholderText = "OPENAI KEY (sk-...)"; AIKeyBox.Text = ""; AIKeyBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20); AIKeyBox.TextColor3 = Color3.new(1, 1, 1); style(AIKeyBox)
local AIToggleBtn = Instance.new("TextButton", PageAI); AIToggleBtn.Size = UDim2.new(1, 0, 0, 40); AIToggleBtn.Position = UDim2.new(0, 0, 0.1, 0); AIToggleBtn.Text = "AI AUTOREPLY: OFF"; AIToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 10, 10); AIToggleBtn.TextColor3 = Color3.new(1, 1, 1); style(AIToggleBtn)
local RecBtn = Instance.new("TextButton", PageAI); RecBtn.Size = UDim2.new(0.48, 0, 0, 40); RecBtn.Position = UDim2.new(0, 0, 0.3, 0); RecBtn.Text = "REC MACRO"; RecBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 10); RecBtn.TextColor3 = Color3.new(1, 1, 1); style(RecBtn)
local PlayBtn = Instance.new("TextButton", PageAI); PlayBtn.Size = UDim2.new(0.48, 0, 0, 40); PlayBtn.Position = UDim2.new(0.52, 0, 0.3, 0); PlayBtn.Text = "PLAY MACRO"; PlayBtn.BackgroundColor3 = Color3.fromRGB(10, 40, 10); PlayBtn.TextColor3 = Color3.new(1, 1, 1); style(PlayBtn)
local AIStatus = Instance.new("TextLabel", PageAI); AIStatus.Size = UDim2.new(1, 0, 0, 30); AIStatus.Position = UDim2.new(0, 0, 0.5, 0); AIStatus.BackgroundTransparency = 1; AIStatus.Text = "AI STATUS: IDLE"; AIStatus.TextColor3 = Color3.fromRGB(150, 150, 150); style(AIStatus, 0, 0)

-- // SIDE BUTTON // --
local SideBtn = Instance.new("TextButton", ScreenGui); SideBtn.Name = "ToggleMenu"; SideBtn.Size = UDim2.new(0, 55, 0, 55); SideBtn.Position = UDim2.new(0, 10, 0.5, 0); SideBtn.Text = "MENU"; SideBtn.BackgroundColor3 = Color3.fromRGB(20,20,20); SideBtn.TextColor3 = Color3.new(1,1,1); style(SideBtn, 16); table.insert(Movable_Objects, SideBtn)
SideBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- [[ 2. LOGIC VARIABLES ]] --
local States = { 
    AI = false, Watermark = true, AntiKnock = false, CamLock = false, InstantCam = false,
    Fly = false, Spd = false, Jump = false, InfJump = false, Esp = false, NoFog = false,
    IsRecording = false, IsPlaying = false, LoopPlay = false
} 
local Vars = { Speed = 50, Jump = 100, Fly = 5, AimSmooth = 0.2, AimFOV = 300 }
local up, down = false, false

-- [[ BIND SYSTEM ]] --
local function makeBind(name, callback)
    local hb = Instance.new("TextButton", ScreenGui); hb.Name="Bind_"..name; hb.Size=UDim2.new(0,55,0,55); hb.Position=UDim2.new(0.85,0,0.4,0); hb.BackgroundColor3=Color3.fromRGB(15,15,15); hb.Text=name:sub(1,3); hb.TextColor3=Color3.new(1,1,1); hb.Visible=false; hb.Draggable=true; style(hb,25); hb.MouseButton1Click:Connect(callback); table.insert(Movable_Objects, hb); return hb
end

local btnTheme = Instance.new("TextButton", PageUI); btnTheme.Size = UDim2.new(1, 0, 0, 40); btnTheme.BackgroundColor3 = Color3.fromRGB(25, 25, 25); btnTheme.Text = "THEME: " .. Themes[CurrentThemeIndex]; btnTheme.TextColor3 = Color3.new(1,1,1); btnTheme.Font = Enum.Font.SciFi; btnTheme.TextSize = 16; style(btnTheme)
btnTheme.MouseButton1Click:Connect(function() CurrentThemeIndex = CurrentThemeIndex + 1; if CurrentThemeIndex > #Themes then CurrentThemeIndex = 1 end; btnTheme.Text = "THEME: " .. Themes[CurrentThemeIndex] end)

local function addOption(page, name, key, useInput, defaultInputVal, inputCallback)
    local f = Instance.new("Frame", page); f.Size = UDim2.new(1, 0, 0, 40); f.BackgroundTransparency = 1
    local btnSize = useInput and 0.55 or 0.75
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(btnSize, -5, 1, 0); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(20, 20, 20); b.TextColor3 = Color3.new(1,1,1); style(b)
    if States[key] then b.BackgroundColor3 = Color3.fromRGB(0, 100, 0) end
    
    local function Toggle()
        States[key] = not States[key]
        b.BackgroundColor3 = States[key] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(20, 20, 20)
        if key == "InstantCam" then if States.InstantCam then Camera.CameraType = Enum.CameraType.Scriptable else Camera.CameraType = Enum.CameraType.Custom end end
    end
    
    local hk = makeBind(name, Toggle)
    b.MouseButton1Click:Connect(Toggle)
    
    local bb = Instance.new("TextButton", f); bb.Size = UDim2.new(0.2, 0, 1, 0); bb.Position = UDim2.new(0.8, 0, 0, 0); bb.Text = "BIND"; style(bb)
    bb.MouseButton1Click:Connect(function() hk.Visible = not hk.Visible end)
    
    if useInput then
        local inp = Instance.new("TextBox", f); inp.Size = UDim2.new(0.2, -5, 1, 0); inp.Position = UDim2.new(0.58, 0, 0, 0); inp.Text = tostring(defaultInputVal); inp.BackgroundColor3 = Color3.fromRGB(15,15,15); inp.TextColor3 = Color3.new(1,1,1); style(inp)
        inp.FocusLost:Connect(function() local n = tonumber(inp.Text); if n then inputCallback(n) else inp.Text = tostring(defaultInputVal) end end)
    end
end

-- [[ OPTIONS LIST (THE BIG LIST) ]] --
-- PAGE MAIN
addOption(PageMain, "INSTANT CAM", "InstantCam", false) 
addOption(PageMain, "SPEED RUN", "Spd", true, Vars.Speed, function(v) Vars.Speed = v end)
addOption(PageMain, "HIGH JUMP", "Jump", true, Vars.Jump, function(v) Vars.Jump = v end)
addOption(PageMain, "INF JUMP", "InfJump", false)
addOption(PageMain, "ESP BOX", "Esp", false)

-- PAGE WORLD
addOption(PageWorld, "ANTI-KNOCKBACK", "AntiKnock", false) -- FIX
addOption(PageWorld, "FLY MODE", "Fly", true, Vars.Fly, function(v) Vars.Fly = v end)
addOption(PageWorld, "REMOVE FOG", "NoFog", false)

-- PAGE AIM
addOption(PageAim, "CAM LOCK", "CamLock", false)
addOption(PageAim, "SMOOTHNESS", "N/A", true, Vars.AimSmooth, function(v) Vars.AimSmooth = v end)
addOption(PageAim, "FOV SIZE", "N/A", true, Vars.AimFOV, function(v) Vars.AimFOV = v end)

-- [[ SAVE SYSTEM ]] --
local SaveBtn = Instance.new("TextButton", PageUI); SaveBtn.Size = UDim2.new(1, 0, 0, 40); SaveBtn.Position = UDim2.new(0,0,0.15,0); SaveBtn.Text = "SAVE CONFIG"; SaveBtn.BackgroundColor3 = Color3.fromRGB(20,20,40); SaveBtn.TextColor3 = Color3.new(1,1,1); style(SaveBtn)
local ConfigName = "AngerTitan_V124.json"
SaveBtn.MouseButton1Click:Connect(function()
    local data = {}; for _, obj in pairs(Movable_Objects) do data[obj.Name] = {X_S=obj.Position.X.Scale, X_O=obj.Position.X.Offset, Y_S=obj.Position.Y.Scale, Y_O=obj.Position.Y.Offset} end
    if writefile then writefile(ConfigName, game:GetService("HttpService"):JSONEncode(data)); SaveBtn.Text="SAVED!"; task.wait(1); SaveBtn.Text="SAVE CONFIG" end
end)
task.spawn(function() if isfile and isfile(ConfigName) then local data = game:GetService("HttpService"):JSONDecode(readfile(ConfigName)); for _, obj in pairs(Movable_Objects) do if data[obj.Name] then obj.Position = UDim2.new(data[obj.Name].X_S, data[obj.Name].X_O, data[obj.Name].Y_S, data[obj.Name].Y_O) end end end end)

-- [[ LOGIC FUNCTIONS ]] --

-- 1. MACROS
local function SmartMove(targetCF)
    local char = Player.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = targetCF end
end
RecBtn.MouseButton1Click:Connect(function()
    States.IsRecording = not States.IsRecording
    if States.IsRecording then States.IsPlaying = false; RecordedPath = {}; RecBtn.Text = "STOP REC"; RecBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0); else RecBtn.Text = "REC MACRO"; RecBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 10); end
end)
PlayBtn.MouseButton1Click:Connect(function()
    States.IsPlaying = not States.IsPlaying
    if States.IsPlaying then 
        States.IsRecording = false; PlayBtn.Text = "STOP PLAY"; PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0); 
        task.spawn(function()
            while States.IsPlaying do
                for i, frame in ipairs(RecordedPath) do
                    if not States.IsPlaying then break end
                    SmartMove(frame.CF)
                    RunService.Heartbeat:Wait()
                end
                States.IsPlaying = false; PlayBtn.Text = "PLAY MACRO"; PlayBtn.BackgroundColor3 = Color3.fromRGB(10, 40, 10)
                break
            end
        end)
    else PlayBtn.Text = "PLAY MACRO"; PlayBtn.BackgroundColor3 = Color3.fromRGB(10, 40, 10) end
end)

-- 2. AI SYSTEM
local AI_Debounce = false
local function SendChat(msg)
    if game:GetService("TextChatService").ChatVersion == Enum.ChatVersion.TextChatService then
        pcall(function() game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(msg) end)
    else game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All") end
end
local function ProcessAI(msg, senderName)
    if AI_Debounce or not States.AI then return end
    AI_Debounce = true; AIStatus.Text = "AI: THINKING..."
    local apiKey = AIKeyBox.Text; if apiKey == "" then AIStatus.Text = "AI: NO KEY"; AI_Debounce = false; return end
    table.insert(ChatHistory, {role = "user", content = senderName .. ": " .. msg})
    if #ChatHistory > 10 then table.remove(ChatHistory, 2) end
    local success, response = pcall(function()
        if request then return request({ Url = "https://api.openai.com/v1/chat/completions", Method = "POST", Headers = {["Content-Type"] = "application/json", ["Authorization"] = "Bearer " .. apiKey}, Body = HttpService:JSONEncode({ model = "gpt-4o-mini", messages = ChatHistory, max_tokens = 60 }) }) end
    end)
    if success and response and response.Body then 
        local data = HttpService:JSONDecode(response.Body)
        if data.choices and data.choices[1] then local reply = data.choices[1].message.content; SendChat(reply); table.insert(ChatHistory, {role = "assistant", content = reply}); AIStatus.Text = "AI: REPLIED" end
    else AIStatus.Text = "AI: ERROR" end
    task.wait(3); AI_Debounce = false; AIStatus.Text = "AI: IDLE"
end
AIToggleBtn.MouseButton1Click:Connect(function() States.AI = not States.AI; AIToggleBtn.BackgroundColor3 = States.AI and Color3.fromRGB(0,100,0) or Color3.fromRGB(30,10,10) end)
for _, p in pairs(Players:GetPlayers()) do p.Chatted:Connect(function(msg) if p ~= Player then ProcessAI(msg, p.Name) end end) end

-- 3. AIMBOT LOGIC
local function GetClosestToMouse()
    local closest = nil
    local shortestDist = Vars.AimFOV
    local mousePos = UserInputService:GetMouseLocation()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 and p.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if dist < shortestDist then shortestDist = dist; closest = p.Character.Head end
            end
        end
    end
    return closest
end

-- 4. MAIN LOOP
btnUp.MouseButton1Down:Connect(function() up = true end); btnUp.MouseButton1Up:Connect(function() up = false end)
btnDn.MouseButton1Down:Connect(function() down = true end); btnDn.MouseButton1Up:Connect(function() down = false end)

RunService.RenderStepped:Connect(function()
    local tickTime = tick()
    local activeColor = ThemeColors[Themes[CurrentThemeIndex]] or Color3.fromHSV(tickTime % 3 / 3, 1, 1)
    
    -- RGB
    DeathLabel.TextColor3 = activeColor
    for i, obj in pairs(RGB_Objects) do 
        if obj.Instance and obj.Instance.Parent then 
            if obj.Type == "Stroke" then obj.Instance.Color = activeColor elseif obj.Type == "Text" then obj.Instance.TextColor3 = activeColor end 
        end 
    end
    
    if States.NoFog then Lighting.FogEnd = 1000000 end

    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if States.IsRecording then table.insert(RecordedPath, {CF = root.CFrame}) end

    -- ANTI-KNOCKBACK
    if States.AntiKnock then
        if root.AssemblyLinearVelocity.Magnitude > 150 then
            root.AssemblyLinearVelocity = Vector3.new(0,0,0)
            root.AssemblyAngularVelocity = Vector3.new(0,0,0)
        end
        for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5) end end
    end

    -- AIMBOT
    if States.CamLock then
        local target = GetClosestToMouse()
        if target then
            AimStatus.Text = "LOCKED: " .. target.Parent.Name
            AimStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Vars.AimSmooth)
        else
            AimStatus.Text = "SEARCHING..."
            AimStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end


    -- MOVEMENT
    if States.Spd and hum.MoveDirection.Magnitude > 0 then root.CFrame = root.CFrame + (hum.MoveDirection * (Vars.Speed / 50)) end
    if States.Fly then
        root.Velocity = Vector3.new(0, 0, 0)
        if hum.MoveDirection.Magnitude > 0 then root.CFrame = root.CFrame + (hum.MoveDirection * Vars.Fly) end
        if up then root.CFrame = root.CFrame * CFrame.new(0, Vars.Fly, 0) end
        if down then root.CFrame = root.CFrame * CFrame.new(0, -Vars.Fly, 0) end
    end
    if States.Jump then hum.UseJumpPower = true; hum.JumpPower = Vars.Jump end
    
    -- ESP
    if States.Esp then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character then
                if not v.Character:FindFirstChild("AngerESP") then
                    local hl = Instance.new("Highlight", v.Character); hl.Name = "AngerESP"; hl.FillTransparency = 0.5; hl.OutlineTransparency = 0
                else v.Character.AngerESP.FillColor = activeColor end
            end
        end
    else for _, v in pairs(Players:GetPlayers()) do if v.Character and v.Character:FindFirstChild("AngerESP") then v.Character.AngerESP:Destroy() end end end
end)

UserInputService.JumpRequest:Connect(function() if States.InfJump and Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)
Player.CharacterAdded:Connect(function(c) DeathScreen.Enabled = false; c:WaitForChild("Humanoid").Died:Connect(function() DeathScreen.Enabled = true end); if States.InstantCam then Camera.CameraType = Enum.CameraType.Custom end end)

-- LOGO LOAD
task.spawn(function()
    local lg = Instance.new("ScreenGui", ScreenGui.Parent); lg.Name = "AngerWatermark"
    local im = Instance.new("ImageLabel", lg); im.Size = UDim2.new(0, 160, 0, 80); im.Position = UDim2.new(0, 10, 0, 10); im.BackgroundTransparency = 1; im.Image = "https://raw.githubusercontent.com/AngerPC-DEV/AngerMOD/main/AngerMOD.png"
end)