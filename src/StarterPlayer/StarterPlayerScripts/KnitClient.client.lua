local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load core module:
local Knit = require(ReplicatedStorage.Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)

Knit.Modules = ReplicatedStorage.Modules

-- Load all controllers:
for _, Controller in ipairs(ReplicatedStorage.Controllers:GetDescendants()) do
	if Controller:IsA("ModuleScript") then
		require(Controller)
	end
end

-- Load all components:
for _, v in ipairs(ReplicatedStorage.Components:GetDescendants()) do
	if v:IsA("ModuleScript") then
		local vModule = require(v)
		Component.new(vModule.Tag, vModule)
	end
end

-- Start Knit:
Knit.Start():catch(warn)