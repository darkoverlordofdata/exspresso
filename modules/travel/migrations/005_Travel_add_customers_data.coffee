#+--------------------------------------------------------------------+
#| 005_Travel_add_customer_data.coffee
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
#	005_Travel_add_customer_data - Migration
#
#
#
class Migration_Travel_add_customer_data extends Exspresso_Migration

  seq: '005'
  description: 'Initialize the customer data'
  table: 'customer'

  up: ($callback) ->

    @db.insert_batch @table, @data, $callback

  down: ($callback) ->

    @db.truncate @table, $callback



  data:
    [
      {id: 1, username: "keith", password: "", name: "Keith"}
      {id: 2, username: "erwin", password: "", name: "Erwin"}
      {id: 3, username: "jeremy", password: "", name: "Jeremy"}
      {id: 4, username: "scott", password: "", name: "Scott"}
    ]

module.exports = Migration_Travel_add_customer_data

# End of file 005_Travel_add_customer_data.coffee
# Location: .modules/travel/migrations/005_Travel_add_customer_data.coffee