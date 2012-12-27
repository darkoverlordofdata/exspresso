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
# This is the default controller
#
require APPPATH+'core/AdminController.coffee'

class Migrate extends AdminController

  constructor: ($args...) ->

    super $args...

    @load.library 'migration',
      migration_db:       'postgres'
      migration_enabled:  true


## --------------------------------------------------------------------

  #
  # Index
  #
  # Migrations list
  #
  #   @access	public
  #   @param  string
  #   @return	void
  #
  index: ($module) ->

    @template.set_title config_item('site_name'), 'Migrations', 'List'

    @migration.set_module $module
    $path = @migration._migration_path + '*.coffee'

    @migration._get_version ($err, $version) =>

      if $err then show_error $err
      else

        $data =
          module:   (if $module then $module+'/' else '')
          path:     $path
          files:    glob($path)
          version:  $version

        @template.view 'migrations', $data


  ## --------------------------------------------------------------------

  #
  # Current
  #
  # Migrate up to the current version
  #
  #   @access	public
  #   @return	void
  #
  current: () ->

    @migration.current ($err) =>
      if $err then show_error $err
      else @redirect '/migrate'

  ## --------------------------------------------------------------------

  #
  # Latest
  #
  # Migrate up to the latest version
  #
  #   @access	public
  #   @return	void
  #
  latest: () ->

    @migration.latest ($err) =>
      if $err then show_error $err
      else @redirect '/migrate'

  ## --------------------------------------------------------------------

  #
  # Up
  #
  # Migrate up to a version
  #
  #   @access	public
  #   @param string
  #   @return	void
  #
  up: ($version) ->

    @migration.version $version, ($err, $current_version) =>
      if $err then show_error $err
      else @redirect '/migrate'

  ## --------------------------------------------------------------------

  #
  # Down
  #
  # Migrate down to a version
  #
  #   @access	public
  #   @param string
  #   @return	void
  #
  down: ($version) ->

    @migration.version $version, ($err, $current_version) =>
      if $err then show_error $err
      else @redirect '/migrate'



  ## --------------------------------------------------------------------

  #
  # Preview
  #
  # Preview migration sql
  #
  #   @access	public
  #   @param string
  #   @return	void
  #
  preview: ($module, $name = '') ->

    @template.set_title config_item('site_name'), 'Migrations', 'Preview'

    if $name is ''
      $name = $module
      $module = ''
    @migration.set_module $module

    $class = require(@migration._migration_path + $name + EXT)
    @template.view 'migration'
      inspect:    require('util').inspect
      path:       @migration._migration_path + $name + EXT
      migration:  new $class(@migration)
      fmtsql:     ($sql) ->
        $sql = ''+$sql
        $sql = $sql.replace("VALUES", "\nVALUES\n").replace(/\), \(/g, "),\n (")
        return $sql

#
# Export the class:
#
module.exports = Migrate

# End of file Migrate.coffee
# Location: .application/modules/migrate/controllers/Migrate.coffee
