#+--------------------------------------------------------------------+
#| Admin.coffee
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
#	Admin Blocks
#
require APPPATH+'core/AdminController.coffee'

module.exports = class Admin extends application.core.AdminController

  constructor: ($args...) ->

    super $args...
    @load.model 'Blocks'
    @load.library 'Table'
    @theme.setAdminMenu 'Blocks'

  #
  # Blocks
  #
  # @return [Void]
  #
  indexAction: ->


    #
    # Form submitted?
    #
    if not @input.isPostBack()

      $weights =
        '-3'  : -3
        '-2'  : -2
        '-1'  : -1
        ' 0'  : 0
        ' 1'  : 1
        ' 2'  : 2
        ' 3'  : 3

      console.log $weights

      @theme.view 'index',
        blocks    : @blocks.getByRegion()
        regions   : @theme.getRegions()
        weights   : $weights

    else

      #
      # Cancel?
      #
      if @input.post("cancel")?
        @redirect '/admin'

      #
      # Save changes?
      #
      else if @input.post("save")?
        @redirect '/admin/block'

      #
      # New block?
      #
      else if @input.post("create")?
        @redirect '/admin/block'


  #
  # Create
  #
  # create block content
  #
  # @return [Void]
  #
  createAction: () ->

  #
  # Edit
  #
  # edit a block content
  #
  # @param  [String]  region  region name
  # @param  [String]  name  block name
  # @return [Void]
  #
  editAction: ($region, $name) ->

    #
    # Form submitted?
    #
    if not @input.isPostBack()

      #
      # No, just display the content
      #
      @blocks.getByRegionAndName $region, $name, ($err, $block) =>

        @theme.view 'edit', $err || {
          form      :
            action  : "/block/edit/#{@region}/#{@name}"
            hidden  :
                id  : $block.id
          region    : $region
          name      : $name
          block     : $block
        }

    else

      #
      # Cancel?
      #
      if @input.post("cancel")?
        @redirect '/admin/block'

      #
      # Save changes?
      #
      else if @input.post("save")?

        $id       = @input.post("id")
        $content  = @input.post("content")
        $active   = @input.post("active")

        @blocks.updateContent $id, $content, $active, ($err) =>

          if $err?
            @session.setFlashdata 'error', 'Unable to save: %s', $err
          else
            @session.setFlashdata 'info', 'Saved %s, %s (%s)', $region, $name, $id
          @redirect '/admin/block'




