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
class global.Migration_Create_users_table extends CI_Migration

  seq: '001'
  description: 'Create the users table'
  table: 'user'

  up: ($callback) ->

    @dbforge.add_field @data
    @dbforge.add_key 'id', true
    @dbforge.create_table @table, true, $callback

  down: ($callback) ->

    @dbforge.drop_table @table, $callback


  data:
    id:
      type: 'INT'
      constraint: 5
      unsigned: true
      auto_increment: true
    email:
      type: 'VARCHAR'
      constraint: 255
    name:
      type: 'VARCHAR'
      constraint: 255
    code:
      type: 'VARCHAR'
      constraint: 255
    last_logon:
      type: 'DATETIME'
    created_on:
      type: 'DATETIME'
    created_by:
      type: 'VARCHAR'
      constraint: 255
    active:
      type: 'INT'
    timezone:
      type: 'VARCHAR'
      constraint: 255
    language:
      type: 'VARCHAR'
      constraint: 255
    theme:
      type: 'VARCHAR'
      constraint: 255
    path:
      type: 'VARCHAR'
      constraint: 255

module.exports = Migration_Create_users_table

# End of file 001_create_users_table.coffee
# Location: ./application/migrations/001_create_users_table.coffee