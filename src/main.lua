---@meta blackjackalgaming-RGBTextGenerator
---@diagnostic disable: lowercase-global
---@diagnostic disable-next-line: undefined-global
local mods = rom.mods

-- Setup environment isolation
---@module 'LuaENVY-ENVY'
envy = mods['LuaENVY-ENVY']
---@module 'LuaENVY-ENVY-auto'
envy.auto()

---@diagnostic disable-next-line: undefined-global
rom = rom
---@diagnostic disable-next-line: undefined-global
_PLUGIN = _PLUGIN

-- Setup game and utility service modules
---@module 'SGG_Modding-Hades2GameDef-Globals'

-- Setup game and utility service modules
---@module 'SGG_Modding-Hades2GameDef-Globals'
game = rom.game
---@module 'SGG_Modding-ModUtil'
modutil = mods['SGG_Modding-ModUtil']
---@module 'SGG_Modding-Chalk'
chalk = mods['SGG_Modding-Chalk']
---@module 'SGG_Modding-Reload'
reload = mods['SGG_Modding-Reload']

-- Load other dependencies
---@module 'Jowday-BoonBuddy'
boonbuddy = mods['Jowday-BoonBuddy']
---@module 'Jowday-Perfectoinist'
perfectionist = mods['Jowday-Perfectoinist']

-- Load configuration
---@module 'config'
config = chalk.auto 'config.lua'
public.config = config

-- Prime the mod for loading
-- Prime the mod for loading
local function on_ready()
    if config.Enabled == false then
        return
    end
    if config.Debug then
        print("[RGBTextGenerator] mod loaded and ready to go!")
    end
    if config.Debug then
        print("[RGBTextGenerator] mod loaded and ready to go!")
    end
    mod = modutil.mod.Mod.Register(_PLUGIN.guid)
    import 'core.lua'
    import 'core.lua'
    import 'ready.lua'
end

-- Set reload handler
-- Set reload handler
local function on_reload()
    if config.Enabled == false then
        return
    end
    import 'reload.lua'
end

local loader = reload.auto_single()

-- Load the mod when the game is ready
-- Load the mod when the game is ready
modutil.once_loaded.game(function()
    loader.load(on_ready, on_reload)
end)

-- Initialization when save data is loaded
modutil.once_loaded.save(function()
    if config.Enabled == false then
-- Initialization when save data is loaded
modutil.once_loaded.save(function()
    if config.Enabled == false then
        return
    end
    if config.Debug then
        print("[RGBTextGenerator] Save data loaded.")
    end
end)
    if config.Debug then
        print("[RGBTextGenerator] Save data loaded.")
    end
end)
