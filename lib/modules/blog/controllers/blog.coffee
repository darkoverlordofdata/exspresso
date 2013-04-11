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
    @load.model 'BlogModel', 'blogs'
    @blogs.initialize()

  #
  # Index Action
  #
  # list blog entries
  #
  # @return [Void]
  #
  indexAction: () ->

    @blogs.getAll ($err, $blogs) =>

      @template.view 'blog_list', $err ||
        entries : $blogs


  #
  # Show Action
  #
  # display blog entry
  #
  # @param  [String]  id  blog record id
  # @return [Void]
  #
  showAction: ($id) ->

    @blogs.getById $id, ($err, $doc) =>

      @template.view 'blog_show', $err ||
        blog  : $doc


  #
  # Edit
  #
  # Edit the blog entry
  #
  # @param  [String]  id  blog record id
  # @return [Void]
  #
  editAction: ($id) ->

    #
    # if we're not logged in, check no further
    #
    unless @user.isLoggedIn
      throw new system.core.AuthorizationError('Not logged in')


    @blogs.getById $id, ($err, $doc) =>

      #
      # check for access to edit this document
      #
      unless @user.isAdmin or (@user.uid is $doc.author_id)
        throw new system.core.AuthorizationError('Not the document owner')


      #
      # Edit the article
      #
      @template.view 'blog_edit', $err || {
        category    : @blogs.categoryName($doc.category_id)
        categories  : @blogs.categoryNames()
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
  deleteAction: ($id) ->

    #
    # if we're not logged in, check no further
    #
    unless @user.isLoggedIn
      throw new system.core.AuthorizationError('Not logged in')

    @blogs.getById $id, ($err, $doc) =>

      #
      # Must be author or admin
      #
      unless @user.isAdmin or (@user.uid is $doc.author_id)
        throw new system.core.AuthorizationError('Not an owner of this article')

      @blogs.delete $id, ($err) =>

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
  newAction: () ->

    #
    # no anonymous access
    #
    unless @user.isLoggedIn
      throw new system.core.AuthorizationError('Not logged in')

    @template.view 'blog_new',
      categories  : @blogs.categoryNames()

  #
  # Create
  #
  # Create the new blog entry
  #
  # @return [Void]
  #
  createAction: () ->

    #
    # Must be logged in to create a doc
    #
    unless @user.isLoggedIn
      throw new system.core.AuthorizationError('Not logged in')

    $now = @load.helper('date').date('YYYY-MM-DD hh:mm:ss')
    #
    # Pack up the document data
    #
    $doc =
      author_id     : @user.uid
      category_id   : @blogs.categoryId(@input.post('category'))
      status        : 1
      created_on    : $now
      updated_on    : $now
      title         : @input.post('title')
      body          : @input.post('blog')


    @blogs.create $doc, ($err, $id) =>

      if $err?
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
  saveAction: () ->
    return @redirect('/blog') if @input.post('cancel')
    #
    # if we're not logged in, check no further
    #
    unless @user.isLoggedIn
      throw new system.core.AuthorizationError('Not logged in')

    $id = @input.post('id')
    @blogs.getById $id, ($err, $doc) =>

      #
      # Must be author or admin
      #
      unless @user.isAdmin or (@user.uid is $doc.author_id)
        throw new system.core.AuthorizationError('Not an owner of this article')

      #
      # pack up the document update
      #
      $update =
        catagory      : @blogs.categoryId(@input.post('category'))
        title         : @input.post('title')
        body          : @input.post('blog')
        updated_on    : @load.helper('date').date('YYYY-MM-DD hh:mm:ss')

      #
      # save it!
      #
      @blogs.save $id, $update, ($err) =>

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
