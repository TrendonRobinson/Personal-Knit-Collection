--[[
Camera

    A short description of the module.

SYNOPSIS

    -- Lua code that showcases an overview of the API.
    local foobar = Camera.TopLevel('foo')
    print(foobar.Thing)

DESCRIPTION

    A detailed description of the module.

API

    -- Describes each API item using Luau type declarations.

    -- Top-level functions use the function declaration syntax.
    function ModuleName.TopLevel(thing: string): Foobar

    -- A description of Foobar.
    type Foobar = {

        -- A description of the Thing member.
        Thing: string,

        -- Each distinct item in the API is separated by \n\n.
        Member: string,

    }
]]

-- Implementation of Camera.

--// Services
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--// Module
local Camera = {}

local Library = require(script.Parent)

local Lerp = Library.Import('Lerp')
local Spring = Library.Import('Spring')

local MouseBehavior = {
    Default = Enum.MouseBehavior.Default,
    LockCenter = Enum.MouseBehavior.LockCenter,
    LockCurrentPosition = Enum.MouseBehavior.LockCurrentPosition,
}

local function Checker(CameraObject)
    if type(CameraObject) ~= 'table' and type(CameraObject) ~= 'string' then
        error('First arg needs to be a table or string')
    end
    
    if type(CameraObject) == 'string' then
        CameraObject = Camera[CameraObject]
    end
    
    return CameraObject
end

local function GetCharacter(Player: Player): Model
    return Player.Character or Player.CharacterAdded:Wait()
end


local function PrepareBodyGyro(): BodyGyro
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 10000

    return bodyGyro 
end

function Camera.new(key: Player, UserCamera: Camera, Ignorables)
    local self = {
        key = key,
        Camera = UserCamera,

        Mode = 'Custom',
        Enabled = false,
        Rotating = false,
        ShiftLock = false,
        BlockedRay = false,
        OffsetRight = false,

        Binds = {},
        Connections = {},

        LerpRate = .5


    }

    self.Ignorables = Ignorables or {}
    

    self.cameraAngleX = 365
    self.cameraAngleY = -14
   
    self.Zoom = 10
    self.MaxZoom = key.CameraMaxZoomDistance
    self.MinZoom = key.CameraMinZoomDistance
    self.bodyGyro = PrepareBodyGyro()
    self.Offset = Instance.new("NumberValue")

    Camera[key] = self
    return self
end

function Camera.GetMode(key: string | {}, Mode)
    local self = Checker(key)
    
    -- RunService:BindToRenderStep("FollowMouse", Enum.RenderPriority.Camera.Value, CameraModes.FollowMouse)
    -- RunService:BindToRenderStep("ShiftLock", Enum.RenderPriority.Camera.Value, CameraModes.OverTheShoulder)
end

function Camera.Set(key: string | {}, Mode)
    local self = Checker(key)
    self.Mode = Mode

    print(self.Mode)
    
    if Mode == "Default" or  Mode == "Custom" or Mode == nil then return Camera.Disconnect(self) end

    self.Active = true

    Camera.Enable(self)
end

function Camera.TrackRotation(key: string | {}, inputObject)
    local self = Checker(key)
    

        -- Calculate camera/player rotation on input change
	self.cameraAngleX = self.cameraAngleX - (inputObject.Delta.X * (string.find(self.Mode, 'Spring') and (self.CurrentSpring.rate*2) or 1))
	self.cameraAngleY = self.cameraAngleY - (inputObject.Delta.Y * (string.find(self.Mode, 'Spring') and (self.CurrentSpring.rate*2) or 1))
	
	if self.cameraAngleY > 20 then
		self.cameraAngleY = 20
	elseif self.cameraAngleY < -60  then
		self.cameraAngleY = -60
	end
end

--------- Mobile Movement Tracking ----------
function Camera.isInDynamicThumbstickArea(key: string | {}, input)
    local self = Checker(key)

	local playerGui = self.key:FindFirstChildOfClass("PlayerGui")
	local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
	local touchFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
	local thumbstickFrame = touchFrame and touchFrame:FindFirstChild("DynamicThumbstickFrame")

	if not thumbstickFrame then
		return false
	end

	local frameCornerTopLeft = thumbstickFrame.AbsolutePosition
	local frameCornerBottomRight = frameCornerTopLeft + thumbstickFrame.AbsoluteSize
	if input.Position.X >= frameCornerTopLeft.X and input.Position.Y >= frameCornerTopLeft.Y then
		if input.Position.X <= frameCornerBottomRight.X and input.Position.Y <= frameCornerBottomRight.Y then
			return true
		end
	end

	return false
end
function Camera.trackZoom(key: string | {}, inputObject)
    local self = Checker(key)
    
    if inputObject.UserInputType == Enum.UserInputType.MouseWheel then
		if self.Zoom >= 1 and self.Zoom <= self.MaxZoom then
			self.Zoom -= inputObject.Position.Z*5
			if self.Zoom > self.MaxZoom then
				self.Zoom = self.MaxZoom
			elseif self.Zoom < self.MinZoom and not self.BlockedRay then
				self.Zoom = self.MinZoom * 2
			elseif self.Zoom < self.MinZoom and self.BlockedRay then
				self.cameraAngleY -= 1
				self.Zoom = self.MinZoom * 2
			end
			
		end
	end
end

function Camera.playerInput(key: string | {}, actionName, inputState, inputObject)
    local self = Checker(key)
    
    if not self.Active then return end

    -- self.Rotating = 
	if actionName == 'MouseMovement' then
		if inputState == Enum.UserInputState.Change then
            if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                    UserInputService.MouseBehavior = MouseBehavior.LockCurrentPosition
                    Camera.TrackRotation(self, inputObject)
                elseif inputState == Enum.UserInputState.Change and self.ShiftLock then
                    UserInputService.MouseBehavior = MouseBehavior.LockCurrentPosition
                    Camera.TrackRotation(self, inputObject)
                else
                    UserInputService.MouseBehavior = not self.ShiftLock and MouseBehavior.Default or MouseBehavior.LockCenter
                end
            else
                if not Camera.isInDynamicThumbstickArea(inputObject) then
                    Camera.TrackRotation(self, inputObject)
                end
            end
			
		end
	elseif actionName == 'LockSwitch' then
		if inputState == Enum.UserInputState.Begin then
			local Character = GetCharacter(self.key)
			
			self.ShiftLock = not self.ShiftLock
			UserInputService.MouseBehavior = self.ShiftLock and MouseBehavior.LockCenter or MouseBehavior.Default
			
            if not self.Spectating  then
                self.bodyGyro.Parent = self.ShiftLock and Character.HumanoidRootPart or nil
            end
		end
	elseif actionName == 'SwitchOffset' then
		if inputState == Enum.UserInputState.Begin then
			self.OffsetRight = not self.OffsetRight
			-- tween.new(Offset, {Value = OffsetCount * (OffsetRight and 1 or -1)}, .5):Play()
		end
    elseif actionName == 'MobileZoom' then
        
	end
end

function Camera.Spectate(key: string | {}, Player: Player)
    local self = Checker(key)
    
end


function Camera.Connect(key: string | {})
    local self = Checker(key)

    local Aim = CFrame.new()
    local Rot = CFrame.new()

    local Character = GetCharacter(self.key)
    local Root = Character:WaitForChild('HumanoidRootPart')
    
    self.TargetCF = CFrame.new((CFrame.new(Root.CFrame.Position) * CFrame.new(0, 0, 12)).Position, Root.Position)
    self.CurrentSpring = Spring.new(self.Camera.CFrame.Position, Vector3.new(), self.TargetCF.Position)
    

    self.Binds['TrackZoom'] = UserInputService.InputChanged:Connect(function(...)
        Camera.trackZoom(self, ...)
    end)

    self.Binds['MouseMovement'] = ContextActionService:BindAction("MouseMovement", function(...) Camera.playerInput(self, ...) end, false, Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch)
    -- self.Binds['MouseButton2'] = ContextActionService:BindAction("MouseButton2", function(...) Camera.playerInput(self, ...) end, false, Enum.UserInputType.MouseButton2, Enum.UserInputType.Touch)
    self.Binds['SwitchOffset'] = ContextActionService:BindAction("SwitchOffset", function(...) Camera.playerInput(self, ...) end, false, Enum.KeyCode.Q, Enum.KeyCode.ButtonR1)
    self.Binds['LockSwitch'] = ContextActionService:BindAction("LockSwitch", function(...) Camera.playerInput(self, ...) end, false, Enum.KeyCode.LeftShift)

    self.Connections['CameraConnnection'] = RunService.RenderStepped:Connect(function(dt)
        if self.Active == nil or self.Active == false then return end

        local Character = GetCharacter(self.key)
        local Root = Character:WaitForChild('HumanoidRootPart')
        --if not Character then Connection:Disconnect() return end -- Kill script if nothing character dies
    
        Camera.CameraType = Enum.CameraType.Scriptable
    
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {
            Character:GetDescendants(),
            self.Ignorables,--:GetDescendants(),
        }
        raycastParams.IgnoreWater = true
    
        -- Cast the ray
        local RX, RY, RZ
        local Rot = CFrame.Angles(0, math.rad(self.cameraAngleX*UserInputService.MouseDeltaSensitivity), 0) * CFrame.Angles(math.rad(self.cameraAngleY*UserInputService.MouseDeltaSensitivity), 0, 0)
        local BaseCF = (CFrame.new(Root.CFrame.Position) * Rot) * (CFrame.new(0, 0, self.Zoom)) 
    
        local raycastResult = workspace:Raycast(
            Root.Position,
            CFrame.new(Root.Position, self.Camera.CFrame.Position).LookVector * 30,
            raycastParams
        )
    
        if raycastResult ~= nil  then
    
            self.BlockedRay = true
    
            local Mag = (Root.Position - raycastResult.Position).Magnitude
            if Mag < self.Zoom then
                BaseCF = (CFrame.new(Root.CFrame.Position) * Rot) * (CFrame.new(0, 0, Mag - 1))
            end
        else
            self.BlockedRay = false
        end
        
        self.TargetCF = CFrame.new(BaseCF.Position, Root.Position)
        self.CurrentSpring.target = self.TargetCF.Position

        Spring.Update(self.CurrentSpring)
    
        Aim = CFrame.new((CFrame.new(self.CurrentSpring.position)).Position, Root.Position) * (CFrame.new(self.Offset.Value, 0 ,0))
        Rot = CFrame.new(Aim.Position, (Aim * CFrame.new(0, 0, -20).Position))
        RX, RY, RZ = Rot:ToOrientation()
        
        -- self.Camera.CFrame = Camera.CFrame:Lerp(TargetCF, .25)
        if self.Mode == "Lerp" then
            Lerp.new(self.Camera, self.TargetCF, self.LerpRate)
        elseif self.Mode == "Spring" then
            self.Camera.CFrame = Aim
        elseif self.Mode == "LerpSpring" then
            Lerp.new(self.Camera, Aim, self.LerpRate)
        end
        self.bodyGyro.CFrame = CFrame.fromOrientation(0, RY, RZ)
    end)
end

function Camera.Enable(key: string | {})
    local self = Checker(key)
    local UserCamera: Camera = self.Camera
    

    if self.Active then
        UserCamera.CameraType = Enum.CameraType.Scriptable
        Camera.Connect(self)
    else
        Camera.Disconnect(self)
        UserCamera.CameraType = 'Custom'
    end
end


function Camera.Disconnect(key: string | {})
    local self = Checker(key)
    
    for index, Connection in pairs(self.Connections) do
        Connection:Disconnect()
    end

    for Bind, BindValue in pairs(self.Binds) do
        ContextActionService:UnbindAction(Bind)
    end
    
end


return Camera