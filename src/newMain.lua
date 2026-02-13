---@meta blackjackalgamingfb-RGBTextGenerator
---@diagnostic disable: lowercase-global
---@diagnostic disable-next-line: undefined-global
local mods = rom.mods

-- Setup environment isolation
---@module 'LuaENVY-ENVY-auto'
mods['LuaENVY-ENVY-auto'].auto()
---@diagnostic disable-next-line: undefined-global
rom = rom
---@diagnostic disable-next-line: undefined-global
_PLUGIN = _PLUGIN

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
local function on_ready()
    if config.Enabled == false then
        return
    end
    mod = modutil.mod.Mod.Register(_PLUGIN.guid)
    import 'core.lua'
    import 'ready.lua'
end

-- Set reload handler
local function on_reload()
    if config.Enabled == false then
        return
    end
    import 'reload.lua'
end

-- Load the mod when the game is ready
modutil.once_loaded.game(function()
    loader.load(on_ready, on_reload)
end)