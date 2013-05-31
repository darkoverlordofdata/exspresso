#+--------------------------------------------------------------------+
#| Katra.coffee
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
#	Katra
#
require APPPATH+'core/AdminController.coffee'

#
# Katra Controller
#
module.exports = class Katra extends application.core.AdminController

  constructor: ($args...) ->

    super $args...
    @load.model 'Katras'

  #
  # Index Action
  #
  # list katra entries
  #
  # @return [Void]
  #
  indexAction: () ->

    @katras.getAll ($err, $docs) =>
      @theme.view 'index', $err ||
        docs : $docs


  #
  # Run Action
  #
  # Run a katra entry
  #
  # @param  [String]  id  katra record id
  # @return [Void]
  #
  runAction: ($id) ->

    # support libs
    @theme.use 'prettify'
    @theme.use '/css/katra.css'

    @theme.use '//d16acdn.aws.af.cm/js/katra-deps.min.js'
    #    @theme.use 'js/json2.js'
    #    @theme.use 'js/underscore-min.js'
    #    @theme.use 'js/backbone-min.js'
    #    @theme.use 'js/jquery.console.js'
    #    @theme.use 'js/coffee-script.js'

    # the katra application
    @theme.use 'js/katra.benchmark.coffee'
    @theme.use 'js/katra.io.coffee'
    @theme.use 'js/katra.basic.coffee'
    @theme.use 'js/katra.runtime.coffee'
    @theme.use 'js/katra.coffee'

    @katras.getById $id, ($err, $doc) =>

      @theme.view 'run.tpl', $err || $code: $doc.code, $notes: $doc.notes


  #
  # Edit Action
  #
  # Edit the katra entry
  #
  # @param  [String]  id  katra id
  # @return [Void]
  #
  editAction: ($id) ->

    #
    # Security check: must be logged in
    #
    unless @user.isLoggedIn
      @session.setFlashdata 'error', 'Not logged in'
      return @redirect '/katra'

    @validation.setRules 'title', 'Katra Title', 'required'
    if @validation.run() is false

      #
      # Edit the article
      #
      @katras.getById $id, ($err, $doc) =>
        @theme.view 'edit', $err || {
          form        :
            action    : "/katra/edit/#{$id}"
            hidden    :
                id    : $id
          doc         : $doc
        }

    else

      #
      # Cancel?
      #
      if @input.post('cancel')?
        @redirect '/katra'

      #
      # Save changes?
      #
      else if @input.post('save')?
        #
        # pack up the document update
        #
        $update =
          title         : @input.post('title')
          notes         : htmlspecialchars(@input.post('notes'))
          code          : htmlspecialchars(@input.post('katra'))
          updated_on    : @load.helper('date').date('YYYY-MM-DD hh:mm:ss')
          updated_by    : @user.uid

        #
        # save it!
        #
        @katras.save $id, $update, ($err) =>

          if $err?
            @session.setFlashdata 'error', $err.message
          else
            @session.setFlashdata 'info', 'Katra entry %s saved', $id

          @redirect "/katra"





  #
  # Delete Action
  #
  # Delete the katra entry
  #
  # @param  [String]  id  katra record id
  # @return [Void]
  #
  deleteAction: ($id) ->

    #
    # Security check: must be logged in
    #
    unless @user.isLoggedIn
      @session.setFlashdata 'error', 'Not logged in'
      return @redirect '/katra'

    @katras.getById $id, ($err, $doc) =>

      #
      # Security check: must be document owner
      #
      unless @user.isAdmin or (@user.uid is $doc.author_id)
        @session.setFlashdata 'error', 'Not an owner of this document'
        return @redirect '/katra'

      @katras.deleteById $id, ($err) =>

        #
        # Show the status of the delete
        #
        if $err?
          @session.setFlashdata 'error', $err.message
        else
          @session.setFlashdata 'info', 'Katra entry %s deleted', $id

        @redirect '/katra'


  #
  # Create Action
  #
  # Create the new katra entry
  #
  # @return [Void]
  #
  createAction: () ->

    #
    # Security check: must be logged in
    #
    unless @user.isLoggedIn
      @session.setFlashdata 'error', 'Not logged in'
      return @redirect '/katra'

    @validation.setRules 'title', 'Katra Title', 'required'

    if @validation.run() is false
      @theme.view 'create',
        form        :
          action    : "/katra/create"
        category    : "Article"
    else

      if @input.post('cancel')?
        @redirect '/katra'

      else if @input.post('save')?

        #
        # Pack up the document data
        #
        $now = @load.helper('date').date('YYYY-MM-DD hh:mm:ss')
        $doc =
          author_id     : @user.uid
          status        : 1
          created_on    : $now
          updated_on    : $now
          updated_by    : @user.uid
          title         : @input.post('title')
          notes         : htmlspecialchars(@input.post('notes'))
          code          : htmlspecialchars(@input.post('katra'))

        #
        # Create the document in database
        #
        @katras.create $doc, ($err, $id) =>

          if $err?
            @session.setFlashdata 'error', $err.message
            return @redirect '/katra'

          #
          # Show the id that was created
          #
          @session.setFlashdata 'info', 'Katra entry %s created', $id
          @redirect '/katra/create'

