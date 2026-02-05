---@meta _
---@diagnostic disable-next-line: undefined-global
local mods = rom.mods

---@module 'LuaENVY-ENVY-auto'
mods['LuaENVY-ENVY-auto'].auto()
---@diagnostic disable: lowercase-global
---@diagnostic disable-next-line: undefined-global
rom = rom
---@diagnostic disable-next-line: undefined-global
_PLUGIN = _PLUGIN
---@module 'game'
game = rom.game
---@module 'game-import'
import_as_fallback(game)

---@module 'SGG_Modding-SJSON'
sjson = mods['SGG_Modding-SJSON']
---@module 'SGG_Modding-ModUtil'
modutil = mods['SGG_Modding-ModUtil']

---@module 'SGG_Modding-Chalk'
chalk = mods["SGG_Modding-Chalk"]
---@module 'SGG_Modding-ReLoad'
reload = mods['SGG_Modding-ReLoad']

---@module 'config'
config = chalk.auto 'config.lua'
public.config = config

local function on_ready()
    if config.enabled == false then
        return
    end
    mod = modutil.mod.Mod.Register(_PLUGIN.guid)
    import 'ready.lua'
end

local function on_reload()
    if config.enabled == false then
        return
    end
    import 'reload.lua'
end

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(on_ready, on_reload)
end)

mod.RGBText = {
  Active = {},     -- [textId] = { t = <phase/time in radians>, speed =..., alpha=..., intensity=... }
  Running = false,
}

rgbText = mod.RGBText

local function Clamp01(RGBIntensity)
  if type(RGBIntensity) ~= "number" then RGBIntensity = tonumber(RGBIntensity) or 0 end
  if RGBIntensity < 0 then return 0 end
  if RGBIntensity > 1 then return 1 end
  return RGBIntensity
end

-- Converts sin output (-1..1) -> (0..1), with optional intensity
-- intensity ~ 0.35..0.5 recommended for UI readability
local function SinTo01(scaleswing, RGBIntensity)
    RGBIntensity = Clamp01(RGBIntensity)
  -- center at 0.5, scale swing by intensity
    return 0.5 + (RGBIntensity * scaleswing)
end

-- Call this when you have a text box id.
function RegisterRgbText( textId, RGBopts )
    if not textId then
        return
    end

    if not RGBopts then
        RGBopts = {}
    end

    RgbText.Active[textId] = {
        phaseT = tonumber(RGBopts.phaseT) or 0.0,           -- initial phase/time (radians)
        speed = tonumber(RGBopts.speed) or 0.8,             -- radians/sec (tuned)
        alpha = tonumber(RGBopts.alpha) or 1.0,             -- opacity
        intensity = tonumber(RGBopts.intensity) or 0.45,    -- 0.45 = vivid but readable
    }


    if not rgbText.Running then
        rgbText.Running = true

        thread(function()
            local frameTime = 0.03

            while rgbText.Running == true do
                local hasActiveEntries = false                -- stop loop if no active ids
                for _ in pairs(rgbText.Active) do hasActiveEntries = true 
                    break
                end

                if not hasActiveEntries then
                    rgbText.Running = false
                end

            for textId, rgbcfg in pairs(RgbText.Active) do
            -- advance phase
                rgbcfg.phaseT = rgbcfg.phaseT + (rgbcfg.speed * frameTime)
            -- OPTIONAL: keep t bounded (tidy, not required)
                if rgbcfg.phaseT >= twopi then
                    rgbcfg.phaseT = rgbcfg.phaseT - twopi
                end

                -- sin-wave RGB with 120° phase offsets
                local r = SinTo01(math.sin(rgbcfg.phaseT),               rgbcfg.intensity)
                local g = SinTo01(math.sin(rgbcfg.phaseT + twopi/3),     rgbcfg.intensity)
                local b = SinTo01(math.sin(rgbcfg.phaseT + 2*twopi/3),   rgbcfg.intensity)

                -- Apply (swap this for your real API if needed)
                SetColor({ Id = textId, Color = { r, g, b, rgbcfg.alpha } })
                end
                wait(frameTime)
            end
        end)
    end
end

function UnregisterRgbText(textId)
    if not textId then 
        return
    end
    RgbText.Active[textId] = nil
end

return RgbText
