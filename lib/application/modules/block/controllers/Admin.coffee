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
    @load.model 'BlockModel', 'blocks'
    @load.library 'Table'
    @theme.setAdminMenu 'Blocks'

  #
  # Blocks
  #
  indexAction: ->

    $blocks = []

    for $name, $desc of @theme.getRegions()

      $rows = []
      for $block in @theme.getBlocks()
        if $block.region is '$'+$name
          $rows.push {
            id        : $block.id
            name      : $block.name
            region    : $block.region.substr(1)
            weight    : $block.order
          }
      $blocks.push {
        name: $name
        desc: $desc
        rows: $rows
      }

    $rows = []
    for $block in @theme.getBlocks()
      if $block.region is ''
        $rows.push {
          id        : $block.id
          name      : $block.name
          region    : ''
          weight    : $block.order
        }
    $blocks.push {
      name: 'disabled'
      desc: 'Disabled'
      rows: $rows
    }



    @theme.view 'index',
      blocks    : $blocks
      regions   : @theme.getRegions()
      weights   :
          '-3'  : -3
          '-2'  : -2
          '-1'  : -1
          '0'   : 0
          '1'   : 1
          '2'   : 2
          '3'   : 3



