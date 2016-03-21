dir = (...)\gsub "%.init$", ""

req = (key) ->
  require "#{dir}.#{key}"

setmetatable {}, __index: (key) =>
  ok, mod = pcall req, key

  if ok
    rawset @, key, mod
    mod
