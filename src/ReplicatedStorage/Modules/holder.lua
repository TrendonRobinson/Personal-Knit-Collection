
-- local RenderSelection = function(Pet, Unlocked)
--     PetSelectionString.Value = Pet.Name
    
--     local Price = PetPrices[Pet.Name]
--     local PetDisplay = self.UI.Selection.PetDisplay

--     local VPF = PetDisplay.ViewportFrame
--     local WorldModel = VPF.WorldModel
--     local Camera = WorldModel:FindFirstChild('Camera') or Instance.new('Camera')
--     Camera.Parent = WorldModel

--     VPF.CurrentCamera = Camera

--     local PreviousPet = WorldModel:FindFirstChild('Pet')

--     if PreviousPet then
--         PreviousPet:Destroy()
--     end

--     local PetCopy = Pet:Clone()
--     PetCopy.Name = 'Pet'
--     PetCopy.Parent = WorldModel
    
--     Camera.CFrame = CFrame.new(
--         (PetCopy.CFrame * CFrame.new(0, 0, -PetCopy.Size.Magnitude)).Position,
--             PetCopy.Position
--         )
            
--     PetCopy.CFrame = PetCopy.CFrame * CFrame.fromEulerAnglesXYZ(0, math.pi/6, 0)

--     task.spawn(function()
--         while PetCopy do
--             PetCopy.CFrame = PetCopy.CFrame * CFrame.fromEulerAnglesXYZ(0, .01, 0)
--             RunService.RenderStepped:Wait()
--         end
--     end)

--     if Unlocked == false then
--         PetDisplay.Equip.Visible = false
--         PetDisplay.Unlock.Price.CoinAmount.Text = tostring(Price)
--         PetDisplay.Unlock.Visible = true
--         VPF.Ambient = Color3.new()
--         VPF.LightColor = Color3.new()
--     else
--         PetDisplay.Equip.Visible = true
--         PetDisplay.Unlock.Visible = false
--         VPF.Ambient = Color3.fromRGB(255, 255, 255)
--         VPF.LightColor = Color3.fromRGB(255, 255, 255)
--     end

    
-- end

-- --------------------------------------------------------------
-- local CalculateDivisibility = function(a, b)
--     local Floored = math.floor(a / b);
--     local Remainder = a % b
    
--     return Floored, Remainder;
-- end

-- local AddItemsToPage = function(StartCount, EndCount, PageArray, SlotArray, CurrentPage)
--     for currentSlot = StartCount, EndCount do
--         table.insert(PageArray[CurrentPage], SlotArray[currentSlot])
--     end
-- end

-- local MakePages = function()
--     local Pages, LeftOver = CalculateDivisibility(#Slots, MaxSlots)
--     local PageArray = {}
    
--     for currentPage = 1, Pages  do
--         local StartCount = currentPage * MaxSlots - MaxSlots + 1
--         PageArray[currentPage] = {}
        
--         AddItemsToPage(StartCount, StartCount + MaxSlots-1, PageArray, Slots, currentPage)
--     end
    
--     if LeftOver > 0 then
--         local StartCount = (#PageArray + 1) * MaxSlots - MaxSlots + 1
--         PageArray[Pages+1] = {}

--         AddItemsToPage(StartCount, StartCount + LeftOver, PageArray, Slots, #PageArray)
--     end

--     return PageArray
-- end

-- --------------------------------------------------------------
-- local WipePages = function()
    
--     for SlotCount = #Slots, 1, -1 do
--         local Item = Slots[SlotCount]
        
--         Item:Destroy()
--         Slots[SlotCount] = nil
--     end
    
--     for PageCount = #self.Pages, 1, -1 do
        
--         for Page, Item in pairs(self.Pages[PageCount]) do
--             Item:Destroy()
--         end
        
--         self.Pages[PageCount] = nil
--     end
    
--     PageCount.Value = 0
    
-- end

-- local ClearGrid = function()
--     for _, Item in pairs(self.UI.Selection.Grid:GetChildren()) do
--         if Item:IsA"ImageButton" then
--             Item:Destroy()
--         end
--     end
-- end


-- local HideGridItems = function()
--     for _, Item in pairs(self.Pages[PageCount.Value]) do
--         Item.Parent = nil
--     end
-- end

-- local AddToGrid = function(Page)
--     for _, Item in pairs(Page) do
--         Item.Parent = self.UI.Selection.Grid
--     end
-- end

-- --------------------------------------------------------------

-- local PrepScrolling = function(Selection)
--     Selection.Right.Button.MouseButton1Click:Connect(function()
--         if #self.Pages == 1 then return end
--         HideGridItems()
        
--         if PageCount.Value + 1 > #self.Pages then
--             PageCount.Value = 1
--         else
--             PageCount.Value += 1
--         end
        
--     end)
    
--     Selection.Left.Button.MouseButton1Click:Connect(function()
--         if #self.Pages == 1 then return end

--         HideGridItems()
        
--         if PageCount.Value - 1 < 1 then
--             PageCount.Value = #self.Pages
--         else
--             PageCount.Value -= 1
--         end
        
        
--     end)
-- end
-- --------------------------------------------------------------
-- local NewSlot = function(SlotType)
--     return Assets[SlotType or 'PetSlot']:Clone()
-- end

-- local SlotLoadingFunctions = {
--     Animals = function(PetList)
--         for _, PetName: string in pairs(PetList) do
--             local Pet = UsablePetModels[PetName]
            
--             local WorldModel = Instance.new('WorldModel')
--             local PetCopy = Pet:Clone()
            
--             local Animation = false
            
--             local Slot = NewSlot()
--             local Camera = Instance.new('Camera')
            
--             Slot.Name = PetCopy.Name
            
--             Slot.MouseButton1Click:Connect(function()
--                 RenderSelection(Pet, UnlockedPets[Pet.Name] == true and true or false)
--             end)
            

--             Slot.MouseEnter:Connect(function()
--                 Animation = true

--                 local Active = true
                
                
--                 if Slot.Parent == self.UI.Selection.Grid and Active then
--                     task.spawn(function()
--                         while Animation do
--                             PetCopy.CFrame = PetCopy.CFrame * CFrame.fromEulerAnglesXYZ(0, .01, 0)
--                             RunService.RenderStepped:Wait()
--                         end
--                     end)
--                 end
--             end)
            
--             Slot.MouseLeave:Connect(function()
--                 if Animation then
--                     Animation = false
--                 end
--             end)
            
--             local VPF = Slot.ViewportFrame
--             if not UnlockedPets[Pet.Name] then
--                 VPF.Ambient = Color3.new()
--                 VPF.LightColor = Color3.new()
--             end
            
--             Camera.Parent = WorldModel
--             PetCopy.Parent = WorldModel
            
--             WorldModel.Parent = VPF
            
--             VPF.CurrentCamera = Camera
            
--             Camera.CFrame = CFrame.new(
--                 (PetCopy.CFrame * CFrame.new(0, 0, -PetCopy.Size.Magnitude)).Position,
--                     PetCopy.Position
--                 )
                    
--             PetCopy.CFrame = PetCopy.CFrame * CFrame.fromEulerAnglesXYZ(0, math.pi/6, 0)
            
--             Slot.AncestryChanged:Connect(function(Slot)
                
--             end)
            
            
            
--             table.insert(Slots, Slot)
--         end
--     end
-- }

-- local LoadSlots = function(Screen, List)
--     SlotLoadingFunctions[Screen](List)
-- end

-- local Start = function(List)
--     local PetSelection = self.Instance
--     local BottomFrame = PetSelection

--     self.UI = {
--         Selection = {
--             Grid = BottomFrame.Grid,
--             PetDisplay = BottomFrame.PetDisplay,

--             Left = BottomFrame.Left,
--             Right = BottomFrame.Right,
--         }
--     }
    

--     local Grid = self.UI.Selection.Grid
    
--     if Grid.AbsoluteSize.X < 500 then
--         Grid.UIGridLayout.CellSize = UDim2.new(.3, 0, .3, 0)
--     end

--     PrepScrolling(self.UI.Selection)
--     LoadSlots(ScreenSelection.Value, CreateSortedList(List))
    
    
--     self.Pages = MakePages()
--     PageCount.Value = 1
    
--     RenderSelection(UsablePetModels.SportCar, UnlockedPets['SportCar'] == true and true or false)


--     BottomFrame.PetDisplay.Equip.MouseButton1Click:Connect(function()
--         self.CharacterService.EquipPet:Fire(PetSelectionString.Value)
--     end)

--     BottomFrame.PetDisplay.Unlock.MouseButton1Click:Connect(function()
--         self.TransactionService.PurchasePet:Fire(PetSelectionString.Value)
--     end)
    
-- end

-- ScreenSelection:GetPropertyChangedSignal('Value'):Connect(function()
--     WipePages()
--     LoadSlots(ScreenSelection.Value, CreateSortedList(UsablePets))
    
--     self.Pages = MakePages()
--     PageCount.Value = 1
-- end)

-- PageCount:GetPropertyChangedSignal('Value'):Connect(function()	
--     if PageCount.Value == 0 then return end
    
--     AddToGrid(self.Pages[PageCount.Value])
-- end)

-- self.DataService.RefreshGrid:Connect(function()
--     UnlockedPets = self.DataService:GetUnlockedPets(Players.LocalPlayer)

--     WipePages()
--     LoadSlots(ScreenSelection.Value, CreateSortedList(UsablePets))

--     RenderSelection(UsablePetModels[PetSelectionString.Value], UnlockedPets[PetSelectionString.Value])
    
--     self.Pages = MakePages()
--     PageCount.Value = 1
-- end)

-- Start(UsablePets)