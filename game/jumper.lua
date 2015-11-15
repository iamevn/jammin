local P = {} -- Jumper package
if _REQUIREDNAME == nil then
  jumper = P
else
  _G[_REQUIREDNAME] = P
end

--set needed packages as locals here

-- setfenv(1, P)

P.Jumper = {
  pxpos = {x = 0, y = 0},
  pxvel = {x = 0, y = 0},
  max_jump_h = 45,
  jump_h = 0,
  jump_v = -1,
  standing = true
}

function P.Jumper:new(posx, posy, velx, vely, mjh, jh, jv, s, o)
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

function P.Jumper:jump(jv)
  if self.standing then
    self.pxvel.y = jv
    self.standing = false
  end
  return self
end

function P.Jumper:clipWings()
  if self.pxvel.y >= 0 then
    self.pxvel.y = self.pxvel.y * -1
  end
  return self
end

function P.Jumper:move(dx)
  self.pxvel.x = dx
  return self
end

function P.Jumper:fall(dt, level, pxl_ratio)
  local newposy = self.pxpos.y + (self.pxvel.y)*dt

  -- check for jumping too high
  if self.pxvel.y < 0 then
    self.jump_h = self.jump_h - dt*self.pxvel.y
    if self.jump_h >= self.max_jump_h then
      self.pxpos.y = self.pxpos.y - (dt*self.pxvel.y + self.max_jump_h - self.jump_h)
      self.pxvel.y = self.pxvel.y * -1
      self.jump_h = self.max_jump_h
      return self
    end
    self.pxpos.y = newposy
    return self
  end

  -- if check floor if standing
  if self.standing then
    if level[math.ceil(self.pxpos.y/pxl_ratio) + 1] then
      if not level[math.ceil(self.pxpos.y/pxl_ratio) + 1][math.ceil(self.pxpos.x/pxl_ratio)] then
        self:jump(-(self.jump_v))
        newposy = self.pxpos.y + dt*self.pxvel.y
      end
    end
  end

  --check for landing
  i = math.ceil(self.pxpos.x/pxl_ratio)
  print("landing check: " .. i .. ", " .. (math.ceil(self.pxpos.y/pxl_ratio) + 1) .. ":" .. (math.ceil(newposy/pxl_ratio)))
  for j = (math.ceil(self.pxpos.y/pxl_ratio) + 1), (math.ceil(newposy/pxl_ratio)) do
    print("checking: " .. i .. ", " .. j)
    if level[j] then
      if level[j][i] then
        self.pxpos.y = (j-1)*pxl_ratio - 1
        self.pxvel.y = 0
        self.standing = true
        self.jump_h = 0
        print("landed")
        return self
      end
    end
  end

  --just fall
  self.pxpos.y = newposy
  return self
end

function P.Jumper:update(dtr, level, pxl_ratio)
  local dt = math.ceil(dtr*100)
  self.pxpos.x = self.pxpos.x + dt*self.pxvel.x
  self:fall(dt, level, pxl_ratio)
  return self
end

function P.Jumper:print(px_r)
  if px_r then
    return string.format("pos (%d, %d), vel (%d, %d), jump_h %d", math.ceil(self.pxpos.x/px_r), math.ceil(self.pxpos.y/px_r), self.pxvel.x, self.pxvel.y, self.jump_h, self.jump_v)
  else
    return string.format("pos (%d, %d), vel (%d, %d), jump_h %d", self.pxpos.x, self.pxpos.y, self.pxvel.x, self.pxvel.y, self.jump_h, self.jump_v)
  end
end

return P
