#+--------------------------------------------------------------------+
#| welcome.coffee
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
#	Blog
#
require APPPATH+'core/AdminController.coffee'

#
# Blog Controller
#
class Blog extends application.core.AdminController

  constructor: ($args...) ->

    super $args...
    @load.model 'blog/BlogModel'
    @blogmodel.initialize()

  #
  # Index
  #
  # list blog entries
  #
  # @return [Void]
  #
  index: () ->

    @db.select 'blog.id, users.name AS author, category.name AS category, blog.status, blog.created_on, blog.updated_on, blog.title'
    @db.from 'blog'
    @db.join 'users', 'users.uid = blog.author_id', 'inner'
    @db.join 'category', 'category.id = blog.category_id', 'inner'
    @db.get ($err, $blog) =>

      #
      # Display a list of articles
      #
      @template.view 'blog_list', $err ||
        entries: $blog.result()


  #
  # Show
  #
  # display blog entry
  #
  # @param  [String]  id  blog record id
  # @return [Void]
  #
  show: ($id) ->

    @db.from 'blog'
    @db.where 'id', $id
    @db.get ($err, $blog) =>

      #
      # Display a single article
      #
      @template.view 'blog_show', $err ||
        blog: $blog.row()


  #
  # Edit
  #
  # Edit the blog entry
  #
  # @param  [String]  id  blog record id
  # @return [Void]
  #
  edit: ($id) ->

    #
    # if we're not logged in, check no further
    #
    unless @user.isLoggedIn
      throw new system.core.AuthorizationError('Not logged in')


    @db.from 'blog'
    @db.where 'id', $id
    @db.get ($err, $doc) =>

      $doc = $doc.row()
      #
      # check for access to edit this document
      #
      unless @user.isAdmin or (@user.uid is $doc.author_id)
        throw new system.core.AuthorizationError('Not the document owner')


      #
      # Edit the article
      #
      @template.view 'blog_edit', $err || {
        category    : @blogmodel.categoryName($doc.category_id)
        categories  : @blogmodel.categoryNames()
        blog        : $doc
      }
          


  #
  # Delete
  #
  # Delete the blog entry
  #
  # @param  [String]  id  blog record id
  # @return [Void]
  #
  del: ($id) ->

    #
    # if we're not logged in, check no further
    #
    unless @user.isLoggedIn
      throw new system.core.AuthorizationError('Not logged in')

    @db.from 'blog'
    @db.where 'id', $id
    @db.get ($err, $doc) =>

      $doc = $doc.row()
      #
      # Must be author or admin
      #
      unless @user.isAdmin or (@user.uid is $doc.author_id)
        throw new system.core.AuthorizationError('Not an owner of this article')

      @db.where 'id', $id
      @db.delete 'blog', ($err) =>

        #
        # Show the status of the delete
        #
        if $err?
          @session.setFlashdata 'error', $err.message
        else
          @session.setFlashdata 'info', 'Blog entry %s deleted', $id

        @redirect '/blog'


  #
  # New
  #
  # Edit a new blog entry
  #
  # @return [Void]
  #
  new: () ->

    #
    # no anonymous access
    #
    unless @user.isLoggedIn
      throw new system.core.AuthorizationError('Not logged in')

    @template.view 'blog_new',
      categories  : @blogmodel.categoryNames()

  #
  # Create
  #
  # Create the new blog entry
  #
  # @return [Void]
  #
  create: () ->

    #
    # Must be logged in to create a doc
    #
    unless @user.isLoggedIn
      throw new system.core.AuthorizationError('Not logged in')

    $now = @load.helper('date').date('YYYY-MM-DD hh:mm:ss')
    #
    # Pack up the article data
    #
    $doc =
      author_id     : @user.uid
      category_id   : @blogmodel.categoryId(@input.post('category'))
      status        : 1
      created_on    : $now
      updated_on    : $now
      title         : @input.post('title')
      body          : @input.post('blog')


    @db.insert 'blog', $doc, ($err) =>

      #
      # Add the article to the database
      #
      if $err? # can't insert, try again?
        @session.setFlashdata 'error', $err.message
        return @redirect '/blog/new'

      @db.insertId ($err, $id) =>

        #
        # get the ID
        #
        if $err? # can't get the id, display the whole list
          @session.setFlashdata 'error', $err.message
          return @redirect '/blog'

        #
        # Show the id that was created
        #
        @session.setFlashdata 'info', 'Blog entry %s created', $id
        @redirect '/blog/edit/'+$id


  #
  # Save
  #
  # saves a blog entry
  #
  # @return [Void]
  #
  save: () ->

    #
    # if we're not logged in, check no further
    #
    unless @user.isLoggedIn
      throw new system.core.AuthorizationError('Not logged in')

    $id = @input.post('id')
    @db.from 'blog'
    @db.where 'id', $id
    @db.get ($err, $doc) =>

      $doc = $doc.row()
      #
      # Must be author or admin
      #
      unless @user.isAdmin or (@user.uid is $doc.author_id)
        throw new system.core.AuthorizationError('Not an owner of this article')

      $update =
        catagory      : @blogmodel.categoryId(@input.post('category'))
        title         : @input.post('title')
        body          : @input.post('blog')
        updated_on    : @load.helper('date').date('YYYY-MM-DD hh:mm:ss')

      @db.where 'id', $id
      @db.update 'blog', $update, ($err) =>

        #
        # Show the status of the update operation
        #
        if $err?
          @session.setFlashdata 'error', $err.message
        else
          @session.setFlashdata 'info', 'Blog entry %s saved', $id

        @redirect '/blog/edit/'+$id



#
# Export the class:
#
module.exports = Blog

# End of file Blog.coffee
# Location: .modules/blog/controllers/Blog.coffee
