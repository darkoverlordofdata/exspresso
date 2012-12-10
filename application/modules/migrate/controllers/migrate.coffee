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
class Migrate extends MY_Controller

  ## --------------------------------------------------------------------

  #
  # Load the migration lib
  #
  # Set the migration database, enable migrations
  #
  #   @access	public
  #   @return	void
  #
  constructor: ($args...) ->

    super($args...)

    @load.library 'template', title:  'Migrations'
    @load.library 'migration',
      migration_enabled:  true
      migration_db:       'mysql'

  ## --------------------------------------------------------------------

  #
  # Index
  #
  # Demo migrate page
  #
  #   @access	public
  #   @return	void
  #
  index: ->

    $path = @migration._migration_path + '*.coffee'

    @migration._get_version ($err, $version) =>

      if $err then show_error $err
      else

        $data =
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
  # Details
  #
  # Display a migration details
  #
  #   @access	public
  #   @param string
  #   @return	void
  #
  info: ($name) ->

    $class = require(@migration._migration_path + $name + EXT)
    @template.view 'migration'
      inspect:    require('util').inspect
      path:       @migration._migration_path + $name + EXT
      migration:  new $class

#
# Export the class:
#
module.exports = Migrate

# End of file Migrate.coffee
# Location: .application/modules/migrate/controllers/Migrate.coffee
