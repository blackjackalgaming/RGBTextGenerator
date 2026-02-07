mod.RGBTextGenerator = mod.RGBTextGenerator or {
  Active = {},   -- [textId] = cfg
  Running = false,
}

local rgbtext = mod.RGBTextGenerator
local active = rgbtext.Active
local twopi = math.pi * 2

local function RGBClamp01(x)
  x = tonumber(x) or 0
  if x <= 0 then return 0 end
  if x >= 1 then return 1 end
  return x
end

local function SinTo01(scaleswing, intensity)
  intensity = RGBClamp01(intensity)
  return 0.5 + (intensity * scaleswing)
end

local function SetColorSafe(id, col)
  -- Centralize in case you later want safety checks
  SetColor({ Id = id, Color = col })
end

local function StartRgbThreadIfNeeded()
  if rgbtext.Running then
    return
  end

  rgbtext.Running = true

  thread(function()
    local frameTime = 0.03

    while true do
      -- Stop if nothing left to animate
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
        -- HARD STOP per entry (TTL)
        if cfg.expiresAt and now >= cfg.expiresAt then
          -- restore vanilla/base color
          if cfg.baseColor then
            SetColorSafe(id, cfg.baseColor)
          end
          active[id] = nil
        else
          -- animate
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
  if not textId then return end
  opts = opts or {}

  local ttl = tonumber(opts.ttl) or 180 -- seconds; adjust default
  if ttl < 0 then ttl = 0 end

  local alpha = tonumber(opts.alpha) or 1.0

  active[textId] = {
    phaseT = tonumber(opts.phaseT or opts.phase) or 0.0,
    speed = tonumber(opts.speed) or 0.8,
    alpha = alpha,
    intensity = tonumber(opts.intensity) or 0.45,

    -- IMPORTANT: this is what we revert to when stopping
    baseColor = opts.baseColor or opts.vanillaColor, -- {r,g,b,a}

    -- expiry
    expiresAt = (ttl == 0) and os.clock() or (os.clock() + ttl),
  }

  StartRgbThreadIfNeeded()
end

function mod.RGBTextGenerator.Unregister(textId)
  if not textId then return end

  local cfg = active[textId]
  if cfg and cfg.baseColor then
    SetColorSafe(textId, cfg.baseColor)
  end

  active[textId] = nil
end

-- Optional: screen-level cleanup
function mod.RGBTextGenerator.UnregisterAll()
  for id, cfg in pairs(active) do
    if cfg.baseColor then
      SetColorSafe(id, cfg.baseColor)
    end
    active[id] = nil
  end
end
