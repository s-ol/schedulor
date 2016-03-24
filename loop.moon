--- Loop-related things
-- @module loop

dir = (...)\gsub "%.[^%.]+$", ""

import build_keyvalue_environment from require dir .. ".dsl"
import Curve    from require dir .. ".curve"
import Schedule from require dir .. ".schedule"

class LoopCurve extends Curve
  --- return the Control Point at `t` (normalized)
  cp_at: (t) =>
    super t % 1

  --- return the last Control Point before `t` (normalized)  
  -- may create a Control Point if `create` is true
  cp_before: (t, create=false) =>
    t = t % 1

    if t == 0 and @points[1]
      return @points[#@points]

    super t, create

  --- add a Control Point at `t` (normalized)  
  -- `new_cp` is a table containing `val` (reference value for next CP) and `eval` (returns value for input in range 0-1)
  add_cp: (t, new_cp) =>
    super t % 1, new_cp

  --- evaluate the Curve at `t` seconds
  eval: (t) =>
    last_end = 0
    for cp in *@points
      if cp.end_time >= t
        if cp.end_time == t
          return cp.eval 1
        return cp.eval (t - last_end) / (cp.end_time - last_end)

      last_end = cp.end_time

    if @points[1]
      last = @points[1]
      before = @points[#@points]
      last.eval (t - before.end_time) / (1 - before.end_time)

  --- debug-draw the Curve on screen (love2d only)  
  -- TODO: bad performance instead of terrible performance
  debug_draw: (max=1, segments=40, width=love.graphics.getWidth!, height=love.graphics.getHeight! / 3) =>
    lg = love.graphics

    return unless @points[1]
    scale = height / max

    lg.push!
    lg.translate 0, height
    lg.scale 1, -1
    lg.line @pos / 1 * width, height/6, @pos / 1 * width, 5*height/6

    lx, ly = 0, scale * @eval 0
    for t=0,1,1/segments
      x, y = lx + width/segments, scale * @eval t
      lg.line lx, ly, x, y
      lx, ly = x, y

    lg.pop!

--- a curve mapping a value over time
class LoopSchedule extends Schedule
  --- create a new Loop.  
  -- `target` and `schedule` are both optional
  new: (length, target, schedule) =>
    @length = length
    @target = target or {}
    @schedule = schedule or ->

    @pos = 0
    @loops = 0
    @curves = {}

    build_keyvalue_environment @curves, @schedule, LoopCurve
    @schedule!

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
  :LoopCurve,
  :LoopSchedule, Loop: LoopSchedule
}
