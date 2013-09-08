describe("String Functions", function()
  local stringExt = require("string_ext")
  it("doubleQuote", function()
    local inputStr = "Original string"
    local expectedOutput = "\"Original string\""
    assert.are.same( expectedOutput, stringExt.doubleQuote(inputStr) )
  end)

  it("toSqlString - input without quotes", function()
    local inputStr = "dog"
    local expectedOutput = "'dog'"
    assert.are.same( expectedOutput, stringExt.toSqlString(inputStr) )
  end)

  it("toSqlString - input with quotes inside", function()
    local inputStr = "dog's day out"
    local expectedOutput = "'dog'''s day out'"
    assert.are.same( expectedOutput, stringExt.toSqlString(inputStr) )
  end)

end)
