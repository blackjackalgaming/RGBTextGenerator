local config = {
    enabled = true,
    debug = false,
    RGBOpts = {  -- PhaseT, Speed, frameTime, etc.     
    }

}

local configDescription = {
    enabled = "Enable RGB Text Generator",
    debug = "Enable detailed debug logging to console (check ReturnOfModding/LogOutput.log)",
    RGBOpts = "Options for fine-tuning RGB Text Generator behavior. Not currently implemented."
}
return config, configDescription
