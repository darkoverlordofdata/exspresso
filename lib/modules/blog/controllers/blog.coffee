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

  #
  # Index Action
  #
  # list blog entries
  #
  # @return [Void]
  #
  indexAction: () ->

    @blogs.getAll ($err, $docs) =>

      @template.view 'list', $err ||
        docs : $docs


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

      @template.view 'display', $err ||
        doc  : $doc


  #
  # Edit Action
  #
  # Edit the blog entry
  #
  # @param  [String]  id  blog id
  # @return [Void]
  #
  editAction: ($id) ->

    #
    # Security check: must be logged in
    #
    unless @user.isLoggedIn
      @session.setFlashdata 'error', 'Not logged in'
      return @redirect '/blog'

    @blogs.getById $id, ($err, $doc) =>
      return @template.view($err) if $err?

      #
      # Security check: must be document owner
      #
      unless @user.isAdmin or (@user.uid is $doc.author_id)
        @session.setFlashdata 'error', 'Not an owner of this document'
        return @redirect '/blog'

      #
      # Edit the article
      #
      @template.view 'edit',
        category    : @blogs.categoryName($doc.category_id)
        categories  : @blogs.categoryNames()
        doc         : $doc

          


  #
  # Delete Action
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
      @session.setFlashdata 'error', "Not logged in"
      return @redirect '/blog'

    @blogs.getById $id, ($err, $doc) =>

      #
      # Must be author or admin
      #
      unless @user.isAdmin or (@user.uid is $doc.author_id)
        @session.setFlashdata 'error', 'Not an owner of this document'
        return @redirect '/blog'

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
  # New Action
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
      @session.setFlashdata 'error', "Not logged in"
      return @redirect '/blog'

    @template.view 'new',
      categories  : @blogs.categoryNames()

  #
  # Create Action
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
      @session.setFlashdata 'error', "Not logged in"
      return @redirect '/blog'

    #
    # Pack up the document data
    #
    $now = @load.helper('date').date('YYYY-MM-DD hh:mm:ss')
    $doc =
      author_id     : @user.uid
      category_id   : @blogs.categoryId(@input.post('category'))
      status        : 1
      created_on    : $now
      updated_on    : $now
      title         : @input.post('title')
      body          : @input.post('blog')


    #
    # Create the document in database
    #
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
  # Save Action
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
      @session.setFlashdata 'error', "Not logged in"
      return @redirect '/blog'


    @blogs.getById @input.post('id'), ($err, $doc) =>

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
      @blogs.save $doc.id, $update, ($err) =>

        if $err?
          @session.setFlashdata 'error', $err.message
        else
          @session.setFlashdata 'info', 'Blog entry %s saved', $doc.id

        @redirect '/blog/edit/'+$doc.id



module.exports = Blog

# End of file Blog.coffee
# Location: .modules/blog/controllers/Blog.coffee
