#+--------------------------------------------------------------------+
#| 001_Blog_create_category_table.coffee
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
#	001_Blog_create_category_table - Migration
#
#
#
class Migration_Blog_create_category_table extends Exspresso_Migration

  seq: '001'
  description: 'Create the category table'
  table: 'category'

  up: ($next) ->

    @dbforge.add_field @data

    @dbforge.add_key 'id', true

    @dbforge.create_table @table, $next

  down: ($next) ->

    @dbforge.drop_table @table, $next

  data:
    id:
      type: 'INT'
      constraint: 5
      unsigned: true
      auto_increment: true
    name:
      type: 'VARCHAR'
      constraint: 255

module.exports = Migration_Blog_create_category_table

# End of file 001_Blog_create_category_table.coffee
# Location: .modules/blog/migrations/001_Blog_create_category_table.coffee