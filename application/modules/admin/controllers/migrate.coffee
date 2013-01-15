#+--------------------------------------------------------------------+
#| migrate.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#	Migrate
#
require APPPATH+'core/AdminController.coffee'

class Migrate extends AdminController

  constructor: ($args...) ->

    super $args...

    @load.library 'migration',
      migration_db      : 'mysql'
      migration_enabled :  true


  ## --------------------------------------------------------------------

  #
  # List migrations
  #
  #   @access	public
  #   @param string
  #   @return	void
  #
  index: ($module = '') ->

    @migration.set_module $module
    @migration._get_version ($err, $version) =>

      @template.view 'admin/migrate/index', $err || {
        nav       : @sidenav('Migrate')
        menu      : @submenu($module || 'Core')
        module    : if $module then $module+'/' else ''
        path      : @migration._migration_path
        files     : glob(@migration._migration_path+'*'+EXT)
        version   : $version
      }

#
# Export the class:
#
module.exports = Migrate

# End of file Migrate.coffee
# Location: .modules/admin/controllers/Migrate.coffee
