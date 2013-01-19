#+--------------------------------------------------------------------+
#| 004_Blog_add_blog_data.coffee
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
#	004_Blog_add_blog_data - Migration
#
#
#
class Migration_Blog_add_blog_data extends Exspresso_Migration

  seq: '004'
  description: 'Initialize the blog data'
  table: 'blog'

  up: ($callback) ->

    @db.insert_batch @table, @data, $callback

  down: ($callback) ->

    @db.delete @table, {id: 1}, $callback


  data:
    [
      {
        id: 1,
        author_id: 1,
        category_id: 1,
        status: 1,
        created_on: "2012-03-13 04:20:00",
        updated_on: "2012-03-13 04:20:00",
        title: "About",
        body: "<p>Dark Overlord of Data is:</p><dl><dt><strong>a web page</strong></dt><dd><em>created using e x s p r e s s o</em></dd><dt><strong>bruce davidson</strong></dt><dd><em>a software developer who lives in seattle with his wife and daughter, two cats, one dog, and an electric guitar</em></dd></dl>"
      }
    ]

module.exports = Migration_Blog_add_blog_data

# End of file 004_Blog_add_blog_data.coffee
# Location: .modules/blog/migrations/004_Blog_add_blog_data.coffee