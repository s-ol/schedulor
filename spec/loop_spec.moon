describe "Loop", ->
  export check_eval, check_iter, check
  check_eval      = (sched, expected) ->
    for key, values in pairs expected
      for time, value in pairs values
        assert.near value, sched\eval(time)[key], .001

  check_iter = (sched, expected) ->
    points = {}
    for key, values in pairs expected
      for t, v in pairs values
        points[t] or= {}
        points[t][key] = v

    points = [{:time, :values} for time, values in pairs points]
    table.sort points, (a, b) -> a.time < b.time

    time = 0
    for point in *points
      sched\update (point.time - time)
      for key, value in pairs point.values
        assert.near value, sched.target[key], .001, "#{key} at #{point.time}"
      time = point.time

  check = (...) ->
    check_eval ...
    check_iter ...

  setup ->
    export ^
    import Loop from require "schedulor.loop"

  it "is instantiable", ->
    local loop
    assert.has_no_errors ->
      loop = Loop 3

    assert.is_table loop

  it "exposes the length", ->
    loop = Loop 3

    assert.equal 3, loop.length

  it "exposes the target", ->
    target = {}
    loop = Loop 2, target

    assert.equal target, loop.target

  it "creates a new target table per default", ->
    loop = Loop 2

    assert.is_table loop.target

  it "wraps around with update and eval", ->
    loop = Loop 2, {}, ->
      set  0, key: 0
      ease 1, key: 1

    check loop, key:
      [0]: 0, [1]: 1, [1.5]: 1
      [2]: 0, [3]: 1, [3.5]: 1

