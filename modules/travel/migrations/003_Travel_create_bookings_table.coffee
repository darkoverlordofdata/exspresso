#+--------------------------------------------------------------------+
#| 003_Travel_create_bookings_table.coffee
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
#	003_Travel_create_bookings_table - Migration
#
#
#
class Migration_Travel_create_bookings_table extends Exspresso_Migration

  seq: '003'
  description: 'Create the bookings table'
  table: 'booking'

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
    email:
      type: 'VARCHAR'
      constraint: 255
    username:
      type: 'VARCHAR'
      constraint: 255
    hotel:
      type: 'INT'
    checkinDate:
      type: 'DATETIME'
    checkoutDate:
      type: 'DATETIME'
    creditCard:
      type: 'VARCHAR'
      constraint: 255
    creditCardName:
      type: 'VARCHAR'
      constraint: 255
    creditCardExpiryMonth:
      type: 'INT'
    creditCardExpiryYear:
      type: 'INT'
    smoking:
      type: 'VARCHAR'
      constraint: 255
    beds:
      type: 'INT'
    amenities:
      type: 'VARCHAR'
      constraint: 255
    state:
      type: 'VARCHAR'
      constraint: 255


module.exports = Migration_Travel_create_bookings_table

# End of file 003_Travel_create_bookings_table.coffee
# Location: .modules/travel/migrations/003_Travel_create_bookings_table.coffee