-- AUTO ATIRAR + AUTO EQUIPAR + RESPAWN + NÃO PEGA MORTO

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Ativo = false
local Cooldown = 0.0
local LastShot = 0

-- EQUIPAR SEGUNDO ITEM
local function EquipSecondItem()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character

    if not backpack or not character then return end

    local tools = {}

    for _, v in pairs(backpack:GetChildren()) do
        if v:IsA("Tool") then
            table.insert(tools, v)
        end
    end

    if #tools >= 2 then
        tools[2].Parent = character
    end
end

-- RESPAWN AUTO EQUIPAR
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Ativo then
        EquipSecondItem()
    end
end)

-- CHECAR TIME
local function IsEnemy(player)
    if not player.Team or not LocalPlayer.Team then
        return true
    end
    return player.Team ~= LocalPlayer.Team
end

-- PLAYER MAIS PERTO (IGNORA MORTOS DE VERDADE)
local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge

    local myChar = LocalPlayer.Character
    if not myChar then return end

    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local myPos = myHRP.Position

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and IsEnemy(player) then
            
            local char = player.Character
            local hum = char:FindFirstChild("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")

            -- 🔥 CHECK COMPLETO PRA NÃO PEGAR MORTO
            if hum and hrp 
            and hum.Health > 0 
            and hum:GetState() ~= Enum.HumanoidStateType.Dead
            and char:IsDescendantOf(workspace) then

                local dist = (hrp.Position - myPos).Magnitude

                if dist < shortestDistance then
                    shortestDistance = dist
                    closest = player
                end
            end
        end
    end

    return closest
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
pcall(function() ScreenGui.Parent = game.CoreGui end)

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 240, 0, 130)
Frame.Position = UDim2.new(0.5, -120, 0.5, -65)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 0
Instance.new("UICorner", Frame)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "AUTO AIM PRO"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local Button = Instance.new("TextButton", Frame)
Button.Size = UDim2.new(0.9, 0, 0, 60)
Button.Position = UDim2.new(0.05, 0, 0.4, 0)
Button.Text = "DESATIVADO"
Button.TextColor3 = Color3.new(1,1,1)
Button.BackgroundColor3 = Color3.fromRGB(40,40,40)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 14
Instance.new("UICorner", Button)

-- BOTÃO
Button.MouseButton1Click:Connect(function()
    Ativo = not Ativo

    if Ativo then
        Button.Text = "ATIVADO"
        Button.BackgroundColor3 = Color3.fromRGB(0,170,0)

        EquipSecondItem()
    else
        Button.Text = "DESATIVADO"
        Button.BackgroundColor3 = Color3.fromRGB(40,40,40)
    end
end)

-- LOOP
RunService.Heartbeat:Connect(function()
    if not Ativo then return end
    if tick() - LastShot < Cooldown then return end
    LastShot = tick()

    local myChar = LocalPlayer.Character
    if not myChar then return end

    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local target = GetClosestPlayer()
    if not target then return end

    local targetChar = target.Character
    if not targetChar then return end

    local hum = targetChar:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local hitPart = targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")
    if not hitPart then return end

    local origem = myHRP.Position + Vector3.new(0, 1.5, 0)
    local destino = hitPart.Position

    local args = {
        origem,
        destino,
        hitPart,
        destino
    }

    pcall(function()
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShootGun"):FireServer(unpack(args))
    end)
end)
