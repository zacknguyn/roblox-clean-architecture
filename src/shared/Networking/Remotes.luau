local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = {}

local function getOrCreate(name: string)
	if RunService:IsServer() then
		local remote = ReplicatedStorage:FindFirstChild(name)
		if not remote then
			remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = ReplicatedStorage
		end
		return remote
	end
	return ReplicatedStorage:WaitForChild(name)
end

function Remotes.init()
	Remotes.ExampleRequest = getOrCreate("ExampleRequest")
	Remotes.ExampleResult = getOrCreate("ExampleResult")
	return Remotes
end

return Remotes