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

    @migration._get_version ($err, $version) =>
      if $err then return show_error $err

      @load.view 'migrations'
        path:     @migration._migration_path
        files:    glob(@migration._migration_path + '*.coffee')
        version:  $version


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
      if $err then return show_error $err

      @redirect '/migrate'

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
      if $err then return show_error $err

      @redirect '/migrate'

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
      if $err then return show_error $err

      @redirect '/migrate'

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
      if $err then return show_error $err

      @redirect '/migrate'



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
    @load.view 'migration'
      inspect:    require('util').inspect
      path:       @migration._migration_path + $name + EXT
      migration:  new $class

#
# Export the class:
#
module.exports = Migrate

# End of file Migrate.coffee
# Location: .application/modules/migrate/controllers/Migrate.coffee
