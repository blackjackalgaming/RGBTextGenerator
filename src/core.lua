---@meta _
---@diagnostic disable: spell-check
---@diagnostic disable: undefined-field

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
                rom.log.debug("[RGBTextGenerator] Jowday-Perfectoinist mod found, new color set.")
            end
        return perfectionColor
    else
        if config.debug then
            rom.log.debug("[RGBTextGenerator] Perfection mods not found, using default color for perfection text")
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
	game.thread( RGBTextThread, args.Id, args.Phase or 0, args.Alpha or 255, args.ScreenName, threadName )
end

local function IsPerfectRarity(value)
	if value == nil then
		return false
	end
	if not ArePerfectModsAvailable() then
		return false
	end

	local rarityValues = game.TraitRarityData and game.TraitRarityData.RarityValues
	if not (rarityValues and rarityValues.Perfect) then
		return false
	end

	local rarity = value
	if type(value) == "table" then
		local levels = value.RarityLevels
		if levels and levels.Perfect then
			return true
		end
		rarity = value.Rarity
	end

	if type(rarity) == "string" then
		if rarity == "Perfect" then
			return true
		end
		return rarityValues and rarityValues[rarity] == rarityValues.Perfect
	end
	if type(rarity) == "number" then
		return rarityValues and rarity == rarityValues.Perfect
	end
	return false
end

local function IsPerfectAspectRarity(traitData)
	if traitData == nil then
		return false
	end
	if not ArePerfectModsAvailable() then
		return false
	end
	local rarityValues = game.TraitRarityData and game.TraitRarityData.RarityValues
	local aspectText = game.TraitRarityData and game.TraitRarityData.AspectRarityText
	local rarityOrder = game.TraitRarityData and game.TraitRarityData.WeaponRarityUpgradeOrder
	if not (rarityValues and rarityValues.Perfect and aspectText and rarityOrder) then
		return false
	end
	local rarityLevel = game.GetRarityValue(traitData.Rarity)
	local perfectLabel = aspectText[rarityValues.Perfect]
	if perfectLabel and aspectText[rarityLevel] == perfectLabel then
		return true
	end
	return rarityOrder[rarityLevel] == "Perfect"
end


function InstallRGBTextHooks()
	if mod == nil or mod.RGBTextGenerator == nil or config.enabled == false then
		return
	end
	if mod.RGBTextGenerator.HooksInstalled then
		return
	end
	mod.RGBTextGenerator.HooksInstalled = true

	if config.debug then
		rom.log.debug("[RGBTextGenerator] Installing hooks...")
	end

	modutil.mod.Path.Wrap("CreateUpgradeChoiceButton", function(base, screen, lootData, itemIndex, itemData, args)
		if config.debug then
			rom.log.debug("[RGBTextGenerator] Wrapping CreateUpgradeChoiceButton")
		end

		local button = base(screen, lootData, itemIndex, itemData, args)
		if button and button.Id then
			if itemData == nil or not IsPerfectRarity(itemData.Rarity) then
				return button
			end
			local phaseKey = nil
			if itemData ~= nil then
				phaseKey = itemData.ItemName or itemData.Name
			end
			if phaseKey == nil and lootData ~= nil then
				phaseKey = lootData.Name
			end
			if phaseKey == nil then
				phaseKey = "Choice_" .. tostring(itemIndex)
			end
			local phase = GetRGBPhaseFromKey(phaseKey)
			StartRGBTextThread({ Id = button.Id, Phase = phase, ScreenName = screen and screen.Name })
			if config.debug then
				rom.log.debug("[RGBTextGenerator] RGB started for Perfect rarity: " .. tostring(phaseKey))
			end
		end
		return button
	end)

	modutil.mod.Path.Wrap("CreateBoonInfoButton", function(base, screen, traitName, index)
		local result = base(screen, traitName, index)
		local traitInfo = screen
			and screen.Components
			and screen.Components["BooninfoButton" .. tostring(index)]
		local purchaseButton = traitInfo and traitInfo.PurchaseButton
		local titleBox = traitInfo and traitInfo.TitleBox
		local traitData = purchaseButton and purchaseButton.TraitData
		if purchaseButton and purchaseButton.Id and traitData and IsPerfectRarity(traitData.Rarity) then
			local phaseKey = traitData.Name or traitName or ("BoonInfo_" .. tostring(index))
			local phase = GetRGBPhaseFromKey(phaseKey)
			StartRGBTextThread({ Id = purchaseButton.Id, Phase = phase, ScreenName = screen and screen.Name })
			if titleBox and titleBox.Id then
				StartRGBTextThread({ Id = titleBox.Id, Phase = phase, ScreenName = screen and screen.Name })
			end
			if config.debug then
				rom.log.debug("[RGBTextGenerator] RGB started for Perfect boon info: " .. tostring(phaseKey))
			end
		end
		return result
	end)

	modutil.mod.Path.Wrap("UpdateWeaponUpgradeButtons", function(base, screen, weaponName)
		local result = base(screen, weaponName)
		if screen and screen.Components then
			for itemIndex = 1, 5 do
				local purchaseButton = screen.Components["PurchaseButton" .. tostring(itemIndex)]
				local traitData = purchaseButton and purchaseButton.TraitData
				if config.debug and traitData then
					mod.RGBTextGenerator.AspectRarityLogged = mod.RGBTextGenerator.AspectRarityLogged or {}
					local key = traitData.Name or ("Aspect_" .. tostring(itemIndex))
					if not mod.RGBTextGenerator.AspectRarityLogged[key] then
						mod.RGBTextGenerator.AspectRarityLogged[key] = true
						rom.log.debug("[RGBTextGenerator] Aspect rarity: " .. tostring(key) .. " = " .. tostring(traitData.Rarity))
					end
				end
				if traitData and IsPerfectAspectRarity(traitData) then
					local rarityComponent = screen.Components["InfoBoxRarity" .. tostring(itemIndex)]
					local textId = rarityComponent and rarityComponent.Id
					local nameComponent = screen.Components["InfoBoxName" .. tostring(itemIndex)]
					local nameId = nameComponent and nameComponent.Id
					if textId ~= nil then
						local phaseKey = traitData.Name or ("Aspect_" .. tostring(itemIndex))
						local phase = GetRGBPhaseFromKey(phaseKey)
						StartRGBTextThread({ Id = textId, Phase = phase, ScreenName = screen.Name })
						if nameId ~= nil then
							StartRGBTextThread({ Id = nameId, Phase = phase, ScreenName = screen.Name })
						end
						if config.debug then
							rom.log.debug("[RGBTextGenerator] RGB started for Perfect aspect: " .. tostring(phaseKey))
						end
					end
				end
			end
		end
		return result
	end)
end
