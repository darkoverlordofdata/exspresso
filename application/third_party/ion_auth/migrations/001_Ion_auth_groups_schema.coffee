#+--------------------------------------------------------------------+
#| 001_Ion_auth_groups_schema.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	001_Ion_auth_groups_schema
#
#
#
class global.Migration_Ion_auth_groups_schema extends CI_Migration

  seq: '001'
  description: 'Create the Ion_auth groups table'
  table: 'groups'
  data:
    id:
      'type':'MEDIUMINT', 'constraint':8, 'unsigned':true, 'null':false, 'auto_increment':true
    name:
      'type':'VARCHAR', 'constraint':'20', 'null':false
    description:
      'type':'VARCHAR', 'constraint':'100', 'null':false


  up: ($next) ->

    @dbforge.add_field @schema
    @dbforge.add_key 'id', true
    @dbforge.create_table @table, true, $next

  down: ($next) ->

    @dbforge.drop_table @table, $next


module.exports = Migration_Ion_auth_groups_schema

# End of file 001_Ion_auth_groups_schema.coffee
# Location: ./ion_auth/migrations/001_Ion_auth_groups_schema.coffee