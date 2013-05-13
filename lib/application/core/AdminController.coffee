#+--------------------------------------------------------------------+
#| AdminController.coffee
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
#	  AdminController
#
#   Base class for all publicly viewable pages
#
module.exports = class application.core.AdminController extends application.core.PublicController

  constructor: ($args...) ->

    super $args...

    @theme.use 'signin', 'sidenav'
    @load.library 'User'
    @load.library 'Validation'
    @validation.setErrorDelimiters '<p><em>', '</em></p>'


