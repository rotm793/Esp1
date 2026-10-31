
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Me = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local BLUE = Color3.fromRGB(173, 216, 230)
local CREAM = Color3.fromRGB(255, 239, 213)
local WHITE = Color3.new(1, 1, 1)

local Gui = Instance.new("ScreenGui")
Gui.Name = "CuteESP"
Gui.ResetOnSpawn = false
Gui.Parent = Me:WaitForChild("PlayerGui")

local Labels = {}

local function createLabel(player)
    if player == Me then return end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(150, 48)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = Gui

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, 0, 0, 21)
    name.BackgroundTransparency = 1
    name.Font = Enum.Font.FredokaOne
    name.TextSize = 15
    name.TextStrokeTransparency = 0.2
    name.TextStrokeColor3 = WHITE
    name.Parent = frame

    local back = Instance.new("Frame")
    back.Position = UDim2.new(0.17, 0, 0, 22)
    back.Size = UDim2.new(0.66, 0, 0, 5)
    back.BackgroundColor3 = WHITE
    back.BorderSizePixel = 0
    back.Parent = frame

    Instance.new("UICorner", back).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(1, 1)
    fill.BorderSizePixel = 0
    fill.BackgroundColor3 = Color3.fromRGB(152, 230, 170)
    fill.Parent = back

    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local hpText = Instance.new("TextLabel")
    hpText.Position = UDim2.new(0, 0, 0, 29)
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
        hpText = hpText
    }
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
end)

RunService.RenderStepped:Connect(function()
    for player, data in pairs(Labels) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local head = character and character:FindFirstChild("Head")

        if character and humanoid and head and humanoid.Health > 0 then
            local screenPos, onScreen =
                Camera:WorldToViewportPoint(head.Position)

            if onScreen then
                data.frame.Visible = true
                data.frame.Position = UDim2.fromOffset(
                    screenPos.X - 75,
                    screenPos.Y - 55
                )

                local color = player:IsFriendsWith(Me.UserId)
                    and BLUE or CREAM

                data.name.Text = player.DisplayName
                data.name.TextColor3 = color

                local health = math.clamp(
                    humanoid.Health / humanoid.MaxHealth, 0, 1
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
                    (Camera.CFrame.Position - head.Position).Magnitude
                )

                data.hpText.Text =
                    "♥ " .. math.floor(humanoid.Health)
                    .. " HP  |  " .. distance .. " studs"
            else
                data.frame.Visible = false
            end
        else
            data.frame.Visible = false
        end
    end
end)
