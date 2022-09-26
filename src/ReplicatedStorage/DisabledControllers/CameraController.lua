--// Services
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService('Players')

--// Modules

--// Knit
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local springmodule = require(Knit.Modules.SpringModule)
local tween = require(Knit.Modules.Tween)

--// Controller
local CameraController = Knit.CreateController { Name = "CameraController" }

--// Variables
local Player = game.Players.LocalPlayer

 -- Camera Info
 local Camera = game.Workspace.CurrentCamera
 local cameraAngleX = 365
 local cameraAngleY = -14

 local Zoom = 10
 local MaxZoom = Player.CameraMaxZoomDistance
 local MinZoom = Player.CameraMinZoomDistance

 local RightDown = false
 local blockedRay = false

 local Offset = Instance.new("NumberValue", script)
 local OffsetCount = 2
 local OffsetRight = true
 Offset.Value = OffsetCount


--// Functions

--// Shortened Library Assets
local Vec3 = Vector3.new
local CF = CFrame.new
local CFAngles = CFrame.Angles


function CameraController:KnitInit()
    self.Spectate = false
    self.CurrentPlayer = Player
    self.Active = false
end

function CameraController:KnitStart()
    -------------Variables-----------
    local CharacterService = Knit.GetService('CharacterService')

    local Character = self:GetCharacter(Player)
    local Humanoid = Character:WaitForChild('Humanoid')
    local Hrp = Character:WaitForChild("HumanoidRootPart")

    local Root = Hrp

    local TargetCF = CF((CF(Root.CFrame.Position) * CF(0, 0, 12)).Position, Root.Position)
    local spring = springmodule.new(Camera.CFrame.Position, Vector3.new(), TargetCF.Position)
    spring.rate = 1
    spring.friction = 1
    -- Camera.CameraType = Enum.CameraType.Scriptable

    -- BodyRotation For ShiftLock
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vec3(math.huge, math.huge, math.huge)
    bodyGyro.P = 10000

    self.bodyGyro = bodyGyro

    -- Mouse Variables
    self.mouseLocked = false
    self.MouseBehavior = {
        Default = Enum.MouseBehavior.Default,
        LockCenter = Enum.MouseBehavior.LockCenter,
        LockCurrentPosition = Enum.MouseBehavior.LockCurrentPosition,
    }




    --------- RightClick Rotation ----------
    UserInputService.InputBegan:Connect(function(key, chat)
        if key.UserInputType == Enum.UserInputType.MouseButton2 then
            RightDown = true
        end
    end)

    UserInputService.InputEnded:Connect(function(key, chat)
        if key.UserInputType == Enum.UserInputType.MouseButton2 then
            RightDown = false
        end
    end)

    --//  Necessities
    local Vehicles = workspace:FindFirstChild('Vehicles')
    local Ignorable = workspace:FindFirstChild('Ignorable') or error("Camera Script: Create 'Ignorable' folder in workspace")--or Instance.new("Folder", workspace); Ignorable.Name = 'Ignorable'
    local Player = game.Players.LocalPlayer
    -------------Variables-----------
    -------------Classes-------------
    
    -------------Classes-------------
    -----------Initialize------------
    ContextActionService:BindAction("MouseMovement", function(...) self:playerInput(...) end, false, Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch)
    ContextActionService:BindAction("SwitchOffset", function(...) self:playerInput(...) end, false, Enum.KeyCode.Q, Enum.KeyCode.ButtonR1)
    -- ContextActionService:BindAction("LockSwitch", function(...) self:playerInput(...) end, false, Enum.KeyCode.LeftShift)
    -- ContextActionService:BindAction("MobileZoom", function(...) self:playerInput(...) end, false,  )

    UserInputService.InputChanged:Connect(function(...)
        self:trackZoom(...)
    end)

    -- UserInputService.TouchMoved:Connect(function(...)
    --     self:trackMobileRotation(...)
    -- end)

    UserInputService.TouchPinch:Connect(function(...)
        self:trackMobileZoom(...)
    end)

    --------- RightClick Rotation ----------
    UserInputService.InputBegan:Connect(function(key, chat)
        if key.UserInputType == Enum.UserInputType.MouseButton2 then
            RightDown = true
        end
    end)

    UserInputService.InputEnded:Connect(function(key, chat)
        if key.UserInputType == Enum.UserInputType.MouseButton2 then
            RightDown = false
        end
    end)


    local Connection
    local Aim = CF()
    local Rot = CF()


    Player.CharacterAdded:Connect(function(Character)
        bodyGyro.Parent = self.mouseLocked and Character:WaitForChild('HumanoidRootPart') or nil
    end)
    -----------Initialize------------
    CharacterService.InitCamera:Connect(function(Character)
        if not self.Active then return end
        -- self.Active = true
    end)

    RunService.RenderStepped:Connect(function(dt)
        if self.Active == nil or self.Active == false then return end

        local Character = self:GetCharacter()
        local Root = Character:WaitForChild('HumanoidRootPart')
        --if not Character then Connection:Disconnect() return end -- Kill script if nothing character dies
    
        Camera.CameraType = Enum.CameraType.Scriptable
    
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {
            Character:GetDescendants(), 
            Ignorable:GetDescendants(),
            Vehicles:GetDescendants(),
            workspace:FindFirstChild('Debris'),
        }
        raycastParams.IgnoreWater = true
    
        -- Cast the ray
        local RX, RY, RZ
        local Rot = CFAngles(0, math.rad(cameraAngleX*UserInputService.MouseDeltaSensitivity), 0) * CFAngles(math.rad(cameraAngleY*UserInputService.MouseDeltaSensitivity), 0, 0)
        local BaseCF = (CF(Root.CFrame.Position) * Rot) * (CF(0, 0, Zoom)) 
    
        local raycastResult = workspace:Raycast(
            Root.Position,
            CF(Root.Position, Camera.CFrame.Position).LookVector * 30,
            raycastParams
        )
    
        if raycastResult ~= nil  then
    
            blockedRay = true
    
            local Mag = (Root.Position - raycastResult.Position).Magnitude
            if Mag < Zoom then
                BaseCF = (CF(Root.CFrame.Position) * Rot) * (CF(0, 0, Mag - 1))
            end
        else
            blockedRay = false
        end
        
        TargetCF = CF(BaseCF.Position, Root.Position)
    
        spring.target = TargetCF.Position
        spring:update()
    
        Aim = CF((CF(spring.position)).Position, Root.Position) * (CF(Offset.Value, 0 ,0))
        Rot = CF(Aim.Position, (Aim * CF(0, 0, -20).Position))
        RX, RY, RZ = Rot:ToOrientation()
        
        Camera.CFrame = Camera.CFrame:Lerp(TargetCF, .25)
        bodyGyro.CFrame = CFrame.fromOrientation(0, RY, RZ)
    end)
    -----------Initialize------------
end

function CameraController:SpectatePlayer(Player, Button)
    if Button then
        Button.TextLabel.Text = Player.Name
    end

    if Camera.CameraType == Enum.CameraType.Scriptable then
        self.CurrentPlayer = Player
    elseif Camera.CameraType == Enum.CameraType.Custom then
        local Humanoid = Player.Character:FindFirstChild('Humanoid')
        if Humanoid then
            Camera.CameraSubject = Humanoid
        end
    end
end

function CameraController:GetCharacter()
	return self.CurrentPlayer.Character or self.CurrentPlayer.CharacterAdded:Wait()
end


--------- Mobile Movement Tracking ----------
function CameraController:isInDynamicThumbstickArea(input)
	local playerGui = Player:FindFirstChildOfClass("PlayerGui")
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

-- local ScreenGui = Instance.new('ScreenGui', Player.PlayerGui)
-- local TextLabel = Instance.new("TextLabel", ScreenGui)

-- TextLabel.Size = UDim2.fromScale(1, .1)
-- TextLabel.Position = UDim2.fromScale(.5, 1)
-- TextLabel.AnchorPoint = Vector2.new(.5, 1)


function CameraController:trackMobileZoom(touchPositions, scale, velocity, state, gameProcessedEvent)	
    local InputOneInBounds = self:isInDynamicThumbstickArea({Position = touchPositions[1]})
    local InputTwoInBounds = self:isInDynamicThumbstickArea({Position = touchPositions[2]})

    if InputOneInBounds or InputTwoInBounds then return end

	if Zoom >= MinZoom and Zoom <= MaxZoom then
		Zoom += (-velocity * scale/2)
		if Zoom > MaxZoom then
			Zoom = MaxZoom
		elseif Zoom < MinZoom and not blockedRay then
			Zoom = MinZoom * 2
		elseif Zoom < MinZoom and blockedRay then
			cameraAngleY -= 1
			Zoom = MinZoom * 2
		end
    else
        if Zoom < MinZoom then
            Zoom = MinZoom + 1
        elseif Zoom > MaxZoom then
            Zoom = MaxZoom - 1
        end
	end
end

function CameraController:trackMobileRotation(inputObject)
	if self:GetCharacter().Humanoid.MoveDirection ~= Vector3.new() then return end
	-- Calculate camera/player rotation on input change
	cameraAngleX = cameraAngleX - inputObject.Delta.X
	cameraAngleY = cameraAngleY - inputObject.Delta.Y

	if cameraAngleY > 20 then
		cameraAngleY = 20
	elseif cameraAngleY < -60  then
		cameraAngleY = -60
	end
end



--------- Mouse Movement Tracking ----------
function CameraController:trackRotation(inputObject)
	-- Calculate camera/player rotation on input change
	cameraAngleX = cameraAngleX - inputObject.Delta.X
	cameraAngleY = cameraAngleY - inputObject.Delta.Y
	
	if cameraAngleY > 20 then
		cameraAngleY = 20
	elseif cameraAngleY < -60  then
		cameraAngleY = -60
	end
end

function CameraController:trackZoom(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseWheel then
		if Zoom >= 1 and Zoom <= MaxZoom then
			Zoom -= inputObject.Position.Z*5
			if Zoom > MaxZoom then
				Zoom = MaxZoom
			elseif Zoom < MinZoom and not blockedRay then
				Zoom = MinZoom * 2
			elseif Zoom < MinZoom and blockedRay then
				cameraAngleY -= 1
				Zoom = MinZoom * 2
			end
			
		end
	end
end

--------- Getting Inputs to Handle Different Functionality ----------
function CameraController:playerInput(actionName, inputState, inputObject)
    if not self.Active then return end
    
	if actionName == 'MouseMovement' then
		if inputState == Enum.UserInputState.Change then
            if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
                if RightDown then
                    UserInputService.MouseBehavior = self.MouseBehavior.LockCurrentPosition
                    self:trackRotation(inputObject)
                elseif inputState == Enum.UserInputState.Change and self.mouseLocked then
                    UserInputService.MouseBehavior = self.MouseBehavior.LockCurrentPosition
                    self:trackRotation(inputObject)
                else
                    UserInputService.MouseBehavior = not self.mouseLocked and self.MouseBehavior.Default or self.MouseBehavior.LockCenter
                end
            else
                if not self:isInDynamicThumbstickArea(inputObject) then
                    self:trackRotation(inputObject)
                end
            end
			
		end
	elseif actionName == 'LockSwitch' then
		if inputState == Enum.UserInputState.Begin then
			local Character = self:GetCharacter()
			
			self.mouseLocked = not self.mouseLocked
			UserInputService.MouseBehavior = self.mouseLocked and self.MouseBehavior.LockCenter or self.MouseBehavior.Default
			
            if not self.Spectating  then
                self.bodyGyro.Parent = self.mouseLocked and Character.HumanoidRootPart or nil
            end
		end
	elseif actionName == 'SwitchOffset' then
		if inputState == Enum.UserInputState.Begin then
			OffsetRight = not OffsetRight
			tween.new(Offset, {Value = OffsetCount * (OffsetRight and 1 or -1)}, .5):Play()
		end
    elseif actionName == 'MobileZoom' then
        
	end
end


return CameraController