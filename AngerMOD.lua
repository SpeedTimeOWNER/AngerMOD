-- [[ AngerMOD V120 - TOOL AURA (By AngerPC) ]] --
local Player = game:GetService("Players").LocalPlayer
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local Debris = game:GetService("Debris")

if CoreGui:FindFirstChild("AngerV120") then CoreGui.AngerV120:Destroy() end
local ui = Instance.new("ScreenGui", CoreGui); ui.Name = "AngerV120"

-- [ GUI ДЛЯ СМЕРТИ ] --
local DeathGui = Instance.new("ScreenGui", CoreGui); DeathGui.Name = "AngerDeath"; DeathGui.Enabled = false
local DeathLabel = Instance.new("TextLabel", DeathGui)
DeathLabel.Size = UDim2.new(1,0,1,0); DeathLabel.BackgroundTransparency = 1
DeathLabel.Text = "HAHA DIED"; DeathLabel.Font = Enum.Font.Creepster; DeathLabel.TextSize = 100
DeathLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
Instance.new("UIStroke", DeathLabel).Thickness = 3

-- [ ПЕРЕМЕННЫЕ ] --
local States = {
    Aim = false, Fly = false, Spd = false, Esp = false, RGB = false, 
    Hitbox = false, Circle = false, Ghosts = false, Jump = false, KillAura = false
}
local up, down = false

-- Настройки
local valHitbox = 15     
local valSpeed = 1       
local valRipple = 25     
local valJumpPower = 50
local valFlySpeed = 1 
local valSmooth = 0.2

local ghostParts = {} 
local currentTarget = nil 

-- [ СТИЛЬ ] --
local function style(obj, r)
    Instance.new("UICorner", obj).CornerRadius = UDim.new(0, r or 12)
    local s = Instance.new("UIStroke", obj)
    s.Thickness = 2.5; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

-- [ ЛОГИН ] --
local LFrame = Instance.new("Frame", ui); LFrame.Size = UDim2.new(0, 300, 0, 200); LFrame.Position = UDim2.new(0.5, -150, 0.5, -100); LFrame.BackgroundColor3 = Color3.fromRGB(8,8,8); local LS = style(LFrame, 15)
local LTitle = Instance.new("TextLabel", LFrame); LTitle.Size = UDim2.new(1,0,0.3,0); LTitle.Text = "ANGER AURA V120"; LTitle.Font = Enum.Font.GothamBold; LTitle.TextSize = 20; LTitle.TextColor3 = Color3.new(1,1,1); LTitle.BackgroundTransparency = 1
local LI = Instance.new("TextBox", LFrame); LI.Size = UDim2.new(0.8, 0, 0, 40); LI.Position = UDim2.new(0.1, 0, 0.35, 0); LI.PlaceholderText = "Key: AngerPC"; style(LI)
local LB = Instance.new("TextButton", LFrame); LB.Size = UDim2.new(0.8, 0, 0, 45); LB.Position = UDim2.new(0.1, 0, 0.65, 0); LB.Text = "LOGIN"; LB.BackgroundColor3 = Color3.fromRGB(20,20,20); LB.TextColor3 = Color3.new(1,1,1); local LBS = style(LB)

-- [ МЕНЮ ] --
local Main = Instance.new("Frame", ui); Main.Size = UDim2.new(0, 330, 0, 580); Main.Position = UDim2.new(0.5, -165, 0.5, -290); Main.BackgroundColor3 = Color3.fromRGB(5, 5, 5); Main.Visible = false; Main.Active = true; Main.Draggable = true; local mS = style(Main, 20)
local Title = Instance.new("TextLabel", Main); Title.Size = UDim2.new(1, 0, 0, 50); Title.Text = "AngerMOD V120"; Title.Font = Enum.Font.GothamBlack; Title.TextSize = 24; Title.BackgroundTransparency = 1

local SideBtn = Instance.new("TextButton", ui); SideBtn.Size = UDim2.new(0, 35, 0, 120); SideBtn.Position = UDim2.new(0, 0, 0.4, 0); SideBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15); SideBtn.Text = "A\nN\nG\nE\nR"; SideBtn.TextColor3 = Color3.new(1,1,1); SideBtn.Visible = false; style(SideBtn, 5)

-- [ FLY UI ] --
local FlyGui = Instance.new("Frame", ui); FlyGui.Size = UDim2.new(0, 60, 0, 130); FlyGui.Position = UDim2.new(0.9, -70, 0.7, 0); FlyGui.BackgroundTransparency = 1; FlyGui.Visible = false
local btnUp = Instance.new("TextButton", FlyGui); btnUp.Size = UDim2.new(1, 0, 0, 60); btnUp.Text = "▲"; btnUp.BackgroundColor3 = Color3.fromRGB(20,20,20); btnUp.TextColor3 = Color3.new(1,1,1); style(btnUp, 30)
local btnDn = Instance.new("TextButton", FlyGui); btnDn.Size = UDim2.new(1, 0, 0, 60); btnDn.Position = UDim2.new(0, 0, 0, 70); btnDn.Text = "▼"; btnDn.BackgroundColor3 = Color3.fromRGB(20,20,20); btnDn.TextColor3 = Color3.new(1,1,1); style(btnDn, 30)

btnUp.MouseButton1Down:Connect(function() up = true end); btnUp.MouseButton1Up:Connect(function() up = false end)
btnDn.MouseButton1Down:Connect(function() down = true end); btnDn.MouseButton1Up:Connect(function() down = false end)

local Scroll = Instance.new("ScrollingFrame", Main); Scroll.Size = UDim2.new(1, -20, 0.85, 0); Scroll.Position = UDim2.new(0, 10, 0, 60); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 2; Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 8)

-- [ БИНДЫ ] --
local function makeBind(name, callback)
    local hb = Instance.new("TextButton", ui); hb.Size = UDim2.new(0, 50, 0, 50); hb.Position = UDim2.new(0.85, 0, 0.4, 0); hb.BackgroundColor3 = Color3.fromRGB(10,10,10); hb.Text = name:sub(1,3); hb.TextColor3 = Color3.new(1,1,1); hb.Visible = false; hb.Draggable = true; local s = style(hb, 25)
    hb.MouseButton1Click:Connect(callback); RunService.RenderStepped:Connect(function() s.Color = Color3.fromHSV(tick()%5/5, 0.8, 1) end); return hb
end

local function addOption(name, key, useInput, defaultInputVal, inputCallback)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(1, 0, 0, 40); f.BackgroundTransparency = 1
    local btnSize = useInput and 0.5 or 0.75
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(btnSize, -5, 1, 0); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(20, 20, 20); b.TextColor3 = Color3.new(1,1,1); style(b)
    local hk = makeBind(name, function() States[key] = not States[key]; if key == "Fly" then FlyGui.Visible = States.Fly end end)
    b.MouseButton1Click:Connect(function() States[key] = not States[key]; b.BackgroundColor3 = States[key] and Color3.fromRGB(100, 0, 255) or Color3.fromRGB(20, 20, 20); if key == "Fly" then FlyGui.Visible = States.Fly end end)
    local bb = Instance.new("TextButton", f); bb.Size = UDim2.new(0.25, 0, 1, 0); bb.Position = UDim2.new(0.75, 0, 0, 0); bb.Text = "BIND"; style(bb)
    bb.MouseButton1Click:Connect(function() hk.Visible = not hk.Visible end)
    if useInput then
        local inp = Instance.new("TextBox", f); inp.Size = UDim2.new(0.25, -5, 1, 0); inp.Position = UDim2.new(0.5, 0, 0, 0); inp.Text = tostring(defaultInputVal); inp.BackgroundColor3 = Color3.fromRGB(15,15,15); inp.TextColor3 = Color3.new(1,1,1); style(inp)
        inp.FocusLost:Connect(function() local n = tonumber(inp.Text); if n then inputCallback(n) else inp.Text = tostring(defaultInputVal) end end)
    end
end

-- [ СПИСОК ФУНКЦИЙ ] --
addOption("KILL AURA (TOOL)", "KillAura", false) -- Переименовал в TOOL AURA
addOption("AIM SMOOTH", "Aim", true, valSmooth, function(v) valSmooth = math.clamp(v, 0.01, 1) end)
addOption("BIG HITBOX", "Hitbox", true, valHitbox, function(v) valHitbox = v end)
addOption("FLY BYPASS", "Fly", true, valFlySpeed, function(v) valFlySpeed = v end)
addOption("SPEED HACK", "Spd", true, valSpeed, function(v) valSpeed = v end)
addOption("SUPER JUMP", "Jump", true, valJumpPower, function(v) valJumpPower = v end)
addOption("JUMP RIPPLE", "Circle", true, valRipple, function(v) valRipple = v end)
addOption("GHOSTS", "Ghosts", false)
addOption("ESP", "Esp", false)
addOption("RGB SKIN", "RGB", false)

-- [ ЛОГИКА LOGIN ] --
LB.MouseButton1Click:Connect(function() if LI.Text == "AngerPC" then LFrame:Destroy(); Main.Visible = true; SideBtn.Visible = true else LI.Text = "WRONG KEY"; wait(1); LI.Text = "" end end)
SideBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- [ ВСПОМОГАТЕЛЬНЫЕ ] --
local function createGhost() local p = Instance.new("Part"); p.Size = Vector3.new(1.2, 1.2, 1.2); p.Anchored = true; p.CanCollide = false; p.Material = Enum.Material.Neon; p.Shape = Enum.PartType.Ball; p.Transparency = 0.4; return p end
local function ChatSay(msg) local args = { [1] = msg, [2] = "All" }; if ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") then ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack(args)) end end

local function SpawnRipple()
    if not Player.Character then return end; local root = Player.Character:FindFirstChild("HumanoidRootPart"); if not root then return end
    local p = Instance.new("Part", workspace); p.Name = "AngerRipple"; p.Anchored = true; p.CanCollide = false; p.Material = Enum.Material.Neon; p.Shape = Enum.PartType.Cylinder 
    p.Size = Vector3.new(0.05, 1, 1); p.CFrame = root.CFrame * CFrame.new(0, -3, 0) * CFrame.Angles(0, 0, math.rad(90)); p.Color = Color3.fromHSV(tick()%5/5, 1, 1)
    local sg = Instance.new("SurfaceGui", p); sg.Face = Enum.NormalId.Right; local tl = Instance.new("TextLabel", sg); tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1
    tl.Text = "AngerMOD Project"; tl.TextScaled = true; tl.Font = Enum.Font.SciFi; tl.TextColor3 = Color3.new(1,1,1)
    TweenService:Create(p, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(0.05, valRipple, valRipple), Transparency = 1}):Play()
    spawn(function() for i=1, 20 do if not p.Parent then break end; p.CFrame *= CFrame.Angles(math.rad(5), 0, 0); task.wait(0.05) end end); Debris:AddItem(p, 1.0)
end

local function InitDeath(char) local hum = char:WaitForChild("Humanoid", 10); if hum then hum.Died:Connect(function() DeathGui.Enabled = true; ChatSay("GG"); wait(3); DeathGui.Enabled = false end) end end
if Player.Character then InitDeath(Player.Character) end; Player.CharacterAdded:Connect(InitDeath)

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

-- [ ГЛАВНЫЙ ЦИКЛ ] --
local lastJump = 0
RunService.RenderStepped:Connect(function()
    local rgb = Color3.fromHSV(tick() % 3 / 3, 1, 1)
    local slowRgb = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
    
    if LFrame.Parent then LS.Color = rgb; LBS.Color = rgb end
    mS.Color = slowRgb; Title.TextColor3 = slowRgb; SideBtn.TextColor3 = slowRgb
    style(btnUp, 30).Color = slowRgb; style(btnDn, 30).Color = slowRgb
    
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    -- [[ FLY LOGIC ]] --
    if States.Fly and root and hum then
        root.Velocity = Vector3.new(0, 0.1, 0) 
        if hum.MoveDirection.Magnitude > 0 then root.CFrame = root.CFrame + (hum.MoveDirection * valFlySpeed) end
        if up then root.CFrame = root.CFrame * CFrame.new(0, valFlySpeed, 0) end
        if down then root.CFrame = root.CFrame * CFrame.new(0, -valFlySpeed, 0) end
    end
    
    -- [[ KILL AURA (TOOL TELEPORT) ]] --
    if States.KillAura then
        -- Ищем оружие в руках
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            -- Ищем врага
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= Player and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                    local dist = (v.Character.Head.Position - root.Position).Magnitude
                    if dist < 50 then -- Работает в радиусе 50 студов
                        -- Телепортируем САМ МЕЧ (Handle) к голове врага
                        -- Используем firetouchinterest если доступен, или CFrame
                        tool.Handle.CFrame = v.Character.Head.CFrame
                        tool:Activate() -- Авто-клик
                        
                        -- Попытка вызвать событие касания (Для Delta/Fluxus)
                        pcall(function()
                            firetouchinterest(tool.Handle, v.Character.Head, 0)
                            firetouchinterest(tool.Handle, v.Character.Head, 1)
                        end)
                        break -- Бьем одного за кадр (быстро переключается)
                    end
                end
            end
        end
    end

    -- [[ AIMBOT ]] --
    if States.Aim then
        local target = GetClosestTarget()
        if target then 
            currentTarget = target; Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), valSmooth)
        else currentTarget = nil end
    end
    
    if currentTarget and currentTarget.Parent then
        local th = currentTarget.Parent:FindFirstChild("Humanoid")
        if th and th.Health <= 0 then ChatSay("EZ"); currentTarget = nil end
    end

    if States.RGB then for _,v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.Color = rgb end end end
    if States.Spd and hum.MoveDirection.Magnitude > 0 then root.CFrame += (hum.MoveDirection * (0.5 * valSpeed)) end
    if States.Jump then hum.UseJumpPower = true; hum.JumpPower = valJumpPower else hum.JumpPower = 50 end

    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("Head") then
            local head = v.Character.Head
            head.Size = States.Hitbox and Vector3.new(valHitbox, valHitbox, valHitbox) or Vector3.new(1,1,1)
            head.Transparency = States.Hitbox and 0.7 or 0
            head.CanCollide = false
            if States.Hitbox then head.Color = rgb; head.Material = Enum.Material.Neon end
        end
    end

    if States.Ghosts then
        if #ghostParts == 0 then for i=1, 3 do table.insert(ghostParts, createGhost()) end; for _,p in pairs(ghostParts) do p.Parent = workspace end end
        local t = tick() * 3
        ghostParts[1].CFrame = root.CFrame * CFrame.Angles(0, t, 0) * CFrame.new(5, 0, 0)
        ghostParts[2].CFrame = root.CFrame * CFrame.Angles(0, 0, t) * CFrame.new(0, 5, 0)
        ghostParts[3].CFrame = root.CFrame * CFrame.Angles(t, t, 0) * CFrame.new(0, 0, 5)
        for _,p in pairs(ghostParts) do p.Color = rgb end
    else for _,p in pairs(ghostParts) do p:Destroy() end; ghostParts = {} end
    
    if States.Circle and hum and hum:GetState() == Enum.HumanoidStateType.Jumping and tick() - lastJump > 0.5 then lastJump = tick(); SpawnRipple() end
end)

-- [ ESP LOOP ] --
spawn(function()
    while task.wait(0.5) do
        local c = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= Player and v.Character then
                local h = v.Character:FindFirstChild("AM_ESP") or Instance.new("Highlight", v.Character)
                h.Name = "AM_ESP"; h.Enabled = States.Esp; h.FillColor = c; h.OutlineColor = Color3.new(1,1,1)
            end
        end
    end
end)
