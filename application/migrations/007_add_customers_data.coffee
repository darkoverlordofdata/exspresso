#+--------------------------------------------------------------------+
#| 007_add_customer_data.coffee
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
#	007_add_customer_data - Migration
#
#
#
class Migration_Add_customer_data extends CI_Migration

  seq: '007'
  description: 'Initialize the customer data'

  up: ($callback) ->

    @db.insert_batch 'customer', @data, $callback

  down: ($callback) ->

    @db.truncate 'customer', $callback



  data:
    [
      {id: 1, username: "keith", password: "", name: "Keith"}
      {id: 2, username: "erwin", password: "", name: "Erwin"}
      {id: 3, username: "jeremy", password: "", name: "Jeremy"}
      {id: 4, username: "scott", password: "", name: "Scott"}
    ]

module.exports = Migration_Add_customer_data

# End of file 007_add_customer_data.coffee
# Location: ./007_add_customer_data.coffee