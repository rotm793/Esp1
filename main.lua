
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Me = Players.LocalPlayer

local BLUE = Color3.fromRGB(173, 216, 230)
local CREAM = Color3.fromRGB(255, 239, 213)
local WHITE = Color3.new(1, 1, 1)

local Gui = Instance.new("ScreenGui")
Gui.Name = "CuteESP"
Gui.ResetOnSpawn = false
Gui.Parent = Me:WaitForChild("PlayerGui")

local Labels = {}
local FRIEND_CACHE = {}

local function readValue(container, names)
    if not container then return nil end

    for _, key in ipairs(names) do
        local attribute = container:GetAttribute(key)

        if attribute ~= nil then
            return attribute
        end

        local value = container:FindFirstChild(key, true)

        if value and (value:IsA("StringValue")
            or value:IsA("BoolValue")) then
            return value.Value
        end
    end

    return nil
end

local function getCharacterName(player, character)
    local names = {
        "CharacterName",
        "SelectedCharacter",
        "CurrentCharacter",
        "EquippedCharacter",
        "Character"
    }

    local result = readValue(player, names)
        or readValue(character, names)

    if typeof(result) == "string" and result ~= "" then
        return result
    end

    return character.Name
end

local function hasShield(container)
    if not container then return false end

    local keys = {
        "Shield",
        "ShieldActive",
        "HasShield",
        "IsShielded"
    }

    for _, key in ipairs(keys) do
        if container:GetAttribute(key) == true then
            return true
        end

        local value = container:FindFirstChild(key, true)

        if value then
            if value:IsA("BoolValue") and value.Value == true then
                return true
            end

            if value:IsA("Folder")
                or value:IsA("Model")
                or value:IsA("Tool") then
                return true
            end
        end
    end

    return false
end

local function createLabel(player)
    if player == Me then return end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(210, 72)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = Gui

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -25, 0, 23)
    name.BackgroundTransparency = 1
    name.Font = Enum.Font.FredokaOne
    name.TextSize = 15
    name.TextStrokeTransparency = 0.2
    name.TextStrokeColor3 = WHITE
    name.Parent = frame

    local shieldIcon = Instance.new("TextLabel")
    shieldIcon.Size = UDim2.fromOffset(25, 23)
    shieldIcon.Position = UDim2.new(1, -25, 0, 0)
    shieldIcon.BackgroundTransparency = 1
    shieldIcon.Text = "🛡️"
    shieldIcon.TextSize = 15
    shieldIcon.Visible = false
    shieldIcon.Parent = frame

    local characterName = Instance.new("TextLabel")
    characterName.Position = UDim2.new(0, 0, 0, 23)
    characterName.Size = UDim2.new(1, 0, 0, 19)
    characterName.BackgroundTransparency = 1
    characterName.Font = Enum.Font.GothamBold
    characterName.TextSize = 14
    characterName.TextColor3 = Color3.fromRGB(180, 150, 220)
    characterName.TextStrokeTransparency = 0.3
    characterName.TextStrokeColor3 = WHITE
    characterName.Parent = frame

    local back = Instance.new("Frame")
    back.Position = UDim2.new(0.17, 0, 0, 45)
    back.Size = UDim2.new(0.66, 0, 0, 5)
    back.BackgroundColor3 = WHITE
    back.BorderSizePixel = 0
    back.Parent = frame

    Instance.new("UICorner", back).CornerRadius =
        UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(1, 1)
    fill.BorderSizePixel = 0
    fill.BackgroundColor3 = Color3.fromRGB(152, 230, 170)
    fill.Parent = back

    Instance.new("UICorner", fill).CornerRadius =
        UDim.new(1, 0)

    local hpText = Instance.new("TextLabel")
    hpText.Position = UDim2.new(0, 0, 0, 54)
    hpText.Size = UDim2.new(1, 0, 0, 15)
    hpText.BackgroundTransparency = 1
    hpText.Font = Enum.Font.GothamBold
    hpText.TextSize = 11
    hpText.TextColor3 = Color3.fromRGB(115, 75, 155)
    hpText.TextStrokeColor3 = WHITE
    hpText.TextStrokeTransparency = 0
    hpText.Parent = frame

    Labels[player] = {
        frame = frame,
        name = name,
        fill = fill,
        hpText = hpText,
        shieldIcon = shieldIcon,
        characterName = characterName
    }

    task.spawn(function()
        local success, result = pcall(function()
            return player:IsFriendsWith(Me.UserId)
        end)

        FRIEND_CACHE[player] = success and result or false
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    createLabel(player)
end

Players.PlayerAdded:Connect(createLabel)

Players.PlayerRemoving:Connect(function(player)
    if Labels[player] then
        Labels[player].frame:Destroy()
        Labels[player] = nil
    end

    FRIEND_CACHE[player] = nil
end)

local updateTimer = 0
local UPDATE_RATE = 1 / 30

RunService.RenderStepped:Connect(function(dt)
    updateTimer += dt

    if updateTimer < UPDATE_RATE then
        return
    end

    updateTimer = 0

    local camera = workspace.CurrentCamera
    if not camera then return end

    local cameraPosition = camera.CFrame.Position

    for player, data in pairs(Labels) do
        local character = player.Character
        local humanoid = character and
            character:FindFirstChildOfClass("Humanoid")
        local head = character and
            character:FindFirstChild("Head")

        if character and humanoid and head
            and humanoid.Health > 0 then

            local screenPos, onScreen =
                camera:WorldToViewportPoint(head.Position)

            if onScreen and screenPos.Z > 0 then
                data.frame.Visible = true

                data.frame.Position = UDim2.fromOffset(
                    screenPos.X - 105,
                    screenPos.Y - 65
                )

                data.name.Text = "@" .. player.Name
                data.name.TextColor3 =
                    FRIEND_CACHE[player] and BLUE or CREAM

                -- KALKAN DÜZELTMESİ
                local shieldActive =
                    hasShield(player) or hasShield(character)

                data.shieldIcon.Visible = shieldActive
                data.shieldIcon.Text =
                    shieldActive and "🛡️" or ""

                data.characterName.Text =
                    getCharacterName(player, character)

                local health = math.clamp(
                    humanoid.Health / math.max(humanoid.MaxHealth, 1),
                    0, 1
                )

                data.fill.Size = UDim2.fromScale(health, 1)

                if health > 0.6 then
                    data.fill.BackgroundColor3 =
                        Color3.fromRGB(152, 230, 170)
                elseif health > 0.3 then
                    data.fill.BackgroundColor3 =
                        Color3.fromRGB(255, 190, 100)
                else
                    data.fill.BackgroundColor3 =
                        Color3.fromRGB(255, 110, 130)
                end

                local distance = math.floor(
                    (cameraPosition - head.Position).Magnitude
                )

                data.hpText.Text =
                    "♥ " .. math.floor(humanoid.Health) ..
                    " HP  |  " .. distance .. " studs"
            else
                data.frame.Visible = false
            end
        else
            data.frame.Visible = false
        end
    end
end)
