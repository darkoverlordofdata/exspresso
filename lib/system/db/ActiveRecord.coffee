#+--------------------------------------------------------------------+
#  ActiveRecord.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
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
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#
# Active Record Class
#
# This is the platform-independent base Active Record implementation class.
#
#
class system.db.ActiveRecord extends system.db.Driver
  
  ar_select:          null
  ar_distinct:        false
  ar_from:            null
  ar_join:            null
  ar_where:           null
  ar_like:            null
  ar_groupby:         null
  ar_having:          null
  ar_keys:            null
  ar_limit:           false
  ar_offset:          false
  ar_order:           false
  ar_orderby:         null
  ar_set:             null
  ar_wherein:         null
  ar_aliased_tables:  null
  ar_store_array:     null
  
  #  Active Record Caching variables
  ar_caching:         false
  ar_cache_exists:    null
  ar_cache_select:    null
  ar_cache_from:      null
  ar_cache_join:      null
  ar_cache_where:     null
  ar_cache_like:      null
  ar_cache_groupby:   null
  ar_cache_having:    null
  ar_cache_orderby:   null
  ar_cache_set:       null

  #  --------------------------------------------------------------------

  #
  # Constructor.  Accepts one parameter containing the database
  # connection settings.
  #
  # @param  [Array]  #
  constructor: ($params = {}) ->
    super($params)
    @ar_select =          []
    @ar_from =            []
    @ar_join =            []
    @ar_where =           []
    @ar_like =            []
    @ar_groupby =         []
    @ar_having =          []
    @ar_keys =            []
    @ar_orderby =         []
    @ar_set =             []
    @ar_wherein =         []
    @ar_aliased_tables =  []
    @ar_store_array =     []
    @ar_cache_exists =    []
    @ar_cache_select =    []
    @ar_cache_from =      []
    @ar_cache_join =      []
    @ar_cache_where =     []
    @ar_cache_like =      []
    @ar_cache_groupby =   []
    @ar_cache_having =    []
    @ar_cache_orderby =   []
    @ar_cache_set =       []

  #
  # Select
  #
  # Generates the SELECT portion of the query
  #
    # @param  [String]    # @return [Object]  #
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
    
  
  #
  # Select Max
  #
  # Generates a SELECT MAX(field) portion of a query
  #
    # @param  [String]  the field
  # @param  [String]  an alias
  # @return [Object]  #
  selectMax: ($select = '', $alias = '') ->
    @_max_min_avg_sum($select, $alias, 'MAX')
    
  
  #
  # Select Min
  #
  # Generates a SELECT MIN(field) portion of a query
  #
    # @param  [String]  the field
  # @param  [String]  an alias
  # @return [Object]  #
  selectMin: ($select = '', $alias = '') ->
    @_max_min_avg_sum($select, $alias, 'MIN')
    
  
  #
  # Select Average
  #
  # Generates a SELECT AVG(field) portion of a query
  #
    # @param  [String]  the field
  # @param  [String]  an alias
  # @return [Object]  #
  selectAvg: ($select = '', $alias = '') ->
    @_max_min_avg_sum($select, $alias, 'AVG')
    
  
  #
  # Select Sum
  #
  # Generates a SELECT SUM(field) portion of a query
  #
    # @param  [String]  the field
  # @param  [String]  an alias
  # @return [Object]  #
  selectSum: ($select = '', $alias = '') ->
    @_max_min_avg_sum($select, $alias, 'SUM')
    
  
  #
  # Processing Function for the four functions above:
  #
  #	select_max()
  #	select_min()
  #	select_avg()
  #  select_sum()
  #
    # @param  [String]  the field
  # @param  [String]  an alias
  # @return [Object]  #
  _max_min_avg_sum: ($select = '', $alias = '', $type = 'MAX') ->
    if not is_string($select) or $select is ''
      @display_error('db_invalid_query')
      
    
    $type = strtoupper($type)
    
    if not in_array($type, ['MAX', 'MIN', 'AVG', 'SUM'])
      show_error('Invalid function type: %s', $type)
      
    
    if $alias is ''
      $alias = @_create_alias_from_table(trim($select))
      
    
    $sql = $type + '(' + @_protect_identifiers(trim($select)) + ') AS ' + $alias
    
    @ar_select.push $sql
    
    if @ar_caching is true
      @ar_cache_select.push $sql
      @ar_cache_exists.push 'select'
      
    
    return @
    
  
  #
  # Determines the alias name based on the table
  #
  # @private
  # @param  [String]    # @return	[String]
  #
  _create_alias_from_table: ($item) ->
    if strpos($item, '.') isnt false
      return end(explode('.', $item))
      
    
    return $item
    
  
  #
  # DISTINCT
  #
  # Sets a flag which tells the query string compiler to add DISTINCT
  #
    # @return	[Boolean]
  # @return [Object]  #
  distinct: ($val = true) ->
    @ar_distinct = if (is_bool($val)) then $val else true
    return @
    
  
  #
  # From
  #
  # Generates the FROM portion of the query
  #
    # @param  [Mixed]  can be a string or array
  # @return [Object]  #
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
    
  
  #
  # Join
  #
  # Generates the JOIN portion of the query
  #
    # @param  [String]    # @param  [String]  the join condition
  # @param  [String]  the type of join
  # @return [Object]  #
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
    if ($match = preg_match('/([\\w\\.]+)([\\W\\s]+)(.+)/', $cond))?
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
    
  
  #
  # Where
  #
  # Generates the WHERE portion of the query. Separates
  # multiple calls with AND
  #
    # @param  [Mixed]  # @param  [Mixed]  # @return [Object]  #
  where: ($key, $value = null, $escape = true) ->
    @_where($key, $value, 'AND ', $escape)
    
  
  #
  # OR Where
  #
  # Generates the WHERE portion of the query. Separates
  # multiple calls with OR
  #
    # @param  [Mixed]  # @param  [Mixed]  # @return [Object]  #
  orWhere: ($key, $value = null, $escape = true) ->
    @_where($key, $value, 'OR ', $escape)
    
  
  #
  # Where
  #
  # Called by where() or orwhere()
  #
  # @private
  # @param  [Mixed]  # @param  [Mixed]  # @param  [String]    # @return [Object]  #
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
    
  
  #
  # Where_in
  #
  # Generates a WHERE field IN ('item', 'item') SQL query joined with
  # AND if appropriate
  #
    # @param  [String]  The field to search
  # @param  [Array]  The values searched on
  # @return [Object]  #
  whereIn: ($key = null, $values = null) ->
    @_where_in($key, $values)
    
  
  #
  # Where_in_or
  #
  # Generates a WHERE field IN ('item', 'item') SQL query joined with
  # OR if appropriate
  #
    # @param  [String]  The field to search
  # @param  [Array]  The values searched on
  # @return [Object]  #
  orWhereIn: ($key = null, $values = null) ->
    @_where_in($key, $values, false, 'OR ')
    
  
  #
  # Where_not_in
  #
  # Generates a WHERE field NOT IN ('item', 'item') SQL query joined
  # with AND if appropriate
  #
    # @param  [String]  The field to search
  # @param  [Array]  The values searched on
  # @return [Object]  #
  whereNotIn: ($key = null, $values = null) ->
    @_where_in($key, $values, true)
    
  
  #
  # Where_not_in_or
  #
  # Generates a WHERE field NOT IN ('item', 'item') SQL query joined
  # with OR if appropriate
  #
    # @param  [String]  The field to search
  # @param  [Array]  The values searched on
  # @return [Object]  #
  orWhereNotIn: ($key = null, $values = null) ->
    @_where_in($key, $values, true, 'OR ')
    
  
  #
  # Where_in
  #
  # Called by where_in, where_in_or, where_not_in, where_not_in_or
  #
    # @param  [String]  The field to search
  # @param  [Array]  The values searched on
  # @return	[Boolean]ean	If the statement would be IN or NOT IN
  # @param  [String]    # @return [Object]  #
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
    
  
  #
  # Like
  #
  # Generates a %LIKE% portion of the query. Separates
  # multiple calls with AND
  #
    # @param  [Mixed]  # @param  [Mixed]  # @return [Object]  #
  like: ($field, $match = '', $side = 'both') ->
    @_like($field, $match, 'AND ', $side)
    
  
  #
  # Not Like
  #
  # Generates a NOT LIKE portion of the query. Separates
  # multiple calls with AND
  #
    # @param  [Mixed]  # @param  [Mixed]  # @return [Object]  #
  not_like: ($field, $match = '', $side = 'both') ->
    @_like($field, $match, 'AND ', $side, 'NOT')
    
  
  #
  # OR Like
  #
  # Generates a %LIKE% portion of the query. Separates
  # multiple calls with OR
  #
    # @param  [Mixed]  # @param  [Mixed]  # @return [Object]  #
  orLike: ($field, $match = '', $side = 'both') ->
    @_like($field, $match, 'OR ', $side)
    
  
  #
  # OR Not Like
  #
  # Generates a NOT LIKE portion of the query. Separates
  # multiple calls with OR
  #
    # @param  [Mixed]  # @param  [Mixed]  # @return [Object]  #
  orNotLike: ($field, $match = '', $side = 'both') ->
    @_like($field, $match, 'OR ', $side, 'NOT')
    
  
  #
  # Like
  #
  # Called by like() or orlike()
  #
  # @private
  # @param  [Mixed]  # @param  [Mixed]  # @param  [String]    # @return [Object]  #
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
    
  
  #
  # GROUP BY
  #
    # @param  [String]    # @return [Object]  #
  groupBy: ($by) ->
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
    
  
  #
  # Sets the HAVING value
  #
  # Separates multiple calls with AND
  #
    # @param  [String]    # @param  [String]    # @return [Object]  #
  having: ($key, $value = '', $escape = true) ->
    @_having($key, $value, 'AND ', $escape)
    
  
  #
  # Sets the OR HAVING value
  #
  # Separates multiple calls with OR
  #
    # @param  [String]    # @param  [String]    # @return [Object]  #
  orHaving: ($key, $value = '', $escape = true) ->
    @_having($key, $value, 'OR ', $escape)
    
  
  #
  # Sets the HAVING values
  #
  # Called by having() or or_having()
  #
  # @private
  # @param  [String]    # @param  [String]    # @return [Object]  #
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
        $v = ' ' + @escapeStr($v)
      
      @ar_having.push $prefix + $k + $v
      if @ar_caching is true
        @ar_cache_having.push $prefix + $k + $v
        @ar_cache_exists.push 'having'
    
    return @
    
  
  #
  # Sets the ORDER BY value
  #
    # @param  [String]    # @param  [String]  direction: asc or desc
  # @return [Object]  #
  orderBy: ($orderby, $direction = '') ->
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
    
  
  #
  # Sets the LIMIT value
  #
    # @param  [Integer]  the limit value
  # @param  [Integer]  the offset value
  # @return [Object]  #
  limit: ($value, $offset = '') ->
    @ar_limit = $value
    
    if $offset isnt ''
      @ar_offset = $offset
    
    return @
    
  
  #
  # Sets the OFFSET value
  #
    # @param  [Integer]  the offset value
  # @return [Object]  #
  offset: ($offset) ->
    @ar_offset = $offset
    return @
    
  
  #
  # The "set" function.  Allows key/value pairs to be set for inserting or updating
  #
    # @param  [Mixed]  # @param  [String]    # @return	[Boolean]ean
  # @return [Object]  #
  set: ($key, $value = '', $escape = true) ->

    if not is_array($key)
      $key = array($key, $value)
    
    for $k, $v of $key
      if $escape is false
        @ar_set[@_protect_identifiers($k)] = $v
        
      else 
        @ar_set[@_protect_identifiers($k, false, true)] = @escape($v)
    
    return @
    
  
  #
  # Get
  #
  # Compiles the select statement based on the other functions called
  # and runs the query
  #
    # @param  [String]  the table
  # @param  [String]  the limit clause
  # @param  [String]  the offset clause
  # @return [Object]  #
  get: ($table, $next = null) ->

    if $next is null
      $next = $table
      $table = ''

    if $table isnt ''
      @_track_aliases($table)
      @from($table)
    
    $sql = @_compile_select()
    @_reset_select()
    @query $sql, $next

  
  #
  # "Count All Results" query
  #
  # Generates a platform-specific query string that counts all records
  # returned by an Active Record query.
  #
    # @param  [String]    # @return	[String]
  #
  countAllResults: ($table = '', $next) ->
    if $table isnt ''
      @_track_aliases($table)
      @from($table)
    
    $sql = @_compile_select(@_count_string + @_protect_identifiers('numrows'))
    @_reset_select()

    @query $sql, ($err, $query) =>

      if $err then $next $err
      else

        if $query.num_rows is 0
          $next null, 0
        else
          $row = $query.row()
          $next null, $row.numrows
    
  
  #
  # Get_Where
  #
  # Allows the where clause, limit and offset to be added directly
  #
    # @param  [String]  the where clause
  # @param  [String]  the limit clause
  # @param  [String]  the offset clause
  # @return [Object]  #
  getWhere: ($table = '', $where = null, $limit = null, $offset = null) ->
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
  # Insert_Batch
  #
  # Compiles batch insert strings and runs the queries
  #
    # @param  [String]  the table to retrieve the results from
  # @param  [Array]  an associative array of insert values
  # @return [Object]  #
  insertBatch : ($table = '', $set = null, $next) ->
    if typeof $set is 'function'
      $next = $set
      $set = null

    if not is_null($set)
      @set_insert_batch($set)

    if count(@ar_set) is 0
      if @db_debug
        # No valid data array.  Folds in cases where keys and values did not match up
        return @display_error('db_must_use_set')

      return false

    if $table is ''
      if not @ar_from[0]?
        if @db_debug
          return @display_error('db_must_set_table')

        return false

      $table = @ar_from[0]

    #  Batch this baby
    $sql = []
    for $i in [0..count(@ar_set)-1] by 100

      $str = @_insert_batch(@_protect_identifiers($table, true, null, false), @ar_keys, array_slice(@ar_set, $i, 100))
      $sql.push $str

    @_reset_write()
    if $next?
      @queryList $sql, $next
    else
      $sql


  #  --------------------------------------------------------------------

  #
  # The "set_insert_batch" function.  Allows key/value pairs to be set for batch inserts
  #
    # @param  [Mixed]  # @param  [String]    # @return	[Boolean]ean
  # @return [Object]  #

  setInsertBatch : ($key, $value = '', $escape = true) ->

    $key = @_object_to_array_batch($key)

    if not Array.isArray($key)
      $key = [array($key, $value)]

    $keys = array_keys(current($key))
    sort($keys)

    for $row in $key

      if count(array_diff($keys, array_keys($row))) > 0 or count(array_diff(array_keys($row), $keys)) > 0
        #  batch function above returns an error on an empty array
        @ar_set.push {}
        return

      ksort($row)#  puts $row in the same order as our keys

      if $escape is false
        @ar_set.push '(' + implode(',', $row) + ')'

      else
        $clean = []

        for $k, $value of $row
          $clean.push @escape($value)

        @ar_set.push '(' + implode(',', $clean) + ')'

    for $k in $keys
      @ar_keys.push @_protect_identifiers($k)

    return @



  #
  # Insert
  #
  # Compiles an insert string and runs the query
  #
    # @param  [String]  the table to retrieve the results from
  # @param  [Array]  an associative array of insert values
  # @return [Object]  #
  insert: ($table = '', $set = null, $next = null) ->

    if $next is null
      $next = $set
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
    return @query($sql, $next)
  
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
    return @query($sql, $next)
    
  
  #
  # Update
  #
  # Compiles an update string and runs the query
  #
    # @param  [String]  the table to retrieve the results from
  # @param  [Array]  an associative array of update values
  # @param  [Mixed]  the where clause
  # @return [Object]  #
  update: ($table = '', $set = null, $where = null, $limit = null, $next = null) ->

    if $next is null
      $next = $limit
      $limit = null

    if $next is null
      $next = $where
      $where = null

    if $next is null
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
    @query($sql, $next)

  #  --------------------------------------------------------------------

  #
  # Update_Batch
  #
  # Compiles an update string and runs the query
  #
    # @param  [String]  the table to retrieve the results from
  # @param  [Array]  an associative array of update values
  # @param  [String]  the where key
  # @return [Object]  #
  updateBatch : ($table = '', $set = null, $index = null) ->
    #  Combine any cached components with the current statements
    @_merge_cache()

    if is_null($index)
      if @db_debug
        return @display_error('db_myst_use_index')


      return false


    if not is_null($set)
      @set_update_batch($set, $index)


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


    #  Batch this baby
    $sql = []
    for $i in [0..count(@ar_set)-1] by 100
      $sql.push @_update_batch(@_protect_identifiers($table, true, null, false), array_slice(@ar_set, $i, 100), @_protect_identifiers($index), @ar_where)

    @queryList $sql, ($err) ->

      @_reset_write()
      $next $err



  #  --------------------------------------------------------------------

  #
  # The "set_update_batch" function.  Allows key/value pairs to be set for batch updating
  #
    # @param  [Array]  # @param  [String]    # @return	[Boolean]ean
  # @return [Object]  #

  setUpdateBatch : ($key, $index = '', $escape = true) ->
    $key = @_object_to_array_batch($key)

    #if not is_array($key)
      #  @todo error


    for $k, $v of $key
      $index_set = false
      $clean = {}

      for $k2, $v2 of $v
        if $k2 is $index
          $index_set = true

        else
          $not.push $k + '-' + $v


        if $escape is false
          $clean[@_protect_identifiers($k2)] = $v2

        else
          $clean[@_protect_identifiers($k2)] = @escape($v2)



      if $index_set is false
        return @display_error('db_batch_missing_index')


      @ar_set.push $clean


    return @




  #
  # Empty Table
  #
  # Compiles a delete string and runs "DELETE FROM table"
  #
    # @param  [String]  the table to empty
  # @return [Object]  #
  emptyTable: ($table = '') ->
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
    
  
  #
  # Truncate
  #
  # Compiles a truncate string and runs the query
  # If the database does not support the truncate() command
  # This function maps to "DELETE FROM table"
  #
    # @param  [String]  the table to truncate
  # @return [Object]  #
  truncate: ($table = '', $next) ->
    if typeof table is 'function'
      $next = $table
      $table = ''

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
    
    @query($sql, $next)
    
  
  #
  # Delete
  #
  # Compiles a delete string and runs the query
  #
    # @param  [Mixed]  the table(s) to delete from. String or array
  # @param  [Mixed]  the where clause
  # @param  [Mixed]  the limit clause
  # @return	[Boolean]ean
  # @return [Object]  #
  delete: ($table = '', $where = '', $limit = null, $reset_data = true) ->

    if typeof $limit is 'function'
      $next = $limit
      $limit = null
      $reset_data = true

    else if typeof $reset_data is 'function'
      $next = $reset_data
      $reset_data = true

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

    @query($sql, $next)
    
  
  #
  # DB Prefix
  #
  # Prepends a database prefix if one exists in configuration
  #
    # @param  [String]  the table
  # @return	[String]
  #
  _dbprefix: ($table = '') ->
    if $table is ''
      @display_error('db_table_name_required')
      
    
    return @dbprefix + $table
    
  
  #
  # Track Aliases
  #
  # Used to track SQL statements written with aliased tables.
  #
  # @private
  # @param  [String]  The table to inspect
  # @return	[String]
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
        
      
    
  
  #
  # Compile the SELECT statement
  #
  # Generates a query string based on which functions were used.
  # Should not be called directly.  The get() function calls it.
  #
  # @private
  # @return	[String]
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
  # Object to Array
  #
  # Takes an object as input and converts the class variables to array key/vals
  #
    # @param  [Object]    # @return	array
  #
  _object_to_array_batch: ($object) ->
    if Array.isArray($object)
      return $object
    if not is_object($object)
      return $object

    $array = []
    $out = get_object_vars($object)
    $fields = array_keys($out)

    for $val in $fields
      #  There are some built in keys we need to ignore for this conversion
      if $val isnt '_parent_name'

        $i = 0
        for $data in $out[$val]
          if not $array[$i]? then $array[$i] = {}
          $array[$i][$val] = $data
          $i++

    return $array

  #
  # Start Cache
  #
  # Starts AR caching
  #
    # @return [Void]  #
  startCache:  ->
    @ar_caching = true
    
  
  #
  # Stop Cache
  #
  # Stops AR caching
  #
    # @return [Void]  #
  stopCache:  ->
    @ar_caching = false
    
  
  #
  # Flush Cache
  #
  # Empties the AR cache
  #
    # @return [Void]  #
  flushCache:  ->
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
    
  
  #
  # Merge Cache
  #
  # When called, this function merges any cached AR arrays with
  # locally called ones.
  #
  # @private
  # @return [Void]  #
  _merge_cache:  ->
    if count(@ar_cache_exists) is 0
      return 
      
    
    for $val in @ar_cache_exists
      $ar_variable = 'ar_' + $val
      $ar_cache_var = 'ar_cache_' + $val
      
      if count(@[$ar_cache_var]) is 0
        continue
        
      
      @[$ar_variable] = array_unique(array_merge(@[$ar_cache_var], @[$ar_variable]))
      
    
    #  If we are "protecting identifiers" we need to examine the "from"
    #  portion of the query to determine if there are any aliases
    if @_protect_identifiers_default is true and count(@ar_cache_from) > 0
      @_track_aliases(@ar_from)
      
    
  
  #
  # Resets the active record values.  Called by the get() function
  #
  # @private
  # @param  [Array]  An array of fields to reset
  # @return [Void]  #
  _reset_run: ($ar_reset_items) ->
    for $item, $default_value of $ar_reset_items
      if not in_array($item, @ar_store_array)
        @[$item] = $default_value
        
      
    
  
  #
  # Resets the active record values.  Called by the get() function
  #
  # @private
  # @return [Void]  #
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
    
  
  #
  # Resets the active record "write" values.
  #
  # Called by the insert() update() insert_batch() update_batch() and delete() functions
  #
  # @private
  # @return [Void]  #
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
    
module.exports = system.db.ActiveRecord

#  End of file ActiveRecord.coffee
#  Location: ./system/db/ActiveRecord.coffee
