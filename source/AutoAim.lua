local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VIM = game:GetService("VirtualInputManager")
local camera = Workspace.CurrentCamera

local SMOOTH_FACTOR = 0.08
local SNAP_RADIUS = 10
local desiredDistance = 20
local jukeChance = 0.
local jukeFactor = 3.5
local rayCheckDist = 20
local jumpChance = 0.05

local humanoid, rootPart
local lastKey = Enum.KeyCode.One
local lastWeapon = nil

repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")

local function getItemType(name)
	name = name:lower()
	if name:find("rocket") or name:find("grenade") or name:find("explosive") or name:find("c4") or name:find("bazooka") or name:find("missile") or name:find("launcher") or name:find("rpg") then
		return "Explosive"
	elseif name:find("knife") or name:find("sword") or name:find("bat") or name:find("melee") then
		return "Melee"
	elseif name:find("gun") or name:find("rifle") or name:find("smg") or name:find("pistol") or name:find("shotgun") or name:find("sniper") then
		return "Gun"
	end
	return "Other"
end

local function updateReferences()
	repeat
		task.wait()
		humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	until humanoid and rootPart and camera
end

local function usingTeams()
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Team then return true end
	end
	return false
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

coroutine.wrap(function()
	while true do
		local keyToPress = math.random() < 0.5 and Enum.KeyCode.One or Enum.KeyCode.Two
		if humanoid and player.Character then
			lastKey = keyToPress
			local currentTool = player.Character:FindFirstChildOfClass("Tool")
			if currentTool then lastWeapon = currentTool.Name end
			VIM:SendKeyEvent(true, keyToPress, false, game)
			VIM:SendKeyEvent(false, keyToPress, false, game)
		end
		task.wait(math.random(1, 5))
	end
end)()

RunService.RenderStepped:Connect(function()
	updateReferences()
	local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
	local toolType = tool and getItemType(tool.Name)
	local head = getNearestEnemyHead()

	if head then
		local predicted = head.Position + head.Velocity * 0
		local camPos = camera.CFrame.Position
		local desiredCFrame = CFrame.new(camPos, predicted)
		camera.CFrame = camera.CFrame:Lerp(desiredCFrame, SMOOTH_FACTOR)

		local viewport = camera:WorldToViewportPoint(head.Position)
		local screenPos = Vector2.new(viewport.X, viewport.Y)
		local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
		if (screenPos - center).Magnitude <= SNAP_RADIUS then
			VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
			VIM:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
			VIM:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
			VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
		end
	end
end)
