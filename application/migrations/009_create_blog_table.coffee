#+--------------------------------------------------------------------+
#| 009_create_blog_table.coffee
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
#	009_create_blog_table - Migration
#
#
#
class Migration_Create_blog_table extends CI_Migration

  seq: '009'
  description: 'Create the blog table'

  up: ($callback) ->

    @dbforge.add_field @data

    @dbforge.add_key 'id', true

    @dbforge.create_table 'blog', $callback

  down: ($callback) ->

    @dbforge.drop_table 'blog', $callback


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



module.exports = Migration_Create_blog_table

# End of file 009_create_blog_table.coffee
# Location: ./application/migrations/009_create_blog_table.coffee