--- the sequences available for the `DSL`.
-- @module sequences

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
}

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
      f = easing_methods.linear

    if "string" == type f
      if not easing_methods[f]
        error "no such easing method: #{f}"
      f = easing_methods[f]

    curve\add_cp time, val: value, eval: (t) ->
      prev, new = curve\cp_before time, true
      delta = value - prev.val
      prev.val + delta * f t
}

--- alias for `jump`
-- @param time
-- @param value
-- @function set
sequences.set = sequences.jump

for name, method in pairs easing_methods
  sequences[name] = (curve, time, value) ->
    sequences.ease curve, time, method, value

sequences
