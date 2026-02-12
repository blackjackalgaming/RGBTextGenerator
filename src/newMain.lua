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
config = chalk.auto 