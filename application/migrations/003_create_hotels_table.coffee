#+--------------------------------------------------------------------+
#| 003_create_hotels_table.coffee
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
#	003_create_hotels_table - Migration
#
#
#
class Migration_create_hotels_table extends CI_Migration

  seq:'003'
  description: 'Create the hotels table'

  up: ($callback) ->

    @dbforge.add_field
      id:
        type: 'INT'
        constraint: 5
        unsigned: true
        auto_increment: true
      price:
        type: 'INT'
      name:
        type: 'VARCHAR'
      address:
        type: 'VARCHAR'
      city:
        type: 'VARCHAR'
      state:
        type: 'VARCHAR'
      zip:
        type: 'VARCHAR'
      country:
        type: 'VARCHAR'

    @dbforge.create_table 'hotel', $callback

  down: ($callback) ->

    @dbforge.drop_table 'hotel', $callback

# End of file 003_create_hotels_table.coffee
# Location: ./application/migrations/003_create_hotels_table.coffee