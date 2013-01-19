#+--------------------------------------------------------------------+
#| MY_Controller.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	PublicController
#
#   Base class for all publicly viewable pages
#

class global.AdminController extends MY_Controller

  constructor: ($args...) ->

    super($args...)

    @load.library 'template'
    @template.set_theme 'default', 'signin', 'sidenav'
    @load.database()
    @load.library 'user/auth'
    @url_helper = @load.helper('url')

  ## --------------------------------------------------------------------

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
    
    @template.html_sidenav($admin_menu, $active)

  ## --------------------------------------------------------------------

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
    
    @template.html_submenu($modules, $active)


module.exports = AdminController
# End of file AdminController.coffee
# Location: ./application/core/AdminController.coffee