#+--------------------------------------------------------------------+
#| 001_create_users_table.coffee
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
#	001_create_users_table - Migration
#
#
#
class Migration_create_users_table extends CI_Migration

  seq: '001'
  description: 'Create the users table'

  up: ($callback) ->

    @dbforge.add_field
      id:
        type: 'INT'
        constraint: 5
        unsigned: true
        auto_increment: true
      email:
        type: 'VARCHAR'
      name:
        type: 'VARCHAR'
      code:
        type: 'VARCHAR'
      last_login:
        type: 'DATETIME'
      created_on:
        type: 'DATETIME'
      created_by:
        type: 'VARCHAR'
      active:
        type: 'INT'
      timezone:
        type: 'VARCHAR'
      language:
        type: 'VARCHAR'
      theme:
        type: 'VARCHAR'
      path:
        type: 'VARCHAR'
      
    @dbforge.create_table 'user', $callback

  down: ($callback) ->

    @dbforge.drop_table 'user', $callback

# End of file 001_create_users_table.coffee
# Location: ./application/migrations/001_create_users_table.coffee