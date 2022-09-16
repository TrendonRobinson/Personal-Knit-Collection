--// Services

--// Modules

--// Knit
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Modules = Knit.Modules

local EasyPages = require(Modules.EasyPages)

--// Controller
local TestController = Knit.CreateController { Name = "TestController" }

--// Variables
function TestController:KnitInit()
    
end

function TestController:KnitStart()
    -------------Variables-----------
    local PlayerGui = game.Players.LocalPlayer.PlayerGui
	local WeaponGui = PlayerGui:WaitForChild('WeaponSelection')
    local Frame = WeaponGui.Grid

    local Model = workspace.Model
    
    local List = EasyPages.new(
        {
            Name = "PartList";
            List = Model:GetChildren();

            Animate = true;
            VpfCF = CFrame.fromEulerAnglesXYZ(-math.pi/2, math.pi/6, 0);

            Parent = Frame;
        }
    )
    
    
    List.SlotClicked = function(Slot, Item)
        Slot:Destroy()
        Item:Destroy()
        List.List = Model:GetChildren()
        EasyPages.Render(List)
    end
    -------------Variables-----------
    -------------Classes-------------
    
    -------------Classes-------------
    -----------Initialize------------
    EasyPages.Render(List)

    for i = 1, 10 do
        EasyPages.Scroll(List)

        task.wait(3)
        print'Turning Page'
    end
    -----------Initialize------------
end

return TestController