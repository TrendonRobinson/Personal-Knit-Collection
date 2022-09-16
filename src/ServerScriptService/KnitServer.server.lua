--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--// Core Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)
local Services = script.Parent:WaitForChild("Services")

Knit.Modules = ReplicatedStorage.Modules

for _, Service in ipairs(Services:GetChildren()) do
	if Service:IsA("ModuleScript") then
		local s,e = pcall(function ()
			require(Service)
		end)

		if not s then
			warn("Failed to load " .. Service.Name .. " because: " .. e)
		end
	end
end

for _, v in ipairs(ServerScriptService.Components:GetDescendants()) do
	if v:IsA("ModuleScript") then
		local vModule = require(v)
	end
end

Knit.Start():catch(warn)