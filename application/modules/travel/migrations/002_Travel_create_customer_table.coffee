#+--------------------------------------------------------------------+
#| 002_Travel_create_customer_table.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#	002_Travel_create_customer_table - Migration
#
#
#
class Migration_Travel_create_customer_table extends Exspresso_Migration

  seq: '002'
  description: 'Create the customer table'
  table: 'customer'

  up: ($callback) ->

    @dbforge.add_field @data

    @dbforge.add_key 'id', true

    @dbforge.create_table @table, $callback

  down: ($callback) ->

    @dbforge.drop_table @table, $callback


  data:
    id:
      type: 'INT'
      constraint: 5
      unsigned: true
      auto_increment: true
    username:
      type: 'VARCHAR'
      constraint: 255
    password:
      type: 'VARCHAR'
      constraint: 255
    name:
      type: 'VARCHAR'
      constraint: 255


module.exports = Migration_Travel_create_customer_table
# End of file 002_Travel_create_customer_table.coffee
# Location: .modules/travel/migrations/002_Travel_create_customer_table.coffee