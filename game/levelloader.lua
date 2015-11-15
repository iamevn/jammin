local P = {} -- LevelLoader package
if _REQUIREDNAME == nil then
  levelloader = P
else
  _G[_REQUIREDNAME] = P
end

function P.loadlevel(filename)
  local line, j
  L = {
    start = {},
    goal = {},
    plat = {}
    }

  for i = 1, 48 do
    L.plat[i] = {}
  end

  io.input(filename)
  j = io.read():gmatch("%d+")
  L.start.x, L.start.y = j.next(), j.next()
  j = io.read():gmatch("%d+")
  L.goal.x, L.goal.y = j.next(), j.next()
  j = 0
  while line = io.read() do
    j = j + 1
    for i = 1, 17 do
      if line:(i,i) == "1" then
        L.plat[j][i] = true
      end
    end
  end

  return L

end

return P
