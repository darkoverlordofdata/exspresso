#+--------------------------------------------------------------------+
#| 003_Blog_add_category_data.coffee
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
#	003_Blog_add_category_data - Migration
#
#
#
class Migration_Blog_add_category_data extends Exspresso_Migration

  seq: '003'
  description: 'Initialize the category data'
  table: 'category'

  up: ($next) ->

    @db.insert_batch @table, @data, $next

  down: ($next) ->

    @db.delete @table, {id: 1}, $next


  data:
    [
      {id: 1, name: "Article"}
    ]


module.exports = Migration_Blog_add_category_data

# End of file 003_Blog_add_category_data.coffee
# Location: .modules/blog/migrations/003_Blog_add_category_data.coffee