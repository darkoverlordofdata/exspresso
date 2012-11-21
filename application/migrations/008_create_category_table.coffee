#+--------------------------------------------------------------------+
#| 008_create_category_table.coffee
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
#	008_create_category_table - Migration
#
#
#
class Migration_create_category_table extends CI_Migration

  seq: '008'
  description: 'Create the category table'

  up: ($callback) ->

    @dbforge.add_field
      id:
        type: 'INT'
        constraint: 5
        unsigned: true
        auto_increment: true
      name:
        type: 'VARCHAR'

    @dbforge.create_table 'category', $callback

  down: ($callback) ->

    @dbforge.drop_table 'category', $callback

# End of file 008_create_category_table.coffee
# Location: ./application/migrations/008_create_category_table.coffee