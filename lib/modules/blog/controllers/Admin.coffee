#+--------------------------------------------------------------------+
#| admin.coffee
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
#	Admin Blog
#
require APPPATH+'core/AdminController.coffee'

module.exports = class Admin extends application.core.AdminController

  constructor: ($args...) ->

    super $args...
    @load.model 'Blogs', 'blog'
    @theme.setAdminMenu 'Blog'

  #
  # Blog Categories/Options
  #
  indexAction: ->
    @load.library 'table'

    @theme.view 'admin/list'



  newCategoryAction: ->


