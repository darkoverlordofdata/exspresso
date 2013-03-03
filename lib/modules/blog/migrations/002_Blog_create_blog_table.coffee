#+--------------------------------------------------------------------+
#| 002_Blog_create_blog_table.coffee
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
#	002_Blog_create_blog_table - Migration
#
#
#
class Migration_Blog_create_blog_table extends ExspressoMigration

  seq: '002'
  description: 'Create the blog table'
  table: 'blog'

  up: ($next) ->

    @dbforge.addField @data

    @dbforge.addKey 'id', true

    @dbforge.createTable @table, $next

  down: ($next) ->

    @dbforge.dropTable @table, $next


  data:
    id:
      type: 'INT'
      constraint: 5
      unsigned: true
      auto_increment: true
    author_id:
      type: 'INT'
    category_id:
      type: 'INT'
    status:
      type: 'INT'
    created_on:
      type: 'DATETIME'
    updated_on:
      type: 'DATETIME'
    title:
      type: 'VARCHAR'
      constraint: 255
    body:
      type: 'TEXT'



module.exports = Migration_Blog_create_blog_table

# End of file 002_Blog_create_blog_table.coffee
# Location: .modules/blog/migrations/002_Blog_create_blog_table.coffee