dir = (...)\gsub "%.[^%.]+$", ""

import build_value_environment from require dir .. ".dsl"
main = require dir

class Curve
  new: (@initial, schedule) =>
    @pos = 0
    @points = {}

    if not schedule
      schedule = @initial
      @initial = 0

    if schedule
      @schedule schedule

  schedule: (schedule) =>
    build_value_environment @, schedule
    schedule!

    @update 0

  cp_at: (t) =>
    for cp in *@points
      if cp.end_time >= t
        return cp

  cp_before: (t, create=false) =>
    if create and not @points[1]
      return @add_cp 0, val: @initial, eval: -> @initial

    if t == 0
      return @points[1] or  @add_cp 0, val: @initial, eval: -> @initial

    for i, cp in ipairs @points
      if cp.end_time >= t
        if i > 1
          return @points[i - 1], 2
        else
          if create
            return @add_cp 0, val: @initial, eval: -> @initial
        return

    return @points[#@points]

  add_cp: (t, new_cp) =>
    new_cp.end_time = t
    for i, cp in ipairs @points
      if cp.end_time > t
        table.insert @points, i, new_cp
        return new_cp
      elseif cp.end_time == t
        @points[i] = new_cp
        return new_cp

    table.insert @points, new_cp
    new_cp

  eval: (t) =>
    last_end = 0
    for cp in *@points
      if cp.end_time >= t
        return cp.eval (t - last_end) / (cp.end_time - last_end)

      last_end = cp.end_time

    if @points[1]
      @points[#@points].val

  update: (dt) =>
    @pos += dt
    @value = @eval @pos
    @value

  -- TODO: bad performance instead of terrible performance
  debug_draw: (max=1, segments=40, width=love.graphics.getWidth!, height=love.graphics.getHeight! / 3) =>
    lg = love.graphics

    return unless @points[1]
    endt = @points[#@points].end_time + .5
    scale = height / max

    lg.push!
    lg.translate 0, height
    lg.scale 1, -1
    lg.line @pos / endt * width, height/6, @pos / endt * width, 5*height/6

    lx, ly = 0, 0
    for t=0,endt,endt/segments
      x, y = lx + width/segments, scale * @eval t
      lg.line lx, ly, x, y
      lx, ly = x, y

    lg.pop!


main.Curve = Curve

{
  :Curve
}
