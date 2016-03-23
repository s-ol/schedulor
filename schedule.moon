--- Schedule-related things
-- @module schedule

dir = (...)\gsub "%.[^%.]+$", ""

import build_keyvalue_environment from require dir .. ".dsl"

--- a schedule for tweening a table
class Schedule
  --- create a new Schedule.  
  -- `target` and `schedule` are both optional
  new: (target, schedule) =>
    @target = target or {}

    @pos = 0
    @curves = {}

    if schedule
      @schedule schedule

  --- schedule using the function `schedule`
  -- @see DSL
  schedule: (schedule) =>
    -- set DSL environment
    build_keyvalue_environment @curves, schedule
    schedule!

    @update 0

  --- evaluate the Schedule at `t` seconds
  eval: (pos) =>
    {k, curve\eval pos for k, curve in pairs @curves}

  --- update the Schedule by `dt` seconds
  update: (dt) =>
    @pos += dt
    for k, curve in pairs @curves
      @target[k] = curve\update dt

{
  :Schedule
}
