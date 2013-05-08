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
#	Migrations Admin
#
require APPPATH+'core/AdminController.coffee'

module.exports = class Admin extends application.core.AdminController

  constructor: ($args...) ->

    super $args...

    @load.library 'migration'

  #
  # List migrations
  #
  #   @access	public
  #   @param string
  # @return [Void]  #
  indexAction: ($module = '') ->

    @theme.setAdminMenu 'Migrate'
    @migration.setModule $module
    @migration.getVersion ($err, $version) =>

      @theme.view 'index', $err || {
        nav       : @sidenav('Migrations')
        menu      : @submenu($module || 'Core')
        module    : if $module then $module+'/' else ''
        path      : @migration._migration_path
        files     : glob(@migration._migration_path+'*.coffee')
        version   : $version
      }

