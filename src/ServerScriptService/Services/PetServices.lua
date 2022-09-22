--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

--// Knit
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

--// Modules
-- local PetInformation = require(Knit.Modules.Pets)

--// Types
type PetDetails = {
    Type: string,
	Name: string,
			
    Level: number,
	XP: number
}

type Pet = {
    Key: string,
    PetInfo: PetDetails
}

--// Service
local PetService = Knit.CreateService {
	Name = "PetService";
	Client = {
		Render = Knit.CreateSignal();
		CastPet = Knit.CreateSignal();
	};
}


function OnPlayerAdded(Player: Player)
	local PlayerInfo = {"SportCar"}--, "Explosive Cow", "Explosive Cow"}
	-- Player.CharacterAdded:Connect(function()
	-- 	PetService.Client.Render:Fire(Player, PlayerInfo)
	-- end)
end



function PetService:KnitInit()

end

function PetService:KnitStart()
	-------------Variables-----------
	self.Services = {
		DataService = Knit.GetService('DataService')
	}
	-------------Variables-----------
	-------------Classes-------------

	-------------Classes-------------
	-----------Initialize------------
    Players.PlayerAdded:Connect(OnPlayerAdded)
    --in case players join the server before this script runs
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(OnPlayerAdded, player)
    end
	-----------Initialize------------
end


function PetService:CreatePet(Player, Pet)
	-- local Profile = self.Services:GetProfile(Player)
	
	local Pet: Pet = {
		Key = HttpService:GenerateGUID(),
		PetInfo = {
			Type = Pet,
			Name = Pet,
			
			Level = 1,
			XP = 0
		}
	}
	
	
	-- Profile.Pets.Inventory[Pet.Key] = Pet
end

function PetService:PurchasePet()
    
end


function PetService:EditPet(Player: Player)
	
end

function PetService:EquipPet(Player: Player)
	
	
end




return PetService