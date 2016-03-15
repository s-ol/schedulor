describe "Curve", ->
  export check_eval, check_iter, check
  check_eval = (curve, expected) ->
    for time, value in pairs expected
      assert.equal value, curve\eval(time)

  check_iter = (curve, expected) ->
    last_time = 0
    for time, value in pairs expected
      assert.equal value, curve\update(last_time - time)
      last_time = time

  check = (...) ->
    check_eval ...
    check_iter ...

  setup ->
    export ^
    import Curve from require "schedulor.curve"

  it "is instantiable", ->
    local curve
    assert.has_no.errors ->
      curve = Curve ->

    assert.is_not_nil curve

  it "can be updated frame-by-frame", ->
    curve = Curve ->
    assert.has_no.errors ->
      curve\update 0.2
      curve\update 0.3

  it "can be evaluated at a specific point", ->
    curve = Curve ->
      set   0, 0
      ease  1, 1

    assert.has_no.errors ->
      assert.equal 0, curve\eval 0
      assert.equal 1, curve\eval 1

  it "exposes the current value", ->
    curve = Curve ->
      set   0, 0
      ease  1, 1

    curve\update 0.1
    assert.equal curve.value, curve\eval 0.1
    curve\update 0.1
    assert.equal curve.value, curve\eval 0.2

  it "returns the current value from update", ->
    curve = Curve ->
      set   0, 2
      ease  1, 1

    assert.equal curve\update(0.1), curve\eval 0.1
    assert.equal curve\update(0.1), curve\eval 0.2

  it "can be programmed with a schedule function", ->
    curve = Curve ->
      set   0, 0
      ease  1, 1
      ease  2, 3
      untl  3, 0

    check curve,
      [0.5]: 0.5
      [  1]: 1
      [1.5]: 2
      [  2]: 3
      [2.1]: 0
      [  3]: 0
      [  9]: 0

  it "supports set, untl, jump and stay", ->
    curve = Curve ->
      set   0, 0
      set   1, 2
      untl  2, 1
      jump  3, 9
      stay  4
      untl  5, 0

    check curve,
      [0]: 0, [0.5]: 0  -- set
      [1]: 2,           -- set
      [1.5]: 1, [2]: 1  -- untl
      [2.5]: 1, [3]: 9  -- jump
      [3.5]: 9, [4]: 9  -- stay
      [4.5]: 0, [5]: 0  -- untl
      [7]: 0

  it "has a debug draw method", ->
    curve = Curve ->

    assert.equal "function", type(curve.debug_draw)

  describe "easing", ->
    it "supports multiple interpolation methods", ->
      curve = Curve ->
        set   0, 0
        ease  1, "linear",  1
        ease  2, "quad",    2
        ease  3, "cubic",   1

      -- TODO: test

    it "provides shorthands for these methods", ->
      curve = Curve ->
        set     0, 0
        linear  1, 1
        quad    2, 2
        cubic   3, 1

      -- TODO: test

    it "uses linear by default", ->
      a = Curve ->
        set   0, 0
        ease  1, 1

      b = Curve ->
        set     0, 0
        linear  1, 1

      for i=0, 1, .2
        assert.equal b\eval(i), a\eval i
