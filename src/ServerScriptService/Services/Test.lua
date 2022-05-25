--// Services

--// Modules

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local Test = Knit.CreateService {
    Name = "Test";
    Client = {};
}

function Test:KnitInit()
    print('Test')
end

function Test:KnitStart()
    
end

return Test