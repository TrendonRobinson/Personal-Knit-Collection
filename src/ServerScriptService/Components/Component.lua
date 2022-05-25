--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Component
local Component = require(ReplicatedStorage.Packages.Component)

--// Component Class
local MyComponent = Component.new({
	Tag = "MyComponent",
	Ancestors = {workspace},
	Extensions = {},
})

MyComponent.Tag = "MyComponent"

-- Optional if UpdateRenderStepped should use BindToRenderStep:
MyComponent.RenderPriority = Enum.RenderPriority.Camera.Value

function MyComponent:Construct()
	self.MyData = "Hello"
end

function MyComponent:Start()
    
end

function MyComponent:Stop()
	self.MyData = "Goodbye"
end

function MyComponent:HeartbeatUpdate(dt)
end

function MyComponent:SteppedUpdate(dt)
end

function MyComponent:RenderSteppedUpdate(dt)
end

return MyComponent