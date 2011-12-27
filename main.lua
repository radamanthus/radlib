--
-- Test harness for RadLib
--
-- Open this entire folder using the Corona simulator from the command line, e.g.:
-- /Applications/CoronaSDK/simulator radlib
-- The test results will be printed on the console
--

local radlib = require "radlib"
require "Test.More"

plan(14)

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
-- string_ext tests
------------------------------------------------------------------------------
expectedResult = '"The quick brown fox"'
result = radlib.string.doublequote('The quick brown fox')
doTest( result, expectedResult, "radlib.string.doubleQuote" )

expectedResult = "'The quick brown fox'"
result = radlib.string.singlequote("The quick brown fox")
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
