--[[
    Script by SillyzUnity on Roblox
    Description:
    This script controls a bot that mimics the movement of the nearest moving player in a game,
    with team/FFA awareness, juke behavior (avoiding jukes for teammates), camera aim at moving enemies,
    and a red transparent circle showing a fixed visual click target (no actual clicking anymore).
    Also presses "E", pauses for 0.5s, then presses "E" again when the nearest moving player dies.
]]

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local camera = Workspace.CurrentCamera
repeat wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")

-- Settings
local SMOOTH_FACTOR = 0.1
local SNAP_FOV_DEGREES = 120
local desiredDistance = 20
local jukeChance = 0.3
local jukeFactor = 3.5
local rayCheckDist = 20
local jumpChance = 0.05

-- GUI FOV circle
local fovGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
fovGui.Name = "FOVVisualizer"
fovGui.ResetOnSpawn = false
local circle = Instance.new("Frame", fovGui)
circle.Size = UDim2.new(0, 16, 0, 16)
circle.BackgroundColor3 = Color3.new(1, 0, 0)
circle.BackgroundTransparency = 0.5
circle.BorderSizePixel = 0
circle.AnchorPoint = Vector2.new(0.5, 0.5)
circle.Position = UDim2.new(0, 165, 0, 250)
circle.ZIndex = 9999

local humanoid, rootPart
local safeDirection = Vector3.zero

local function updateReferences()
    repeat task.wait()
        humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        camera = Workspace.CurrentCamera
    until humanoid and rootPart and camera
end

local function isGrounded(position)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { player.Character }
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local origin = position + Vector3.new(0, 1, 0)
    local downCast = Workspace:Raycast(origin, Vector3.new(0, -6, 0), params)
    return downCast ~= nil
end

local function isClearDirection(direction, distance)
    if not rootPart then return false end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { player.Character }
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local origin = rootPart.Position + Vector3.new(0, 2, 0)
    local result = Workspace:Raycast(origin, direction * distance, params)
    return result == nil
end

local function findPathDirection(desiredDir)
    for offset = 0, 180, 5 do
        for _, sign in ipairs({ 1, -1 }) do
            local ang = math.rad(offset * sign)
            local cframe = CFrame.fromAxisAngle(Vector3.yAxis, ang)
            local candDir = (cframe:VectorToWorldSpace(desiredDir)).Unit
            if isClearDirection(candDir, rayCheckDist) and isGrounded(rootPart.Position + candDir * 2) then
                return candDir
            end
        end
    end
    for i = 1, 8 do
        local randDir = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5).Unit
        if isClearDirection(randDir, rayCheckDist) then
            return randDir
        end
    end
    return Vector3.zero
end

local function usingTeams()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Team then return true end
    end
    return false
end

local function getNearestMovingPlayer()
    local nearest, shortest = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character.HumanoidRootPart
            if hum and hum.Health > 0 and hrp.Velocity.Magnitude > 1 then
                local dist = (rootPart.Position - hrp.Position).Magnitude
                if dist < shortest then
                    shortest, nearest = dist, p
                end
            end
        end
    end
    return nearest
end

local function getNearestEnemyHead()
    local myHRP = player.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local nearestHead, shortestDist = nil, math.huge
    local myTeam = player.Team
    local isTeamGame = usingTeams()

    for _, model in pairs(Workspace:GetChildren()) do
        local hum = model:FindFirstChildOfClass("Humanoid")
        local head = model:FindFirstChild("Head")
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if hum and head and hrp and hum.Health > 0 and model ~= player.Character and hrp.Velocity.Magnitude > 1 then
            local otherPlayer = Players:GetPlayerFromCharacter(model)
            local isEnemy = not isTeamGame or (otherPlayer and otherPlayer.Team ~= myTeam)
            if isEnemy then
                local dist = (Vector3.new(myHRP.Position.X, 0, myHRP.Position.Z) - Vector3.new(head.Position.X, 0, head.Position.Z)).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    nearestHead = head
                end
            end
        end
    end
    return nearestHead
end

RunService.RenderStepped:Connect(function()
    local targetHead = getNearestEnemyHead()
    if targetHead then
        local cameraPos = camera.CFrame.Position
        local targetPos = targetHead.Position
        local desiredCFrame = CFrame.new(cameraPos, targetPos)
        local directionToTarget = (targetPos - cameraPos).Unit
        local angle = math.deg(math.acos(camera.CFrame.LookVector:Dot(directionToTarget)))
        if angle <= SNAP_FOV_DEGREES then
            camera.CFrame = desiredCFrame
        else
            camera.CFrame = camera.CFrame:Lerp(desiredCFrame, SMOOTH_FACTOR)
        end
    end

    if humanoid then
        humanoid:Move(safeDirection, false)
        humanoid.Jump = math.random() < jumpChance
    end
end)

coroutine.wrap(function()
    local lastNearest = nil
    local watchingHumanoid = nil

    while true do
        updateReferences()
        local nearest = getNearestMovingPlayer()
        local moveDir = Vector3.zero

        if nearest ~= lastNearest then
            if watchingHumanoid then
                watchingHumanoid:Disconnect()
                watchingHumanoid = nil
            end

            if nearest and nearest.Character then
                local hum = nearest.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    watchingHumanoid = hum.Died:Connect(function()
                        if humanoid then
                            -- Press E (start)
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            -- Freeze
                            safeDirection = Vector3.zero
                            task.wait(0.5)
                            -- Press E (stop)
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        end
                    end)
                end
            end

            lastNearest = nearest
        end

        if nearest and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = nearest.Character.HumanoidRootPart
            local toTarget = targetHRP.Position - rootPart.Position
            local dist = toTarget.Magnitude
            local myTeam = player.Team
            local isTeamGame = usingTeams()
            local isTeammate = isTeamGame and nearest.Team == myTeam

            if dist < desiredDistance then
                local perp = toTarget:Cross(Vector3.new(0, 1, 0)).Unit
                moveDir = perp * (desiredDistance - dist)
            else
                moveDir = isTeammate and -toTarget.Unit or toTarget.Unit
            end

            if not isTeammate and math.random() < jukeChance then
                local juke = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5).Unit
                moveDir = (moveDir + juke * jukeFactor).Unit
            end
        else
            moveDir = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5).Unit
        end

        safeDirection = findPathDirection(Vector3.new(moveDir.X, 0, moveDir.Z).Unit)
        task.wait(math.random(1, 2))
    end
end)()

player.CharacterAdded:Connect(function()
    task.wait(1)
    updateReferences()
end)

if humanoid then
    humanoid.Died:Connect(function()
        safeDirection = Vector3.zero
    end)
end
