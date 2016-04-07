--- the sequences available for the `DSL`.
-- @module sequences

dir = (...)\gsub "%.[^%.]+$", ""

import rgb2hsl, hsl2rgb from require dir .. ".color"

easing_methods = {
  --- alias for linear `ease`
  -- @param time
  -- @param value
  linear: (t) -> t

  --- alias for quadracic `ease`
  -- @param time
  -- @param value
  quad: (t) -> t * t

  --- alias for cubic `ease`
  -- @param time
  -- @param value
  cubic: (t) -> t * t * t

  --- alias for sinusoid `ease`
  -- @param time
  -- @param value
  sine: (t) -> 1 - math.cos t * math.pi/2
}

get_easing_method = (name) ->
  one, two = name\match "^(.*)%+(.*)$"
  prefix, postfix = name\match("^(.*)%-([^-]*)$")

  if one
    one = get_easing_method one
    two = get_easing_method two
    (t) ->
      if t < .5
        .5 * one t
      else
        .5 + .5 * two t - .5
  elseif prefix
    method = get_easing_method prefix
    switch postfix
      when "out"
        method
      when "in"
        (t) -> 1 - method 1 - t
      when "inout"
        get_easing_method "#{prefix}-in+#{prefix}-out"
  else
    easing_methods[name]

sequences = {
  --- set to `value`, from the last CP on until `time` seconds
  -- @param time
  -- @param value
  untl: (curve, time, value) ->
    curve\add_cp time, val: value, eval: (t) -> value

  --- leave the last value until `time` seconds, then jump to `value`
  -- @param time
  -- @param value
  jump: (curve, time, value) ->
    curve\add_cp time, val: value, eval: (t) ->
      if t == 1 then value
      else
        curve\cp_before(time, true).val

  --- set an existing Control Points reference value to `value`  
  -- if no CP at `time` acts like `jump`
  -- @param time
  -- @param value
  set: (curve, time, value) ->
    if cp = curve\cp_at time
      cp.val = value
      return cp

    curve\add_cp time, val: value, eval: (t) ->
      if t == 1 then value
      else
        curve\cp_before(time, true).val

  --- stay at the last value until `time`
  -- @param time
  stay: (curve, time) ->
    curve\add_cp time, val: prev_val, eval: (t) ->
      curve\cp_before(time, true).val

  --- ease from the last value to `value` until `time`  
  -- interpolate using the function `f` (or specified easing method)
  -- @param time
  -- @param[opt] method
  -- @param value
  ease: (curve, time, f, value) ->
    if not value
      value = f
      f = "linear"

    if "string" == type f
      f = get_easing_method f

    curve\add_cp time, val: value, eval: (t) ->
      prev = curve\cp_before time, true
      delta = value - prev.val
      prev.val + delta * f t

  --- ease from the last RGB color to `value` until `time`  
  -- interpolate in HSL color-space using the function `f` (or specified easing method)
  -- @param time
  -- @param[opt] method
  -- @param value
  colorease: (curve, time, f, value) ->
    if not value
      value = f
      f = "linear"

    if "string" == type f
      f = get_easing_method f

    th,ts,tv = rgb2hsl unpack value
    curve\add_cp time, val: value, eval: (t) ->
      h,s,v = rgb2hsl unpack curve\cp_before(t, true).val
      dh,ds,dv = th-h, ts-s, tv-v
      t = f t
      { hsl2rgb h + dh * t,
                s + ds * t,
                v + dv * t
      }
}

for name, method in pairs easing_methods
  sequences[name] = (curve, time, value) ->
    sequences.ease curve, time, method, value

sequences
