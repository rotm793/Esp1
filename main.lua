
-- SW_HUB ESP
-- Roblox Studio / LocalScript
-- Kendi oyunun için

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- SETTINGS
local ESP_ENABLED = true
local SHOW_HEALTH = true
local SHOW_DISTANCE = true
local MAX_DISTANCE = 2000

local FRIEND_COLOR = Color3.fromRGB(60, 160, 255)
local ENEMY_COLOR = Color3.fromRGB(255, 65, 65)
local NEUTRAL_COLOR = Color3.fromRGB(255, 255, 255)

local classifications = {}
local espObjects = {}

-- CLASSIFICATION
local function getColor(player)
    local class = classifications[player.UserId]

    if class == "friend" then
        return FRIEND_COLOR
    elseif class == "enemy" then
        return ENEMY_COLOR
    end

    return NEUTRAL_COLOR
end

-- INVISIBILITY CHECK
local function isInvisible(character)
    local total = 0
    local invisible = 0

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart")
            and part.Name ~= "HumanoidRootPart" then

            total += 1

            if math.max(
                part.Transparency,
                part.LocalTransparencyModifier
            ) >= 0.95 then
                invisible += 1
            end
        end
    end

    return total > 0 and invisible == total
end

-- SHIELD CHECK
local function hasShield(player, character)
    local names = {
        "Shielded",
        "Shield",
        "ForceField",
        "HasShield",
        "IsShielded",
        "ShieldActive"
    }

    if character:FindFirstChildOfClass("ForceField") then
        return true
    end

    for _, name in ipairs(names) do
        if player:GetAttribute(name) == true
            or character:GetAttribute(name) == true then
            return true
        end
    end

    for _, container in ipairs({player, character}) do
        for _, name in ipairs(names) do
            local value = container:FindFirstChild(name)

            if value and value:IsA("BoolValue")
                and value.Value then
                return true
            end
        end
    end

    return false
end

-- CREATE ESP
local function createESP(player)
    if player == LocalPlayer or espObjects[player] then
        return
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SW_HUB_ESP"
    billboard.Size = UDim2.fromOffset(270, 95)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    billboard.MaxDistance = MAX_DISTANCE

    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = NEUTRAL_COLOR
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0.15
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextWrapped = true
    label.RichText = false
    label.Parent = billboard

    espObjects[player] = {
        gui = billboard,
        label = label
    }
end

-- INITIAL PLAYERS
for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(createESP)

Players.PlayerRemoving:Connect(function(player)
    local data = espObjects[player]

    if data then
        data.gui:Destroy()
        espObjects[player] = nil
    end

    classifications[player.UserId] = nil
end)

-- CHARACTER / ESP UPDATE
RunService.RenderStepped:Connect(function()
    local myCharacter = LocalPlayer.Character
    local myRoot = myCharacter
        and myCharacter:FindFirstChild("HumanoidRootPart")

    for player, data in pairs(espObjects) do
        local character = player.Character

        local root = character
            and character:FindFirstChild("HumanoidRootPart")

        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")

        if not ESP_ENABLED or not myRoot
            or not root or not humanoid
            or humanoid.Health <= 0 then

            data.gui.Enabled = false
            data.gui.Parent = nil
            continue
        end

        local distance =
            (myRoot.Position - root.Position).Magnitude

        if distance > MAX_DISTANCE then
            data.gui.Enabled = false
            data.gui.Parent = nil
            continue
        end

        data.gui.Adornee = root
        data.gui.Parent = PlayerGui
        data.gui.Enabled = true

        local invisible = isInvisible(character)
        local shielded = hasShield(player, character)

        local icons = ""

        if invisible then
            icons ..= " 👻"
        end

        if shielded then
            icons ..= " 🛡️"
        end

        local lines = {
            player.DisplayName .. " (@" .. player.Name .. ")" .. icons,
            shielded and "SHIELD: ON" or "SHIELD: OFF"
        }

        if SHOW_HEALTH then
            table.insert(lines,
                "HP: " .. math.floor(humanoid.Health)
                .. " / " .. math.floor(humanoid.MaxHealth))
        end

        if SHOW_DISTANCE then
            table.insert(lines,
                "DISTANCE: " .. math.floor(distance) .. "m")
        end

        data.label.Text = table.concat(lines, "\n")
        data.label.TextColor3 = getColor(player)
    end
end)

print("SW_HUB ESP loaded!")
