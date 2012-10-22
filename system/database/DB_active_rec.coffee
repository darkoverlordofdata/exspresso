#+--------------------------------------------------------------------+
#  DB_active_rec.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# This file was ported from php to coffee-script using php2coffee v6.6.6
#
#

{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{array_keys, array_merge, array_slice, array_unique, array_values, count, current, end, explode, implode, in_array, is_array, is_bool, is_null, is_numeric, is_object, is_string, preg_match, preg_replace, strpos, strrchr, strtolower, strtoupper, trim}  = require(FCPATH + 'lib')
{config_item, get_class, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

CI_DB_driver   = require(BASEPATH + 'database/DB_driver') # Exspresso DB driver Base Class

array = ($field, $match) ->
  $array = {}
  $array[$field] = $match
  return $array

#  ------------------------------------------------------------------------

#
# Active Record Class
#
# This is the platform-independent base Active Record implementation class.
#
#
class CI_DB_active_record extends CI_DB_driver
  
  ar_select:          []
  ar_distinct:        false
  ar_from:            []
  ar_join:            []
  ar_where:           []
  ar_like:            []
  ar_groupby:         []
  ar_having:          []
  ar_keys:            []
  ar_limit:           false
  ar_offset:          false
  ar_order:           false
  ar_orderby:         []
  ar_set:             []
  ar_wherein:         []
  ar_aliased_tables:  []
  ar_store_array:     []
  
  #  Active Record Caching variables
  ar_caching:         false
  ar_cache_exists:    []
  ar_cache_select:    []
  ar_cache_from:      []
  ar_cache_join:      []
  ar_cache_where:     []
  ar_cache_like:      []
  ar_cache_groupby:   []
  ar_cache_having:    []
  ar_cache_orderby:   []
  ar_cache_set:       []

  #  --------------------------------------------------------------------

  #
  # Constructor.  Accepts one parameter containing the database
  # connection settings.
  #
  # @param array
  #
  constructor: ($params = {}) ->
    super($params)
    @_reset_select()  # make sure the member var's are own properties
                      # of 'this' - otherwise it fails somewhere,
                      # and we get inconsistent error messages
  
  #  --------------------------------------------------------------------
  
  #
  # Select
  #
  # Generates the SELECT portion of the query
  #
  # @access	public
  # @param	string
  # @return	object
  #
  #select: ($select = '*', $escape = null) ->
    #  Set the global value if this was sepecified
    #if is_bool($escape)
      #@_protect_identifiers_default = $escape
      
  select: ($select) ->

    if is_string($select)
      $select = explode(',', $select)
      
    for $val in $select
      $val = trim($val)
      
      if $val isnt ''
        @ar_select.push $val
        
        if @ar_caching is true
          @ar_cache_select.push $val
          @ar_cache_exists.push 'select'
          
        
      
    return @
    
  
  #  --------------------------------------------------------------------
  
  #
  # Select Max
  #
  # Generates a SELECT MAX(field) portion of a query
  #
  # @access	public
  # @param	string	the field
  # @param	string	an alias
  # @return	object
  #
  select_max: ($select = '', $alias = '') ->
    return @_max_min_avg_sum($select, $alias, 'MAX')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Select Min
  #
  # Generates a SELECT MIN(field) portion of a query
  #
  # @access	public
  # @param	string	the field
  # @param	string	an alias
  # @return	object
  #
  select_min: ($select = '', $alias = '') ->
    return @_max_min_avg_sum($select, $alias, 'MIN')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Select Average
  #
  # Generates a SELECT AVG(field) portion of a query
  #
  # @access	public
  # @param	string	the field
  # @param	string	an alias
  # @return	object
  #
  select_avg: ($select = '', $alias = '') ->
    return @_max_min_avg_sum($select, $alias, 'AVG')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Select Sum
  #
  # Generates a SELECT SUM(field) portion of a query
  #
  # @access	public
  # @param	string	the field
  # @param	string	an alias
  # @return	object
  #
  select_sum: ($select = '', $alias = '') ->
    return @_max_min_avg_sum($select, $alias, 'SUM')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Processing Function for the four functions above:
  #
  #	select_max()
  #	select_min()
  #	select_avg()
  #  select_sum()
  #
  # @access	public
  # @param	string	the field
  # @param	string	an alias
  # @return	object
  #
  _max_min_avg_sum: ($select = '', $alias = '', $type = 'MAX') ->
    if not is_string($select) or $select is ''
      @display_error('db_invalid_query')
      
    
    $type = strtoupper($type)
    
    if not in_array($type, ['MAX', 'MIN', 'AVG', 'SUM'])
      show_error('Invalid function type: ' + $type)
      
    
    if $alias is ''
      $alias = @_create_alias_from_table(trim($select))
      
    
    $sql = $type + '(' + @_protect_identifiers(trim($select)) + ') AS ' + $alias
    
    @ar_select.push $sql
    
    if @ar_caching is true
      @ar_cache_select.push $sql
      @ar_cache_exists.push 'select'
      
    
    return @
    
  
  #  --------------------------------------------------------------------
  
  #
  # Determines the alias name based on the table
  #
  # @access	private
  # @param	string
  # @return	string
  #
  _create_alias_from_table: ($item) ->
    if strpos($item, '.') isnt false
      return end(explode('.', $item))
      
    
    return $item
    
  
  #  --------------------------------------------------------------------
  
  #
  # DISTINCT
  #
  # Sets a flag which tells the query string compiler to add DISTINCT
  #
  # @access	public
  # @param	bool
  # @return	object
  #
  distinct: ($val = true) ->
    @ar_distinct = if (is_bool($val)) then $val else true
    return @
    
  
  #  --------------------------------------------------------------------
  
  #
  # From
  #
  # Generates the FROM portion of the query
  #
  # @access	public
  # @param	mixed	can be a string or array
  # @return	object
  #
  from: ($from) ->
    if is_string($from) then $from = [$from]
    for $val in $from
      if strpos($val, ',') isnt false
        for $v in explode(',', $val)
          $v = trim($v)
          @_track_aliases($v)
          
          @ar_from.push @_protect_identifiers($v, true, null, false)
          
          if @ar_caching is true
            @ar_cache_from.push @_protect_identifiers($v, true, null, false)
            @ar_cache_exists.push 'from'

      else 
        $val = trim($val)
        
        #  Extract any aliases that might exist.  We use this information
        #  in the _protect_identifiers to know whether to add a table prefix
        @_track_aliases($val)
        
        @ar_from.push @_protect_identifiers($val, true, null, false)
        
        if @ar_caching is true
          @ar_cache_from.push @_protect_identifiers($val, true, null, false)
          @ar_cache_exists.push 'from'

    return @
    
  
  #  --------------------------------------------------------------------
  
  #
  # Join
  #
  # Generates the JOIN portion of the query
  #
  # @access	public
  # @param	string
  # @param	string	the join condition
  # @param	string	the type of join
  # @return	object
  #
  join: ($table, $cond, $type = '') ->
    if $type isnt ''
      $type = strtoupper(trim($type))
      
      if not in_array($type, ['LEFT', 'RIGHT', 'OUTER', 'INNER', 'LEFT OUTER', 'RIGHT OUTER'])
        $type = ''
        
      else 
        $type+=' '
    
    #  Extract any aliases that might exist.  We use this information
    #  in the _protect_identifiers to know whether to add a table prefix
    @_track_aliases($table)
    
    #  Strip apart the condition and protect the identifiers
    # if preg_match('/([\w\.]+)([\W\s]+)(.+)/', $cond, $match)
    $match = preg_match('/([\\w\\.]+)([\\W\\s]+)(.+)/', $cond)
    if $match?
      $match[1] = @_protect_identifiers($match[1])
      $match[3] = @_protect_identifiers($match[3])
      
      $cond = $match[1] + $match[2] + $match[3]
      
    
    #  Assemble the JOIN statement
    $join = $type + 'JOIN ' + @_protect_identifiers($table, true, null, false) + ' ON ' + $cond
    
    @ar_join.push $join
    if @ar_caching is true
      @ar_cache_join.push $join
      @ar_cache_exists.push 'join'
      
    
    return @
    
  
  #  --------------------------------------------------------------------
  
  #
  # Where
  #
  # Generates the WHERE portion of the query. Separates
  # multiple calls with AND
  #
  # @access	public
  # @param	mixed
  # @param	mixed
  # @return	object
  #
  where: ($key, $value = null, $escape = true) ->
    return @_where($key, $value, 'AND ', $escape)
    
  
  #  --------------------------------------------------------------------
  
  #
  # OR Where
  #
  # Generates the WHERE portion of the query. Separates
  # multiple calls with OR
  #
  # @access	public
  # @param	mixed
  # @param	mixed
  # @return	object
  #
  or_where: ($key, $value = null, $escape = true) ->
    return @_where($key, $value, 'OR ', $escape)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Where
  #
  # Called by where() or orwhere()
  #
  # @access	private
  # @param	mixed
  # @param	mixed
  # @param	string
  # @return	object
  #
  _where: ($key, $value = null, $type = 'AND ', $escape = null) ->
    if not is_array($key)
      $key = array($key, $value)

    #  If the escape value was not set will will base it on the global setting
    if not is_bool($escape)
      $escape = @_protect_identifiers_default
    
    for $k, $v of $key
      $prefix = if (count(@ar_where) is 0 and count(@ar_cache_where) is 0) then '' else $type
      
      if is_null($v) and  not @_has_operator($k)
        #  value appears not to have been set, assign the test to IS NULL
        $k+=' IS NULL'
      
      if not is_null($v)
        if $escape is true
          $k = @_protect_identifiers($k, false, $escape)
          $v = ' ' + @escape($v)
        
        if not @_has_operator($k)
          $k+=' ='
        
      else 
        $k = @_protect_identifiers($k, false, $escape)
      
      @ar_where.push $prefix + $k + $v
      
      if @ar_caching is true
        @ar_cache_where.push $prefix + $k + $v
        @ar_cache_exists.push 'where'

    return @
    
  
  #  --------------------------------------------------------------------
  
  #
  # Where_in
  #
  # Generates a WHERE field IN ('item', 'item') SQL query joined with
  # AND if appropriate
  #
  # @access	public
  # @param	string	The field to search
  # @param	array	The values searched on
  # @return	object
  #
  where_in: ($key = null, $values = null) ->
    return @_where_in($key, $values)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Where_in_or
  #
  # Generates a WHERE field IN ('item', 'item') SQL query joined with
  # OR if appropriate
  #
  # @access	public
  # @param	string	The field to search
  # @param	array	The values searched on
  # @return	object
  #
  or_where_in: ($key = null, $values = null) ->
    return @_where_in($key, $values, false, 'OR ')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Where_not_in
  #
  # Generates a WHERE field NOT IN ('item', 'item') SQL query joined
  # with AND if appropriate
  #
  # @access	public
  # @param	string	The field to search
  # @param	array	The values searched on
  # @return	object
  #
  where_not_in: ($key = null, $values = null) ->
    return @_where_in($key, $values, true)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Where_not_in_or
  #
  # Generates a WHERE field NOT IN ('item', 'item') SQL query joined
  # with OR if appropriate
  #
  # @access	public
  # @param	string	The field to search
  # @param	array	The values searched on
  # @return	object
  #
  or_where_not_in: ($key = null, $values = null) ->
    return @_where_in($key, $values, true, 'OR ')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Where_in
  #
  # Called by where_in, where_in_or, where_not_in, where_not_in_or
  #
  # @access	public
  # @param	string	The field to search
  # @param	array	The values searched on
  # @param	boolean	If the statement would be IN or NOT IN
  # @param	string
  # @return	object
  #
  _where_in: ($key = null, $values = null, $not = false, $type = 'AND ') ->
    if $key is null or $values is null
      return 
    
    if not is_array($values)
      $values = [$values]
    
    $not = if ($not) then ' NOT' else ''
    
    for $value in $values
      @ar_wherein.push @escape($value)
    
    $prefix = if (count(@ar_where) is 0) then '' else $type
    
    $where_in = $prefix + @_protect_identifiers($key) + $not + " IN (" + implode(", ", @ar_wherein) + ") "
    
    @ar_where.push $where_in
    if @ar_caching is true
      @ar_cache_where.push $where_in
      @ar_cache_exists.push 'where'
      
    
    #  reset the array for multiple calls
    @ar_wherein = []
    return @
    
  
  #  --------------------------------------------------------------------
  
  #
  # Like
  #
  # Generates a %LIKE% portion of the query. Separates
  # multiple calls with AND
  #
  # @access	public
  # @param	mixed
  # @param	mixed
  # @return	object
  #
  like: ($field, $match = '', $side = 'both') ->
    return @_like($field, $match, 'AND ', $side)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Not Like
  #
  # Generates a NOT LIKE portion of the query. Separates
  # multiple calls with AND
  #
  # @access	public
  # @param	mixed
  # @param	mixed
  # @return	object
  #
  not_like: ($field, $match = '', $side = 'both') ->
    return @_like($field, $match, 'AND ', $side, 'NOT')
    
  
  #  --------------------------------------------------------------------
  
  #
  # OR Like
  #
  # Generates a %LIKE% portion of the query. Separates
  # multiple calls with OR
  #
  # @access	public
  # @param	mixed
  # @param	mixed
  # @return	object
  #
  or_like: ($field, $match = '', $side = 'both') ->
    return @_like($field, $match, 'OR ', $side)
    
  
  #  --------------------------------------------------------------------
  
  #
  # OR Not Like
  #
  # Generates a NOT LIKE portion of the query. Separates
  # multiple calls with OR
  #
  # @access	public
  # @param	mixed
  # @param	mixed
  # @return	object
  #
  or_not_like: ($field, $match = '', $side = 'both') ->
    return @_like($field, $match, 'OR ', $side, 'NOT')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Like
  #
  # Called by like() or orlike()
  #
  # @access	private
  # @param	mixed
  # @param	mixed
  # @param	string
  # @return	object
  #
  _like: ($field, $match = '', $type = 'AND ', $side = 'both', $not = '') ->
    if not is_array($field)
      $field = array($field, $match)
    
    for $k, $v of $field
      $k = @_protect_identifiers($k)
      
      $prefix = if (count(@ar_like) is 0) then '' else $type
      
      #$v = @escape_like_str($v)
      
      if $side is 'before'
        $like_statement = $prefix + " #{$k} #{$not} LIKE '#{$v}'"
        
      else if $side is 'after'
        $like_statement = $prefix + " #{$k} #{$not} LIKE '#{$v}%'"
        
      else 
        $like_statement = $prefix + " #{$k} #{$not} LIKE '%#{$v}%'"
        
      
      #  some platforms require an escape sequence definition for LIKE wildcards
      if @_like_escape_str isnt ''
        $like_statement = $like_statement + sprintf(@_like_escape_str, @_like_escape_chr)
      
      @ar_like.push $like_statement
      if @ar_caching is true
        @ar_cache_like.push $like_statement
        @ar_cache_exists.push 'like'

    return @
    
  
  #  --------------------------------------------------------------------
  
  #
  # GROUP BY
  #
  # @access	public
  # @param	string
  # @return	object
  #
  group_by: ($by) ->
    if is_string($by)
      $by = explode(',', $by)
    
    for $val in $by
      $val = trim($val)
      
      if $val isnt ''
        @ar_groupby.push @_protect_identifiers($val)
        
        if @ar_caching is true
          @ar_cache_groupby.push @_protect_identifiers($val)
          @ar_cache_exists.push 'groupby'

    return @
    
  
  #  --------------------------------------------------------------------
  
  #
  # Sets the HAVING value
  #
  # Separates multiple calls with AND
  #
  # @access	public
  # @param	string
  # @param	string
  # @return	object
  #
  having: ($key, $value = '', $escape = true) ->
    return @_having($key, $value, 'AND ', $escape)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Sets the OR HAVING value
  #
  # Separates multiple calls with OR
  #
  # @access	public
  # @param	string
  # @param	string
  # @return	object
  #
  or_having: ($key, $value = '', $escape = true) ->
    return @_having($key, $value, 'OR ', $escape)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Sets the HAVING values
  #
  # Called by having() or or_having()
  #
  # @access	private
  # @param	string
  # @param	string
  # @return	object
  #
  _having: ($key, $value = '', $type = 'AND ', $escape = true) ->
    if not is_array($key)
      $key = $key:$value
    
    for $k, $v of $key
      $prefix = if (count(@ar_having) is 0) then '' else $type
      
      if $escape is true
        $k = @_protect_identifiers($k)
      
      if not @_has_operator($k)
        $k+=' = '
      
      if $v isnt ''
        $v = ' ' + @escape_str($v)
      
      @ar_having.push $prefix + $k + $v
      if @ar_caching is true
        @ar_cache_having.push $prefix + $k + $v
        @ar_cache_exists.push 'having'
    
    return @
    
  
  #  --------------------------------------------------------------------
  
  #
  # Sets the ORDER BY value
  #
  # @access	public
  # @param	string
  # @param	string	direction: asc or desc
  # @return	object
  #
  order_by: ($orderby, $direction = '') ->
    if strtolower($direction) is 'random'
      $orderby = ''#  Random results want or don't need a field name
      $direction = @_random_keyword
      
    else if trim($direction) isnt ''
      $direction = if (in_array(strtoupper(trim($direction)), ['ASC', 'DESC'], true)) then ' ' + $direction else ' ASC'
    
    if strpos($orderby, ',') isnt false
      $temp = []
      for $part in explode(',', $orderby)
        $part = trim($part)
        if not in_array($part, @ar_aliased_tables)
          $part = @_protect_identifiers(trim($part))
          
        $temp.push $part
      
      $orderby = implode(', ', $temp)
      
    else if $direction isnt @_random_keyword
      $orderby = @_protect_identifiers($orderby)
    
    $orderby_statement = $orderby + $direction
    
    @ar_orderby.push $orderby_statement
    if @ar_caching is true
      @ar_cache_orderby.push $orderby_statement
      @ar_cache_exists.push 'orderby'
    
    return @
    
  
  #  --------------------------------------------------------------------
  
  #
  # Sets the LIMIT value
  #
  # @access	public
  # @param	integer	the limit value
  # @param	integer	the offset value
  # @return	object
  #
  limit: ($value, $offset = '') ->
    @ar_limit = $value
    
    if $offset isnt ''
      @ar_offset = $offset
    
    return @
    
  
  #  --------------------------------------------------------------------
  
  #
  # Sets the OFFSET value
  #
  # @access	public
  # @param	integer	the offset value
  # @return	object
  #
  offset: ($offset) ->
    @ar_offset = $offset
    return @
    
  
  #  --------------------------------------------------------------------
  
  #
  # The "set" function.  Allows key/value pairs to be set for inserting or updating
  #
  # @access	public
  # @param	mixed
  # @param	string
  # @param	boolean
  # @return	object
  #
  set: ($key, $value = '', $escape = true) ->

    if not is_array($key)
      $key = array($key, $value)
    
    for $k, $v of $key
      if $escape is false
        @ar_set[@_protect_identifiers($k)] = $v
        
      else 
        @ar_set[@_protect_identifiers($k, false, true)] = @escape($v)
    
    return @
    
  
  #  --------------------------------------------------------------------
  
  #
  # Get
  #
  # Compiles the select statement based on the other functions called
  # and runs the query
  #
  # @access	public
  # @param	string	the table
  # @param	string	the limit clause
  # @param	string	the offset clause
  # @return	object
  #
  get: ($table, $callback = null) ->

    if $callback is null
      $callback = $table
      $table = ''

    if $table isnt ''
      @_track_aliases($table)
      @from($table)
    
    $sql = @_compile_select()
    @_reset_select()
    @query $sql, $callback

  
  #
  # "Count All Results" query
  #
  # Generates a platform-specific query string that counts all records
  # returned by an Active Record query.
  #
  # @access	public
  # @param	string
  # @return	string
  #
  count_all_results: ($table = '') ->
    if $table isnt ''
      @_track_aliases($table)
      @from($table)
    
    $sql = @_compile_select(@_count_string + @_protect_identifiers('numrows'))
    
    $query = @query($sql)
    @_reset_select()
    
    if $query.num_rows() is 0
      return 0
    
    $row = $query.row()
    return $row.numrows
    
  
  #  --------------------------------------------------------------------
  
  #
  # Get_Where
  #
  # Allows the where clause, limit and offset to be added directly
  #
  # @access	public
  # @param	string	the where clause
  # @param	string	the limit clause
  # @param	string	the offset clause
  # @return	object
  #
  get_where: ($table = '', $where = null, $limit = null, $offset = null) ->
    if $table isnt ''
      @from($table)
    
    if not is_null($where)
      @where($where)
    
    if not is_null($limit)
      @limit($limit, $offset)
    
    $sql = @_compile_select()
    
    $result = @query($sql)
    @_reset_select()
    return $result
    
  
  #  --------------------------------------------------------------------
  
  #
  # Insert
  #
  # Compiles an insert string and runs the query
  #
  # @access	public
  # @param	string	the table to retrieve the results from
  # @param	array	an associative array of insert values
  # @return	object
  #
  insert: ($table = '', $set = null, $callback = null) ->

    if $callback is null
      $callback = $set
      $set = null

    if not is_null($set)
      @set($set)
    
    if count(@ar_set) is 0
      if @db_debug
        return @display_error('db_must_use_set')
        
      return false
    
    if $table is ''
      if not @ar_from[0]? 
        if @db_debug
          return @display_error('db_must_set_table')
          
        return false
      
      $table = @ar_from[0]
      
    $sql = @_insert(@_protect_identifiers($table, true, null, false), array_keys(@ar_set), array_values(@ar_set))
    
    @_reset_write()
    return @query($sql, $callback)
  
  replace: ($table = '', $set = null) ->
    if not is_null($set)
      @set($set)
      
    
    if count(@ar_set) is 0
      if @db_debug
        return @display_error('db_must_use_set')
        
      return false
      
    
    if $table is ''
      if not @ar_from[0]? 
        if @db_debug
          return @display_error('db_must_set_table')
          
        return false
        
      
      $table = @ar_from[0]
      
    
    $sql = @_replace(@_protect_identifiers($table, true, null, false), array_keys(@ar_set), array_values(@ar_set))

    log_message 'debug', 'SQL: %s', $sql
    @_reset_write()
    return @query($sql, $callback)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Update
  #
  # Compiles an update string and runs the query
  #
  # @access	public
  # @param	string	the table to retrieve the results from
  # @param	array	an associative array of update values
  # @param	mixed	the where clause
  # @return	object
  #
  update: ($table = '', $set = null, $where = null, $limit = null, $callback = null) ->

    if $callback is null
      $callback = $limit
      $limit = null

    if $callback is null
      $callback = $where
      $where = null

    if $callback is null
      throw Error('DB_active_rec::update No callback passed to update')


    #  Combine any cached components with the current statements
    @_merge_cache()
    
    if not is_null($set)
      @set($set)
      
    
    if count(@ar_set) is 0
      if @db_debug
        return @display_error('db_must_use_set')
        
      return false
      
    
    if $table is ''
      if not @ar_from[0]? 
        if @db_debug
          return @display_error('db_must_set_table')
          
        return false
        
      
      $table = @ar_from[0]
      
    
    if $where isnt null
      @where($where)
      
    
    if $limit isnt null
      @limit($limit)
      
    
    $sql = @_update(@_protect_identifiers($table, true, null, false), @ar_set, @ar_where, @ar_orderby, @ar_limit)

    @_reset_write()
    @query($sql, $callback)
    
  

  #  --------------------------------------------------------------------
  
  #
  # Empty Table
  #
  # Compiles a delete string and runs "DELETE FROM table"
  #
  # @access	public
  # @param	string	the table to empty
  # @return	object
  #
  empty_table: ($table = '') ->
    if $table is ''
      if not @ar_from[0]? 
        if @db_debug
          return @display_error('db_must_set_table')
          
        return false
        
      
      $table = @ar_from[0]
      
    else 
      $table = @_protect_identifiers($table, true, null, false)
      
    
    $sql = @_delete($table)
    
    @_reset_write()
    
    return @query($sql)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Truncate
  #
  # Compiles a truncate string and runs the query
  # If the database does not support the truncate() command
  # This function maps to "DELETE FROM table"
  #
  # @access	public
  # @param	string	the table to truncate
  # @return	object
  #
  truncate: ($table = '') ->
    if $table is ''
      if not @ar_from[0]? 
        if @db_debug
          return @display_error('db_must_set_table')
          
        return false
        
      
      $table = @ar_from[0]
      
    else 
      $table = @_protect_identifiers($table, true, null, false)
      
    
    $sql = @_truncate($table)
    
    @_reset_write()
    
    return @query($sql)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Delete
  #
  # Compiles a delete string and runs the query
  #
  # @access	public
  # @param	mixed	the table(s) to delete from. String or array
  # @param	mixed	the where clause
  # @param	mixed	the limit clause
  # @param	boolean
  # @return	object
  #
  delete: ($table = '', $where = '', $limit = null, $reset_data = true) ->
    #  Combine any cached components with the current statements
    @_merge_cache()
    
    if $table is ''
      if not @ar_from[0]? 
        if @db_debug
          return @display_error('db_must_set_table')
          
        return false
        
      
      $table = @ar_from[0]
      
    else if is_array($table)
      for $single_table in $table
        @['delete']($single_table, $where, $limit, false)
        
      
      @_reset_write()
      return 
      
    else 
      $table = @_protect_identifiers($table, true, null, false)
      
    
    if $where isnt ''
      @where($where)
      
    
    if $limit isnt null
      @limit($limit)
      
    
    if count(@ar_where) is 0 and count(@ar_wherein) is 0 and count(@ar_like) is 0
      if @db_debug
        return @display_error('db_del_must_use_where')
        
      
      return false
      
    
    $sql = @_delete($table, @ar_where, @ar_like, @ar_limit)
    
    if $reset_data
      @_reset_write()
      
    
    return @query($sql)
    
  
  #  --------------------------------------------------------------------
  
  #
  # DB Prefix
  #
  # Prepends a database prefix if one exists in configuration
  #
  # @access	public
  # @param	string	the table
  # @return	string
  #
  _dbprefix: ($table = '') ->
    if $table is ''
      @display_error('db_table_name_required')
      
    
    return @dbprefix + $table
    
  
  #  --------------------------------------------------------------------
  
  #
  # Track Aliases
  #
  # Used to track SQL statements written with aliased tables.
  #
  # @access	private
  # @param	string	The table to inspect
  # @return	string
  #
  _track_aliases: ($table) ->
    if is_array($table)
      for $t in $table
        @_track_aliases($t)
        
      return 
      
    
    #  Does the string contain a comma?  If so, we need to separate
    #  the string into discreet statements
    if strpos($table, ',') isnt false
      return @_track_aliases(explode(',', $table))
      
    
    #  if a table alias is used we can recognize it by a space
    if strpos($table, " ") isnt false
      #  if the alias is written with the AS keyword, remove it
      $table = preg_replace('/ AS /i', ' ', $table)
      
      #  Grab the alias
      $table = trim(strrchr($table, " "))
      
      #  Store the alias, if it doesn't already exist
      if not in_array($table, @ar_aliased_tables)
        @ar_aliased_tables.push $table
        
      
    
  
  #  --------------------------------------------------------------------
  
  #
  # Compile the SELECT statement
  #
  # Generates a query string based on which functions were used.
  # Should not be called directly.  The get() function calls it.
  #
  # @access	private
  # @return	string
  #
  _compile_select: ($select_override = false) ->
    #  Combine any cached components with the current statements
    @_merge_cache()
    
    #  ----------------------------------------------------------------
    
    #  Write the "select" portion of the query
    
    if $select_override isnt false
      $sql = $select_override
      
    else 
      $sql = if ( not @ar_distinct) then 'SELECT ' else 'SELECT DISTINCT '

      if count(@ar_select) is 0
        $sql+='*'
        
      else 
        #  Cycle through the "select" portion of the query and prep each column name.
        #  The reason we protect identifiers here rather then in the select() function
        #  is because until the user calls the from() function we don't know if there are aliases

        for $key, $val of @ar_select
          @ar_select[$key] = @_protect_identifiers($val)

        $sql+=implode(', ', @ar_select)

    #  ----------------------------------------------------------------
    
    #  Write the "FROM" portion of the query
    
    if count(@ar_from) > 0
      $sql+="\nFROM "
      
      $sql+=@_from_tables(@ar_from)
      
    
    #  ----------------------------------------------------------------
    
    #  Write the "JOIN" portion of the query
    
    if count(@ar_join) > 0
      $sql+="\n"
      
      $sql+=implode("\n", @ar_join)
      
    
    #  ----------------------------------------------------------------
    
    #  Write the "WHERE" portion of the query
    
    if count(@ar_where) > 0 or count(@ar_like) > 0
      $sql+="\n"
      
      $sql+="WHERE "
      
    
    $sql+=implode("\n", @ar_where)
    
    #  ----------------------------------------------------------------
    
    #  Write the "LIKE" portion of the query
    
    if count(@ar_like) > 0
      if count(@ar_where) > 0
        $sql+="\nAND "
        
      $sql+=implode("\n", @ar_like)
      
    
    #  ----------------------------------------------------------------
    
    #  Write the "GROUP BY" portion of the query
    
    if count(@ar_groupby) > 0
      $sql+="\nGROUP BY "
      
      $sql+=implode(', ', @ar_groupby)
      
    
    #  ----------------------------------------------------------------
    
    #  Write the "HAVING" portion of the query
    
    if count(@ar_having) > 0
      $sql+="\nHAVING "
      $sql+=implode("\n", @ar_having)
      
    
    #  ----------------------------------------------------------------
    
    #  Write the "ORDER BY" portion of the query
    
    if count(@ar_orderby) > 0
      $sql+="\nORDER BY "
      $sql+=implode(', ', @ar_orderby)
      
      if @ar_order isnt false
        $sql+= if (@ar_order is 'desc') then ' DESC' else ' ASC'
        
      
    
    #  ----------------------------------------------------------------
    
    #  Write the "LIMIT" portion of the query
    
    if is_numeric(@ar_limit)
      $sql+="\n"
      $sql = @_limit($sql, @ar_limit, @ar_offset)

    return $sql
    
  
  #  --------------------------------------------------------------------
  
  #
  # Start Cache
  #
  # Starts AR caching
  #
  # @access	public
  # @return	void
  #
  start_cache:  ->
    @ar_caching = true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Stop Cache
  #
  # Stops AR caching
  #
  # @access	public
  # @return	void
  #
  stop_cache:  ->
    @ar_caching = false
    
  
  #  --------------------------------------------------------------------
  
  #
  # Flush Cache
  #
  # Empties the AR cache
  #
  # @access	public
  # @return	void
  #
  flush_cache:  ->
    @_reset_run(
    
      'ar_cache_select':[]
      'ar_cache_from':[]
      'ar_cache_join':[]
      'ar_cache_where':[]
      'ar_cache_like':[]
      'ar_cache_groupby':[]
      'ar_cache_having':[]
      'ar_cache_orderby':[]
      'ar_cache_set':[]
      'ar_cache_exists':[]
      
    )
    
  
  #  --------------------------------------------------------------------
  
  #
  # Merge Cache
  #
  # When called, this function merges any cached AR arrays with
  # locally called ones.
  #
  # @access	private
  # @return	void
  #
  _merge_cache:  ->
    if count(@ar_cache_exists) is 0
      return 
      
    
    for $val in @ar_cache_exists
      $ar_variable = 'ar_' + $val
      $ar_cache_var = 'ar_cache_' + $val
      
      if count(@$ar_cache_var) is 0
        continue
        
      
      @$ar_variable = array_unique(array_merge(@$ar_cache_var, @$ar_variable))
      
    
    #  If we are "protecting identifiers" we need to examine the "from"
    #  portion of the query to determine if there are any aliases
    if @_protect_identifiers_default is true and count(@ar_cache_from) > 0
      @_track_aliases(@ar_from)
      
    
  
  #  --------------------------------------------------------------------
  
  #
  # Resets the active record values.  Called by the get() function
  #
  # @access	private
  # @param	array	An array of fields to reset
  # @return	void
  #
  _reset_run: ($ar_reset_items) ->
    for $item, $default_value of $ar_reset_items
      if not in_array($item, @ar_store_array)
        @[$item] = $default_value
        
      
    
  
  #  --------------------------------------------------------------------
  
  #
  # Resets the active record values.  Called by the get() function
  #
  # @access	private
  # @return	void
  #
  _reset_select:  ->
    $ar_reset_items = 
      'ar_select':[]
      'ar_from':[]
      'ar_join':[]
      'ar_where':[]
      'ar_like':[]
      'ar_groupby':[]
      'ar_having':[]
      'ar_orderby':[]
      'ar_wherein':[]
      'ar_aliased_tables':[]
      'ar_distinct':false
      'ar_limit':false
      'ar_offset':false
      'ar_order':false
      
    
    @_reset_run($ar_reset_items)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Resets the active record "write" values.
  #
  # Called by the insert() update() insert_batch() update_batch() and delete() functions
  #
  # @access	private
  # @return	void
  #
  _reset_write:  ->
    $ar_reset_items = 
      'ar_set':[]
      'ar_from':[]
      'ar_where':[]
      'ar_like':[]
      'ar_orderby':[]
      'ar_keys':[]
      'ar_limit':false
      'ar_order':false
      
    
    @_reset_run($ar_reset_items)
    
module.exports = CI_DB_active_record

#  End of file DB_active_rec.php 
#  Location: ./system/database/DB_active_rec.php 
