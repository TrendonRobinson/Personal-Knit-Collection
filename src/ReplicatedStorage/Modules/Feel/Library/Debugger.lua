--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// module
local Debugger = {}

function Debugger.new(key: string)
    local self = {
        key = key
    }
    
    Debugger[key] = self
    return self
end


return Debugger