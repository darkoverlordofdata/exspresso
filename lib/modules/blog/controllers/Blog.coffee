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
module.exports = class Blog extends application.core.AdminController

  constructor: ($args...) ->

    super $args...
    @load.model 'Blogs'

  #
  # Index Action
  #
  # list blog entries
  #
  # @return [Void]
  #
  indexAction: () ->

    @blogs.getAll ($err, $docs) =>
      @theme.view 'index', $err ||
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
      @theme.view 'show', $err ||
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

    @theme.use 'ckeditor'

    @validation.setRules 'title', 'Blog Title', 'required'
    if @validation.run() is false

      #
      # Edit the article
      #
      @blogs.getById $id, ($err, $doc) =>
        @theme.view 'editz', $err || {
          form        :
            action    : "/blog/edit/#{$id}"
            hidden    :
                id    : $id
          category    : @blogs.getCategoryName($doc.category_id)
          categories  : @blogs.getCategoryNames()
          doc         : $doc
        }

    else

      #
      # Cancel?
      #
      if @input.post('cancel')?
        @redirect '/blog'

      #
      # Save changes?
      #
      else if @input.post('save')?
        #
        # pack up the document update
        #
        $update =
          title         : @input.post('title')
          body          : @input.post('blog')
          updated_on    : @load.helper('date').date('YYYY-MM-DD hh:mm:ss')
          updated_by    : @user.uid

        #
        # save it!
        #
        @blogs.save $id, $update, ($err) =>

          if $err?
            @session.setFlashdata 'error', $err.message
          else
            @session.setFlashdata 'info', 'Blog entry %s saved', $id

          @redirect "/blog"





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
    # Security check: must be logged in
    #
    unless @user.isLoggedIn
      @session.setFlashdata 'error', 'Not logged in'
      return @redirect '/blog'

    @blogs.getById $id, ($err, $doc) =>

      #
      # Security check: must be document owner
      #
      unless @user.isAdmin or (@user.uid is $doc.author_id)
        @session.setFlashdata 'error', 'Not an owner of this document'
        return @redirect '/blog'

      @blogs.deleteById $id, ($err) =>

        #
        # Show the status of the delete
        #
        if $err?
          @session.setFlashdata 'error', $err.message
        else
          @session.setFlashdata 'info', 'Blog entry %s deleted', $id

        @redirect '/blog'


  #
  # Create Action
  #
  # Create the new blog entry
  #
  # @return [Void]
  #
  createAction: () ->

    #
    # Security check: must be logged in
    #
    unless @user.isLoggedIn
      @session.setFlashdata 'error', 'Not logged in'
      return @redirect '/blog'

    @theme.use 'ckeditor'

    @validation.setRules 'title', 'Blog Title', 'required'
    @validation.setRules 'category', 'Blog Category', 'required'

    if @validation.run() is false
      @theme.view 'create',
        form        :
          action    : "/blog/create"
        category    : "Article"
    else

      if @input.post('cancel')?
        @redirect '/blog'

      else if @input.post('save')?

        #
        # Pack up the document data
        #
        $now = @load.helper('date').date('YYYY-MM-DD hh:mm:ss')
        $doc =
          author_id     : @user.uid
          category_id   : @blogs.getCategoryId(@input.post('category'))
          status        : 1
          created_on    : $now
          updated_on    : $now
          updated_by    : @user.uid
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
          @redirect '/blog/create'

