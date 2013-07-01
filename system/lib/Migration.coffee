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
# Migration Class
#
# All migrations should implement this, forces up() and down() and gives
# access to the CI super-global.
#
#
module.exports = class system.lib.Migration

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
      throw new system.core.AppError('Acess Denied', 'Migrations has been loaded but is disabled or set up incorrectly.')

    # If not set, set it
    @_migration_path = @_migration_path ? APPPATH + 'migrations/'

    # Add trailing slash if not set
    @_migration_path = rtrim(@_migration_path, '/')+'/'

    # Load migration language
    @i18n.load('migration')

    # They'll probably be using dbforge
    @load.dbforge(@_migration_db)

    @queue ($next) =>
      # Create migration table if it isn't found
      if @connected is true then return $next null
      @connected = true

      # If the migrations table is missing, make it
      @db.tableExists 'migrations', ($err, $table_exists) =>

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
  #     APPPATH + 'vendor/' + $module + '/migrations/'
  #
  #     and in $config['module_paths']
  #     APPPATH + 'modules/' + $module + '/migrations/'
  #     MODPATH + $module + '/migrations/'
  #
  # @param  string
  # @return [Void]  #
  setModule: ($module = '') ->

    return if $module is '' # use the default value

    $paths = []
    $config = get_config()
    for $k in $config['module_paths']
      $paths.push $k + $module + '/migrations/'
    $paths.push APPPATH + 'vendor/' + $module + '/migrations/'

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
  # @return [Mixed]  true if already latest, false if failed, int if upgraded
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
        if $f.length
          @_error_string = sprintf(@i18n.line('migration_multiple_version'), $i)
          return $next(@_error_string)

        # Migration step not found
        if $f.length is 0
          # If trying to migrate up to a version greater than the last
          # existing one, migrate to the last one.
          if ($step is 1)
            break

          # If trying to migrate down but we're missing a step,
          # something must definitely be wrong.
          @_error_string = sprintf(@i18n.line('migration_not_found'), $i)
          return $next(@_error_string)

        $file = basename($f[0])
        $name = basename($f[0], '.coffee')

        # Filename validations
        if ($match = $name.match(/^\d{3}_(\w+)$/))
          $match[1] = $match[1].toLowerCase()

          # Cannot repeat a migration at different steps
          if ($migrations.indexOf($match[1]) isnt -1)
            @_error_string = sprintf(@i18n.line('migration_multiple_version'), $match[1])
            return $next(@_error_string)

          $class = require($f[0])

          if not $class::[$method]?
            @_error_string = sprintf(@i18n.line('migration_missing_'+$method+'_method'), $class)
            return $next(@_error_string)

          if typeof $class::[$method] isnt 'function'
            @_error_string = sprintf(@i18n.line('migration_missing_'+$method+'_method'), $class)
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
      # @return [Void]  #
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
  # @return [Mixed]  true if already latest, false if failed, int if upgraded
  #
  latest: ($next) ->
    if not ($migrations = @find_migrations())
      @_error_string = @i18n.line('migration_none_found')
      return $next(@_error_string)

    $last_migration = basename($migrations[$migrations.length-1])

    # Calculate the last migration step from existing migration
    # filenames and procceed to the standard version migration
    @version $last_migration.substr(0, 3), ($err, $current_version) ->
      $next $err, $current_version

  #
  # Set's the schema to the migration version set in config
  #
  # @return [Mixed]  true if already current, false if failed, int if upgraded
  #
  current: ($next) ->
    @version @_migration_version, ($err, $current_version) ->
      $next $err, $current_version

  #
  # Error string
  #
  # @return  [String]  Error message returned as a string
  #
  errorString: () ->
    @_error_string

  #
  # Set's the schema to the latest migration
  #
  # @return [Mixed]  true if already latest, false if failed, int if upgraded
  #
  findMigrations: () ->

    # Load all#_*.coffee files in the migrations path
    $files = glob(@_migration_path + '*_*.coffee')
    $file_count = $files.length

    for $i in [0..$file_count-1]

      # Mark wrongly formatted files as false for later filtering
      $name = basename($files[$i], '.coffee')
      if not $name.match(/^\d{3}_(\w+)$/)
        $files[$i] = false

    $files.sort()


  #
  # Retrieves current schema version
  #
  # @return  int  Current Migration
  #
  getVersion: ($next) ->

    @db.from 'migrations'
    @db.where 'module', @_migration_module
    @db.get ($err, $result) ->

      return $next($err) if $err
      $row = $result.row()
      $next null, (if $row? then $row.version else 0)



  #
  # Stores the current schema version
  #
  # @param  int  Migration reached
  # @return  bool
  #
  _update_version: ($migrations, $next) ->

    @db.where 'module', @_migration_module
    @db.update 'migrations',
      'version': $migrations, $next

