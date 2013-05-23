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
# Abstract Active Record Class
#
#
module.exports = class system.db.ActiveRecord extends system.db.Driver
  
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
  ar_offset:          0
  ar_order:           false
  ar_orderby:         null
  ar_set:             null
  ar_wherein:         null
  ar_aliased_tables:  null
  ar_store_array:     null
  ar_record:          null

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

  #
  # Constructor.
  #
  # @param  [Array]
  #
  constructor: ($args...) ->
    super $args...

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
    @ar_rec =             {}
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
  # @param  [String]
  # @return [Object]
  #
  select: ($select) ->

    if 'string' is typeof($select)
      $select = $select.split(',')

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
  # @return [Object]
  #
  selectMax: ($select = '', $alias = '') ->
    @_max_min_avg_sum($select, $alias, 'MAX')


  #
  # Select Min
  #
  # Generates a SELECT MIN(field) portion of a query
  #
  # @param  [String]  the field
  # @param  [String]  an alias
  # @return [Object]
  #
  selectMin: ($select = '', $alias = '') ->
    @_max_min_avg_sum($select, $alias, 'MIN')


  #
  # Select Average
  #
  # Generates a SELECT AVG(field) portion of a query
  #
  # @param  [String]  the field
  # @param  [String]  an alias
  # @return [Object]
  #
  selectAvg: ($select = '', $alias = '') ->
    @_max_min_avg_sum($select, $alias, 'AVG')


  #
  # Select Sum
  #
  # Generates a SELECT SUM(field) portion of a query
  #
  # @param  [String]  the field
  # @param  [String]  an alias
  # @return [Object]
  #
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
  # @return [Object]
  #
  _max_min_avg_sum: ($select = '', $alias = '', $type = 'MAX') ->
    if not 'string' is typeof($select) or $select is ''
      @displayError('db_invalid_query')


    $type = $type.toUpperCase()

    if ['MAX', 'MIN', 'AVG', 'SUM'].indexOf($type) is -1
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
  # @param  [String]  # @return	[String]
  #
  _create_alias_from_table: ($item) ->
    return $item.split('.').pop() unless $item.indexOf('.') is -1
    return $item


  #
  # DISTINCT
  #
  # Sets a flag which tells the query string compiler to add DISTINCT
  #
  # @return	[Boolean]
  # @return [Object]
  #
  distinct: ($val = true) ->
    @ar_distinct = if 'boolean' is typeof($val) then $val else true
    return @

  #
  # From
  #
  # Generates the FROM portion of the query
  #
  # @param  [Mixed]  can be a string or array
  # @return [Object]
  #
  from: ($from) ->
    if 'string' is typeof($from) then $from = [$from]
    for $val in $from
      if $val.indexOf(',') isnt -1
        for $v in $val.split(',')
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
  # @param  [String]  # @param  [String]  the join condition
  # @param  [String]  the type of join
  # @return [Object]
  #
  join: ($table, $cond, $type = '') ->
    if $type isnt ''
      $type = trim($type).toUpperCase()

      if ['LEFT', 'RIGHT', 'OUTER', 'INNER', 'LEFT OUTER', 'RIGHT OUTER'].indexOf($type) is -1
        $type = ''

      else
        $type+=' '

    #  Extract any aliases that might exist.  We use this information
    #  in the _protect_identifiers to know whether to add a table prefix
    @_track_aliases($table)

    #  Strip apart the condition and protect the identifiers
    # if preg_match('/([\w\.]+)([\W\s]+)(.+)/', $cond, $match)
    if ($match = $cond.match(/([\w\.]+)([\W\s]+)(.+)/))
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
  # @param  [Mixed]
  # @param  [Mixed]
  # @return [Object]
  #
  where: ($key, $value = null, $escape = true) ->
    @_where($key, $value, 'AND ', $escape)


  #
  # OR Where
  #
  # Generates the WHERE portion of the query. Separates
  # multiple calls with OR
  #
  # @param  [Mixed]
  # @param  [Mixed]
  # @return [Object]
  #
  orWhere: ($key, $value = null, $escape = true) ->
    @_where($key, $value, 'OR ', $escape)


  #
  # Where
  #
  # Called by where() or orwhere()
  #
  # @private
  # @param  [Mixed]
  # @param  [Mixed]
  # @param  [String]
  # @return [Object]
  #
  _where: ($key, $value = null, $type = 'AND ', $escape = null) ->
    if 'string' is typeof($key)
      $key = array($key, $value)

    #  If the escape value was not set will will base it on the global setting
    if 'boolean' isnt typeof($escape)
      $escape = @_protect_identifiers_default

    for $k, $v of $key
      $prefix = if (@ar_where.length is 0 and @ar_cache_where.length is 0) then '' else $type

      if $v is null and not @_has_operator($k)
        #  value appears not to have been set, assign the test to IS NULL
        $k+=' IS NULL'

      if $v isnt null
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
  # @return [Object]
  #
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
  # @return [Object]
  #
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
  # @return [Object]
  #
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
  # @return [Object]
  #
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
  # @param  [String]
  # @return [Object]
  #
  _where_in: ($key = null, $values = null, $not = false, $type = 'AND ') ->
    if $key is null or $values is null
      return

    if not Array.isArray($values)
      $values = [$values]

    $not = if ($not) then ' NOT' else ''

    for $value in $values
      @ar_wherein.push @escape($value)

    $prefix = if @ar_where.length is 0 then '' else $type

    $where_in = $prefix + @_protect_identifiers($key) + $not + " IN (" + @ar_wherein.join(", ") + ") "

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
  # @param  [Mixed]
  # @param  [Mixed]
  # @return [Object]
  #
  like: ($field, $match = '', $side = 'both') ->
    @_like($field, $match, 'AND ', $side)


  #
  # Not Like
  #
  # Generates a NOT LIKE portion of the query. Separates
  # multiple calls with AND
  #
  # @param  [Mixed]
  # @param  [Mixed]
  # @return [Object]
  #
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
  # @param  [Mixed]  # @param  [Mixed]  # @param  [String]  # @return [Object]  #
  _like: ($field, $match = '', $type = 'AND ', $side = 'both', $not = '') ->
    if 'string' is typeof($field)
      $field = array($field, $match)

    for $k, $v of $field
      $k = @_protect_identifiers($k)

      $prefix = if @ar_like.length is 0 then '' else $type

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
  # @param  [String]  # @return [Object]  #
  groupBy: ($by) ->
    if 'string' is typeof($by)
      $by = $by.split(',')

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
  # @param  [String]  # @param  [String]  # @return [Object]  #
  having: ($key, $value = '', $escape = true) ->
    @_having($key, $value, 'AND ', $escape)


  #
  # Sets the OR HAVING value
  #
  # Separates multiple calls with OR
  #
  # @param  [String]  # @param  [String]  # @return [Object]  #
  orHaving: ($key, $value = '', $escape = true) ->
    @_having($key, $value, 'OR ', $escape)


  #
  # Sets the HAVING values
  #
  # Called by having() or or_having()
  #
  # @private
  # @param  [String]  # @param  [String]  # @return [Object]  #
  _having: ($key, $value = '', $type = 'AND ', $escape = true) ->
    if 'string' is typeof($key)
      $key = array($key, $value)

    for $k, $v of $key
      $prefix = if (@ar_having.length is 0) then '' else $type

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
  # @param  [String]  # @param  [String]  direction: asc or desc
  # @return [Object]  #
  orderBy: ($orderby, $direction = '') ->
    if $direction.toLowerCase() is 'random'
      $orderby = ''#  Random results want or don't need a field name
      $direction = @_random_keyword

    else if trim($direction) isnt ''
      $direction = if ['ASC', 'DESC'].indexOf(trim($direction.toUpperCase())) isnt -1 then ' ' + $direction else ' ASC'

    if $orderby.indexOf(',') isnt -1
      $temp = []
      for $part in $orderby.split(',')
        $part = trim($part)
        if @ar_aliased_tables.indexOf($part) is -1
          $part = @_protect_identifiers(trim($part))

        $temp.push $part

      $orderby = $temp.join(', ')

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
  # @param  [Mixed]  # @param  [String]  # @return	[Boolean]ean
  # @return [Object]  #
  set: ($key, $value = '', $escape = true) ->

    if 'string' is typeof($key)
      $key = array($key, $value)

    for $k, $v of $key
      if $escape is false
        @ar_rec[@_protect_identifiers($k)] = $v

      else
        @ar_rec[@_protect_identifiers($k, false, true)] = @escape($v)

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
  # @param  [String]  # @return	[String]
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

    if $where isnt null
      @where($where)

    if $limit isnt null
      @limit($limit, $offset)

    $sql = @_compile_select()

    $result = @query($sql)
    @_reset_select()
    return $result

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

    if $set?
      @set_insert_batch($set)

    if @ar_set.length is 0
      if @db_debug
        # No valid data array.  Folds in cases where keys and values did not match up
        return @displayError('db_must_use_set')

      return false

    if $table is ''
      if not @ar_from[0]?
        if @db_debug
          return @displayError('db_must_set_table')

        return false

      $table = @ar_from[0]

    #  Batch this baby
    $sql = []
    for $i in [0..@ar_set.length-1] by 100

      $str = @_insert_batch(@_protect_identifiers($table, true, null, false), @ar_keys, @ar_set.slice($i, 100))
      $sql.push $str

    @_reset_write()
    if $next?
      @queryList $sql, $next
    else
      $sql


  #
  # The "set_insert_batch" function.  Allows key/value pairs to be set for batch inserts
  #
  # @param  [Mixed]  # @param  [String]  # @return	[Boolean]ean
  # @return [Object]  #

  set_insert_batch : ($key, $value = '', $escape = true) ->

    $key = @_object_to_array_batch($key)

    if not Array.isArray($key)
      $key = [array($key, $value)]

    $keys = Object.keys($key[0]).sort()
    $ckeys = $keys.join()

    for $row in $key

      # field names need to be the same
      if $ckeys isnt Object.keys($row).sort().join()
        #  batch function above returns an error on an empty array
        @ar_set.push {}
        return

      $list = if $escape then $list = @escape($row[$k]) for $k in $keys
      else $list = $row[$k] for $k in $keys

      @ar_set.push '(' + $list.join(',') + ')'

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

    if $set isnt null
      @set($set)

    if Object.keys(@ar_rec).length is 0
      if @db_debug
        return @display_error('db_must_use_set')

      return false

    if $table is ''
      if not @ar_from[0]?
        if @db_debug
          return @display_error('db_must_set_table')

        return false

      $table = @ar_from[0]

    $sql = @_insert(@_protect_identifiers($table, true, null, false), Object.keys(@ar_rec).sort(), @ar_rec[$k] for $k in Object.keys(@ar_rec).sort())

    @_reset_write()
    return @query($sql, $next)

  replace: ($table = '', $set = null) ->
    if $set isnt null
      @set($set)


    if Object.keys(@ar_rec).length is 0
      if @db_debug
        return @display_error('db_must_use_set')

      return false


    if $table is ''
      if not @ar_from[0]?
        if @db_debug
          return @display_error('db_must_set_table')

        return false


      $table = @ar_from[0]


    $sql = @_replace(@_protect_identifiers($table, true, null, false), Object.keys(@ar_rec).sort(), @ar_rec[$k] for $k in Object.keys(@ar_rec).sort())

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

    if $set isnt null
      @set($set)


    if Object.keys(@ar_rec).length is 0
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


    $sql = @_update(@_protect_identifiers($table, true, null, false), @ar_rec, @ar_where, @ar_orderby, @ar_limit)

    @_reset_write()
    @query($sql, $next)

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

    if $index is null
      if @db_debug
        return @display_error('db_myst_use_index')
      return false

    if $set isnt null
      @set_update_batch($set, $index)

    if @ar_set.length is 0
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
    for $i in [0..@ar_set.length-1] by 100
      $sql.push @_update_batch(@_protect_identifiers($table, true, null, false), @ar_set.slice($i, 100), @_protect_identifiers($index), @ar_where)

    @queryList $sql, ($err) ->

      @_reset_write()
      $next $err



  #
  # The "set_update_batch" function.  Allows key/value pairs to be set for batch updating
  #
  # @param  [Array]  # @param  [String]  # @return	[Boolean]ean
  # @return [Object]  #

  set_update_batch : ($key, $index = '', $escape = true) ->
    $key = @_object_to_array_batch($key)

    for $k, $v of $key
      $index_set = false
      $clean = {}

      for $k2, $v2 of $v
        if $k2 is $index
          $index_set = true

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
  # @return	[Boolean]
  # @return [Object]
  #
  delete: ($table = '', $where = '', $limit = null, $reset_data = true, $next) ->

    if typeof $table is 'function'
      $next = $table
      $table = ''
      $where = ''
      $limit = null
      $reset_data = true

    else if typeof $where is 'function'
      $next = $where
      $where = ''
      $limit = null
      $reset_data = true

    else if typeof $limit is 'function'
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

    else if Array.isArray($table)
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

    if @ar_where.length is 0 and @ar_wherein.length is 0 and @ar_like.length is 0
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
    if Array.isArray($table)
      for $t in $table
        @_track_aliases($t)

      return


    #  Does the string contain a comma?  If so, we need to separate
    #  the string into discreet statements
    if $table.indexOf(',') isnt -1
      return @_track_aliases($table.split(','))


    #  if a table alias is used we can recognize it by a space
    if $table.indexOf(' ') isnt -1
      #  if the alias is written with the AS keyword, remove it
      $table = $table.replace(/\ AS /i, ' ')

      #  Grab the alias
      $table = trim($table.substr($table.indexOf(' ')))

      #  Store the alias, if it doesn't already exist
      if @ar_aliased_tables.indexOf($table) is -1
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
      $sql = if not @ar_distinct then 'SELECT ' else 'SELECT DISTINCT '

      if @ar_select.length is 0
        $sql+='*'

      else
        #  Cycle through the "select" portion of the query and prep each column name.
        #  The reason we protect identifiers here rather then in the select() function
        #  is because until the user calls the from() function we don't know if there are aliases

        for $key, $val of @ar_select
          @ar_select[$key] = @_protect_identifiers($val)

        $sql+=@ar_select.join(', ')

    #  ----------------------------------------------------------------

    #  Write the "FROM" portion of the query

    if @ar_from.length > 0
      $sql+="\nFROM "

      $sql+=@_from_tables(@ar_from)


    #  ----------------------------------------------------------------

    #  Write the "JOIN" portion of the query

    if @ar_join.length > 0
      $sql+="\n"

      $sql+=@ar_join.join("\n")


    #  ----------------------------------------------------------------

    #  Write the "WHERE" portion of the query

    if @ar_where.length > 0 or @ar_like.length > 0
      $sql+="\n"

      $sql+="WHERE "


    $sql+=@ar_where.join("\n")

    #  ----------------------------------------------------------------

    #  Write the "LIKE" portion of the query

    if @ar_like.length > 0
      if @ar_where.length > 0
        $sql+="\nAND "

      $sql+=@ar_like.join("\n")


    #  ----------------------------------------------------------------

    #  Write the "GROUP BY" portion of the query

    if @ar_groupby.length > 0
      $sql+="\nGROUP BY "

      $sql+=@ar_groupby.join(', ')


    #  ----------------------------------------------------------------

    #  Write the "HAVING" portion of the query

    if @ar_having.length > 0
      $sql+="\nHAVING "
      $sql+=@ar_having.join("\n")


    #  ----------------------------------------------------------------

    #  Write the "ORDER BY" portion of the query

    if @ar_orderby.length > 0
      $sql+="\nORDER BY "
      $sql+=@ar_orderby.join(', ')

      if @ar_order isnt false
        $sql+= if (@ar_order is 'desc') then ' DESC' else ' ASC'



    #  ----------------------------------------------------------------

    #  Write the "LIMIT" portion of the query

    if 'number' is typeof(@ar_limit)
      $sql+="\n"
      $sql = @_limit($sql, @ar_limit, @ar_offset)

    return $sql

  #
  # Object to Array
  #
  # Takes an object as input and converts the class variables to array key/vals
  #
  # @param  [Object]  # @return	array
  #
  _object_to_array_batch: ($object) ->
    if Array.isArray($object)
      return $object
    return $object if 'string' is typeof($object)

    $array = []
    $out = {}
    for $key, $val of $object
      if $key.substr(0,1) isnt '_' and typeof $object[$key] isnt 'function'
        $out[$key] = $val
    $fields = Object.keys($out)

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
  # @return [Void]
  #
  startCache:  ->
    @ar_caching = true


  #
  # Stop Cache
  #
  # Stops AR caching
  #
  # @return [Void]
  #
  stopCache:  ->
    @ar_caching = false


  #
  # Flush Cache
  #
  # Empties the AR cache
  #
  # @return [Void]
  #
  flushCache:  ->
    @_reset_run
      ar_cache_select:[]
      ar_cache_from:[]
      ar_cache_join:[]
      ar_cache_where:[]
      ar_cache_like:[]
      ar_cache_groupby:[]
      ar_cache_having:[]
      ar_cache_orderby:[]
      ar_cache_set:[]
      ar_cache_exists:[]


  #
  # Merge Cache
  #
  # When called, this function merges any cached AR arrays with
  # locally called ones.
  #
  # @private
  # @return [Void]
  #
  _merge_cache:  ->
    if @ar_cache_exists.length is 0
      return

    for $val in @ar_cache_exists
      $ar_variable = 'ar_' + $val
      $ar_cache_var = 'ar_cache_' + $val

      if @[$ar_cache_var].length is 0
        continue

      $tmp = []
      $unique = {}
      for $value, $index in [].concat($item for $item in @[$ar_cache_var], $item for $item in @[$ar_variable])
        if not $unique[$value]?
          $unique[$value] = true
          $tmp.push $value

      @[$ar_variable] = $tmp

    #  If we are "protecting identifiers" we need to examine the "from"
    #  portion of the query to determine if there are any aliases
    if @_protect_identifiers_default is true and @ar_cache_from.length > 0
      @_track_aliases(@ar_from)


  #
  # Resets the active record values.  Called by the get() function
  #
  # @private
  # @param  [Array]  An array of fields to reset
  # @return [Void]
  #
  _reset_run: ($ar_reset_items) ->
    for $item, $default_value of $ar_reset_items
      if @ar_store_array.indexOf($item) is -1
        @[$item] = $default_value

  #
  # Resets the active record values.  Called by the get() function
  #
  # @private
  # @return [Void]
  #
  _reset_select:  ->
    $ar_reset_items = 
      ar_select:[]
      ar_from:[]
      ar_join:[]
      ar_where:[]
      ar_like:[]
      ar_groupby:[]
      ar_having:[]
      ar_orderby:[]
      ar_wherein:[]
      ar_aliased_tables:[]
      ar_distinct:false
      ar_limit:false
      ar_offset:0
      ar_order:false

    @_reset_run($ar_reset_items)
    
  
  #
  # Resets the active record "write" values.
  #
  # Called by the insert() update() insert_batch() update_batch() and delete() functions
  #
  # @private
  # @return [Void]
  #
  _reset_write:  ->
    $ar_reset_items = 
      ar_set:[]
      ar_from:[]
      ar_where:[]
      ar_like:[]
      ar_orderby:[]
      ar_keys:[]
      ar_rec:{}
      ar_limit:false
      ar_order:false

    @_reset_run($ar_reset_items)
    
