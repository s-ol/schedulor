Curve = function ()
  return setmetatable({}, {__index=function() return function() return 0 end end })
end

return {Curve=Curve}
