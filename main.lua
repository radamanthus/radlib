--
-- Test harness for RadLib
--
-- Open this entire folder using the Corona simulator from the command line, e.g.:
-- /Applications/CoronaSDK/simulator radlib
-- The test results will be printed on the console
--

local _ = require "underscore"
local radlib = require "radlib"
require "Test.More"

plan(53)

local testCount = 0
local expectedResult = nil
local result = nil

function doTest( result, expectedResult, title )
  if result == nil then
    result = 'nil'
  end
  if expectedResult == nil then
    expectedResult = 'nil'
  end
  local msg = title .. " : " .. tostring(result) .. " should be equal to " .. tostring(expectedResult)
  is( result, expectedResult, msg )
  testCount = testCount + 1
end

------------------------------------------------------------------------------
-- io_ext tests
------------------------------------------------------------------------------
local book = radlib.io.parseJson( "book.json" )
expectedResult = "Slide Show"
result = book.title
doTest( result, expectedResult, "radlib.io.parseJson")

------------------------------------------------------------------------------
-- orm tests
------------------------------------------------------------------------------
orm = require "orm"
db = orm.initialize( nil )
db:exec(
  [[
    CREATE TABLE IF NOT EXISTS "users" (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE ,
      "username" CHAR NOT NULL ,
      "email" CHAR NOT NULL
    );
    INSERT INTO users(id, username, email) VALUES(1, 'alice', 'alice@wonderland.com');
    INSERT INTO users(id, username, email) VALUES(2, 'bob', 'bob@dabuilder.com');
    INSERT INTO users(id, username, email) VALUES(3, 'charlie', 'charlie@chaplin.com');
  ]])

-- selectAll
local users = orm.selectAll('users', {})
doTest( #users, 3, 'orm.selectAll with orderBy = nil' )

local orderedUsers = orm.selectAll( 'users', {order = 'username DESC'} )
doTest( orderedUsers[1].username, 'charlie', 'orm.selectAll with orderBy' )

-- selectWhere
local records = orm.selectWhere( 'users', {where = 'id = 1'} )
doTest( records[1].username, 'alice', 'orm.selectWhere' )
doTest( records[1].email, 'alice@wonderland.com', 'orm.selectWhere with orderBy = nil' )

local orderedUsers = orm.selectWhere( 'users', {where = 'id > 1', order = 'username'} )
doTest( orderedUsers[1].username, 'bob', 'orm.selectWhere with orderBy' )

local records = orm.selectWhere( 'users', {where = 'id > 1'} )
doTest( #records, 2, 'orm.selectWhere' )

local aliceRecords = _.select( records,
  function(record) return('alice' == record.username) end
)
doTest( #aliceRecords, 0, 'orm.selectWhere' )
local bobRecords = _.select( records,
  function(record) return('bob' == record.username) end
)
doTest( #bobRecords, 1, 'orm.selectWhere' )
local charlieRecords = _.select( records,
  function(record) return('charlie' == record.username) end
)
doTest( #charlieRecords, 1, 'orm.selectWhere' )

-- selectOne
local record = orm.selectOne( 'users', 'id', 2 )
doTest( record.username, 'bob', 'orm.selectOne' )

-- getTableRowCount
doTest( 3, orm.getTableRowCount('users'), 'orm.getTableRowCount' )

-- insertRow
local row = {
  id = 4,
  username = 'dennis',
  email = 'dennis@damenace.com'
}
orm.insertRow( 'users', row )
doTest( 4, orm.getTableRowCount('users'), 'orm.insertRow' )
local savedRecord = orm.selectOne( 'users', 'id', 4 )
doTest( savedRecord.username, row.username, 'orm.insertRow' )
doTest( savedRecord.email, row.email, 'orm.insertRow' )

-- updateAll
orm.updateAll( 'users', 'id = id + 100' )
local usersWithUpdatedIDs = orm.selectWhere( 'users', "id > 100" )
doTest( #usersWithUpdatedIDs, 4, 'orm.updateAll' )

-- updateWhere
orm.updateWhere( 'users', 'id = id - 100', 'id > 100' )
usersWithUpdatedIDs = orm.selectWhere( 'users', 'id < 100' )
doTest( #usersWithUpdatedIDs, 4, 'orm.updateWhere' )

-- updateRow
local row = {
  id = 4,
  username = 'newDennis'
}
orm.updateRow( 'users', row )
local savedRecord = orm.selectOne( 'users', 'id', 4 )
doTest( savedRecord.username, row.username, 'orm.updateRow' )

-- createOrUpdate
-- create
local row = {
  id = 5,
  username = 'emo',
  email = 'emo@tcl.com'
}
orm.createOrUpdate( 'users', row )
doTest( 5, orm.getTableRowCount('users'), 'orm.createOrUpdate' )
local savedRecord = orm.selectOne( 'users', 'id', 5 )
doTest( savedRecord.username, row.username, 'orm.createOrUpdate' )
doTest( savedRecord.email, row.email, 'orm.createOrUpdate' )
-- then update
row.username = 'emoUpdated'
row.email = 'emonew@tcl.com'
orm.createOrUpdate( 'users', row )
local savedRecord = orm.selectOne( 'users', 'id', 5 )
doTest( savedRecord.username, row.username, 'orm.createOrUpdate' )
doTest( savedRecord.email, row.email, 'orm.createOrUpdate' )

-- updateAttribute
local newEmailAddress = 'bob@newaddress.com'
orm.updateAttribute( 'users', 'id = 2', 'email', newEmailAddress )
local updatedRecord = orm.selectOne( 'users', 'id', 2 )
doTest( updatedRecord.email, newEmailAddress, 'orm.updateAttribute' )

-- updateAttributes
local newUsername = 'calvin'
local newEmailAddress = 'calvin@hobbes.com'
orm.updateAttributes( 'users', 'id = 3', {'username', 'email'}, {newUsername, newEmailAddress})
local updatedRecord = orm.selectOne( 'users', 'id', 3 )
doTest( updatedRecord.username, newUsername, 'orm.updateAttributes' )
doTest( updatedRecord.email, newEmailAddress, 'orm.updateAttributes' )

------------------------------------------------------------------------------
-- sql tests
------------------------------------------------------------------------------
local sql = require 'sql'

-- sql.generateCreateTable
local tableName = 'users'
local tableFields = {
  id = {
    dataType = 'integer',
    flags = {'not null', 'primary key', 'autoincrement'}
  },
  username = {
    dataType = 'char', flags = {'not null', 'unique'}
  },
  email = {
    dataType = 'char', flags = {'not null', 'unique'}
  }
}
local createSql = sql.generateCreateTable( tableName, tableFields )
doTest(
  string.find(createSql, 'CREATE TABLE IF NOT EXISTS ' .. tableName) ~= nil,
  true,
  'sql.generateCreateTable'
)

-- sql.generateSelect
local s = nil

s = sql.generateSelect({
  tableName = 'users'
})
doTest( s, 'SELECT * FROM users', 'sql.generateSelect - only tableName param')

s = sql.generateSelect({
  tableName = 'users',
  columns = 'id, email'
})
doTest( s, 'SELECT id, email FROM users', 'sql.generateSelect with columns param')

s = sql.generateSelect({
  tableName = 'users',
  columns = 'id, email',
  where = 'id > 100'
})
doTest( s, 'SELECT id, email FROM users WHERE id > 100', 'sql.generateSelect with columns and where param')

s = sql.generateSelect({
  tableName = 'users',
  order = 'id DESC'
})
doTest( s, 'SELECT * FROM users ORDER BY id DESC', 'sql.generateSelect with order param')

s = sql.generateSelect({
  tableName = 'users',
  limit = 1
})
doTest( s, 'SELECT * FROM users LIMIT 1', 'sql.generateSelect with limit param')

------------------------------------------------------------------------------
-- active_record tests
------------------------------------------------------------------------------
require 'user'

-- ActiveRecord.static:count
doTest( 5, User.static:count(), 'ActiveRecord.static:count' )

-- ActiveRecord.static:find
local a = User.static:find(User, 3)
doTest( a.email, 'calvin@hobbes.com', 'ActiveRecord.static:find' )

-- ActiveRecord.static:findAll with no filter
local allUsers = User.static:findAll( User, nil )
doTest( #allUsers, 5, 'ActiveRecord.static:findAll(nil)' )

-- ActiveRecord.static:findAll with filter
local filteredUsers = User.static:findAll( User, {where = 'id > 3'})
doTest( #filteredUsers, 2, 'ActiveRecord.static:findAll(<where_filter>)' )

-- ActiveRecord.static:updateAttribute
local updatedEmail = 'newcalvinemail@hobbes.com'
a:updateAttribute( 'email', updatedEmail )
local a2 = User.static:find(User, 3)
doTest( a2.email, updatedEmail, 'ActiveRecord.static:updateAttribute' )

-- ActiveRecord:reload()
a:reload()
doTest( a.email, updatedEmail, 'ActiveRecord:reload')

-- ActiveRecord:save()
local newEmail = 'reallylatestemail@asdf.com'
a = User.static:find(User, 3)
a.email = newEmail
a:save()
a:reload()
doTest( a.email, newEmail, 'ActiveRecord:save - update an existing record' )

local c = User:new({})
local expectedEmail = 'c@asdf.com'
c.id = 101
c.email = expectedEmail
c:save()
c:reload()
doTest( c.email, expectedEmail, 'ActiveRecord:save - insert a new record' )




orm.close()

------------------------------------------------------------------------------
-- string_ext tests
------------------------------------------------------------------------------
expectedResult = '"The quick brown fox"'
result = radlib.string.doubleQuote('The quick brown fox')
doTest( result, expectedResult, "radlib.string.doubleQuote" )

expectedResult = "'The quick brown fox'"
result = radlib.string.singleQuote("The quick brown fox")
doTest( result, expectedResult, "radlib.string.singleQuote")

------------------------------------------------------------------------------
-- table_ext tests
------------------------------------------------------------------------------

local t = { "lion", "tiger", "leopard" }
local quoted = radlib.table.quoteValues( t )
doTest( quoted[1], "'lion'", "radlib.table.quoteValues" )
doTest( quoted[2], "'tiger'", "radlib.table.quoteValues" )
doTest( quoted[3], "'leopard'", "radlib.table.quoteValues" )

local objects = {
  { name = "Alice", gender = "female", age = 20 },
  { name = "Bob", gender = "male", age = 25 },
  { name = "Carlos", gender = "alien", age = 70 },
  { name = "Donna", gender = "female", age = 37 },
  { name = "Rad", gender = "male", age = 36 },
  { name = "Walter", gender = "male", age = 30 }
}

local females = _.select( objects,
   function(object) return("female" == object.gender) end
)
doTest( #females, 2, "_.select" )

local femalesOver30 = _.select( females,
  function(object) return(object.age > 30) end
)
doTest( #femalesOver30, 1, "_.select" )

local males = _.select( objects,
  function(object) return("male" == object.gender) end
)
doTest( #males, 3, "_.select" )

local aliens = _.select( objects,
  function(object) return("alien" == object.gender) end
)
doTest( #aliens, 1, "_.select" )

------------------------------------------------------------------------------
-- time_ext tests
------------------------------------------------------------------------------
expectedResult = "01:00:00"
result = radlib.time.formatTimeDuration( 3600 )
doTest( result, expectedResult, "radlib.time.formatTimeDuration" )

expectedResult = "00:01:00"
result = radlib.time.formatTimeDuration( 60 )
doTest( result, expectedResult, "radlib.time.formatTimeDuration" )

expectedResult = "00:00:01"
result = radlib.time.formatTimeDuration( 1 )
doTest( result, expectedResult, "radlib.time.formatTimeDuration" )

expectedResult = "01:01:01"
result = radlib.time.formatTimeDuration( 3661 )
doTest( result, expectedResult, "radlib.time.formatTimeDuration" )

done_testing(testCount)
