dir = (...)\gsub "%.[^%.]+$", ""

import setfenv, getfenv from require dir .. ".compat"
main = require dir
-- import Curve            from require dir .. ".curve"
sequences = require dir .. ".sequences"

build_value_environment = (curve, schedule) ->
  convert = (func) ->
    (...) ->
      func curve, ...

  env = {name, convert f for name, f in pairs sequences}
  setfenv schedule, setmetatable env, __index: getfenv schedule

build_keyvalue_environment = (curves, schedule) ->
  convert = (func) ->
    (...) ->
      args = {...}
      if #args > 1
        for name, value in pairs args[#args]
          args[#args] = value
          curves[name] = main.curve.Curve! unless curves[name]
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
