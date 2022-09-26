--[[
Spring

    A short description of the module.

SYNOPSIS

    -- Lua code that showcases an overview of the API.
    local foobar = Spring.TopLevel('foo')
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

-- Implementation of Spring.

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Module
local Spring = {}

local function Checker(SpringObject)
    if type(SpringObject) ~= 'table' and type(SpringObject) ~= 'string' then
        error('First arg needs to be a table or string')
    end
    
    if type(SpringObject) == 'string' then
        SpringObject = Spring[SpringObject]
    end
    
    return SpringObject
end

function Spring.new(key: string, Position, Velocity, Target)
    local self = {key = key}

    self.position = Position
	self.velocity = Velocity
	self.target = Target
	self.rate = 1
	self.friction = 1

    
    Spring[key] = self
    return self
end


function Spring.Update(key: string | {})
    local self = Checker(key)
    
    local difference = (self.target - self.position)
	local force = difference * self.rate;

	self.velocity = (self.velocity *(1-self.friction))+force 
	self.position = self.position + self.velocity
end

return Spring