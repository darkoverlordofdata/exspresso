#+--------------------------------------------------------------------+
#| Migration.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#-----------------------------------------------------------------------

#
# Migration Class
#
# All migrations should implement this, forces up() and down() and gives
# access to the CI super-global.
#
#
class global.Exspresso_Migration

  _migration_enabled    : false
  _migration_module     : ''
  _migration_path       : ''
  _migration_version    : 0
  _migration_db         : ''
  _error_string         : ''

  constructor: ($controller, $config = {}) ->

    if typeof $config is 'boolean'
      #
      # The controller is a parent object, we just want to
      # perform a shallow clone of all the properties.
      #
      copyOwnProperties @, $controller
      return

    # Initialize the config preferences
    for $key, $val of $config
      if @['_'+$key]?
        @['_'+$key] = $val

    # Are they trying to use migrations while it is disabled?
    if (@_migration_enabled isnt true)
      show_error('Migrations has been loaded but is disabled or set up incorrectly.')

    # If not set, set it
    @_migration_path = @_migration_path ? APPPATH + 'migrations/'

    # Add trailing slash if not set
    @_migration_path = rtrim(@_migration_path, '/')+'/'

    # Load migration language
    @lang.load('migration')

    # They'll probably be using dbforge
    @load.dbforge(@_migration_db)

    @queue ($next) =>
      # Create migration table if it isn't found
      if @connected is true then return $next null
      @connected = true

      # If the migrations table is missing, make it
      @db.table_exists 'migrations', ($err, $table_exists) =>

        return $next($err) if $err
        return $next(null) if $table_exists

        @dbforge.addField
          'module' :
            'type'        : 'VARCHAR'
            'constraint'  : 40
          'version' :
            'type'        : 'INT'
            'constraint'  : 3

        @dbforge.createTable 'migrations', true, ($err) =>

          return $next($err) if $err
          @db.insert 'migrations', version: 0, $next

  #
  # Override migration path to include module name
  #   Look for migrations (in order) :
  #
  #     APPPATH + 'migrations/'
  #     APPPATH + 'third_party/' + $module + '/migrations/'
  #
  #     and in $config['modules_locations']
  #     APPPATH + 'modules/' + $module + '/migrations/'
  #
  # @param  string
  # @return void
  #
  setModule: ($module = '') ->

    return if $module is '' # use the default value

    $paths = []
    $config = get_config()
    if $config['modules_locations']? # using HMVC?
      for $k, $v of $config['modules_locations']
        $paths.push $k + $module + '/migrations/'
    $paths.push APPPATH + 'third_party/' + $module + '/migrations/'

    @_migration_module = $module
    for $path in $paths
      if file_exists($path) and is_dir($path)

        @_migration_path = $path
        # Add trailing slash if not set
        @_migration_path = rtrim(@_migration_path, '/')+'/'
        return


  #
  # Migrate to a schema version
  #
  # Calls each migration step required to get to the schema version of
  # choice
  #
  # @param  int  Target schema version
  # @return  mixed  true if already latest, false if failed, int if upgraded
  #
  version: ($target_version, $next) ->

    @getVersion ($err, $current_version) =>
      return $next($err) if $err

      $start = $current_version
      $stop = $target_version

      if $target_version > $current_version
        # Moving Up
        ++$start
        ++$stop
        $step = 1
      else
        # Moving Down
        $step = -1
        --$stop # ending loop index is excluded: ...

      $method = if $step is 1 then 'up' else 'down'
      $migrations = []

      # We now prepare to actually DO the migrations
      # But first let's make sure that everything is the way it should be
      for $i in [$start...$stop] by $step

        $f = glob(sprintf(@_migration_path + '%03d_*.coffee', $i))

        # Only one migration per step is permitted
        if (count($f) > 1)
          @_error_string = sprintf(@lang.line('migration_multiple_version'), $i)
          return $next(@_error_string)

        # Migration step not found
        if (count($f) is 0)
          # If trying to migrate up to a version greater than the last
          # existing one, migrate to the last one.
          if ($step is 1)
            break

          # If trying to migrate down but we're missing a step,
          # something must definitely be wrong.
          @_error_string = sprintf(@lang.line('migration_not_found'), $i)
          return $next(@_error_string)

        $file = basename($f[0])
        $name = basename($f[0], '.coffee')

        # Filename validations
        if ($match = preg_match('/^\\d{3}_(\\w+)$/', $name))?
          $match[1] = strtolower($match[1])

          # Cannot repeat a migration at different steps
          if (in_array($match[1], $migrations))
            @_error_string = sprintf(@lang.line('migration_multiple_version'), $match[1])
            return $next(@_error_string)

          $class = require($f[0])

          if not $class::[$method]?
            @_error_string = sprintf(@lang.line('migration_missing_'+$method+'_method'), $class)
            return $next(@_error_string)

          if typeof $class::[$method] isnt 'function'
            @_error_string = sprintf(@lang.line('migration_missing_'+$method+'_method'), $class)
            return $next(@_error_string)

          $migrations.push $class

        else

          @_error_string = sprintf(lang.line('migration_invalid_filename'), $file)
          return $next(@_error_string)

      log_message('debug', 'Current migration: ' + $current_version)

      $version = $i + (if $step is 1 then -1 else 0)

      # If there is nothing to do so quit
      log_message('debug', 'Migrating from' + $method + ' to version ' + $version)

      $index = 0
      #
      # Migrate: run each migration
      #
      #   @access	private
      #   @param	function callback
      #   @return	void
      #
      migrate = ($next) =>
        return $next(null) if $migrations.length is 0
        #
        # run the migration at index
        #
        $class = $migrations[$index]
        $migration = new $class(@, true)
        $migration[$method].call $migration, ($err) =>
          return $next(null) if $err
          #
          # bump the version number
          #
          $current_version += $step
          @_update_version $current_version, ($err) =>
            return $next(null) if $err
            #
            # do the next migration
            #
            $index += 1
            if $index is $migrations.length then $next null
            else migrate $next


      migrate ($err) ->

        log_message('debug', 'Finished migrating to '+$current_version)
        $next $err, $current_version


  #
  # Set's the schema to the latest migration
  #
  # @return  mixed  true if already latest, false if failed, int if upgraded
  #
  latest: ($next) ->
    if not ($migrations = @find_migrations())
      @_error_string = @lang.line('migration_none_found')
      return $next(@_error_string)

    $last_migration = basename(end($migrations))

    # Calculate the last migration step from existing migration
    # filenames and procceed to the standard version migration
    @version substr($last_migration, 0, 3), ($err, $current_version) ->
      $next $err, $current_version

  #
  # Set's the schema to the migration version set in config
  #
  # @return  mixed  true if already current, false if failed, int if upgraded
  #
  current: ($next) ->
    @version @_migration_version, ($err, $current_version) ->
      $next $err, $current_version

  #
  # Error string
  #
  # @return  string  Error message returned as a string
  #
  errorString: () ->
    @_error_string

  #
  # Set's the schema to the latest migration
  #
  # @return  mixed  true if already latest, false if failed, int if upgraded
  #
  findMigrations: () ->

    # Load all#_*.coffee files in the migrations path
    $files = glob(@_migration_path + '*_*.coffee')
    $file_count = count($files)

    for $i in [0..$file_count-1]

      # Mark wrongly formatted files as false for later filtering
      $name = basename($files[$i], '.coffee')
      if not preg_match('/^\\d{3}_(\\w+)$/', $name)?
        $files[$i] = false

    sort($files)
    $files


  #
  # Retrieves current schema version
  #
  # @return  int  Current Migration
  #
  getVersion: ($next) ->

    @db.where 'module', @_migration_module
    @db.get 'migrations', ($err, $result) ->

      return $next($err) if $err
      $row = $result.row()
      $next null, if $row then $row.version else 0



  #
  # Stores the current schema version
  #
  # @param  int  Migration reached
  # @return  bool
  #
  _update_version: ($migrations, $next) ->

    @db.where 'module', @_migration_module
    @db.update 'migrations'
      'version': $migrations, $next

#  END Exspresso_Migration class
module.exports = Exspresso_Migration
# End of file Migration.coffee
# Location: ./system/libraries/Migration.coffee