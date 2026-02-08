---@diagnostic disable: redefined-local
---@meta blackjackalgamingfb-RGBTextGenerator
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
    if config.Enabled == false then
        return
    end
    mod = modutil.mod.Mod.Register(_PLUGIN.guid)
    import 'ready.lua'
end

local function on_reload()
    if config.Enabled == false then
        return
    end
    import 'reload.lua'
end

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(on_ready, on_reload)
end)

-- ...existing code...
mod.RGBTextGenerator = {
  Active = {}, -- [textId] = { phaseT = <phase/time in radians>, speed = ... , alpha = ... , intensity = ... }
  Running = false,
}

local rgbtext = mod.RGBTextGenerator
local active = rgbtext.Active
local twopi = ( math.pi * 2 )

local function RGBClamp01(x)
    x = tonumber(x) or 0
    if x <= 0 then return 0 end
    if x >= 1 then return 1 end
    return x
end

local function SetBaseColor( id, color )
    SetColor({ Id = id, Color = color })
end


local x = 0
local intensity = x
-- Converts sin output (-1..1) -> (0..1), with optional intensity
-- intensity ~ 0.35..0.5 recommended for UI readability
local function SinTo01(scaleswing, intensity)
    intensity = RGBClamp01(intensity)
    -- center at 0.5, scale swing by intensity
    return 0.5 + (intensity * scaleswing)
end

-- Call this when you have a text box id.
function RegisterRgbText(textId, RGBopts)
    if not textId then
        return
    end

    if not RGBopts then
        RGBopts = {}
    end

    rgbtext.Active[textId] = {
        phaseT = tonumber(phaseT) or 0.0,        -- initial phase/time (radians)
        speed = tonumber(speed) or 0.8,          -- radians/sec (tuned)
        alpha = tonumber(alpha) or 1.0,          -- opacity
        intensity = tonumber(intensity) or 0.45, -- 0.45 = vivid but readable
    }

    if not rgbtext.Running then
        rgbtext.Running = true

        thread(function()
        local frameTime = 0.03

        while rgbtext.Running == true do
            local hasActiveEntries = false -- stop loop if no active ids
            for _ in pairs(rgbtext.Active) do
                hasActiveEntries = true
                break
            end

            if not hasActiveEntries then
            rgbtext.Running = false
            break
            end

            for id, cfg in pairs(rgbtext.Active) do
                -- advance phase
                cfg.phaseT = cfg.phaseT + (cfg.speed * frameTime)
                -- keep phaseT bounded (tidy, not required)
                if cfg.phaseT >= twopi then
                    cfg.phaseT = cfg.phaseT - twopi
                end

                -- sin-wave RGB with 120° phase offsets
                local r = SinTo01(math.sin(cfg.phaseT), cfg.intensity)
                -- sin-wave RGB with 120° phase offsets
                local g = SinTo01(math.sin(cfg.phaseT + twopi / 3), cfg.intensity)
                -- sin-wave RGB with 120° phase offsets
                local b = SinTo01(math.sin(cfg.phaseT + (2 * twopi) / 3), cfg.intensity)

          -- Apply (swap this for your real API if needed)
                SetColor({ Id = id, Color = { r, g, b, cfg.alpha } })
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
    rgbtext.Active[textId] = nil
end

