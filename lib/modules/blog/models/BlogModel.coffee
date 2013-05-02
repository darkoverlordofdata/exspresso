#+--------------------------------------------------------------------+
#| BlogModel.coffee
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
#	Blog Data Model
#
module.exports = class modules.blog.models.BlogModel extends system.core.Model

  _categories       : null  # category table cache
  _category_names   : null  # hash of category names for drop-down list

  #
  # Initialize Blog Model
  #
  constructor: ($args...) ->

    super $args...

    defineProperties @,
      _categories       : {writeable: false, value: []}
      _category_names   : {writeable: false, value: {}}

    #@queue @_load_categories

  #
  # Get all
  #
  # @param  [Function] $next  async function
  # @return [Void]
  #
  getAll: ($next) ->
    @db.select 'blog.id, users.name AS author, category.name AS category, blog.status, blog.created_on, blog.updated_on, blog.title'
    @db.from 'blog'
    @db.join 'users', 'users.uid = blog.author_id', 'inner'
    @db.join 'category', 'category.id = blog.category_id', 'inner'
    @db.get ($err, $blog) ->
      return $next($err) if $err?
      $next null, $blog.result()

  #
  # Get blog by id
  #
  # @param  [Integer] $id blog id
  # @param  [Function] $next  async function
  # @return [Void]
  #
  getById: ($id, $next) ->
    @db.from 'blog'
    @db.where 'id', $id
    @db.get ($err, $blog) ->
      return $next($err) if $err?
      $next null, $blog.row()

  #
  # Delete blog by id
  #
  # @param  [Integer] $id blog id
  # @param  [Function] $next  async function
  # @return [Void]
  #
  deleteById: ($id, $next) ->
    @db.where 'id', $id
    @db.delete 'blog', $next

  #
  # Create new blog doc
  #
  # @param  [Integer] $doc blog document
  # @param  [Function] $next  async function
  # @return [Void]
  #
  create: ($doc, $next) ->

    @db.insert 'blog', $doc, ($err) =>
      return $next($err) if $err?

      @db.insertId ($err, $id) ->
        return $next($err) if $err?
        $next null, $id

  #
  # Save blog doc by id
  #
  # @param  [Integer] $id blog id
  # @param  [Integer] $doc blog document
  # @param  [Function] $next  async function
  # @return [Void]
  #
  save: ($id, $doc, $next) ->
    @db.where 'id', $id
    @db.update 'blog', $update, $next


  #
  # New Category
  #
  # Create a new category, update cache
  #
  # @param  [String]  $name new category name
  # @param  [Fundtion]  $next async callback
  # @return [Void]
  #
  newCategory: ($name, $next) ->

    @db.insert 'category', name: $name, ($err) =>
      return $next($err) if $err?

      @db.insertId ($err, $id) =>
        return $next($err) if $err?

        @_categories.push id: $id, name: $name
        @_category_names[$name] = $name

        $next null, $id


  getCategories: () ->
    @_categories

  #
  # Category Names
  #
  # @return [Object] hash of category names for dropdown list
  #
  getCategoryNames: () ->
    @_category_names

  #
  # Category Name
  #
  # @param  [String]  id  category id
  # @return [String] the name associated with the id
  #
  getCategoryName: ($id) ->
    for $row in @_categories
      return $row.name if $id is $row.id
    ''

  #
  # Category Id
  #
  # @param  [String]  name  category name
  # @return [String] the id associated with the name
  #
  getCategoryId: ($name) ->
    for $row in @_categories
      return $row.id if $name is $row.name
    ''

  #
  # Load the Categories.
  #
  # 1. load the category table rows
  # 2. compile a drop down list of category names
  #
  # Save/Get values from cache
  #
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  _load_categories: ($next) =>

    @cache.get 'blog._load_categories', ($err, $data) =>

      if $data isnt false
        @_categories = $data.categories
        @_category_names = $data.category_names
        return $next(null)

      @db.from 'category'
      @db.get ($err, $cat) =>
        return $next() if $err

        for $row in $cat.result()
          @_categories.push $row
          @_category_names[$row.name] = $row.name

        $data =
          categories: @_categories
          category_names: @_category_names

        @cache.save 'blog._load_categories', $data, -1, $next

  #
  # Install the Blog Module data
  #
  # @return [Void]
  #
  install: () ->

    @load.dbforge() unless @dbforge?
    @queue @install_category
    @queue @install_blog

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
    @dbforge.createTable 'category', $next, ($category) ->
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
    @dbforge.createTable 'blog', $next, ($blog) ->
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
        updated_by: 2,
        title: "About",
        body: "<p>Dark Overlord of Data is:</p><dl><dt><strong>a web page</strong></dt><dd><em>created using e x s p r e s s o</em></dd><dt><strong>bruce davidson</strong></dt><dd><em>a software developer who lives in seattle with his wife and daughter, two cats, one dog, and an electric guitar</em></dd></dl>"



