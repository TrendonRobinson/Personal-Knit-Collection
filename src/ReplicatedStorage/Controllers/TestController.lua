--// Services

--// Modules

--// Knit
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Modules = Knit.Modules

local Feel = require(Modules.Feel)
local EasyPages = require(Modules.EasyPages)

--// Controller
local TestController = Knit.CreateController { Name = "TestController" }

--// Variables
function TestController:KnitInit()
    
end

function TestController:KnitStart()
    -------------Variables-----------
    local Player = game.Players.LocalPlayer
    local PlayerGui = Player.PlayerGui

    local Camera = Feel.Camera
    local ProtoWrap = Feel.ProtoWrap

    local CustomCamera = Camera.new(Player, workspace.CurrentCamera, workspace.Ignorables:GetDescendants())
    -------------Variables-----------
    -------------Classes-------------
    -- Camera.Set(CustomCamera, "Lerp")


    -- task.wait(10)
    -- print('Changing rate')
    -- CustomCamera.rate = .1
    -- task.wait(10)
    -- print('Changing friction')
    -- CustomCamera.friction = .1


    Camera.Set(CustomCamera, "Lerp")
    
    CustomCamera.CurrentSpring.rate = .01
    CustomCamera.CurrentSpring.friction = .5

    ProtoWrap.Wrap(workspace.Wrap:GetChildren())

    -- task.wait(10)
    -- Camera.Set(CustomCamera, "Default")

    -- for i = 1, 50 do
    --     CustomCamera.CurrentSpring.rate = i/100
    --     task.wait(.1)
    -- end
    -------------Classes-------------
    -----------Initialize------------

    -----------Initialize------------
end

return TestController