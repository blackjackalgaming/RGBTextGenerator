---@meta _
---@diagnostic disable: spell-check
---@
local function ArePerfectModsAvailable()
    if not rom or not rom.mods then
        return false end
    return rom.mods['Jowday-BoonBuddy'] ~= nil
    and rom.mods['Jowday-Perfectoinist'] ~= nil
end

local perfectionColor = { 255, 255, 255, 255 } -- default color if perfection mods are not available
if rom.mods['Jowday-Perfectoinist'] ~= nil then
    game.Color.BoonPatchPerfect = { 97, 230, 255, 255 } -- is same call as in Perfectoinist mod, but we need to set it here to be able to use it in our code
        if config.debug then
            print("[RGBTextGenerator] Perfection mods found, using custom color for perfection text")
        end
    return perfectionColor = game.Color.BoonPatchPerfect
else
    if config.debug then
        print("[RGBTextGenerator] Perfection mods not found, using default color for perfection text")
    end
end


-- Mod initialization
if config.debug then
    print("[RGBTextGenerator] Core logic loaded")
end

