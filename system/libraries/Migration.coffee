#+--------------------------------------------------------------------+
#| Exspresso_Migration.coffee
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
# Exspresso_Migration class
#
#   Allow per module migrations
#
require BASEPATH+'libraries/Base/Migration.coffee'

class global.Exspresso_Migration extends Base_Migration

  _migration_module: ''


  #-------------------------------------------------------------------

  #
  # Create migration table if it isn't found
  #
  #
  # @param  function
  # @return void
  #
  initialize: ($next) ->

    if @connected is true then return $next null
    @connected = true

    # If the migrations table is missing, make it
    @db.table_exists 'migrations', ($err, $table_exists) =>

      if $err then return $next $err
      if $table_exists then return $next null

      @dbforge.add_field
        'module' :
          'type' : 'VARCHAR'
          'constraint' : 40
        'version' :
          'type' : 'INT'
          'constraint' : 3

      @dbforge.create_table 'migrations', true, ($err) =>

        if $err then return $next $err
        @db.insert 'migrations', version: 0, $next

  #-------------------------------------------------------------------

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
  set_module: ($module = '') ->

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

  #-------------------------------------------------------------------

  #
  # Retrieves current schema version
  #
  # @return  int  Current Migration
  #
  get_version: ($next) ->

    #@db.where 'module', @_migration_module
    @db.get 'migrations', ($err, $result) ->

      if $err then return $next $err
      $row = $result.row()
      $next null, if $row then $row.version else 0


  #-------------------------------------------------------------------

  #
  # Stores the current schema version
  #
  # @param  int  Migration reached
  # @return  bool
  #
  _update_version: ($migrations, $next) ->

    #@db.where 'module', @_migration_module
    @db.update 'migrations'
      'version': $migrations, $next

module.exports = Exspresso_Migration

# End of file Migration.coffee
# Location: ./core/libraries/Migration.coffee