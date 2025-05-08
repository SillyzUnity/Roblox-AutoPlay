local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer
local isTextChatService = TextChatService.ChatVersion == Enum.ChatVersion.TextChatService

-- Sadboi Emoji Pool (💀 removed)
local SAD_EMOJIS = {"🥀", "💔", "✌️", "🙏"}

local function getSadEmojiString()
	local count = math.random(1, #SAD_EMOJIS)
	local pool = {unpack(SAD_EMOJIS)}
	local chosen = {}
	for i = 1, count do
		local index = math.random(1, #pool)
		table.insert(chosen, pool[index])
		table.remove(pool, index)
	end
	return table.concat(chosen, "")
end

-- 10% chance to add emojis
local function addEmojisRandomly(msg)
	if math.random() < 0.1 then
		return msg .. " " .. getSadEmojiString()
	end
	return msg
end

-- Rage & Brag Messages
local RAGE_MESSAGES = {
	"lag spike", "bro how u hit that", "nice ping bro", "shot first lol", "ok hacker", "i was reloading",
	"not even close on my screen", "stop playing 24 7", "who uses that gun", "mouse slipped", "p2w moment",
	"dead but still ur fault", "spawn killed smh", "was afk chill", "hit reg broken", "ur aim assist showing",
	"lag switch??", "aimbot showing rn", "macros crazy", "camp harder bro", "reporting u rn", "1v1 me then",
	"bad hitbox", "desync again", "i blinked n died", "gun carried u", "unfair moment", "op strat cringe",
	"scripted aim", "bad rng", "ur not even good", "keyboard fell off", "wifi goin thru it"
}

local BRAG_MESSAGES = {
	"ez clap", "ur aim fell asleep", "get gud", "walked into it", "too slow lol", "outplayed ez",
	"skill issue fr", "npc movement", "stay mad", "sniped ur soul", "free kill", "movement diff",
	"didnt even try", "u peeked wrong", "head clicked", "guess better next time", "gg ez", "where ur aim?",
	"clapped fr", "outplayed n outvibed", "deleted u", "reaction diff", "held the angle", "aimbot? nah just me",
	"snapped u", "target practice"
}

local function getRageMessage()
	return addEmojisRandomly(RAGE_MESSAGES[math.random(1, #RAGE_MESSAGES)])
end

local function getBragMessage()
	return addEmojisRandomly(BRAG_MESSAGES[math.random(1, #BRAG_MESSAGES)])
end

local function sendChatMessage(msg)
	if isTextChatService then
		pcall(function()
			TextChatService.TextChannels.RBXGeneral:SendAsync(msg)
		end)
	else
		local chatEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
		if chatEvent then
			local sayMessageRequest = chatEvent:FindFirstChild("SayMessageRequest")
			if sayMessageRequest then
				sayMessageRequest:FireServer(msg, "All")
			end
		end
	end
end

-- Rage when LocalPlayer dies
local function onMyCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if humanoid then
		humanoid.Died:Connect(function()
			task.wait(0.4)
			sendChatMessage(getRageMessage())
		end)
	end
end

-- Brag when LocalPlayer kills someone
local function onOtherCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then return end

	humanoid.Died:Connect(function()
		local killer = humanoid:FindFirstChild("creator")
		if killer and killer.Value == LocalPlayer then
			task.wait(0.4)
			sendChatMessage(getBragMessage())
		end
	end)
end

-- Connect to character events
if LocalPlayer.Character then
	onMyCharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(onMyCharacterAdded)

-- Hook other players
for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		if player.Character then
			onOtherCharacterAdded(player.Character)
		end
		player.CharacterAdded:Connect(onOtherCharacterAdded)
	end
end

Players.PlayerAdded:Connect(function(player)
	if player == LocalPlayer then return end
	player.CharacterAdded:Connect(onOtherCharacterAdded)
end)
