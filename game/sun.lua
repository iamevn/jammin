local P = {} -- Person package
if _REQUIREDNAME == nil then
  sun = P
else
  _G[_REQUIREDNAME] = P
end

--set needed packages as locals here

setfenv(1, P)

Sun = {
  pxpos = {x=0, y=0}
  pxvel = {x=0, y=0}
}

function Sun:new(posx, posy, velx, vely, o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  if posx then
    self.pxpos.x = posx
  end
  if posy then
    self.pxpos.y = posy
  end
  if velx then
    self.pxvel.x = velx
  end
  if vely then
    self.pxvel.y = vely
  end
  return o
end

function Sun:movex(dx)
  self.pxvel.x = dx
  return self
end

function Sun:movey(dy)
  self.pxvel.y = dy
  return self
end

function Sun:update(dt)
  pxpos.x += dt*self.pxvel.x
  pxpos.y += dt*self.pxvel.y
  return self
end

return P
