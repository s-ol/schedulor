dir = (...)\gsub "%.[^%.]+$", ""

import build_keyvalue_environment from require dir .. ".dsl"

class Schedule
  new: (@target, schedule) =>
    @curves = {}

    if schedule
      @schedule schedule

  schedule: (schedule) =>
    -- set DSL environment
    build_keyvalue_environment @curves, schedule
    schedule!

    @update 0

  update: (dt) =>
    for k, curve in pairs @curves
      @target[k] = curve\update dt

  eval: (pos) =>
    {k, curve\eval pos for k, curve in pairs @curves}

{
  :Schedule
}
