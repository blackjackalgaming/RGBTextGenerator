---@meta _
---@diagnostic disable: spell-check
local function ArePerfectModsAvailable()
    if not rom or not rom.mods then
        return false end
    return rom.mods['Jowday-BoonBuddy'] ~= nil
    and rom.mods['Jowday-Perfectoinist'] ~= nil
end

-- Mod initialization
if config.debug then
    print("[RGBTextGenerator] Core logic loaded")
end

