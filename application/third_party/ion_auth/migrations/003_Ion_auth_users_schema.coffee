#+--------------------------------------------------------------------+
#| 003_Ion_auth_users_schema.coffee
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
#	003_Ion_auth_users_schema
#
#
#
class global.Migration_Ion_auth_users_schema extends CI_Migration

  seq: '001'
  description: 'Create the Ion_auth users table'
  table: 'users'
  data:
    id:
      'type':'MEDIUMINT', 'constraint':8, 'unsigned':true, 'null':false, 'auto_increment':true
    ip_address:
      'type':'VARBINARY', 'constraint':'16', 'null':false
    username:
      'type':'VARCHAR', 'constraint':'100', 'null':false
    password:
      'type':'VARCHAR', 'constraint':'40', 'null':false
    salt:
      'type':'VARCHAR', 'constraint':'40', 'null':true
    email:
      'type':'VARCHAR', 'constraint':'100', 'null':false
    activation_code:
      'type':'VARCHAR', 'constraint':'40', 'null':true
    forgotten_password_code:
      'type':'VARCHAR', 'constraint':'40', 'null':true
    forgotten_password_time:
      'type':'int', 'constraint':'11', 'unsigned':true, 'null':true
    remember_code:
      'type':'VARCHAR', 'constraint':'40', 'null':true
    created_on:
      'type':'int', 'constraint':'11', 'unsigned':true, 'null':false
    last_login:
      'type':'int', 'constraint':'11', 'unsigned':true, 'null':true
    active:
      'type':'tinyint', 'constraint':'1', 'unsigned':true, 'null':true
    first_name:
      'type':'VARCHAR', 'constraint':'50', 'null':true
    last_name:
      'type':'VARCHAR', 'constraint':'100', 'null':true
    company:
      'type':'VARCHAR', 'constraint':'100', 'null':true
    phone:
      'type':'VARCHAR', 'constraint':'50', 'null':true


  up: ($next) ->

    @dbforge.add_field @schema
    @dbforge.add_key 'id', true
    @dbforge.create_table @table, true, $next

  down: ($next) ->

    @dbforge.drop_table @table, $next


module.exports = Migration_Ion_auth_users_schema

# End of file 003_Ion_auth_users_schema.coffee
# Location: ./ion_auth/migrations/003_Ion_auth_users_schema.coffee