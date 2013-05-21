#+--------------------------------------------------------------------+
#| Blogs.coffee
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
module.exports = class modules.blog.models.Blogs extends system.core.Model

  _categories_load  = false # skip 1st instantiation
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

    if _categories_load then @queue @_load_categories
    _categories_load = true


  #
  # Get all
  #
  # @param  [Function] $next  async function
  # @return [Void]
  #
  getAll: ($next) ->
    @db.select 'blogs.id, users.name AS author, categories.name AS category'
    @db.select 'blogs.status, blogs.created_on, blogs.updated_on, blogs.title'
    @db.from 'blogs'
    @db.join 'users', 'users.uid = blogs.author_id', 'inner'
    @db.join 'categories', 'categories.id = blogs.category_id', 'inner'
    @db.get ($err, $blogs) ->
      return $next($err) if $err?
      $next null, $blogs.result()

  #
  # Get blogs by id
  #
  # @param  [Integer] $id blogs id
  # @param  [Function] $next  async function
  # @return [Void]
  #
  getById: ($id, $next) ->
    @db.from 'blogs'
    @db.where 'id', $id
    @db.get ($err, $blogs) ->
      return $next($err) if $err?
      $next null, $blogs.row()

  #
  # Get the most recently updated article
  #
  # @return [Void]
  #
  getLatest: ($next) ->
    @db.from 'blogs'
    @db.orderBy 'updated_on', 'desc'
    @db.limit 1
    @db.get ($err, $blogs) ->
      return $next($err) if $err?
      $next null, $blogs.row()

  #
  # Delete blogs by id
  #
  # @param  [Integer] $id blogs id
  # @param  [Function] $next  async function
  # @return [Void]
  #
  deleteById: ($id, $next) ->
    @db.where 'id', $id
    @db.delete 'blogs', $next

  #
  # Create new blogs doc
  #
  # @param  [Integer] $doc blogs document
  # @param  [Function] $next  async function
  # @return [Void]
  #
  create: ($doc, $next) ->

    @db.insert 'blogs', $doc, ($err) =>
      return $next($err) if $err?

      @db.insertId ($err, $id) ->
        return $next($err) if $err?
        $next null, $id

  #
  # Save blogs doc by id
  #
  # @param  [Integer] $id blogs id
  # @param  [Integer] $doc blogs document
  # @param  [Function] $next  async function
  # @return [Void]
  #
  save: ($id, $doc, $next) ->
    @db.where 'id', $id
    @db.update 'blogs', $doc, $next


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

    @db.insert 'categories', name: $name, ($err) =>
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

    @cache.get 'blogs._load_categories', ($err, $data) =>

      if $data isnt false
        @_categories = $data.categories
        @_category_names = $data.category_names
        return $next(null)

      @db.from 'categories'
      @db.get ($err, $cat) =>
        return $next() if $err

        for $row in $cat.result()
          @_categories.push $row
          @_category_names[$row.name] = $row.name

        $data =
          categories: @_categories
          category_names: @_category_names

        @cache.save 'blogs._load_categories', $data, -1, $next

  #
  # Install the Blog Module data
  #
  # @return [Void]
  #
  install: () ->

    @load.dbforge() unless @dbforge?
    @queue @install_categories
    @queue @install_blogs

  #
  # Step 1:
  # Install Check
  # Create the category table
  #
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  install_categories: ($next) =>

    #
    # if categories doesn't exist, create and load initial data
    #
    @dbforge.createTable 'categories', $next, ($categories) ->
      $categories.addKey 'id', true
      $categories.addField
        id:
          type: 'INT', constraint: 5, unsigned: true, auto_increment: true
        name:
          type: 'VARCHAR', constraint: 255

      $categories.addData id: 1, name: "Article"


  #
  # Step 2:
  # Install Check
  # Create the blogs table
  #
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  install_blogs: ($next) =>

    #
    # if blogs table doesn't exist, create and load initial data
    #
    @dbforge.createTable 'blogs', $next, ($blogs) ->
      $blogs.addKey 'id', true
      $blogs.addField
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

      $blogs.addData
        id: 1,
        author_id: 2,
        category_id: 1,
        status: 1,
        created_on: "2012-03-13 04:20:00",
        updated_on: "2012-03-13 04:20:00",
        updated_by: 2,
        title: "About",
        body: "<p>Dark Overlord of Data is:</p><dl><dt><strong>a web page</strong></dt><dd><em>created using e x s p r e s s o</em></dd><dt><strong>bruce davidson</strong></dt><dd><em>a software developer who lives in seattle with his wife and daughter, two cats, one dog, and an electric guitar</em></dd></dl>"



