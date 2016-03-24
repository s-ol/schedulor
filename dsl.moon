---
-- the DSL is used in two different modes:
--
-- `value` mode
-- ------------
-- (`build_value_environment`, as used by `curve.Curve`)
-- in this mode calls take a single number value as their last parameter,
-- which is passed to the sequence. For example:
--
--     Curve(function ()
--       set (0, 3)
--       untl(4, 7)
--       ease(5, 4)
--     end)
--
-- `key-value` mode
-- ------------
-- (`build_keyvalue_environment`, as used by `schedule.Schedule`)
-- in this mode calls take a key -> value mapped table as their last parameter,
-- the values of which are passed to the sequence on the `curve.Curve` corresponding
-- to the `key`:
--
--     Curve(function ()
--       set (0, {a = 3})
--       untl(4, {a = 7})
--       ease(5, {a = 4})
--     end)
--
-- the available functions are the ones documented in `sequences`.
-- @module DSL

dir = (...)\gsub "%.[^%.]+$", ""

import unpack, setfenv, getfenv from require dir .. ".compat"
sequences = require dir .. ".sequences"
main      = require dir

--- build a functon environment with all sequences
-- @see sequences
build_value_environment = (curve, schedule) ->
  convert = (func) ->
    (...) ->
      func curve, ...

  env = {name, convert f for name, f in pairs sequences}
  setfenv schedule, setmetatable env, __index: getfenv schedule

--- build a function environment that runs key-value
-- @see sequences
build_keyvalue_environment = (curves, schedule, curve_class) ->
  convert = (func) ->
    (...) ->
      args = {...}
      if #args > 1
        for name, value in pairs args[#args]
          args[#args] = value
          curves[name] = curve_class! unless curves[name]
          func curves[name], unpack args
      else
        error "invalid arguments"
        for name, curve in pairs curves
          func curve, unpack args

  env = {name, convert f for name, f in pairs sequences}
  setfenv schedule, setmetatable env, __index: getfenv schedule

{
  :build_value_environment,
  :build_keyvalue_environment
}
