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
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#  ------------------------------------------------------------------------
#
#	  AdminController
#
#   Base class for all publicly viewable pages
#

class application.core.AdminController extends application.core.PublicController

  constructor: ($args...) ->

    super $args...

    @theme.more 'signin', 'sidenav'
    @load.library 'user/user'


module.exports = application.core.AdminController
# End of file AdminController.coffee
# Location: .application/core/AdminController.coffee