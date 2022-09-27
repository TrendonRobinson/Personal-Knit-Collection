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
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables
local DeveloperTexture = 'rbxassetid://11092346044'

--// Module
local ProtoWrap = {}

local Faces = {
    Enum.NormalId.Back,
    Enum.NormalId.Bottom,
    Enum.NormalId.Front,
    Enum.NormalId.Left,
    Enum.NormalId.Right,
    Enum.NormalId.Top,
}

local function CreateTexture(Face): Texture
    local Texture = Instance.new('Texture')

    Texture.Face = Face
    Texture.StudsPerTileU = 5
    Texture.StudsPerTileV = 5
    Texture.Texture = DeveloperTexture

    return Texture
end

local function WrapObject(Object: BasePart | MeshPart, Color: Color3 | BrickColor)
    if Color == nil then Color = BrickColor.random() end

    for Index, Face: Enum.NormalId in pairs(Faces) do
        CreateTexture(Face).Parent = Object

        if typeof(Color) == "BrickColor" then
            Object.BrickColor = Color
        else
            Object.Color = Color
        end
    end
end

function ProtoWrap.Wrap(Object: BasePart | Model, Color: Color3 | BrickColor)
    if type(Object == "table") then
        ProtoWrap.WrapTable(Object, Color)
    else
        WrapObject(Object, Color)
    end
end

function ProtoWrap.WrapTable(Collection: table, Color: Color3 | BrickColor, Tag: string)
    if Color == nil then Color = BrickColor.random() end
    if Tag then
        ProtoWrap[Tag] = {}

        Collection = CollectionService:GetTagged(Tag)
    end

    for Index, Value: BasePart | MeshPart in pairs(Collection) do
        if (Value:IsA"BasePart" or Value:IsA"MeshPart") then
            if Tag then
                table.insert(ProtoWrap[Tag], Value)
            end

            WrapObject(Value, Color)
            task.wait()
        end
    end
end

function ProtoWrap.TagWrap(Tag: string, Color: Color3 | BrickColor)
    if not (typeof(Color) == 'Color3' or typeof(Color) == 'BrickColor') then
        error('ProtoWrap.Wrap 2nd Arg must be a Color3 or BrickColor Value')
    end

    ProtoWrap.WrapTable(CollectionService:GetTagged(Tag), Color, Tag)
end


return ProtoWrap