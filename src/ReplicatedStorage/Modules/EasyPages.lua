local RunService = game:GetService("RunService")
local EasyPages = {}

local function Checker(EasyPagesGrid)
    if type(EasyPagesGrid) ~= "table" and type(EasyPagesGrid) ~= "string" then
        error('First arg needs to be a table or string')
    end
        
    if type(EasyPagesGrid) == "string" then
        EasyPagesGrid = EasyPages[EasyPagesGrid]
    end

    return EasyPagesGrid
end

local function CreateSlot()
    local ImageButton = Instance.new('ImageButton')
    
    ImageButton.Image = ''
    ImageButton.BackgroundTransparency = 1

    local ViewportFrame = Instance.new('ViewportFrame')
    ViewportFrame.Parent = ImageButton
    ViewportFrame.BackgroundTransparency = 1
    ViewportFrame.Size = UDim2.fromScale(1, 1)
    ViewportFrame.AnchorPoint = Vector2.new(.5, .5)
    ViewportFrame.Position = UDim2.fromScale(.5, .5)

    local ImageLabel = Instance.new('ImageLabel')

    ImageLabel.Image = ''
    ImageLabel.BackgroundTransparency = 1
    ImageLabel.AnchorPoint = Vector2.new(.5, .5)

    ImageLabel.Parent = ImageButton

    local AspectRatio = Instance.new('UIAspectRatioConstraint')
    AspectRatio.Parent = ImageButton

    return ImageButton
end

local function CreateGrid(MaxSlots)
    local Frame = Instance.new("Frame")
    Frame.AnchorPoint = Vector2.new(.5, .5)
    Frame.Position = UDim2.fromScale(.5, .5)
    Frame.Size = UDim2.fromScale(1, 1)
    Frame.BackgroundTransparency = 1

    local AspectRatio = Instance.new('UIAspectRatioConstraint')
    AspectRatio.Parent = Frame

    local UIGridLayout = Instance.new('UIGridLayout')
    UIGridLayout.CellPadding = UDim2.fromScale(.05, .1)
    UIGridLayout.CellSize = UDim2.fromScale(.25, .3)
    UIGridLayout.FillDirection = Enum.FillDirection.Horizontal
    UIGridLayout.FillDirectionMaxCells = math.ceil(math.sqrt(MaxSlots))
    UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    UIGridLayout.Name = 'DefaultGridLayout'
    UIGridLayout.Parent = Frame

    return Frame
end


function EasyPages.new(Information) : {}
    assert(Information['Name'] ~= nil, "First arg needs be a dictionary and to have a Name key and value")
    assert(Information['List'] ~= nil, "First arg needs be a dictionary and to have a List key and value")

    local self = {
        Name = Information.Name;
        List = Information.List;

        Parent = Information['Parent'] or nil;

        VpfCF = Information['VpfCF'] or nil;
        Animate = Information['Animate'] or nil;
        Unique = true;

        AssetList = {};
        StringList = {};

        AssetDictionary = {};

        
        Slots = {};
        Pages = {};
        MaxSlots = Information['MaxSlots'] or 9;
        PageCount = Instance.new("NumberValue");
        
        Grid = Information['Grid'] or CreateGrid(Information['MaxSlots'] or 9);
        SlotDesign = Information['Slot'] or CreateSlot();

        Connections = {};

        SlotClicked = Information.SlotClicked or function() print('Slot Clicked') end;
        MouseEnter = Information.MouseEnter or function() print('Slot Entered') end;
        MouseLeave = Information.MouseLeave or function() print('Slot Left') end;
    }

    EasyPages[self.Name] = self
    return self
end

--------------------------------------------------------------
function EasyPages.SortDictionaryByValue(EasyPagesGrid: table, ValueList: {[string]: number}, Ascending: boolean)
    local self = Checker(EasyPagesGrid)
    ValueList = self['ValueList'] or ValueList

    
    local Temp = {}
    local Finalized = {}
    
    for Key, Value in pairs(ValueList) do
        if table.find(self.StringList, Key) then
            table.insert(Temp, {Value, Key})
        end
    end

    table.sort(Temp, function(a,b) return Ascending and a[1] < b[1] or a[1] > b[1]; end)

    for Index, Array in pairs(Temp) do
        table.insert(Finalized, Array[2])
    end
    
    self.StringList = Finalized
end


function EasyPages.SortByName(EasyPagesGrid, Ascending)
    local self = Checker(EasyPagesGrid)
    table.sort(self.StringList, function(a,b) return Ascending and a > b or a < b end)
end
--------------------------------------------------------------

-- Page Functions
--------------------------------------------------------------
local CalculateDivisibility = function(a, b)
    local Floored = math.floor(a / b);
    local Remainder = a % b
    
    return Floored, Remainder;
end

local AddItemsToPage = function(StartCount: number, EndCount: number, PageArray: {}, SlotArray: {}, CurrentPage: number)
    for currentSlot = StartCount, EndCount do
        table.insert(PageArray[CurrentPage], SlotArray[currentSlot])
    end
end

function EasyPages.MakePages(EasyPagesGrid)
    local self = Checker(EasyPagesGrid)

    local Pages, LeftOver = CalculateDivisibility(#self.Slots, self.MaxSlots)
    local PageArray = {}
    
    for currentPage = 1, Pages  do
        local StartCount = currentPage * self.MaxSlots - self.MaxSlots + 1
        PageArray[currentPage] = {}
        
        AddItemsToPage(StartCount, StartCount + self.MaxSlots-1, PageArray, self.Slots, currentPage)
    end
    
    if LeftOver > 0 then
        local StartCount = (#PageArray + 1) * self.MaxSlots - self.MaxSlots + 1
        PageArray[Pages+1] = {}

        AddItemsToPage(StartCount, StartCount + LeftOver, PageArray, self.Slots, #PageArray)
    end

    self.Pages = PageArray
end

function EasyPages.WipePages(EasyPagesGrid)
    local self = Checker(EasyPagesGrid)

    for SlotCount = #self.Slots, 1, -1 do
        local Item = self.Slots[SlotCount]
        
        Item:Destroy()
        self.Slots[SlotCount] = nil
    end
    
    for PageCount = #self.Pages, 1, -1 do
        
        for Page, Item in pairs(self.Pages[PageCount]) do
            Item:Destroy()
        end
        
        self.Pages[PageCount] = nil
    end
    
    self.PageCount.Value = 0
end

function EasyPages.HideGridItems(EasyPagesGrid)
    local self = Checker(EasyPagesGrid)

    for _, Item in pairs(self.Pages[self.PageCount.Value]) do
        Item.Parent = nil
    end
end

function EasyPages.AddToGrid(EasyPagesGrid, Page)
    local self = Checker(EasyPagesGrid)

    for _, Item in pairs(Page) do
        Item.Parent = self.Grid
    end
end


--------------------------------------------------------------
function EasyPages.Scroll(EasyPagesGrid, ScrollLeft: boolean)
    local self = Checker(EasyPagesGrid)
    
    if #self.Pages == 1 then return end

    EasyPages.HideGridItems(self)
        
    if not ScrollLeft then
        if self.PageCount.Value + 1 > #self.Pages then
            self.PageCount.Value = 1
        else
            self.PageCount.Value += 1
        end
    else
        if self.PageCount.Value - 1 < #self.Pages then
            self.PageCount.Value = #self.Pages
        else
            self.PageCount.Value -= 1
        end
    end
end  

function EasyPages.EventPrep(EasyPagesGrid)
    local self = Checker(EasyPagesGrid)

    self.Connections['PageCount'] = self.PageCount:GetPropertyChangedSignal('Value'):Connect(function()	
		if self.PageCount.Value == 0 then return end
        local CurrentPage = self.Pages[self.PageCount.Value]
        local DefaultGridLayout = self.Grid:FindFirstChild('DefaultGridLayout')

        if DefaultGridLayout and #CurrentPage < self.MaxSlots then
            DefaultGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        else
            DefaultGridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        end
		EasyPages.AddToGrid(self, CurrentPage)
	end)
end


function EasyPages.Disconnect(EasyPagesGrid)
    local self = Checker(EasyPagesGrid)
    
    for Key, Value in pairs(self.Connections) do
        Value:Disconnect()
    end
    
end
--------------------------------------------------------------
function EasyPages.PrepList(EasyPagesGrid)
    local self = Checker(EasyPagesGrid)

    local UniqueNameFind = {}

    local AssetList = {}
    local StringList = {}
    local AssetDictionary = {}

    for Index, Value in pairs(self.List) do
        if type(Value) == "userdata" then

            if not UniqueNameFind[Value.Name] then
                UniqueNameFind[Value.Name] = true
            else
                -- error('Page Items must be unique')
                self.Unique = false
            end

            table.insert(StringList, Value.Name)
            table.insert(AssetList, Value)

            AssetDictionary[Value.Name] = Value
        else
            error('EasyPages only works with Models and Parts')
        end
    end

    self.AssetList = AssetList
    self.StringList = StringList
    self.AssetDictionary = AssetDictionary

end


function EasyPages.LoadSlots(EasyPagesGrid)
    local self = Checker(EasyPagesGrid)

    for ItemIndex, ItemName: string in pairs(self.StringList) do
        local Item 

        if self.Unique then
            Item = self.AssetList[ItemName]
        else
            Item = self.AssetList[ItemIndex]
        end
        
        local ItemCopy = Item:Clone()
        
        local Animation = false
        
        local Slot = self.SlotDesign:Clone()
        
        
        Slot.Name = ItemName
        
        Slot.MouseButton1Click:Connect(function()
            self.SlotClicked(Slot, Item) 
        end)

        local InitialCF = ItemCopy.CFrame
        

        Slot.MouseEnter:Connect(function()
            Animation = true

            if self.Animate then
                local Active = true
            
            
                if Slot.Parent == self.Grid and Active then
                    task.spawn(function()
                        while Animation do
                            if ItemCopy:IsA"Model" and ItemCopy.PrimaryPart ~= nil then
                                ItemCopy:SetPrimaryPartCFrame(
                                    ItemCopy.PrimaryPart.CFrame * CFrame.fromEulerAnglesXYZ(0, .01, 0)
                                )
                            elseif ItemCopy:IsA"BasePart" or ItemCopy:IsA"MeshPart" then
                                ItemCopy.CFrame = ItemCopy.CFrame * CFrame.fromEulerAnglesXYZ(0, .01, 0)
                            elseif ItemCopy:IsA"Model" and ItemCopy.PrimaryPart == nil then
                                error('Model does not have PrimaryPart set')
                            else
                                error('Item is not a Model or Part, disable Animate setting')
                            end
                            RunService.RenderStepped:Wait()
                        end
                    end)
                end
            end

            self.MouseEnter(Slot, Item)
        end)
        
        Slot.MouseLeave:Connect(function()
            if Animation then
                Animation = false
            end

            if ItemCopy:IsA"Model" and ItemCopy.PrimaryPart ~= nil then
                ItemCopy:SetPrimaryPartCFrame(
                    InitialCF * (self['VpfCF'] or CFrame.fromEulerAnglesXYZ(0, math.pi/6, 0))
                )
            elseif ItemCopy:IsA"BasePart" or ItemCopy:IsA"MeshPart" then
                ItemCopy.CFrame = InitialCF * (self['VpfCF'] or CFrame.fromEulerAnglesXYZ(0, math.pi/6, 0))
            elseif ItemCopy:IsA"Model" and ItemCopy.PrimaryPart == nil then
                error('Model does not have PrimaryPart set')
            else
                error('Item is not a Model or Part, disable Animate setting')
                
            end
            self.MouseLeave(Slot, Item)
        end)
        

        local DesiredCF 

        if ItemCopy:IsA"Model" and ItemCopy.PrimaryPart ~= nil then
            DesiredCF = CFrame.new(
                (ItemCopy.PrimaryPart.CFrame * CFrame.new(0, 0, -ItemCopy:GetExtentsSize().Magnitude)).Position,
                ItemCopy.PrimaryPart.Position
            )

            ItemCopy:SetPrimaryPartCFrame(
                ItemCopy.PrimaryPart.CFrame * (self['VpfCF'] or CFrame.fromEulerAnglesXYZ(0, math.pi/6, 0))
            )
        elseif ItemCopy:IsA"BasePart" or ItemCopy:IsA"MeshPart" then
            DesiredCF = CFrame.new(
                (ItemCopy.CFrame * CFrame.new(0, 0, -ItemCopy.Size.Magnitude)).Position,
                ItemCopy.Position
            )

            ItemCopy.CFrame = ItemCopy.CFrame *  (self['VpfCF'] or CFrame.fromEulerAnglesXYZ(0, math.pi/6, 0))
        elseif ItemCopy:IsA"Model" and ItemCopy.PrimaryPart == nil then
            error('Model does not have PrimaryPart set')
        else
            error('Item is not a Model or Part, disable Animate setting')
            
        end
        local VPF = Slot.ViewportFrame
        local WorldModel = Instance.new('WorldModel')
        local Camera = Instance.new('Camera')
        
        Camera.Parent = WorldModel
        ItemCopy.Parent = WorldModel
        
        WorldModel.Parent = VPF
        
        VPF.CurrentCamera = Camera
        
        Camera.CFrame = DesiredCF
                
        
        
        -- Slot.AncestryChanged:Connect(function(Slot)
            
        -- end)
        
        
        
        table.insert(self.Slots, Slot)
    end
end

--------------------------------------------------------------

function EasyPages.Render(EasyPagesGrid)
    local self = Checker(EasyPagesGrid)

    if #self.List > 0 then
        print('Rendering', self.Name)

        EasyPages.WipePages(self)
        EasyPages.Disconnect(self)


        EasyPages.EventPrep(self)
        EasyPages.PrepList(self)
        EasyPages.LoadSlots(self)
        EasyPages.MakePages(self)

        self.Grid.Parent = self.Parent or nil
        
        print('Rendered \n')
        print(self)
        self.PageCount.Value = 1

        return self.Grid
    else
        warn('Your list is empty')
    end

    
end

return EasyPages