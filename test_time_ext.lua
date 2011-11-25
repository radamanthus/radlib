require "luaunit"

local time_ext = require "time_ext"

TestTimeExt = {}

  function TestTimeExt:testFormatTimeDuration()
    local expectedResult = "01:00:00"
    local result = time_ext.formatTimeDuration( 3600 )
    assertEquals( result, expectedResult )

    expectedResult = "00:01:00"
    result = time_ext.formatTimeDuration( 60 )
    assertEquals( result, expectedResult )

    expectedResult = "00:00:01"
    result = time_ext.formatTimeDuration( 1 )
    assertEquals( result, expectedResult )

    expectedResult = "01:01:01"
    result = time_ext.formatTimeDuration( 3661 )
    assertEquals( result, expectedResult )
  end

LuaUnit:run()
