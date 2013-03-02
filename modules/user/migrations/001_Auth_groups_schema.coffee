#+--------------------------------------------------------------------+
#| 001_Auth_groups_schema.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#	001_Auth_groups_schema
#
#
#
class global.Migration_Auth_groups_schema extends Exspresso_Migration

  seq: '001'
  description: 'Create the Auth groups table'
  table: 'groups'
  data:
    id:
      'type':'MEDIUMINT', 'constraint':8, 'unsigned':true, 'null':false, 'auto_increment':true
    name:
      'type':'VARCHAR', 'constraint':'20', 'null':false
    description:
      'type':'VARCHAR', 'constraint':'100', 'null':false


  up: ($next) ->

    @dbforge.addField @data
    @dbforge.addKey 'id', true
    @dbforge.createTable @table, true, $next

  down: ($next) ->

    @dbforge.dropTable @table, $next


module.exports = Migration_Auth_groups_schema

# End of file 001_Auth_groups_schema.coffee
# Location: ./ion_auth/migrations/001_Auth_groups_schema.coffee