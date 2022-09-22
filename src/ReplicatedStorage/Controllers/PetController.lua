--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// Modules
local Player = game.Players.LocalPlayer
local PlayerModule = require(Player.PlayerScripts:WaitForChild("PlayerModule"))
local Controls = PlayerModule:GetControls()


--// Knit
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

--// Knit Modules
-- local PetInformation = require(ReplicatedStorage.Client.Mods.Pets)

local Modules = Knit.Modules
local Tween = require(Modules.Tween)

local Assets = ReplicatedStorage.Assets
local Pets = Assets.Pets
local Body = Pets.PetBody

local PlayerPets = {}


--// Controller
local PetController = Knit.CreateController { Name = "PetController" }

--// Functions
function GetCharacter(Player)
	return Player.Character or Player.CharacterAdded:Wait()
end

function GetPrimaryPart(Player)
	local Character = GetCharacter(Player)
	Character:WaitForChild('HumanoidRootPart')
	
	return Character.PrimaryPart
end

function GetClosestGridSize(Number)
	if math.sqrt(Number) == math.floor(math.sqrt(Number)) then
		return Number
	elseif math.sqrt(Number) ~= math.floor(math.sqrt(Number)) then
		return GetClosestGridSize(Number + 1)
	end
end

function CreateBricks(Amount)

	local Iteration = 1
	local Count = 0
	local GridSizeX = math.sqrt(GetClosestGridSize(Amount)) < 4 and math.sqrt(GetClosestGridSize(Amount)) or 4
	local GridSizeZ = math.sqrt(GetClosestGridSize(Amount))

	for Spot = 1, Amount, GridSizeX do
		for X = 1, GridSizeX do
			Count += 1
			if Count > Amount then break end
		end
		Iteration += 1
	end
end

function GetPet(PetArray)
	for i = 1, #PetArray do
		if PetArray[i]:GetAttribute("Active") == false then
			return PetArray[i]
		end
	end
end

function GetCFrame(Target)
	local radius = 3
	local total = Target:GetAttribute('Pet_Count')

	local angle = (math.pi*2/5) * total
	local x = radius * math.cos(angle) 
	local y = radius * math.sin(angle)

	local CF = Target.CFrame * CFrame.new(x, 0, y)
	return CFrame.new(CF.p, Target.CFrame.p)
end

function PetController:KnitInit()
	
	self.States = {
		CanFetch = true,
		CanFeed = true,
		CanPet = true,
	}
	
	self.Pets = {}
	self.Attachments = {}
	
	
	self.PetCount = 0
	self.CastCount = 0
	
	
end

function PetController:KnitStart()
	-------------Variables-----------
	local PetService = Knit.GetService('PetService')
	-------------Variables-----------
    -- self.PetsFolder = GetCharacter():FindForChild("Pets")
	-------------Classes-------------

	-------------Classes-------------
	-----------Initialize------------
	PetService.Render:Connect(function(Player, Data)
		self:ClearPets(Player)

        PlayerPets[Player] = {
            Player = Player,
            Data = Data,

            PetCount = #Data,

            Pets = {},
            Attachments = {},
        }

		self:LoadPets(PlayerPets[Player])
		self:Render(Player)
	end)
	-----------Initialize------------
end

function PetController:ClearPets(Player)
	if PlayerPets[Player] == nil then return end
	
	local Player = PlayerPets[Player]
	if #Player.Attachments < 1 then return end
	
	for _, Pets in pairs(Player.Pets) do
		Pets:Destroy()
	end

	for _, Attachment in pairs(Player.Attachments) do
		Attachment:Destroy()
	end
end



function PetController:CheckStates()
	for Key, State in pairs(self.States) do
		if not State then
			return not State
		end
	end
	
	return false
end


function PetController:ArrangeAttachments(Player)

	local Width = math.sqrt(GetClosestGridSize(Player.PetCount))
	local Amount = Player.PetCount
	local Radius = 5
	local Attachments = Player.Attachments

	local Iteration = 1

	local parts = Player.Pets

	local missingParts = Width - (#parts % (Width)) 
	missingParts = missingParts == Width and 0 or missingParts

	--// Radial Pets
	--for index, part in ipairs(self.Pets) do 
	--	local Attachment = self.Attachments[index]

	--	local angle = (math.pi*2/Amount) * index  -- There are 360 degrees in a circle or pi*2 radians
	--	local x = Radius * math.cos(angle) 
	--	local y = Radius * math.sin(angle)

	--	local CF = self.Primary.CFrame * CFrame.new(x, 0, y)
	--	local GoalCF = CFrame.new(CF.p, self.Primary.CFrame.p)

	--	part:SetPrimaryPartCFrame(GoalCF)

	--	Attachment.WorldCFrame = GoalCF
	--end

	--// Grid Pets
	for index, part in ipairs(Player.Pets) do

		local row = math.ceil(index / Width)
		local col = index % Width
		local isLastRow = row == math.ceil( #parts / Width)
		local partsVoid = isLastRow and missingParts or 0

		local X = index - 1
		local ZOffset = X % Width

		if ZOffset == 0 then Iteration += 1 end

		local Column = ZOffset

		local Attachment = Attachments[index]
		local Scale = Body.Size.X
		local HorizontalPadding = Scale*1.5
		local VerticalPadding = 1.5

		local xOffset = (ZOffset * (HorizontalPadding))

		local FirstCF = GetPrimaryPart(Player.Player).CFrame * CFrame.new(xOffset, -2, (Iteration * Scale * VerticalPadding))
		local GoalCF = (FirstCF * CFrame.new(-(HorizontalPadding)/2 + (partsVoid * HorizontalPadding)/2, 3, -2)) * CFrame.new(0, 0, -2)

		part.CFrame = GoalCF

		Attachment.WorldCFrame = GoalCF
        Attachment.Orientation = Vector3.new(0, 90, 0)

	end

end



function PetController:AddPet(Player, Pet)

    local Attachments = {}
	local ID = math.random(1111111, 9999999)
	Pet:SetAttribute("PetID", ID)
	Pet:SetAttribute("Active", false)
	
	table.insert(Player.Pets, Pet)
	
	Pet.CFrame = GetPrimaryPart(Player.Player).CFrame * CFrame.new(0, 0, -3)


	self.PetCount += 1

	local Attachment = Instance.new("Attachment")
	Attachment.Name = "Pet"..self.PetCount
	-- Attachment.Visible = true
	Attachment.Parent = GetPrimaryPart(Player.Player)
	Attachment.WorldCFrame = Attachment.Parent.CFrame


	Pet.Align.Attachment1 = Attachment
	Pet.Orientate.Attachment1 = Attachment

	table.insert(Player.Attachments, Attachment)
	self:ArrangeAttachments(Player)

end

function PetController:RetrievePet(ID)
	for i, Pet in pairs(self.Pets) do
		if Pet:GetAttribute("PetID") == ID then
			return i, Pet
		end
	end
end

function GetCFrames(Target, Root)
	local DesiredPosCF = CFrame.new(Target.Position) * CFrame.new(0, Root.body.Size.Y/2, 0)

	local LookAngle = CFrame.new(Root.body.CFrame.Position, DesiredPosCF.Position)
	local DesiredCF = CFrame.new(DesiredPosCF.Position, DesiredPosCF * LookAngle.LookVector)
	
	
	return DesiredCF
end


function PetController:CastPet(Target)

	local Pet = GetPet(self.Pets)
	local Root = Pet
	local PetBody = Root.body

	Pet:SetAttribute("Active", true)

	Pet.body.Orientate.Enabled = false
	Pet.body.Align.Enabled = false

	Root.body.Anchored = true
	Root.body.CanCollide = false
	
	
	
	local RetrieveBone = Tween.new(Root.PrimaryPart, 
		{
			CFrame = GetCFrames(Target, Root)
		},
		2,
		{
			Reversing = false
		}
	)
	
	RetrieveBone:Play()
	RetrieveBone.Completed:Wait()
	
	local Weld = Instance.new('Weld')
	Weld.Part0 = Target
	Weld.Part1 = Body
	Weld.C0 = CFrame.new(Body.Size.X/2, Body.Size.Y/6, 0) --* CFrame.fromEulerAnglesXYZ(0, math.pi/2, 0)
	Weld.Parent = Target
	
	Target.CanCollide = false
	
	task.wait(1)

	--Target:SetAttribute('Pet_Count', Target:GetAttribute('Pet_Count')-1)

	Root.body.Anchored = false

	Pet.body.Orientate.Enabled = true
	Pet.body.Align.Enabled = true

	Pet:SetAttribute("Active", false)

end

function PetController:RemovePet(ID)

	local Position, TargetPet = self:RetrievePet(ID)
	table.remove(self.Pets, Position)

	TargetPet:Destroy()

	self.PetCount += 0

end

function PetController:LoadPets(Player)
	for i, CurrentPet in pairs(Player.Data) do

        local Rarity = 'Common'--PetInformation[CurrentPet].Rarity
		local Pet =  Pets[Rarity][CurrentPet]:Clone()
		local Root = Pet

		if not Root:FindFirstChild("Attachment") then
			local Attachment = Instance.new("Attachment")
			Attachment.Parent = Root
		end

		local Align = Instance.new("AlignPosition")
		Align.Attachment0 = Root.Attachment
		Align.Parent = Root
		Align.Responsiveness = 20
		Align.Name = "Align"

		local Orientate = Instance.new("AlignOrientation")
		Orientate.Attachment0 = Root.Attachment
		Orientate.Parent = Root
		Orientate.Name = "Orientate"

		Pet.Parent = GetCharacter(Player.Player):WaitForChild("Pets")

		self:AddPet(Player, Pet)
	end
end


function PetController:Render()

end

function PetController:Destroy()

end

return PetController