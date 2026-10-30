
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local BLUE = Color3.fromRGB(173, 216, 230)
local CREAM = Color3.fromRGB(255, 239, 213)
local TEXT_COLOR = Color3.fromRGB(115, 75, 155)
local WHITE = Color3.fromRGB(255, 255, 255)

local function setupPlayer(player)
    if player == LocalPlayer then return end

    local function setupCharacter(character)
        local head = character:WaitForChild("Head", 15)
        local humanoid = character:WaitForChild("Humanoid", 15)

        if not head or not humanoid then return end

        local oldGui = head:FindFirstChild("CuteESPLabel")
        if oldGui then oldGui:Destroy() end

        local oldHighlight = character:FindFirstChild("CuteESP")
        if oldHighlight then oldHighlight:Destroy() end

        local isFriend = false
        local ok, result = pcall(function()
            return LocalPlayer:IsFriendsWith(player.UserId)
        end)
        if ok then isFriend = result end

        local color = isFriend and BLUE or CREAM

        local highlight = Instance.new("Highlight")
        highlight.Name = "CuteESP"
        highlight.Adornee = character
        highlight.FillColor = color
        highlight.OutlineColor = color
        highlight.FillTransparency = 0.9
        highlight.OutlineTransparency = 0.1
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = character

        local gui = Instance.new("BillboardGui")
        gui.Name = "CuteESPLabel"
        gui.Adornee = head
        gui.Size = UDim2.fromOffset(120, 48)
        gui.StudsOffset = Vector3.new(0, 2.4, 0)
        gui.AlwaysOnTop = true
        gui.MaxDistance = 1000
        gui.Parent = head

        local name = Instance.new("TextLabel")
        name.Name = "PlayerName"
        name.Size = UDim2.new(1, 0, 0, 23)
        name.BackgroundTransparency = 1
        name.Text = "♡ " .. player.DisplayName
        name.TextColor3 = color
        name.TextStrokeColor3 = WHITE
        name.TextStrokeTransparency = 0.15
        name.Font = Enum.Font.FredokaOne
        name.TextScaled = true
        name.Parent = gui

        local barBack = Instance.new("Frame")
        barBack.Name = "HealthBack"
        barBack.Position = UDim2.new(0.1, 0, 0, 25)
        barBack.Size = UDim2.new(0.8, 0, 0, 7)
        barBack.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
        barBack.BorderSizePixel = 0
        barBack.Parent = gui

        local backCorner = Instance.new("UICorner")
        backCorner.CornerRadius = UDim.new(1, 0)
        backCorner.Parent = barBack

        local fill = Instance.new("Frame")
        fill.Name = "HealthFill"
        fill.Size = UDim2.fromScale(1, 1)
        fill.BackgroundColor3 = Color3.fromRGB(152, 230, 170)
        fill.BorderSizePixel = 0
        fill.Parent = barBack

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill

        local hpText = Instance.new("TextLabel")
        hpText.Name = "HealthText"
        hpText.Position = UDim2.new(0, 0, 0, 33)
        hpText.Size = UDim2.new(1, 0, 0, 14)
        hpText.BackgroundTransparency = 1
        hpText.TextColor3 = TEXT_COLOR
        hpText.TextStrokeColor3 = WHITE
        hpText.TextStrokeTransparency = 0
        hpText.Font = Enum.Font.GothamBold
        hpText.TextScaled = true
        hpText.Parent = gui

        local function updateHealth()
            if not humanoid.Parent then return end

            local maxHP = math.max(humanoid.MaxHealth, 1)
            local hp = math.clamp(humanoid.Health, 0, maxHP)
            local percent = hp / maxHP

            fill.Size = UDim2.new(percent, 0, 1, 0)

            if percent >= 0.7 then
                fill.BackgroundColor3 =
                    Color3.fromRGB(152, 230, 170)
            elseif percent >= 0.35 then
                fill.BackgroundColor3 =
                    Color3.fromRGB(255, 183, 110)
            else
                fill.BackgroundColor3 =
                    Color3.fromRGB(255, 125, 145)
            end

            hpText.Text = string.format(
                "♥ %d / %d HP",
                math.ceil(hp),
                math.ceil(maxHP)
            )
        end

        updateHealth()
        humanoid.HealthChanged:Connect(updateHealth)
        humanoid:GetPropertyChangedSignal("MaxHealth")
            :Connect(updateHealth)

        print("Cute ESP aktif:", player.Name)
    end

    player.CharacterAdded:Connect(function(character)
        task.spawn(setupCharacter, character)
    end)

    if player.Character then
        task.spawn(setupCharacter, player.Character)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)
