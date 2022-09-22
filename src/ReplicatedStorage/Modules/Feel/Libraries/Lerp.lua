--[[
Lerp

    A short description of the module.

SYNOPSIS

    -- Lua code that showcases an overview of the API.
    local foobar = Lerp.TopLevel('foo')
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

-- Implementation of Lerp.

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// module
local Lerp = {}


function Lerp.CFrame(part: BasePart | MeshPart, goal: CFrame, t: number)
    local timepassed: number = 0
    local start: CFrame = part.CFrame
    while timepassed <= t do
        timepassed = timepassed + RunService.RenderStepped:Wait()
        part.CFrame = start:Lerp(goal,timepassed/t)
    end
end


function Lerp.Size(part: BasePart | MeshPart, goal: Vector3, t: number, reversing: boolean)
    local timepassed: number = 0
    local start: Vector3 = part.Size
    while timepassed <= t do
        timepassed = timepassed + RunService.RenderStepped:Wait()
        part.Size = start:Lerp(goal,timepassed/t)
    end

    timepassed = 0

    if reversing then
        while timepassed <= t do
            timepassed = timepassed + RunService.RenderStepped:Wait()
            part.Size = part.Size:Lerp(start,timepassed/t)
        end
    end
end

function Lerp.CFrameAndSize(part: BasePart | MeshPart, goalCF: CFrame, goalV3: Vector3, t: number)
    local timepassed: number = 0
    local startV3: Vector3 = part.Size
    local startCF: CFrame = part.CFrame
    while timepassed <= t do
        timepassed = timepassed + RunService.RenderStepped:Wait()
        part.CFrame = startCF:Lerp(goalCF,timepassed/t)
        part.Size = startV3:Lerp(goalV3,timepassed/t)
    end
end



return Lerp