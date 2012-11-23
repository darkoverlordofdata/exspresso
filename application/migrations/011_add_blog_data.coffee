#+--------------------------------------------------------------------+
#| 011_add_blog_data.coffee
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
#	011_add_blog_data - Migration
#
#
#
class Migration_Add_blog_data extends CI_Migration

  seq: '011'
  description: 'Initialize the blog data'

  up: ($callback) ->

    @db.insert_batch 'blog', @data, $callback

  down: ($callback) ->

    @db.delete 'blog', @keys, $callback

  keys:
    [
      {id: 1}
    ]


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

module.exports = Migration_Add_blog_data

# End of file 011_add_blog_data.coffee
# Location: ./011_add_blog_data.coffee