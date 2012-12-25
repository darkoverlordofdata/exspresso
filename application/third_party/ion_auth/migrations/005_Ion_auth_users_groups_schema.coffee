#+--------------------------------------------------------------------+
#| 005_Ion_auth_users_groups_schema.coffee
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
#	005_Ion_auth_users_groups_schema
#
#
#
class global.Migration_Ion_auth_users_groups_schema extends CI_Migration

  seq: '005'
  description: 'Create the Ion_auth groups table'
  table: 'users_groups'
  data:
    id:
      'type':'MEDIUMINT', 'constraint':8, 'unsigned':true, 'null':false, 'auto_increment':true
    user_id:
      'type':'MEDIUMINT', 'constraint':8, 'unsigned':true, 'null':false
    group_id:
      'type':'MEDIUMINT', 'constraint':8, 'unsigned':true, 'null':false


  up: ($next) ->

    @dbforge.add_field @data
    @dbforge.add_key 'id', true
    @dbforge.create_table @table, true, $next

  down: ($next) ->

    @dbforge.drop_table @table, $next


module.exports = Migration_Ion_auth_users_groups_schema

# End of file 005_Ion_auth_users_groups_schema.coffee
# Location: ./ion_auth/migrations/005_Ion_auth_users_groups_schema.coffee