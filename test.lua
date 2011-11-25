require "luaunit"

local radlib = require "radlib"

TestRadLib = {}
  function TestRadLib:testIoParseJson()
    local book = radlib.io.parseJson( "book.json" )
    print( "TITLE: " .. book.title )
    radlib.table.print( book.pages )
  end

  function TestRadLib:testTableQuoteValues()
    local t = { "lion", "tiger", "leopard" }
    local quoted = radlib.table.quoteValues( t )
    assertEquals( quoted[1], "'lion'")
    assertEquals( quoted[2], "'tiger'")
    assertEquals( quoted[3], "'leopard'")
  end

  function TestRadLib:testTableFindAll()
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
    assertEquals( #females, 2 )
    local femalesOver30 = radlib.table.findAll( females,
      function(object) return(object.age > 30) end
    )
    assertEquals( #femalesOver30, 1 )

    local males = radlib.table.findAll( objects,
      function(object) return("male" == object.gender) end
    )
    assertEquals( #males, 3 )

    local aliens = radlib.table.findAll( objects,
      function(object) return("alien" == object.gender) end
    )
    assertEquals( #aliens, 1 )
  end

LuaUnit:run()
