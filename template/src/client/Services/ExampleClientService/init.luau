local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Networking.Remotes).init()

local ExampleClientService = {}

function ExampleClientService.init()
	Remotes.ExampleResult.OnClientEvent:Connect(function(resultName: string)
		print("Result:", resultName)
	end)
end

return ExampleClientService