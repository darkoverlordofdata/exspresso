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

class Migrate extends CI_Controller

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

#
# Export the class:
#
module.exports = Migrate

# End of file Migrate.coffee
# Location: .application/controllers/Migrate.coffee
