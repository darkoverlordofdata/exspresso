#+--------------------------------------------------------------------+
#| 001_Travel_create_hotels_table.coffee
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
#	001_Travel_create_hotels_table - Migration
#
#
#
class Migration_Travel_create_hotels_table extends Exspresso_Migration

  seq:'001'
  description: 'Create the hotels table'
  table: 'hotel'

  up: ($next) ->

    @dbforge.addField @data
    @dbforge.addKey 'id', true
    @dbforge.createTable @table, $next

  down: ($next) ->

    @dbforge.dropTable @table, $next


  data:
    id:
      type: 'INT'
      constraint: 5
      unsigned: true
      auto_increment: true
    price:
      type: 'INT'
    name:
      type: 'VARCHAR'
      constraint: 255
    address:
      type: 'VARCHAR'
      constraint: 255
    city:
      type: 'VARCHAR'
      constraint: 255
    state:
      type: 'VARCHAR'
      constraint: 255
    zip:
      type: 'VARCHAR'
      constraint: 255
    country:
      type: 'VARCHAR'
      constraint: 255

module.exports = Migration_Travel_create_hotels_table

# End of file 001_Travel_create_hotels_table.coffee
# Location: .modules/travel/migrations/001_Travel_create_hotels_table.coffee