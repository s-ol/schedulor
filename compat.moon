--- a lua version compatibility layer
-- @module compat

--- set the function `fn`s execution environment to `env`
-- implementation for Lua 5.1 and above
-- @param fn the function
-- @param env the environment
setfenv = setfenv or (fn, env) ->
  i = 1
  while true
    name = debug.getupvalue fn, i
    if name == "_ENV"
      debug.upvaluejoin fn, i, (->
        env
      ), 1
      break
    elseif not name
      break
    i = i + 1
  fn

--- get `fn`s execution environment
-- @param fn the function
-- @return the environment table
getfenv = getfenv or (fn) ->
  i = 1
  while true
    name, val = debug.getupvalue fn, i
    if name == "_ENV"
      return val
    elseif not name
      break
    i = i + 1

--- unpack a table
-- @param tbl the table to unpack
-- @return the integer-indexed values in `tbl`
unpack = unpack or table.unpack

{
  :setfenv,
  :getfenv,
  :unpack
}
