--
-- Test harness for RadLib
--
-- Open this entire folder using the Corona simulator from the command line, e.g.:
-- /Applications/CoronaSDK/simulator radlib
-- The test results will be printed on the console
--

local radlib = require "radlib"
require "Test.More"

plan(35)

local testCount = 0
local expectedResult = nil
local result = nil

function doTest( result, expectedResult, title )
  local msg = title .. " : " .. result .. " should be equal to " .. expectedResult
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
local orm = require "orm"
local db = orm.initialize( nil )
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
local users = orm.selectAll('users')
doTest( #users, 3, 'orm.selectAll' )

-- selectWhere
local records = orm.selectWhere( 'users', 'id = 1' )
doTest( records[1].username, 'alice', 'orm.selectWhere' )
doTest( records[1].email, 'alice@wonderland.com', 'orm.selectWhere' )

local records = orm.selectWhere( 'users', 'id > 1' )
doTest( #records, 2, 'orm.selectWhere' )

local aliceRecords = radlib.table.findAll( records,
  function(record) return('alice' == record.username) end
)
doTest( #aliceRecords, 0, 'orm.selectWhere' )
local bobRecords = radlib.table.findAll( records,
  function(record) return('bob' == record.username) end
)
doTest( #bobRecords, 1, 'orm.selectWhere' )
local charlieRecords = radlib.table.findAll( records,
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

local females = radlib.table.findAll( objects,
   function(object) return("female" == object.gender) end
)
doTest( #females, 2, "radlib.table.findAll" )

local femalesOver30 = radlib.table.findAll( females,
  function(object) return(object.age > 30) end
)
doTest( #femalesOver30, 1, "radlib.table.findAll" )

local males = radlib.table.findAll( objects,
  function(object) return("male" == object.gender) end
)
doTest( #males, 3, "radlib.table.findAll" )

local aliens = radlib.table.findAll( objects,
  function(object) return("alien" == object.gender) end
)
doTest( #aliens, 1, "radlib.table.findAll" )

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
