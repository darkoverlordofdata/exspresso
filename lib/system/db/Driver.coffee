#+--------------------------------------------------------------------+
#| Driver.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Darklite is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+

#
# Abstract Database Driver Class
#
#
module.exports = class system.db.Driver

  async = require('async')
  #
  # @property [String] Dsn url. Overrides all other connection settings
  #
  url: ''
  #
  # @property [String] The hostname of your database server.
  #
  hostname: ''
  #
  # @property [String] The username used to connect to the database
  #
  username: ''
  #
  # @property [String] The password used to connect to the database
  #
  password: ''
  #
  # @property [String] The name of the database you want to connect to
  #
  database: ''
  #
  # @property [String] The database type: mysql | postgres | sqlite
  #
  dbdriver: ''
  #
  # @property [String] Optional table name prefix when using the Active Record class
  #
  dbprefix: ''
  #
  # @property [String] true/false - Whether database errors should be displayed.
  #
  db_debug: true
  #
  # @property [String] true/false - Enables/disables query caching
  #
  cache_on: true
  #
  # @property [String] The path to the folder where cache files should be stored
  #
  cachedir: ''
  #
  # @property [String] The character set used in communicating with the database
  #
  char_set: 'utf8'
  #
  # @property [String] The character collation used in communicating with the database
  #
  dbcollat: 'utf8_general_ci'
  #
  # @property [String] A default table prefix that should be swapped with the dbprefix
  #
  swap_pre: ''
  #
  # @property [String] Whether or not to automatically initialize the database.
  #
  autoinit: true
  #
  # @property [String] true/false - forces 'Strict Mode' connections
  #
  stricton: false
  #
  # @property [String] port to connect with
  #
  port: ''
  #
  # @property [Object] the connected db client reference
  #
  client: null
  #
  # @property [Array<String>] Saved queries array
  #
  queries: null
  #
  # @property [Array<Number>] Saved query times
  #
  query_times: null
  #
  # @property [system.core.Controller] The page controller
  #
  controller: null
  #
  # @property [String] The internal driver: mysql | pg | sqlite3
  #
  driver: ''
  #
  # @property [String] Internal driver version.
  #
  version: ''
  #
  # @property [String] true/false - Is db connected?
  #
  connected: false

  _query_count        : 0       # Count of saved queries
  _save_queries       : true    # true/false - Save queries in array for profiling
  _benchmark          : 0       # Query time
  _trans_enabled      : true    # true/false - Transactions enabled
  _trans_strict       : true    # true/false - Strict mode transactions
  _trans_depth        : 0       # Transaction nestion level
  _trans_status       : true    # Used with transactions to determine if a rollback should occur
  _cache              : null    # The controller cache object
  _cache_autodel      : false   # true/false - auto delete cache
  _data_cache         : null    # Table & field anmes
  _bind_marker        : '?'     # Symbol for parameter in query

  _protect_identifiers_default  : true
  _reserved_identifiers         : ['*']  #  Identifiers that should NOT be escaped



  #
  # Database connection settings
  #
  #
  # @param  [Object]  params  config array
  # @param  [system.core.Controller]  controller  the page controller
  #
  constructor: ($params = {}, $controller) ->

    Object.defineProperties @,
      controller    : {writeable: false, enumerable: true, value: $controller}
      queries       : {writeable: false, enumerable: true, value: []}
      query_times   : {writeable: false, enumerable: true, value: []}
      _data_cache   : {writeable: false, enumerable: true, value: {}}

    for $key, $val of $params
      if @[$key]? then @[$key] = $val

    log_message 'debug', '%s Driver Initialized', ucfirst(@dbdriver)


  #
  # Initialize Database Settings
  #
  # @private Called by the router
  # @param	callback
  # @return [Void]  #
  initialize: ($next) =>

    log_message 'debug', '%s Driver initialized', ucfirst(@dbdriver)
    if $next?
      @connect $next



  #
  # The name of the platform in use (mysql, mssql, etc...)
  #
  # @return	[String]
  #
  platform: ->
    return @dbdriver


  #
  # Database Version Number.  Returns a string containing the
  # version of the database being used
  #
  # @return	[String]
  #
  dbVersion: ($next) ->
    if false is ($sql = @_db_version())
      return $next(@displayError('db_unsupported_function'))

    @query $sql, $next




  #
  # Execute a list of sql statements in order
  #
  # @param  [Array<String>] sql array of sql statements
  # #param  [Function] next async callback
  # @return none
  #
  queryList: ($sql, $next) ->

    async.mapSeries $sql, @query, $next

#    $results = []
#    $index = 0
#    $query = @query
#
#    $iterate = =>
#
#      return $next(null, $results) if $sql.length is 0
#      #
#      # execute sql
#      #
#      $query $sql[$index], ($err, $result) =>
#        return $next($err) if $err
#
#        $results.push $result
#        $index += 1
#        if $index is $sql.length then $next null, $results
#        else $iterate()
#
#    $iterate()



  #
  # Execute the query
  #
  # Accepts an SQL string as input and returns a result object upon
  # successful execution of a "read" type query.  Returns boolean TRUE
  # upon successful execution of a "write" type query. Returns boolean
  # FALSE upon failure, and if the $db_debug variable is set to TRUE
  # will raise an error.
  #
  # @param  [String]  An SQL query string
  # @param  [Array]  An array of binding data
  # @return [Mixed]
  #
  query: ($sql, $binds, $next) =>

    # validate parameters
    [$binds, $next] = [null, $binds] unless $next?
    throw Error('Invalid Async Callback') unless $next?
    if $sql is ''
      return $next(Error(@displayError('db_invalid_query')))

    #  Verify table prefix and replace if necessary
    if (@dbprefix isnt '' and @swap_pre isnt '') and (@dbprefix isnt @swap_pre)
      $sql = $sql.replace(RegExp("(\\W)" + @swap_pre + "(\\S+?)", 'mig'), "$1" + @dbprefix + "$2")

    #  Save the  query for debugging
    @queries.push $sql if @_save_queries

    #  Start the Query Timer
    $time_start = Date.now()

    async.waterfall [

      #
      # 1 - Try to read cached query
      #
      ($step) =>

        if @cache_on is true and $sql.search(/^SELECT/i) isnt -1
          @_cache_init()
          @_cache_read $sql, $step
        else
          $step(null, false)

      #
      # 2 - If no cache, execute Sql
      #
      ,
      ($cache, $step) =>

        if $cache is false
          @_execute $sql, $binds, $step

        else
          $driver = @_load_rdriver()
          $rs = new $driver($cache.data, $cache.meta)
          # do NOT pass go
          # do NOT collect $200
          $next(null, $rs, $rs._meta)

      #
      # 3 - Finish up
      #
      ,
      ($data, $meta, $step) =>

        [$meta, $step] = [null, $meta] unless $step?
        # profile
        $time_end = Date.now()
        @_benchmark+= $time_end - $time_start
        if @_save_queries is true
          @query_times.push $time_end - $time_start
        @_query_count++

        # create the result set
        $driver = @_load_rdriver()
        $rs = new $driver($data, $meta)

        # delete cache?
        if @is_write_type($sql) is true and @cache_on is true and @_cache_autodel is true
          @_cache_init()
          @_cache.delete()

        # write cache?
        if @cache_on
          @_cache_init()
          @_cache.write $sql, $rs, $step
        else
          $step null, $rs

      #
      # Done
      #
      ],
      ($err, $rs) =>
        if $err?
          #  Trigger a rollback if transactions are being used
          @_trans_status = false
          return show_error($err)
        else
          $next null, $rs, $rs._meta


  #
  # Load the result drivers
  #
  # @private
  # @return	[Class] the result set driver class
  #
  _load_rdriver :  ->
    require SYSPATH + 'db/Result.coffee'
    $driver = require(SYSPATH + 'db/drivers/' + @dbdriver + '/' + ucfirst(@dbdriver) + 'Result.coffee')


  #
  # Simple Query
  # This is a simplified version of the query() function.  Internally
  # we only use it when running transaction commands since they do
  # not require all the features of the main query() function.
  #
  # @param  [String]  the sql query
  # @return [Mixed]
  #
  simpleQuery: ($sql, $binds, $next) =>

    # validate parameters
    [$binds, $next] = [null, $binds] unless $next?
    throw Error('Invalid Async Callback') unless $next?
    if $sql is ''
      return $next(Error(@displayError('db_invalid_query')))

    @_execute $sql, $binds, $next


  #
  # Disable Transactions
  # This permits transactions to be disabled at run-time.
  #
  # @return [Void]  #
  transOff: ->
    @_trans_enabled = false


  #
  # Enable/disable Transaction Strict Mode
  # When strict mode is enabled, if you are running multiple groups of
  # transactions, if one group fails all groups will be rolled back.
  # If strict mode is disabled, each group is treated autonomously, meaning
  # a failure of one group will not affect any others
  #
  # @return [Void]  #
  transStrict : ($mode = true) ->
    @_trans_strict = if 'boolean' is typeof($mode) then $mode else true


  #
  # Start Transaction
  #
  # @return [Void]  #
  transStart : ($test_mode = false, $next) ->
    if $next is null
      $next = $test_mode
      $test_mode = false

    if not @_trans_enabled
      return $next null, false

    #  When transactions are nested we only begin/commit/rollback the outermost ones
    if @_trans_depth > 0
      @_trans_depth+=1
      return $next null

    @transBegin($test_mode, $next)


  #
  # Complete Transaction
  #
  # @return	bool
  #
  transComplete: ($next) ->
    if not @_trans_enabled
      return $next null, false

    #  When transactions are nested we only begin/commit/rollback the outermost ones
    if @_trans_depth > 1
      @_trans_depth-=1
      return $next null, true

    #  The query() function will set this flag to FALSE in the event that a query failed
    if @_trans_status is false
      @trans_rollback ($err) =>

        if $err then return $next $err
        #  If we are NOT running in strict mode, we will reset
        #  the _trans_status flag so that subsequent groups of transactions
        #  will be permitted.
        if @transStrict is false
          @_trans_status = true

        log_message('debug', 'DB Transaction Failure')
        return $next null, false

    @trans_commit($next)


  #
  # Lets you retrieve the transaction flag to determine if it has failed
  #
  # @return	bool
  #
  transStatus: ->
    return @_trans_status


  #
  # Compile Bindings
  #
  # @param  [String]  the sql statement
  # @param  [Array]  an array of bind data
  # @return	[String]
  #
  compile_binds : ($sql, $binds) ->
    return $sql if $sql.indexOf(@_bind_marker) is -1

    $binds = [$binds] if not Array.isArray($binds)

    #  Get the sql segments around the bind markers
    $segments = $sql.split(@_bind_marker)

    #  The count of bind should be 1 less then the count of segments
    #  If there are more bind arguments trim it down
    if $binds.length>=$segments.length
      $binds = $binds.slice(0, $segments.length - 1)


    #  Construct the binded query
    $result = $segments[0]
    $i = 0
    for $bind in $binds
      $result+=@escape($bind)
      $result+=$segments[++$i]


    return $result


  #
  # Determines if a query is a "write" type.
  #
  # @param  [String]  An SQL query string
  # @return	[Boolean]
  #
  is_write_type : ($sql) ->
    if not /^\s*"?(SET|INSERT|UPDATE|DELETE|REPLACE|CREATE|DROP|TRUNCATE|LOAD DATA|COPY|ALTER|GRANT|REVOKE|LOCK|UNLOCK)\s+/i.test($sql)
      return false

    return true


  #
  # Calculate the aggregate query elapsed time
  #
  # @param  [Integer]  The number of decimal places
  # @return	integer
  #
  elapsedTime : ($decimals = 6) ->
    return number_format(@_benchmark, $decimals)


  #
  # Returns the total number of queries
  #
  # @return	integer
  #
  totalQueries: ->
    return @_query_count


  #
  # Returns the last query that was executed
  #
  # @return [Void]  #
  lastQuery: ->
    if @queries.length is 0 then false else @queries[@queries.length-1]


  #
  # "Smart" Escape String
  #
  # Escapes data based on type
  # Sets boolean and null types
  #
  # @param  [String]  # @return [Mixed]  #
  escape : ($str) ->
    if 'string' is typeof($str)
      $str = @escapeStr($str)
      # $str = "'" + @escapeStr($str) + "'"

    else if 'boolean' is typeof($str)
      $str = if ($str is false) then 0 else 1

    else if not($str?)
      $str = 'NULL'


    return $str


  #
  # Escape LIKE String
  #
  # Calls the individual driver for platform
  # specific escaping for LIKE conditions
  #
  # @param  [String]  # @return [Mixed]  #
  escapeLikeStr : ($str) ->
    return @escapeStr($str, true)


  #
  # Primary
  #
  # Retrieves the primary key.  It assumes that the row in the first
  # position is the primary key
  #
  # @param  [String]  the table name
  # @return	[String]
  #
  primary : ($table = '') ->
    $fields = @list_fields($table)

    if not Array.isArray($fields)
      return false


    return $fields[0]


  #
  # Returns an array of table names
  #
  # @return	array
  #
  listTables : ($constrain_by_prefix = false, $next = null) ->

    if $next is null
      $next = $constrain_by_prefix
      $constrain_by_prefix = false

    #  Is there a cached result?
    if @_data_cache['table_names']?
      return $next null, @_data_cache['table_names']


    if false is ($sql = @_list_tables($constrain_by_prefix))
      if @db_debug
        return $next @displayError('db_unsupported_function')

      return $next false

    $retval = []
    @query $sql, ($err, $query) =>

      if $query.num_rows > 0
        for $row in $query.result()
          if $row['TABLE_NAME']?
            $retval.push $row['TABLE_NAME']

          else
            $retval.push $row[Object.keys($row)[0]]

      @_data_cache['table_names'] = $retval
      $next $err, @_data_cache['table_names']


  #
  # Determine if a particular table exists
  # @return	[Boolean]
  #
  tableExists : ($table_name, $next) ->

    @listTables ($err, $table_names) =>

      if $err then return $next $err

      $table_exists = if $table_names.indexOf(@_protect_identifiers($table_name, true, false, false)) is -1 then false else true
      $next null, $table_exists


  #
  # Fetch MySQL Field Names
  #
  # @param  [String]  the table name
  # @return	array
  #
  listFields : ($table = '', $next) ->
    #  Is there a cached result?
    if @_data_cache['field_names'][$table]?
      return @_data_cache['field_names'][$table]


    if $table is ''
      if @db_debug
        return @displayError('db_field_param_missing')

      return false


    if false is ($sql = @_list_columns($table))
      if @db_debug
        return @displayError('db_unsupported_function')

      return false


    @query $sql, ($err, $results) ->

      $retval = []
      for $row in $query.result()
        if $row['COLUMN_NAME']?
          $retval.push $row['COLUMN_NAME']

        else
          $retval.push $row[Object.keys($row)[0]]


      @_data_cache['field_names'][$table] = $retval
      $next $err, @_data_cache['field_names'][$table]


  #
  # Determine if a particular field exists
  # @param  [String]  # @param  [String]  # @return	[Boolean]
  #
  fieldExists : ($field_name, $table_name) ->
    if @list_fields($table_name).indexOf($field_name) is -1 then false else true


  #
  # Returns an object with field data
  #
  # @param  [String]  the table name
  # @return [Object]  #
  field_data : ($table = '', $next) ->
    if $table is ''
      if @db_debug
        return @displayError('db_field_param_missing')

      return false


    @query @_field_data(@_protect_identifiers($table, true, null, false)), ($err, $results) ->

      $next $err, $results


  #
  # Generate an insert string
  #
  # @param  [String]  the table upon which the query will be performed
  # @param  [Array]  an associative array data of key/values
  # @return	[String]
  #
  insert_string : ($table, $data) ->
    $fields = []
    $values = []

    for $key, $val of $data
      $fields.push @_escape_identifiers($key)
      $values.push @escape($val)


    return @_insert(@_protect_identifiers($table, true, null, false), $fields, $values)


  #
  # Generate an update string
  #
  # @param  [String]  the table upon which the query will be performed
  # @param  [Array]  an associative array data of key/values
  # @param  [Mixed]  the "where" statement
  # @return	[String]
  #
  update_string : ($table, $data, $where) ->
    if $where is ''
      return false

    $fields = []
    for $key, $val of $data
      $fields[@_protect_identifiers($key)] = @escape($val)

    if 'string' is typeof($where)
      $dest = [$where]

    else
      $dest = []
      for $key, $val of $where
        $prefix = if $dest.length is 0 then '' else ' AND '

        if $val isnt ''
          if not @_has_operator($key)
            $key+=' ='

          $val = ' ' + @escape($val)

        $dest.push $prefix + $key + $val

    return @_update(@_protect_identifiers($table, true, null, false), $fields, $dest)


  #
  # Tests whether the string has an SQL operator
  #
  # @private
  # @param  [String]  # @return	bool
  #
  _has_operator : ($str) ->
    $str = trim($str)
    if not /(\\s|<|>|!|=|is null|is not null)/i.test($str)
      return false


    return true


  #
  # Set Cache Directory Path
  #
  # @param  [String]  the path to the cache directory
  # @return [Void]
  #
  cacheSetPath : ($path = '') ->
    @cachedir = $path


  #
  # Enable Query Caching
  #
  # @return [Void]
  #
  cacheOn: ->
    @cache_on = true
    return true


  #
  # Disable Query Caching
  #
  # @return [Void]
  #
  cacheOff: ->
    @cache_on = false
    return false



  #
  # Delete the cache files associated with a particular URI
  #
  # @return [Void]
  #
  cacheDelete : ($segment_one = '', $segment_two = '') ->
    @_cache_init()
    @_cache.delete($segment_one, $segment_two)


  #
  # Delete All cache files
  #
  # @return [Void]
  #
  cacheDeleteAll: () ->
    @_cache_init()
    @_cache.deleteAll()


  #
  # Initialize the Cache Class
  #
  # @private
  # @return [Void]
  #
  _cache_init: ->
    return true if @_cache?

    require(SYSPATH + 'db/Cache' + EXT)
    Object.defineProperties @,
      _cache    : {writeable: false, enumerable: true, value: new system.db.Cache(@, @controller.uri)}
    return true

  #
  # Close DB Connection
  #
  # @return [Void]
  #
  close: ($next)->

    @conn_id = false
    @_close($next)


  #
  # Display an error message
  #
  # @param  [String]  the error message
  # @param  [String]  any "swap" values
  # @return	[Boolean]ean	whether to localize the message
  # @return	[String]	sends the application/error_db.php template
  #
  displayError : ($error = '', $swap = '', $native = false) ->

    @i18n.load('db')
    $message = if $native is true then $error
    else if 'string' is typeof($error) then @i18n.line($error).replace('%s', $swap) else $error

    console.log $message
    $message


  #
  # Protect Identifiers
  #
  # This function adds backticks if appropriate based on db type
  #
  # @private
  # @param  [Mixed]  the item to escape
  # @return [Mixed]  the item with backticks
  #
  protect_identifiers : ($item, $prefix_single = false) ->
    @_protect_identifiers($item, $prefix_single)


  #
  # Protect Identifiers
  #
  # This function is used extensively by the Active Record class, and by
  # a couple functions in this class.
  # It takes a column or table name (optionally with an alias) and inserts
  # the table prefix onto it.  Some logic is necessary in order to deal with
  # column names that include the path.  Consider a query like this:
  #
  # SELECT * FROM hostname.database.table.column AS c FROM hostname.database.table
  #
  # Or a query with aliasing:
  #
  # SELECT m.member_id, m.member_name FROM members AS m
  #
  # Since the column name can include up to four segments (host, DB, table, column)
  # or also have an alias prefix, we need to do a bit of work to figure this out and
  # insert the table prefix (if it exists) in the proper position, and escape only
  # the correct identifiers.
  #
  # @private
  # @param  [String]  # @return	[Boolean]
  # @param  [Mixed]  # @return	[Boolean]
  # @return	[String]F
  #
  _protect_identifiers: ($item, $prefix_single = false, $protect_identifiers = null, $field_exists = true) ->

    if 'boolean' isnt typeof($protect_identifiers)
      $protect_identifiers = @_protect_identifiers_default

    if Array.isArray($item)
      $escaped_array = []
      for $v in $item
        $escaped_array.push @_protect_identifiers($v)
      return $escaped_array

    if 'object' is typeof($item)
      $escaped_array = []
      for $k, $v of $item
        $escaped_array[@_protect_identifiers($k)] = @_protect_identifiers($v)
      return $escaped_array

    #  Convert tabs or multiple spaces into single spaces
    $item = $item.replace(/[\t ]+/g, ' ')

    #  If the item has an alias declaration we remove it and set it aside.
    #  Basically we remove everything to the right of the first space
    $alias = ''
    if ($pos = $item.indexOf(' ')) isnt -1
      $alias = $item.substr($pos)
      $item = $item.substr(0, $pos)

    #  This is basically a bug fix for queries that use MAX, MIN, etc.
    #  If a parenthesis is found we know that we do not need to
    #  escape the data or add a prefix.  There's probably a more graceful
    #  way to deal with this, but I'm not thinking of it -- Rick
    if $item.indexOf('(') isnt -1
      return $item + $alias


    #  Break the string apart if it contains periods, then insert the table prefix
    #  in the correct location, assuming the period doesn't indicate that we're dealing
    #  with an alias. While we're at it, we will escape the components
    if $item.indexOf('.') isnt -1
      $parts = $item.split('.')

      #  Does the first segment of the exploded item match
      #  one of the aliases previously identified?  If so,
      #  we have nothing more to do other than escape the item
      if @ar_aliased_tables.indexOf($parts[0]) isnt -1
        if $protect_identifiers is true
          for $key, $val of $parts
            if @_reserved_identifiers.indexOf($val) is -1
              $parts[$key] = @_escape_identifiers($val)

          $item = $parts.join('.')
        return $item + $alias


      #  Is there a table prefix defined in the config file?  If not, no need to do anything
      if @dbprefix isnt ''
        #  We now add the table prefix based on some logic.
        #  Do we have 4 segments (hostname.database.table.column)?
        #  If so, we add the table prefix to the column name in the 3rd segment.
        if $parts[3]?
          $i = 2

          #  Do we have 3 segments (database.table.column)?
          #  If so, we add the table prefix to the column name in 2nd position
        else if $parts[2]?
          $i = 1

          #  Do we have 2 segments (table.column)?
          #  If so, we add the table prefix to the column name in 1st segment
        else
          $i = 0


        #  This flag is set when the supplied $item does not contain a field name.
        #  This can happen when this function is being called from a JOIN.
        if $field_exists is false
          $i++

        #  Verify table prefix and replace if necessary
        if @swap_pre isnt '' and $parts[$i].substr(0,@swap_pre.length) is @swap_pre
          $parts[$i] = $parts[$i].replace(RegExp("^" + @swap_pre + "(\\S+?)"), @dbprefix + "$1")

        #  We only add the table prefix if it does not already exist
        if $parts[$i].substr(0, @dbprefix.length) isnt @dbprefix
          $parts[$i] = @dbprefix + $parts[$i]

        #  Put the parts back together
        $item = $parts.join('.')


      if $protect_identifiers is true
        $item = @_escape_identifiers($item)

      return $item + $alias


    #  Is there a table prefix?  If not, no need to insert it
    if @dbprefix isnt ''
      #  Verify table prefix and replace if necessary
      if @swap_pre isnt '' and $item.substr(0, @swap_pre.length) is @swap_pre
        $item = $item.replace(RegExp("^" + @swap_pre + "(\\S+?)"), @dbprefix + "$1")

      #  Do we prefix an item with no segments?
      if $prefix_single is true and $item.substr(0, @dbprefix.lenth) isnt @dbprefix
        $item = @dbprefix + $item

    if $protect_identifiers is true and @_reserved_identifiers.indexOf($item) is -1
      $item = @_escape_identifiers($item)


    return $item + $alias
