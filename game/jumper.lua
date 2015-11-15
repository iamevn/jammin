local P = {} -- Jumper package
if _REQUIREDNAME == nil then
  jumper = P
else
  _G[_REQUIREDNAME] = P
end

--set needed packages as locals here

setfenv(1, P)

Jumper = {
  pxpos = {x=0, y=0},
  pxvel = {x=0, y=0},
  max_jump_h = 63,
  jump_h = 0,
  jump_v = 2,
  standing = false
}

function Jumper:new(posx, posy, velx, vely, mjh, jh, jv, s, o)
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
  if mjh then
    self.max_jump_h = mjh
  end
  if jh then
    self.jump_h = jh
  end
  if jv then
    self.jump_v = jv
  end
  if s then
    self.standing = s
  end
  return o
end

function Jumper:jump()
  if self.standing then
    self.pxvel.y = jump_v
  end
  return self
end

function Jumper:clipWings()
  if self.pxvel.y >= 0 then
    self.pxvel.y = self.pxvel.y * -1
  end
  return self
end

function Jumper:move(dx)
  self.pxvel.x = dx
  return self
end

local function Jumper:fall(dt, level, pxl_ratio)
  newposy = self.pxpos.y + dt*self.pxvel.y

  -- check for jumping too high
  if self.pxvel.y > 0 then
    self.jump_h = self.jump_h + dt*self.pxvel.y
    if self.jump_h >= self.max_jump_h then
      self.pos.y = self.pos.y + dt*self.pxvel.y + self.max_jump_h - self.jump_h
      self.pxvel.y = self.pxvel.y * -1
      self.jump_h = self.max_jump_h
      return self
    end
    self.pos.y = newposy
    return self
  end

  -- if check floor if standing
  if self.standing then
    if not level[self.pxpos.x/pxl_ratio + 1][self.pxpos.y/pxl_ratio + 2] then
      self.pxvel.y = -jump_v
      newposy = self.pxpos.y + dt*self.pxvel.y
      self.standing = false
    end
  end

  --check for landing
  i = self.pxpos.x/pxl_ratio + 1
  for j = self.pxpos.y/pxl_ratio + 2, newposy/pxl_ratio + 1, -1 do
    if level[i][j] then
      self.pxpos.y = (j-1)*pxl_ratio - 1
      self.pxvel.y = 0
      self.standing = true
      self.jump_h = 0
      return self
    end
  end

  --just fall
  self.pxpos.y = newposy
  return self
end

function Jumper:update(dtr, level, pxl_ratio)
  local dt = math.ceil(dtr*100)
  self.pxpos.x += dt*self.pxvel.x
  self.fall(dt, level, pxl_ratio)
  return self
end

return P
