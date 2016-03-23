--- Loop-related things
-- @module loop

dir = (...)\gsub "%.[^%.]+$", ""

import build_keyvalue_environment from require dir .. ".dsl"
import Schedule from require dir .. ".schedule"

--- a curve mapping a value over time
class Loop extends Schedule
  --- create a new Loop.  
  -- `target` and `schedule` are both optional
  new: (length, target, schedule) =>
    @length = length
    @target = target or {}
    @schedule = schedule or ->

    @pos = 0
    @loops = 0
    @curves = {}

    build_keyvalue_environment @curves, @schedule
    @schedule!

  --- return the Control Point at `t` seconds
  cp_at: (t) =>
    super t % @length
    for cp in *@points
      if cp.end_time >= t
        return cp

  --- return the last Control Point before `t` seconds
  -- may create a Control Point if `create` is true
  cp_before: (t, create=false) =>
    super t % @length, create

  --- add a Control Point at `t` seconds
  -- `new_cp` is a table containing `val` (reference value for next CP) and `eval` (returns value for input in range 0-1)
  add_cp: (t, new_cp) =>
    super t % @length, new_cp

  --- evaluate the Loop at `t` seconds
  eval: (t) =>
    super t % @length

  --- update the Loop by `dt` seconds
  update: (dt) =>
    if @pos + dt >= @length
      @pos -= @length
      for k, curve in pairs @curves
        curve.pos -= @length

      @loops += 1
      @schedule!

    super dt

{
  :Loop
}
