#+--------------------------------------------------------------------+
#| 005_create_bookings_table.coffee
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
#	005_create_bookings_table - Migration
#
#
#
class Migration_Create_bookings_table extends CI_Migration

  seq: '005'
  description: 'Create the bookings table'

  up: ($callback) ->

    @dbforge.add_field @data

    @dbforge.add_key 'id', true

    @dbforge.create_table 'booking', $callback

  down: ($callback) ->

    @dbforge.drop_table 'booking', $callback


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


module.exports = Migration_Create_bookings_table

# End of file 005_create_bookings_table.coffee
# Location: ./application/migrations/005_create_bookings_table.coffee