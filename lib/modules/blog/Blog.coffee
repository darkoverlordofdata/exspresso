#+--------------------------------------------------------------------+
#| Blog.coffee
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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#
#	Class application.lib.Blog
#

require APPPATH+'core/Module.coffee'

class Blog extends application.core.Module

  name          : 'Blog'
  description   : ''
  path          : __dirname
  active        : true

  #
  # Set the properties
  #
  # @param  [system.core.Exspresso] controller  the system controller
  #
  constructor: ($controller) ->

    defineProperties @,
      controller        : {writeable: false, value: $controller}
      _categories       : {writeable: false, value: []}
      _category_names   : {writeable: false, value: {}}


  #
  # Category Names
  #
  # @return [Object] hash of category names for dropdown list
  #
  categoryNames: () ->
    @_category_names

  #
  # Category Name
  #
  # @param  [String]  id  category id
  # @return [String] the name associated with the id
  #
  categoryName: ($id) ->
    for $row in @_categories
      return $row.name if $id is $row.id
    ''

  #
  # Category Id
  #
  # @param  [String]  name  category name
  # @return [String] the id associated with the name
  #
  categoryId: ($name) ->
    for $row in @_categories
      return $row.id if $name is $row.name
    ''

  #
  # Initialize the module
  #
  #   Install if needed
  #   Load the categories
  #
  # @return [Void]
  #
  initialize: () ->

    @controller.load.dbforge() unless @controller.dbforge?
    @controller.queue @install_category
    @controller.queue @install_blog
    @controller.queue @load_categories

  #
  # Step 1:
  # Install Check
  # Create the category table
  #
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  install_category: ($next) =>

    #
    # if categories doesn't exist, create and load initial data
    #
    @controller.dbforge.createTable 'category', $next, ($category) ->
      $category.addKey 'id', true
      $category.addField
        id:
          type: 'INT', constraint: 5, unsigned: true, auto_increment: true
        name:
          type: 'VARCHAR', constraint: 255

      $category.addData id: 1, name: "Article"


  #
  # Step 2:
  # Install Check
  # Create the blog table
  #
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  install_blog: ($next) =>

    #
    # if blog table doesn't exist, create and load initial data
    #
    @controller.dbforge.createTable 'blog', $next, ($blog) ->
      $blog.addKey 'id', true
      $blog.addField
        id:
          type: 'INT', constraint: 5, unsigned: true, auto_increment: true
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
        updated_by:
          type: 'INT'
        title:
          type: 'VARCHAR', constraint: 255
        body:
          type: 'TEXT'

      $blog.addData
        id: 1,
        author_id: 2,
        category_id: 1,
        status: 1,
        created_on: "2012-03-13 04:20:00",
        updated_on: "2012-03-13 04:20:00",
        title: "About",
        body: "<p>Dark Overlord of Data is:</p><dl><dt><strong>a web page</strong></dt><dd><em>created using e x s p r e s s o</em></dd><dt><strong>bruce davidson</strong></dt><dd><em>a software developer who lives in seattle with his wife and daughter, two cats, one dog, and an electric guitar</em></dd></dl>"

  #
  # Step 3:
  # Load the Categories
  #
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  load_categories: ($next) =>

    #
    # load the blog categories
    #
    @controller.db.from 'category'
    @controller.db.get ($err, $cat) =>

      return $next() if $err
      for $row in $cat.result()
        @_categories.push $row
        @_category_names[$row.name] = $row.name

      $next()

# END CLASS Blog
module.exports = Blog


# End of file Blog.coffee
# Location: .application/lib/Blog.coffee