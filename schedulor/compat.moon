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

getfenv = getfenv or (fn) ->
  i = 1
  while true
    name, val = debug.getupvalue fn, i
    if name == "_ENV"
      return val
    elseif not name
      break
    i = i + 1

{
  :setfenv,
  :getfenv
}
