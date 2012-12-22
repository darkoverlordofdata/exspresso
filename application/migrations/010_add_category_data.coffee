#+--------------------------------------------------------------------+
#| 010_add_category_data.coffee
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
#	010_add_category_data - Migration
#
#
#
class Migration_Add_category_data extends CI_Migration

  seq: '010'
  description: 'Initialize the category data'
  table: 'category'

  up: ($callback) ->

    @db.insert_batch @table, @data, $callback

  down: ($callback) ->

    @db.delete @table, {id: 1}, $callback


  data:
    [
      {id: 1, name: "Article"}
    ]


module.exports = Migration_Add_category_data

# End of file 010_add_category_data.coffee
# Location: ./010_add_category_data.coffee