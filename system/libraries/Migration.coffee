#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package    CodeIgniter
# @author    EllisLab Dev Team
# @copyright  Copyright (c) 2006 - 2012, EllisLab, Inc.
# @license    http://codeigniter.com/user_guide/license.html
# @link    http://codeigniter.com
# @since    Version 1.0
# @filesource
#

#-----------------------------------------------------------------------

#
# Migration Class
#
# All migrations should implement this, forces up() and down() and gives
# access to the CI super-global.
#
# @package    CodeIgniter
# @subpackage  Libraries
# @category  Libraries
# @author    Reactor Engineers
# @link
#
class global.CI_Migration

  _migration_enabled: false
  _migration_path: ''
  _migration_version: 0
  _migration_db: ''
  _error_string: ''

  CI: null
  db: null
  dbforge: null
  connected: false

  constructor: ($config = {}, @CI, @db, @dbforge) ->

    # Only run this constructor on main library load
    #if (get_parent_class(@) isnt false)
    #  return
    if @constructor isnt CI_Migration
      return

    for $key, $val of $config
      @['_'+$key] = $val

    log_message('debug', 'Migrations class initialized')

    # Are they trying to use migrations while it is disabled?
    if (@_migration_enabled isnt true)
      show_error('Migrations has been loaded but is disabled or set up incorrectly.')

    # If not set, set it
    @_migration_path = @_migration_path ? APPPATH + 'migrations/'

    # Add trailing slash if not set
    @_migration_path = rtrim(@_migration_path, '/')+'/'

    # Load migration language
    @CI.lang.load('migration')

    # They'll probably be using dbforge
    @CI.load.dbforge(@_migration_db)
    @db = @CI.dbforge.db
    @dbforge = @CI.dbforge

    @CI._ctor.push ($callback) => @initialize $callback


  initialize: ($callback) ->

    if @connected is true then return $callback null
    @connected = true

    # If the migrations table is missing, make it
    @db.table_exists 'migrations', ($err, $table_exists) =>

      if $err then return $callback $err
      if $table_exists then return $callback null

      @dbforge.add_field
        'version' :
          'type' : 'INT'
          'constraint' : 3

      @dbforge.create_table 'migrations', true, ($err) =>

        if $err then return $callback $err
        @db.insert 'migrations', version: 0, $callback

  #-------------------------------------------------------------------

  #
  # Migrate to a schema version
  #
  # Calls each migration step required to get to the schema version of
  # choice
  #
  # @param  int  Target schema version
  # @return  mixed  true if already latest, false if failed, int if upgraded
  #
  version: ($target_version, $callback) ->

    @_get_version ($err, $current_version) =>
      if $err then return $callback $err

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
          @_error_string = sprintf(@CI.lang.line('migration_multiple_version'), $i)
          return $callback @_error_string

        # Migration step not found
        if (count($f) is 0)
          # If trying to migrate up to a version greater than the last
          # existing one, migrate to the last one.
          if ($step is 1)
            break

          # If trying to migrate down but we're missing a step,
          # something must definitely be wrong.
          @_error_string = sprintf(@CI.lang.line('migration_not_found'), $i)
          return $callback @_error_string

        $file = basename($f[0])
        $name = basename($f[0], '.coffee')

        # Filename validations
        $match = preg_match('/^\\d{3}_(\\w+)$/', $name)
        if $match.length > 0
          $match[1] = strtolower($match[1])

          # Cannot repeat a migration at different steps
          if (in_array($match[1], $migrations))
            @_error_string = sprintf(@CI.lang.line('migration_multiple_version'), $match[1])
            return $callback @_error_string

          $class = require($f[0])

          if not $class::[$method]?
            @_error_string = sprintf(@CI.lang.line('migration_missing_'+$method+'_method'), $class)
            return $callback @_error_string

          if typeof $class::[$method] isnt 'function'
            @_error_string = sprintf(@CI.lang.line('migration_missing_'+$method+'_method'), $class)
            return $callback @_error_string

          $migrations.push $class

        else

          @_error_string = sprintf(@CI.lang.line('migration_invalid_filename'), $file)
          return $callback @_error_string

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
      migrate = ($callback) =>
        if $migrations.length is 0 then $callback null
        else
          #
          # run the migration at index
          #
          $class = $migrations[$index]
          $migration = new $class({}, @CI, @db, @dbforge)
          call_user_func [$migration, $method], ($err) =>
            if $err then $callback $err
            else
              #
              # bump the version number
              #
              $current_version += $step
              @_update_version $current_version, ($err) =>
                if $err then $callback $err
                else
                  #
                  # do the next migration
                  #
                  $index += 1
                  if $index is $migrations.length then $callback null
                  else migrate $callback


      migrate ($err) ->

        log_message('debug', 'Finished migrating to '+$current_version)
        $callback $err, $current_version


  #-------------------------------------------------------------------

  #
  # Set's the schema to the latest migration
  #
  # @return  mixed  true if already latest, false if failed, int if upgraded
  #
  latest: ($callback) ->
    if not ($migrations = @find_migrations())
      @_error_string = @CI.lang.line('migration_none_found')
      return $callback @_error_string

    $last_migration = basename(end($migrations))

    # Calculate the last migration step from existing migration
    # filenames and procceed to the standard version migration
    @version substr($last_migration, 0, 3), ($err, $current_version) ->
      $callback $err, $current_version

  #-------------------------------------------------------------------

  #
  # Set's the schema to the migration version set in config
  #
  # @return  mixed  true if already current, false if failed, int if upgraded
  #
  current: ($callback) ->
    @version @_migration_version, ($err, $current_version) ->
      $callback $err, $current_version

  #-------------------------------------------------------------------

  #
  # Error string
  #
  # @return  string  Error message returned as a string
  #
  error_string: () ->
    return @_error_string

  #-------------------------------------------------------------------

  #
  # Set's the schema to the latest migration
  #
  # @return  mixed  true if already latest, false if failed, int if upgraded
  #
  find_migrations: () ->

    # Load all#_*.coffee files in the migrations path
    $files = glob(@_migration_path + '*_*.coffee')
    $file_count = count($files)

    for $i in [0..$file_count-1]

      # Mark wrongly formatted files as false for later filtering
      $name = basename($files[$i], '.coffee')
      if ( not preg_match('/^\\d{3}_(\\w+)$/', $name))
        $files[$i] = false

    sort($files)
    return $files


  #-------------------------------------------------------------------

  #
  # Retrieves current schema version
  #
  # @return  int  Current Migration
  #
  _get_version: ($callback) ->

    $row = @db.get 'migrations', ($err, $result) ->

      if $err then return $callback $err
      $row = $result.row()
      $callback null, if $row then $row.version else 0


  #-------------------------------------------------------------------

  #
  # Stores the current schema version
  #
  # @param  int  Migration reached
  # @return  bool
  #
  _update_version: ($migrations, $callback) ->

    @db.update 'migrations'
      'version': $migrations, $callback

module.exports = CI_Migration

# End of file Migration.coffee
# Location: ./system/libraries/Migration.coffee