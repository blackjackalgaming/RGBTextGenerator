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
chalk = mods['SGG_Modding-Chalk']
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

mod.RGBTextGenerator = mod.RGBTextGenerator or {
    Active = {}, -- [textId] = cfg
    Running = false,
}

local rgbtext = mod.RGBTextGenerator
local active = rgbtext.Active
local twopi = math.pi * 2

local function RGBClamp01(x)
    x = tonumber(x) or 0
    if x <= 0 then
        return 0
    end
    if x >= 1 then
        return 1
    end
    return x
end

local function NormalizeColor(col)
    if type(col) ~= 'table' then
        return nil
    end

    local r = tonumber(col[1]) or 0
    local g = tonumber(col[2]) or 0
    local b = tonumber(col[3]) or 0
    local a = tonumber(col[4])

    if a == nil then
        a = 255
    end

    if r > 1 or g > 1 or b > 1 or a > 1 then
        return { r / 255, g / 255, b / 255, a / 255 }
    end

    return { r, g, b, a }
end

local function SinTo01(scaleSwing, intensity)
    intensity = RGBClamp01(intensity)
    return 0.5 + (intensity * scaleSwing)
end

local function SetColorSafe(id, color)
    SetColor({ Id = id, Color = color })
end

local function StartRgbThreadIfNeeded()
    if rgbtext.Running then
        return
    end

    rgbtext.Running = true

    thread(function()
        local frameTime = 0.03

        while true do
            local hasAny = false
            for _ in pairs(active) do
                hasAny = true
                break
            end

            if not hasAny then
                rgbtext.Running = false
                return
            end

            local now = os.clock()
            for id, cfg in pairs(active) do
                if cfg.expiresAt and now >= cfg.expiresAt then
                    if cfg.baseColor then
                        SetColorSafe(id, cfg.baseColor)
                    end
                    active[id] = nil
                else
                    cfg.phaseT = (cfg.phaseT or 0) + (cfg.speed * frameTime)
                    if cfg.phaseT >= twopi then
                        cfg.phaseT = cfg.phaseT - twopi
                    end

                    local r = SinTo01(math.sin(cfg.phaseT), cfg.intensity)
                    local g = SinTo01(math.sin(cfg.phaseT + twopi / 3), cfg.intensity)
                    local b = SinTo01(math.sin(cfg.phaseT + (2 * twopi) / 3), cfg.intensity)

                    SetColorSafe(id, { r, g, b, cfg.alpha })
                end
            end

            wait(frameTime)
        end
    end)
end

-- PUBLIC API
function mod.RGBTextGenerator.Register(textId, opts)
    if not textId then
        return
    end

    opts = opts or {}

    local ttl = tonumber(opts.ttl) or 180
    if ttl < 0 then
        ttl = 0
    end

    local base = opts.baseColor
    if not base and game and game.Color and opts.baseColorKey and game.Color[opts.baseColorKey] then
        base = game.Color[opts.baseColorKey]
    end

    active[textId] = {
        phaseT = tonumber(opts.phaseT or opts.phase) or 0,
        speed = tonumber(opts.speed) or 0.8,
        alpha = tonumber(opts.alpha) or 1,
        intensity = tonumber(opts.intensity) or 0.45,
        baseColor = NormalizeColor(base),
        expiresAt = (ttl == 0) and os.clock() or (os.clock() + ttl),
    }

    StartRgbThreadIfNeeded()
end

function mod.RGBTextGenerator.Unregister(textId)
    if not textId then
        return
    end

    local cfg = active[textId]
    if cfg and cfg.baseColor then
        SetColorSafe(textId, cfg.baseColor)
    end

    active[textId] = nil
end

function mod.RGBTextGenerator.RegisterPerfect(textId, opts)
    opts = opts or {}
    opts.baseColorKey = opts.baseColorKey or 'BoonPatchPerfect'
    return mod.RGBTextGenerator.Register(textId, opts)
end

local function findRarityTextId(screen)
    if not screen or type(screen.Components) ~= 'table' then
        return nil
    end

    local components = screen.Components
    local candidates = {
        'RarityText',
        'TraitRarity',
        'BoonRarity',
    }

    for _, key in ipairs(candidates) do
        local component = components[key]
        if component and component.Id then
            return component.Id
        end
    end

    return nil
end

modutil.path.Wrap('CreateBoonLootButtons', function(base, screen, lootData, args)
    local result = base(screen, lootData, args)

    local rarityTextId = findRarityTextId(screen)
    if rarityTextId then
        mod.RGBTextGenerator.RegisterPerfect(rarityTextId, { ttl = 180 })
    end

    return result
end, mod)
