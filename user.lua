-- This is a sample Lua file that demonstrates how to use active_record
-- You don't need to include this in your app when you use radlib
require 'active_record'
User = class('User', ActiveRecord)
User.static.tableName = 'users'
User.static.tableFields = {
  id = {
    type = 'integer',
    flags = {'primary_key', 'autoincrement', 'not_null'}
  },
  name = {type = 'string', flags = {'not_null'}}
}
