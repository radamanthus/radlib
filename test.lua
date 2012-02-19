require 'middleclass'

Point = class('Point')
function Point:initialize(x,y)
  self.x = x
  self.y = y
end
function Point:__tostring()
  return 'Point: [' .. tostring(self.x) .. ', ' .. tostring(self.y) .. ']'
end

p1 = Point(100, 200)
p2 = Point(35, -10)
print(p1)
print(p2)

ActiveRecord = class('ActiveRecord')
function ActiveRecord.static:getCount()
  print("SELECT COUNT(*) FROM " .. self.tableName)
end

function ActiveRecord.static:find(klass, id)
  --local record = orm.selectOne(self.tableName, 'id', id)
  local record = {id = id, name = 'rabbit'}
  local result = klass:new(record)
  return result
end

function ActiveRecord:printName(params)
  print("Name: " .. self.name)
end



User = class('User', ActiveRecord)
User.static.tableName = 'users'
function User:initialize(u)
  for k,v in pairs(u) do
    self[k] = v
  end
  --self.id = u.id
  --self.name = u.name
end

Animal = class('Animal', ActiveRecord)
Animal.static.tableName = 'animals'

print('User tablename: ' .. User.tableName)
User.static:getCount()
print('Animal tablename: ' .. Animal.tableName)
Animal.static:getCount()

local u = User:new({id = 1, name = 'rabbit'})
print("id: " .. u.id)
print("name: " .. u.name)
u:printName()

u1 = User.static:find(User, 1)
print("CLASS OF u1: " .. u1.class.name)
a1 = Animal.static:find(Animal, 1)
print("CLASS OF a1: " .. a1.class.name)
