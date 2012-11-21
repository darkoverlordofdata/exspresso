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
class Migration_create_bookings_table extends CI_Migration

  seq: '005'
  description: 'Create the bookings table'

  up: ($callback) ->

    @dbforge.add_field
      id:
        type: 'INT'
        constraint: 5
        unsigned: true
        auto_increment: true
      email:
        type: 'VARCHAR'
      username:
        type: 'VARCHAR'
      hotel:
        type: 'INT'
      checkinDate:
        type: 'DATETIME'
      checkoutDate:
        type: 'DATETIME'
      creditCard:
        type: 'VARCHAR'
      creditCardName:
        type: 'VARCHAR'
      creditCardExpiryMonth:
        type: 'INT'
      creditCardExpiryYear:
        type: 'INT'
      smoking:
        type: 'VARCHAR'
      beds:
        type: 'INT'
      amenities:
        type: 'VARCHAR'
      state:
        type: 'VARCHAR'
  

    @dbforge.create_table 'booking', $callback

  down: ($callback) ->

    @dbforge.drop_table 'booking', $callback

# End of file 005_create_bookings_table.coffee
# Location: ./application/migrations/005_create_bookings_table.coffee