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

  --- return the Control Point at `t` (normalized)
  cp_at: (t) =>
    super t % 1
    for cp in *@points
      if cp.end_time >= t
        return cp

  --- return the last Control Point before `t` (normalized)  
  -- may create a Control Point if `create` is true
  cp_before: (t, create=false) =>
    super t % 1, create

  --- add a Control Point at `t` (normalized)  
  -- `new_cp` is a table containing `val` (reference value for next CP) and `eval` (returns value for input in range 0-1)
  add_cp: (t, new_cp) =>
    super t % 1, new_cp

  --- evaluate the Loop at `t` seconds
  eval: (t) =>
    super (t / @length) % 1

  --- update the Loop by `dt` seconds
  update: (dt) =>
    dt = dt / @length
    if @pos + dt >= 1
      @pos -= 1
      for k, curve in pairs @curves
        curve.pos -= 1

      @loops += 1
      @schedule!

    super dt

{
  :Loop
}
