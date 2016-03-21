describe "Schedule", ->
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
    table.sort points, (a, b) -> a.time > b.time

    time = 0
    for point in *points
      sched\update (point.time - time)
      for key, value in pairs point.values
        assert.near value, sched.target[key], .001
      time = point.time

  check = (...) ->
    check_eval ...
    check_iter ...

  setup ->
    export ^
    import Schedule from require "schedulor.schedule"

  it "is instantiable", ->
    local schedule
    assert.has_no_errors ->
      schedule = Schedule {}

    assert.is_table schedule

  it "exposes the target", ->
    target = {}
    schedule = Schedule target

    assert.equal target, schedule.target

  describe "has a #DSL", ->
    it "which can be programmed with a schedule function", ->
      sched = Schedule {}, ->
        set 0, key: 0
        set 1, key: 1

      check sched, key:
        [.1]: 0
        [.5]: 0
        [ 1]: 1
        [ 2]: 1

    it "which tracks multiple keys seperately", ->
      sched = Schedule {}, ->
        set   0, a: 0, b: 2
        ease  1, a: 1
        ease  2, a: 2, b: 1

      check sched,
        a:
          [ 0]:  0
          [.5]: .5
          [ 1]:  1
        b:
          [0]: 2
          [1]: 1.5
          [2]: 1

    it "which supports everything Curve does", ->
      -- TODO

  it "has a debug draw method", ->
    schedule = Schedule ->

    assert.is_function schedule.debug_draw
