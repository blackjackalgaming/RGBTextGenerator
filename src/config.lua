---@meta _
local config = {
    Enabled = true,
    Debug = false,
    Intensity = 
    RGBOpts = {  -- PhaseT, Speed, frameTime, etc.
        
    }

}

local configDescription = {
    Enabled = "Enable RGB Text Generator",
    Debug = "Enable detailed debug logging to console (check ReturnOfModding/LogOutput.log)",
    RGBOpts = "Options for fine-tuning RGB Text Generator behavior. Not currently implemented."
}

return config, configDescription