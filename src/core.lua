---@meta _
---@diagnostic disable: spell-check

-- Mod initialization
if config.debug then
    print("[RGBTextGenerator] Core logic loaded")
end

local function ArePerfectModsAvailable()
    if not rom or not rom.mods then
        return false 
    end
    return rom.mods['Jowday-BoonBuddy'] ~= nil
    and rom.mods['Jowday-Perfectoinist'] ~= nil
end

local boonBuddy = rom.mods['Jowday-BoonBuddy']
local perfectionist = rom.mods['Jowday-Perfectoinist']

local perfectionColor = game.Color.BoonPatchPerfect -- default color if perfection mods are not available
function GetPerfectionColor()
    if boonBuddy ~= nil and perfectionist ~= nil then
        perfectionColor = { 97, 230, 255, 255 } -- is same call as in Perfectoinist mod, but we need to set it here to be able to use it in our code
            if config.debug then
                print("[RGBTextGenerator] Perfection mods found, using custom color for perfection text")
            end
        return perfectionColor
    else
        if config.debug then
            print("[RGBTextGenerator] Perfection mods not found, using default color for perfection text")
        end
        return game.Color.BoonPatchPerfect
    end
end


mod.RGBTextGenerator = {
	Speed = 0.20,        -- cycles per second
	UpdateInterval = 0.033,
}

function GetRGBPhaseFromKey( key )
	local s = tostring( key or "" )
	local hash = 0
	for i = 1, #s do
		hash = (hash * 31 + string.byte(s, i)) % 1000
	end
	return hash / 1000
end

local twopi = (math.pi * 2)

function GetRGBTextColor( phase, alpha )
	local speed = mod.RGBTextGenerator.Speed or 0.20
	local t = (game.GetTime({}) * speed) + (phase or 0)
	local radians = (t * twopi)
	local r = math.floor(128 + 127 * math.sin(radians))
	local g = math.floor(128 + 127 * math.sin(radians + twopi / 3))
	local b = math.floor(128 + 127 * math.sin(radians + (2 * twopi / 3)))
	return { r, g, b, alpha or 255 }
end

function RGBTextThread( id, phase, alpha, screenName, threadName )
	local interval = mod.RGBTextGenerator.UpdateInterval or 0.033
	while id ~= nil do
		if screenName ~= nil and not game.IsScreenOpen( screenName ) then
			break
		end
		game.ModifyTextBox({ Id = id, Color = GetRGBTextColor( phase, alpha ) })
		game.waitUnmodified( interval, threadName )
	end
end

function StartRGBTextThread( args )
	if mod == nil or mod.RGBTextGenerator == nil or config.enabled == false then
		return
	end
	if args == nil or args.Id == nil then
		return
	end
	local threadName = args.ThreadName or ("RGBText_"..tostring(args.Id))
	if game.HasThread( threadName ) then
		return
	end
	thread( RGBTextThread, args.Id, args.Phase or 0, args.Alpha or 255, args.ScreenName, threadName )
end


-- Example 1: Trait name (boons, upgrades)
local phase = GetRGBPhaseFromKey( traitData.Name )
StartRGBTextThread({ Id = rarityText.Id, Phase = phase, ScreenName = screen.Name })

-- Example 2: Upgrade choice item
local phase = GetRGBPhaseFromKey( upgradeData.Name or itemData.ItemName )
StartRGBTextThread({ Id = titleText.Id, Phase = phase, ScreenName = screen.Name })

-- Example 3: Sell screen item (use button or trait key)
local phase = GetRGBPhaseFromKey( button.UpgradeName or traitData.Name )
StartRGBTextThread({ Id = rarityText.Id, Phase = phase, ScreenName = screen.Name })

-- Example 4: Fallback when no stable name (use index)
local phase = GetRGBPhaseFromKey( "Choice_"..tostring(itemIndex) )
StartRGBTextThread({ Id = titleText.Id, Phase = phase, ScreenName = screen.Name })
