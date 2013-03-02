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
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#  ------------------------------------------------------------------------
#
#	  AdminController
#
#   Base class for all publicly viewable pages
#
require APPPATH+'core/PublicController.coffee'

class global.AdminController extends PublicController

  constructor: ($args...) ->

    super $args...

    @theme.more 'signin', 'sidenav'
    @load.library 'user/user'

  #
  # Sidenav
  #
  # Administrator side-bar navigation menu
  #
  #   @access	public
  #   @param string
  #   @return	void
  #
  sidenav: ($active) ->

    $admin_menu = 
      Dashboard    : '/admin'
      Config       : '/admin/config'
      Routes       : '/admin/routes'
      Users        : '/admin/users'
      Database     : '/admin/db'
      Migrations   : '/admin/migrate'
      Blog         : '/admin/blog'
      Demo         : '/admin/travel'
    
    @template.htmlSidenav($admin_menu, $active)

  #
  # Submenu
  #
  # Administrator sub menu
  #
  #   @access	public
  #   @param string
  #   @return	void
  #
  submenu: ($active) ->

    $modules = 
      Core   : '/admin/migrate/list'
      Blog   : '/admin/migrate/list/blog'
      Travel : '/admin/migrate/list/travel'
      User   : '/admin/migrate/list/user'
    
    @template.htmlSubmenu($modules, $active)


module.exports = AdminController
# End of file AdminController.coffee
# Location: ./application/core/AdminController.coffee