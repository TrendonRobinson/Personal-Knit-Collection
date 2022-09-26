--[[
ProtoWrap

    A short description of the module.

SYNOPSIS

    -- Lua code that showcases an overview of the API.
    local foobar = ProtoWrap.TopLevel('foo')
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

-- Implementation of ProtoWrap.

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Module
local ProtoWrap = {}

local function Checker(ProtoWrapObject)
    if type(ProtoWrapObject) ~= 'table' and type(ProtoWrapObject) ~= 'string' then
        error('First arg needs to be a table or string')
    end
    
    if type(ProtoWrapObject) == 'string' then
        ProtoWrapObject = ProtoWrap[ProtoWrapObject]
    end
    
    return ProtoWrapObject
end

function ProtoWrap.new(key: string)
    local self = {
        key = key
    }
    
    ProtoWrap[key] = self
    return self
end


return ProtoWrap