describe "Curve", ->
  export check_eval, check_iter, check
  check_eval = (curve, expected) ->
    for time, value in pairs expected
      assert.near value, curve\eval(time), .0001

  check_iter = (curve, expected) ->
    last_time = 0
    for time, value in pairs expected
      assert.near value, curve\update(time - last_time), .0001
      last_time = time

  check = (...) ->
    check_eval ...
    check_iter ...

  setup ->
    export *
    import Curve from require "schedulor.curve"
    sequences = require "schedulor.sequences"

  it "is instantiable", ->
    local curve
    assert.has_no_errors ->
      curve = Curve!

    assert.is_table curve

  it "can be updated frame-by-frame", ->
    curve = Curve!

    assert.is_function curve.update
    assert.has_no_errors ->
      curve\update 0.2
      curve\update 0.3

  it "can be evaluated at a specific point", ->
    curve = Curve!

    assert.is_function curve.eval
    assert.has_no_errors ->
      curve\eval 0
      curve\eval 1

  describe "supports an #API which", ->
    it "allows adding control points", ->
      curve = Curve!

      assert.is_function curve.add_cp
      assert.has_no_errors ->
        curve\add_cp 1, val: 1, eval: (i) -> i

      assert.equal 0.5, (curve\eval 0.5)

    it "inserts at the right spot", ->
      curve = Curve!
      curve\add_cp 1, val: 1, eval: (i) -> 0
      curve\add_cp 3, val: 3, eval: (i) -> 3
      curve\add_cp 2, val: 2, eval: (i) -> 2
      curve\add_cp 0, val: 0, eval: (i) -> 0
      curve\add_cp 4, val: 4, eval: (i) -> 4

      check curve, [0]: 0, 1, 2, 3, 4

    it "replaces control points with the same time", ->
      curve = Curve!
      curve\add_cp 1, val: 0, eval: (i) -> 1
      curve\add_cp 1, val: 1, eval: (i) -> 2

      assert.equal 2, (curve\eval 0.5)
      assert.equal 2, (curve\eval 1)

    it "returns the inserted control point", ->
      curve = Curve!

      cp = val: 1, eval: -> 1
      assert.equal cp, (curve\add_cp 2, cp)

    it "can find control points", ->
      curve = Curve!

      assert.is_function curve.cp_at

      assert.is_nil (curve\cp_at 0)
      assert.is_nil (curve\cp_at 1)

      one = val: 1, eval: (i) -> i
      curve\add_cp 0, one

      assert.equal one, (curve\cp_at 0)
      assert.is_nil     (curve\cp_at 0.5)

      two = val: 1, eval: (i) -> i
      curve\add_cp 1, two

      assert.equals one, (curve\cp_at 0)
      assert.equals two, (curve\cp_at 0.5)
      assert.equals two, (curve\cp_at 1)
      assert.is_nil      (curve\cp_at 1.5)

    it "can find the previous point", ->
      curve = Curve!

      assert.is_function curve.cp_before

      assert.is_nil (curve\cp_before 2)

      one = val: 2, eval: -> 2
      curve\add_cp 1, one
 
      assert.equal one, (curve\cp_before 2)
      assert.is_nil     (curve\cp_before 1)

    it "can create the previous point if it doesn't exist", ->
      curve = Curve!

      assert.is_nil (curve\cp_before 1)

      two = curve\cp_before 1, true

      assert.is_table two
      assert.equal two, (curve\cp_before 1)
      assert.equal 0, two.end_time

    it "uses the initial value to create the control point", ->
      curve = Curve 7, ->

      cp = curve\cp_before 1, true

      assert.equal 7, cp.val

  it "exposes the current value", ->
    curve = Curve ->
      set   0, 0
      ease  1, 1

    curve\update 0.1
    assert.equal curve\eval(0.1), curve.value
    curve\update 0.1
    assert.equal curve\eval(0.2), curve.value

  it "returns the current value from update", ->
    curve = Curve ->
      set   0, 2
      ease  1, 1

    assert.equal curve\update(0.1), (curve\eval 0.1)
    assert.equal curve\update(0.1), (curve\eval 0.2)

  describe "supports a #DSL", ->
    it "which can be programmed with a schedule function", ->
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

    it "which supports set, untl, jump and stay", ->
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

    it "which doesn't care in what order the scheduling happens", ->
      calls = {
        { _: "set",   0, 0 },
        { _: "ease",  4, 1 },
        { _: "ease",  2, 3 },
        { _: "untl",  3, 0 },
        { _: "set",   1, 2 },
        { _: "untl",  7, 1 },
        { _: "jump",  6, 9 },
        { _: "stay",  5    }
      }

      orig = Curve ->
        for c in *calls do
          _ENV[c._] unpack c

      for n=1,4
        -- rotate by three
        calls = {(i+2)%8 + 1, v for i, v in ipairs calls}

        rotated = Curve ->
          for c in *calls
            _ENV[c._] unpack c

        for i=0, 7, .4
          assert.equal orig\eval(i), (rotated\eval i)

    it "which allows overriding earlier scheduling though", ->
      curve = Curve ->
        set   0, 0
        ease .5, 8
        ease  1, 1
        ease  2, 2
        ease  3, 3

        untl .3, 3
        set   2, 0
        untl  3, 1

      check curve,
        [0]: 0,
        [.2]: 3, [.3]: 3
        [.5]: 8
        [1]: 1
        [2]: 0
        [2.5]: 1, [3]: 1
        [4]: 1

    describe "with easing which", ->
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
          assert.equal b\eval(i), (a\eval i)

  it "has a debug draw method", ->
    curve = Curve!

    assert.is_function curve.debug_draw
