#+--------------------------------------------------------------------+
#| 004_create_customer_table.coffee
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
#	004_create_customer_table - Migration
#
#
#
class Migration_create_customer_table extends CI_Migration

  seq: '004'
  description: 'Create the customer table'

  up: ($callback) ->

    @dbforge.add_field
      id:
        type: 'INT'
        constraint: 5
        unsigned: true
        auto_increment: true
      username:
        type: 'VARCHAR'
      password:
        type: 'VARCHAR'
      name:
        type: 'VARCHAR'

    @dbforge.create_table 'customer', $callback

  down: ($callback) ->

    @dbforge.drop_table 'customer', $callback

# End of file 004_create_customer_table.coffee
# Location: ./application/migrations/004_create_customer_table.coffee