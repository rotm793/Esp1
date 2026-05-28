local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local FRIEND_COLOR  = Color3.fromRGB(100, 149, 237)
local ENEMY_COLOR   = Color3.fromRGB(220, 20, 60)
local NEUTRAL_COLOR = Color3.fromRGB(255, 255, 255)
local playerClasses = {}

-- GUI
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local old = PlayerGui:FindFirstChild("SW_HUB")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "SW_HUB"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

-- SINIF
local function getClass(plr)
    return playerClasses[plr.Name] or "neutral"
end
local function setClass(plr, class)
    playerClasses[plr.Name] = class
end
local function cycleClass(plr)
    local c = getClass(plr)
    local n = c == "neutral" and "friend" or c == "friend" and "enemy" or "neutral"
    setClass(plr, n)
    return n
end

-- SES
local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://12221967"
clickSound.Volume = 0.6
clickSound.Parent = gui

-- TOGGLE
local soundEnabled = true
local radioEnabled = true
local toggleKey    = "Home"
local capturingKey = false

-- ANA PANEL
local PANEL_W  = 265
local PANEL_H  = 340
local BOTTOM_H = 36

local listFrame = Instance.new("Frame")
listFrame.Name = "listFrame"
listFrame.Size = UDim2.new(0, PANEL_W, 0, PANEL_H)
listFrame.Position = UDim2.new(1, -(PANEL_W + 10), 0, 10)
listFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
listFrame.BorderSizePixel = 0
listFrame.ClipsDescendants = true
listFrame.Visible = true
listFrame.Parent = gui
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 12)
local pStroke = Instance.new("UIStroke", listFrame)
pStroke.Color = Color3.fromRGB(55, 55, 55)
pStroke.Thickness = 1

-- Başlık
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
titleBar.BorderSizePixel = 0
titleBar.Parent = listFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -36, 1, 0) -- X butonu için sağdan boşluk
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "SW HUB"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 16
titleLabel.Parent = titleBar

-- MOBİL X BUTONU (başlık çubuğuna)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -32, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 14
closeBtn.Text = "✕"
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 5
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    listFrame.Visible = false
end)

-- Hover efekti (mobilde görünmez ama masaüstü için güzel)
closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(220, 60, 60)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(180, 40, 40)}):Play()
end)

local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, 0, 0, 1)
sep.Position = UDim2.new(0, 0, 0, 32)
sep.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sep.BorderSizePixel = 0
sep.Parent = listFrame

-- Scroll
local scrolling = Instance.new("ScrollingFrame")
scrolling.Position = UDim2.new(0, 6, 0, 36)
scrolling.Size = UDim2.new(1, -12, 0, PANEL_H - 36 - BOTTOM_H - 8)
scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
scrolling.BackgroundTransparency = 1
scrolling.BorderSizePixel = 0
scrolling.ScrollBarThickness = 3
scrolling.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
scrolling.Parent = listFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = scrolling
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrolling.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 6)
end)

-- Alt çubuk
local bottomBar = Instance.new("Frame")
bottomBar.Size = UDim2.new(1, 0, 0, BOTTOM_H)
bottomBar.Position = UDim2.new(0, 0, 1, -BOTTOM_H)
bottomBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
bottomBar.BorderSizePixel = 0
bottomBar.Parent = listFrame

local bSep = Instance.new("Frame")
bSep.Size = UDim2.new(1, 0, 0, 1)
bSep.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
bSep.BorderSizePixel = 0
bSep.Parent = bottomBar

local PAD = 5
local BW  = math.floor((PANEL_W - PAD * 4) / 3)

local function makeBottomBtn(text, xPos)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, BW, 0, 26)
    b.Position = UDim2.new(0, xPos, 0.5, -13)
    b.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.Text = text
    b.BorderSizePixel = 0
    b.Parent = bottomBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local soundBtn = makeBottomBtn("🔊 Sound: On", PAD)
local radioBtn = makeBottomBtn("☢ Radio: On", PAD * 2 + BW)

local keyBox = Instance.new("TextButton")
keyBox.Size = UDim2.new(0, BW, 0, 26)
keyBox.Position = UDim2.new(0, PAD * 3 + BW * 2, 0.5, -13)
keyBox.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
keyBox.TextColor3 = Color3.new(1, 1, 1)
keyBox.Font = Enum.Font.GothamBold
keyBox.TextSize = 11
keyBox.Text = "🔑 " .. toggleKey
keyBox.BorderSizePixel = 0
keyBox.Parent = bottomBar
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 6)

-- MOBİL: Panel kapalıyken tekrar açmak için küçük buton
local reopenBtn = Instance.new("TextButton")
reopenBtn.Size = UDim2.new(0, 44, 0, 44)
reopenBtn.Position = UDim2.new(1, -54, 0, 10)
reopenBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
reopenBtn.TextColor3 = Color3.new(1, 1, 1)
reopenBtn.Font = Enum.Font.GothamBlack
reopenBtn.TextSize = 18
reopenBtn.Text = "☰"
reopenBtn.BorderSizePixel = 0
reopenBtn.Visible = false
reopenBtn.ZIndex = 10
reopenBtn.Parent = gui
Instance.new("UICorner", reopenBtn).CornerRadius = UDim.new(0, 10)
local rStroke = Instance.new("UIStroke", reopenBtn)
rStroke.Color = Color3.fromRGB(55, 55, 55)
rStroke.Thickness = 1

reopenBtn.MouseButton1Click:Connect(function()
    listFrame.Visible = true
    reopenBtn.Visible = false
end)

-- Panel görünürlük değişince reopen butonu güncelle
listFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    reopenBtn.Visible = not listFrame.Visible
end)

-- Toggle bağlantıları
soundBtn.MouseButton1Click:Connect(function()
    soundEnabled = not soundEnabled
    soundBtn.Text = soundEnabled and "🔊 Sound: On" or "🔇 Sound: Off"
end)

radioBtn.MouseButton1Click:Connect(function()
    radioEnabled = not radioEnabled
    radioBtn.Text = radioEnabled and "☢ Radio: On" or "☢ Radio: Off"
end)

keyBox.MouseButton1Click:Connect(function()
    if capturingKey then return end
    capturingKey = true
    keyBox.Text = "Press a key..."
end)

-- BİLDİRİM SİSTEMİ
local NOTIF_W      = 300
local NOTIF_H      = 52
local NOTIF_GAP    = 6
local NOTIF_BOT    = 14
local showTime     = 3.5
local fadeTime     = 0.4
local activeNotifs = {}
local damageCooldown = {}
local COOLDOWN     = 10

local function repositionNotifs()
    local y = NOTIF_BOT
    for i = #activeNotifs, 1, -1 do
        local n = activeNotifs[i]
        if n and n.Parent then
            TweenService:Create(n, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, -(NOTIF_W + 10), 1, -(y + NOTIF_H))
            }):Play()
            y = y + NOTIF_H + NOTIF_GAP
        end
    end
end

local function createNotification(text, accentColor)
    accentColor = accentColor or Color3.fromRGB(0, 140, 255)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, NOTIF_W, 0, NOTIF_H)
    frame.Position = UDim2.new(1, -(NOTIF_W + 10), 1, 80)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local fStroke = Instance.new("UIStroke", frame)
    fStroke.Color = Color3.fromRGB(60, 60, 60)
    fStroke.Thickness = 1

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -12, 0, 3)
    barBg.Position = UDim2.new(0, 6, 0, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 3
    barBg.Parent = frame
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 1, 0)
    bar.BackgroundColor3 = accentColor
    bar.BorderSizePixel = 0
    bar.ZIndex = 4
    bar.Parent = barBg
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 3, 1, -14)
    accent.Position = UDim2.new(0, 7, 0, 7)
    accent.BackgroundColor3 = accentColor
    accent.BorderSizePixel = 0
    accent.ZIndex = 2
    accent.Parent = frame
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -22, 1, -6)
    label.Position = UDim2.new(0, 16, 0, 3)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(225, 225, 225)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextWrapped = true
    label.ZIndex = 2
    label.Text = text
    label.Parent = frame

    if soundEnabled then pcall(function() clickSound:Play() end) end

    table.insert(activeNotifs, 1, frame)
    repositionNotifs()

    TweenService:Create(bar, TweenInfo.new(showTime, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()

    task.delay(showTime, function()
        TweenService:Create(frame,   TweenInfo.new(fadeTime), {BackgroundTransparency = 1}):Play()
        TweenService:Create(label,   TweenInfo.new(fadeTime), {TextTransparency = 1}):Play()
        TweenService:Create(fStroke, TweenInfo.new(fadeTime), {Transparency = 1}):Play()
        TweenService:Create(accent,  TweenInfo.new(fadeTime), {BackgroundTransparency = 1}):Play()
        TweenService:Create(barBg,   TweenInfo.new(fadeTime), {BackgroundTransparency = 1}):Play()
        TweenService:Create(bar,     TweenInfo.new(fadeTime), {BackgroundTransparency = 1}):Play()
        task.delay(fadeTime + 0.05, function()
            for i, n in ipairs(activeNotifs) do
                if n == frame then table.remove(activeNotifs, i) break end
            end
            if frame and frame.Parent then frame:Destroy() end
            repositionNotifs()
        end)
    end)
end

-- RADYASYON EFEKTİ
local function setupRadioactiveEffect(plr)
    if not radioEnabled then return end
    local char = plr.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if root:FindFirstChild("SW_RADIO") then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "SW_RADIO"
    bb.Size = UDim2.new(0, 50, 0, 50)
    bb.StudsOffset = Vector3.new(0, 7.5, 0)
    bb.AlwaysOnTop = true
    bb.Parent = root

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "☢"
    lbl.TextColor3 = Color3.fromRGB(255, 165, 0)
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextScaled = true
    lbl.Parent = bb

    local tw = TweenService:Create(lbl,
        TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {TextTransparency = 0.5})
    tw:Play()

    task.delay(6, function()
        tw:Cancel()
        if bb and bb.Parent then bb:Destroy() end
    end)
end

-- ARKADAŞ HASAR DİNLEYİCİSİ
local function setupFriendDamageListener(plr)
    local char = plr.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local lastHP = hum.Health
    hum.HealthChanged:Connect(function(newHP)
        if getClass(plr) ~= "friend" then lastHP = newHP return end
        if newHP < lastHP and not damageCooldown[plr.Name] then
            damageCooldown[plr.Name] = true
            local dist = 0
            local lr = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local pr = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if lr and pr then
                dist = math.floor((lr.Position - pr.Position).Magnitude)
            end
            createNotification("⚠ " .. plr.Name .. " took damage! (" .. dist .. "m)", FRIEND_COLOR)
            setupRadioactiveEffect(plr)
            task.delay(COOLDOWN, function() damageCooldown[plr.Name] = nil end)
        end
        lastHP = newHP
    end)
    plr.CharacterAdded:Connect(function() task.wait(0.5) setupFriendDamageListener(plr) end)
end

-- OYUNCU BUTONLARI
local playerButtons = {}

local function refreshButton(plr, btn)
    local class = getClass(plr)
    local hp = 0
    if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
        hp = math.floor(plr.Character:FindFirstChildOfClass("Humanoid").Health)
    end
    local dist = 0
    local lr = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local pr = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if lr and pr then
        dist = math.floor((lr.Position - pr.Position).Magnitude)
    end
    local color, tag
    if class == "friend" then
        color = FRIEND_COLOR; tag = "FRIEND"
    elseif class == "enemy" then
        color = ENEMY_COLOR; tag = "ENEMY"
    else
        color = NEUTRAL_COLOR; tag = "NEUTRAL"
    end
    btn.BackgroundColor3 = color
    btn.TextColor3 = class == "neutral" and Color3.fromRGB(20, 20, 20) or Color3.new(1, 1, 1)
    btn.Text = "[" .. tag .. "] " .. plr.Name .. "  ♥" .. hp .. "  " .. dist .. "m"
end

local function createPlayerRow(plr)
    if plr == LocalPlayer then return end
    if playerButtons[plr] then return end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 30)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.ClipsDescendants = true
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.Parent = scrolling
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local bp = Instance.new("UIPadding", btn)
    bp.PaddingLeft = UDim.new(0, 8)
    bp.PaddingRight = UDim.new(0, 8)

    playerButtons[plr] = btn
    refreshButton(plr, btn)

    btn.MouseButton1Click:Connect(function()
        local newClass = cycleClass(plr)
        refreshButton(plr, btn)
        if newClass == "friend" then setupFriendDamageListener(plr) end
    end)

    local function onCharAdded(char)
        local hum = char:WaitForChild("Humanoid")
        hum.HealthChanged:Connect(function()
            if playerButtons[plr] then refreshButton(plr, playerButtons[plr]) end
        end)
    end
    if plr.Character then onCharAdded(plr.Character) end
    plr.CharacterAdded:Connect(onCharAdded)
end

for _, plr in pairs(Players:GetPlayers()) do createPlayerRow(plr) end
Players.PlayerAdded:Connect(createPlayerRow)
Players.PlayerRemoving:Connect(function(plr)
    if playerButtons[plr] then
        playerButtons[plr]:Destroy()
        playerButtons[plr] = nil
    end
    playerClasses[plr.Name] = nil
    damageCooldown[plr.Name] = nil
end)

-- ESP OLUŞTUR
local function createESP(plr)
    local char = plr.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if root:FindFirstChild("SW_ESP") then return end

    local esp = Instance.new("BillboardGui")
    esp.Name = "SW_ESP"
    esp.Size = UDim2.new(0, 200, 0, 30)
    esp.StudsOffset = Vector3.new(0, 3.2, 0)
    esp.AlwaysOnTop = true
    esp.Enabled = true -- Her zaman aktif
    esp.Parent = root

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label"
    lbl.Size = UDim2.new(1, -8, 1, 0)
    lbl.Position = UDim2.new(0, 4, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextStrokeTransparency = 0.5
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Parent = esp
end

-- RENDER LOOP
-- FIX: ESP artık panel durumundan bağımsız, her zaman güncellenir
RunService.RenderStepped:Connect(function()
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if char and root then
                -- ESP oluştur (yoksa)
                createESP(plr)

                local esp = root:FindFirstChild("SW_ESP")
                if esp then
                    -- ÖNEKİ HATA: esp.Enabled = true sadece listFrame.Visible bloğu içindeydi
                    -- DÜZELTME: Enabled her zaman true, panel durumundan bağımsız
                    esp.Enabled = true

                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local lbl = esp:FindFirstChild("Label")
                    if hum and lbl then
                        local hp = math.floor(hum.Health)
                        local dist = 0
                        if localRoot then
                            dist = math.floor((localRoot.Position - root.Position).Magnitude)
                        end
                        local class = getClass(plr)
                        lbl.TextColor3 = class == "friend" and FRIEND_COLOR
                            or class == "enemy" and ENEMY_COLOR
                            or NEUTRAL_COLOR
                        lbl.Text = plr.Name .. "  ♥" .. hp .. "  " .. dist .. "m"
                    end
                end

                -- Buton mesafe güncelle (sadece panel açıksa)
                if listFrame.Visible and playerButtons[plr] then
                    refreshButton(plr, playerButtons[plr])
                end
            end
        end
    end
end)

-- KLAVYE
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if capturingKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            toggleKey = input.KeyCode.Name
            keyBox.Text = "🔑 " .. toggleKey
            capturingKey = false
        end
        return
    end

    if input.KeyCode.Name == toggleKey then
        listFrame.Visible = not listFrame.Visible
    end
end)

-- Açılışta bildirim
task.wait(0.5)
createNotification("✓ SW HUB loaded!", Color3.fromRGB(80, 200, 120))
