--[[
Particles

    A short description of the module.

SYNOPSIS

    -- Lua code that showcases an overview of the API.
    local foobar = Particles.TopLevel('foo')
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

-- Implementation of Particles.

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Libraries = require(script.Parent)

local Lerp: {} = Libraries.Import('Lerp')

--// module
local Particles = {}

local function Checker(ParticlesObject: table | string)
    if type(ParticlesObject) ~= 'table' and type(ParticlesObject) ~= 'string' then
        error('First arg needs to be a table or string')
    end
    
    if type(ParticlesObject) == 'string' then
        ParticlesObject = Particles[ParticlesObject]
    end
    
    return ParticlesObject
end

local function MakeParticle(_Mesh: BasePart | MeshPart, CF: CFrame)
    local MeshSize: Vector3 = _Mesh.Size
    local Mesh: BasePart | MeshPart = _Mesh:Clone()

    Mesh.Size = Vector3.new()
    Mesh.CanCollide = false

    Mesh.CFrame = CF
    Mesh.Anchored = true

    Mesh.Parent = game.Workspace:FindFirstChild('Debris') or workspace

    return Mesh, MeshSize
    
end

function Particles.new(key: string, Humanoid: Humanoid, Mesh: MeshPart | {})
    if Humanoid == nil then error('Humanoid needs to be provided as the 2nd arg') end
    if Mesh == nil then error('Mesh needs to be provided as the 3rd arg') end


    local self = {
        key = key,
        Active = false,

        Connections = {},

        Humanoid = Humanoid,
        Base = Humanoid.Parent:FindFirstChild('HumanoidRootPart'),

        Mesh = (Mesh:IsA"MeshPart" and not nil) and {Mesh} or Mesh
    }
    
    Particles[key] = self
    return self
end

function Particles.CreateParticle(key: string | {})
    local self = Checker(key)
    

    local Speed = self._Base.AssemblyLinearVelocity.Magnitude
    local Current_State = self._Humanoid:GetState()

    if Speed < 10 then return end
    if self._Humanoid.Sit == true then return end
    if 
        Current_State == Enum.HumanoidStateType.Jumping 
        or  Current_State == Enum.HumanoidStateType.Freefall
        or  Current_State == Enum.HumanoidStateType.FallingDown
    then return end

    local Mesh, MeshSize = MakeParticle(self._Mesh, self._Base.CFrame * self._Offset)

    Lerp.Size(Mesh, MeshSize * math.random(70, 100)/100, .25, true)

    Mesh:Destroy()
end


function Particles.Connect(key: string | {})
    local self = Checker(key)

    local Humanoid: Humanoid = self.Humanoid

    local CurrentState: string = Enum.HumanoidStateType.None
    local MoveDirection = Vector3.new()
    local CurrentlyMoving = false

    self.Connections['MoveDirection'] = Humanoid:GetPropertyChangedSignal('MoveDirection'):Connect(function()
        MoveDirection = Humanoid.MoveDirection

        while self.Connections['MoveDirection'] do

            if CurrentState == Enum.HumanoidStateType.Running or CurrentState == Enum.HumanoidStateType.RunningNoPhysics then
                Particles.CreateParticle(self)
                task.wait(math.random(5, 10)/100)
            end

            RunService.RenderStepped:Wait()
        end
    end)

    self.Connections['HumanoidState'] = Humanoid.StateChanged:Connect(function(old, new)
        CurrentState = new

        if CurrentState == Enum.HumanoidStateType.Landed then
            Particles.Landed(self)
        end
    end)
end

function Particles.Disconnect(key: string | {}, Connection)
    local self = Checker(key)
    
    if Connection then
        self.Connections[Connection]:Disconnect()
    else
        for Index: string, Connection: RBXScriptConnection in pairs(self.Connections) do
            Connection:Disconnect()

            self.Connections[Index] = nil
        end
    end
end

function Particles.Toggle(key: string | {}, Activate)
    local self = Checker(key)

    if Activate then
        Particles.Connect(self)
    else
        Particles.Disconnect(self)
    end
end


return Particles