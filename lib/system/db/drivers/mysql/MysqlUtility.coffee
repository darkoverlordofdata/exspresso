#+--------------------------------------------------------------------+
#  MysqlUtility.coffee
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
# MySQL Utility Class
#
#
module.exports = class system.db.mysql.MysqlUtility extends system.db.Utility
  
  #
  # List databases
  #
  # @private
  # @return	bool
  #
  _list_databases :  ->
    "SHOW DATABASES"
    
  
  #
  # Optimize table query
  #
  # Generates a platform-specific query so that a table can be optimized
  #
  # @private
  # @param  [String]  the table name
  # @return [Object]  #
  _optimize_table: ($table) ->
    "OPTIMIZE TABLE " + @db._escape_identifiers($table)
    
  
  #
  # Repair table query
  #
  # Generates a platform-specific query so that a table can be repaired
  #
  # @private
  # @param  [String]  the table name
  # @return [Object]  #
  _repair_table: ($table) ->
    "REPAIR TABLE " + @db._escape_identifiers($table)
    
  
  #  --------------------------------------------------------------------
  #
  # MySQL Export
  #
  # @private
  # @param  [Array]  Preferences
  # @return [Mixed]  #
  _backup: ($params = {}, $next) ->
    return false if keys($params).length is 0

    #  Extract the prefs for simplicity
    #extract($params)
    $tables = $params.tables
    $ignore = $params.ignore
    $filename = $params.filename
    $format = $params.format
    $add_drop = $params.add_drop
    $add_insert = $params.add_insert
    $newline = $param.newline

    #  Build the output

    $output = ''
    $sql_list = []
    $tables = $table for $table in $tables when $ignore.indexOf($table) is -1

    for $table in $tables #  Is the table in the "ignore" list?
      $sql_list.push "SHOW CREATE TABLE `" + @db.database + '`.' + $table
      $sql_list.push "SELECT * FROM #{$table}"

    @db.queries $sql_list, ($err, $results) =>

      #  No result means the table name was invalid
      $next($err) if $err

      for $query, $index in $results
        $table = $tables[Math.floor($index/2)]
        if $index & 1 is 0
          #  Get the table schema
          # "SHOW CREATE TABLE `" + @db.database + '`.' + $table

          #  Write out the table schema
          $output+='#' + $newline + '# TABLE STRUCTURE FOR: ' + $table + $newline + '#' + $newline + $newline

          if $add_drop is true
            $output+='DROP TABLE IF EXISTS ' + $table + ';' + $newline + $newline

          $i = 0
          $result = $query.result_array()
          for $val in $result[0]
            if $i++ % 2
              $output+=$val + ';' + $newline + $newline

        else

          #  If inserts are not needed we're done...
          if $add_insert is false
            continue

          #  Grab all the data from the current table
          # "SELECT * FROM #{$table}"

          if $query.num_rows is 0
            continue


          #  Fetch the field names and determine if the field is an
          #  integer type.  We use this info to decide whether to
          #  surround the data with quotes or not

          $i = 0
          $field_str = ''
          $is_int = {}
          while $field = mysql_fetch_field($query.result_id)
            #  Most versions of MySQL store timestamp as a string
            #  Create a string of field names
            $is_int[$i] = if ['tinyint', 'smallint', 'mediumint', 'int', 'bigint'].indexOf(mysql_field_type($query.result_id, $i).toUpperCase()) is -1 then false else true
            $field_str+='`' + $field.name + '`, '
            $i++

          #  Trim off the end comma
          $field_str = $field_str.replace(/, $/, '')

          #  Build the insert string
          for $row in $query.result_array()
            $val_str = ''

            $i = 0
            for $v in $row
              #  Is the value NULL?
              if $v is null
                $val_str+='NULL'

              else
                #  Escape the data if it's not an integer
                if $is_int[$i] is false
                  $val_str+=@db.escape($v)

                else
                  $val_str+=$v

              #  Append a comma
              $val_str+=', '
              $i++

            #  Remove the comma at the end of the string
            $val_str = $val_str.replace(/, $/, '')

            #  Build the INSERT string
            $output+='INSERT INTO ' + $table + ' (' + $field_str + ') VALUES (' + $val_str + ');' + $newline

          $output+=$newline + $newline

      $next(null, $output)
    
