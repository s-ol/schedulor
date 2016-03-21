easing_methods = {
  linear: (t) -> t
  quad: (t) -> t * t
  cubic: (t) -> t * t * t
}

sequences = {
  untl: (curve, time, value) ->
    curve\add_cp time, val: value, eval: (t) -> value

  jump: (curve, time, value) ->
    curve\add_cp time, val: value, eval: (t) ->
      if t == 1 then value
      else
        curve\cp_before(time, true).val

  stay: (curve, time) ->
    curve\add_cp time, val: prev_val, eval: (t) ->
      curve\cp_before(time, true).val

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

sequences.set = sequences.jump

for name, method in pairs easing_methods
  sequences[name] = (curve, time, value) ->
    sequences.ease curve, time, method, value

sequences
