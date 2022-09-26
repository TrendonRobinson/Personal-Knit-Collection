--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// module
local Library = {}

Library.Required = {}


function Library.Import(ModuleToImportName: string)
    local ModuleToImport: ModuleScript? = script:FindFirstChild(ModuleToImportName)

    if ModuleToImport then
        local PreviouslyRequired = Library.Required[ModuleToImport.Name]
        
        if PreviouslyRequired then
            return PreviouslyRequired
        end

        local RequiredModule = require(ModuleToImport)
        Library.Required[ModuleToImport.Name] = RequiredModule
        
        return RequiredModule
    else
        error('Module does not exist')
    end
end


return Library