#+--------------------------------------------------------------------+
#| Preview.coffee
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
#	Migration Preview
#
require APPPATH+'core/AdminController.coffee'

class Preview extends application.core.AdminController

  constructor: ($args...) ->

    super $args...

    @load.library 'migration',
      migration_db      : 'mysql'
      migration_enabled :  true

  #
  # Preview
  #
  # Preview migration sql
  #
  #   @access	public
  #   @param string
  # @return [Void]  #
  index: ($module = '', $name = '') ->


    if $name is ''
      $name = $module
      $module = ''


    @migration.set_module $module
    $class = require(@migration._migration_path + $name + EXT)
    @theme.view 'preview',
      nav       : @sidenav('Migrate')
      module    : if $module.length then $module else 'core'
      path      : @migration._migration_path + $name + EXT
      migration : new $class(@migration)
      fmtsql    : ($sql) ->
        (''+$sql).replace("VALUES", "\nVALUES\n").replace(/\), \(/g, "),\n (")


#
# Export the class:
#
module.exports = Preview

# End of file Preview.coffee
# Location: .modules/admin/controllers/Preview.coffee
