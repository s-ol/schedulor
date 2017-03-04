rgb2hsl = (r, g, b, a=255) ->
  r, g, b = r / 255, g / 255, b / 255
  local h, s, l

  max, min = math.max(r, g, b), math.min(r, g, b)
  l = (max + min) / 2

  if max == min
    h, s = 0, 0 -- achromatic
  else
    d = max - min
    s = if l > 0.5 then d / (2 - max - min) else d / (max + min)
    if max == r then
      h = (g - b) / d
      h += 6 if g < b
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    h = h / 6

  h, s, l, a

hue2rgb = (p, q, t) ->
  t += 1 if t < 0
  t -= 1 if t > 1

  if t < 1/6 then p + (q - p) * 6 * t
  elseif t < 1/2 then q
  elseif t < 2/3 then p + (q - p) * (2/3 - t) * 6
  else p

hsl2rgb = (h, s, l, a=1) ->
  local r, g, b

  if s == 0
    r, g, b = l, l, l -- achromatic
  else
    local q
    if l < 0.5
      q = (l * (1 + s))
    else
      q = l + s - l * s
    p = 2 * l - q

    r = hue2rgb p, q, h + 1/3
    g = hue2rgb p, q, h
    b = hue2rgb p, q, h - 1/3

  r * 255, g * 255, b * 255, a * 255

{
  :rgb2hsl,
  :hsl2rgb
}
