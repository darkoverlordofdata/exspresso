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

class Admin extends application.core.AdminController

  constructor: ($args...) ->

    super $args...

    @load.library 'migration'

  #
  # List migrations
  #
  #   @access	public
  #   @param string
  # @return [Void]  #
  index: ($module = '') ->

    @migration.setModule $module
    @migration.getVersion ($err, $version) =>

      @template.view 'index', $err || {
        nav       : @sidenav('Migrations')
        menu      : @submenu($module || 'Core')
        module    : if $module then $module+'/' else ''
        path      : @migration._migration_path
        files     : glob(@migration._migration_path+'*.coffee')
        version   : $version
      }

#
# Export the class:
#
module.exports = Admin

# End of file Admin.coffee
# Location: .modules/migrare/controllers/Admin.coffee
