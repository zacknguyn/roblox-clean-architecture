local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Remotes = require(ReplicatedStorage.Shared.Networking.Remotes).init()
local Config = require(script.Config)
local GameConfig = require(ReplicatedStorage.Shared.Configs.GameConfig)

local ExampleService = {}

local cooldowns: { [number]: number } = {}

local function weightedPick(rng: Random)
	local total = 0
	for _, outcome in Config.Outcomes do
		total += outcome.Weight
	end
	if total <= 0 then return nil end

	local roll = rng:NextNumber() * total
	for _, outcome in Config.Outcomes do
		roll -= outcome.Weight
		if roll <= 0 then return outcome end
	end
	return Config.Outcomes[#Config.Outcomes]
end

local function onRequest(player: Player)
	local now = os.clock()
	if cooldowns[player.UserId] and now < cooldowns[player.UserId] then return end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	cooldowns[player.UserId] = now + Config.Cooldown

	local rng = if Config.Seed then Random.new(Config.Seed) else Random.new()
	local result = weightedPick(rng)
	if not result then return end

	Remotes.ExampleResult:FireClient(player, result.Name)
end

function ExampleService.init()
	Remotes.ExampleRequest.OnServerEvent:Connect(onRequest)
end

return ExampleService