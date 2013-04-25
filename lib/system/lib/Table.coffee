#+--------------------------------------------------------------------+
#  Table.coffee
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
# HTML Table Generating Class
#
# Lets you create tables manually or from database result objects, or arrays.
#
#

module.exports = class system.lib.Table
  
  _rows             : null
  _heading          : null
  _auto_heading     : true
  _caption          : null
  _template         : null
  _newline          : "\n"
  _empty_cells      : ""
  _function         : false
  _striped          : false
  _hover            : false
  _condensed        : false
  _class            : 'table-striped table-hover table-condensed'

  constructor: () ->
    log_message('debug', "Table Class Initialized")
    @_rows = []
    @_heading = {}


  #
  # Set the html class
  #
  # @param  [String]  class table class to use
  # @return [Void]
  #
  setClass: ($class) ->
    @_class = $class

  #
  # Set the template
  #
  # @param  [Array]
  # @return [Void]
  #
  setTemplate : ($template) ->
    if 'object' isnt typeof ($template)
      return false
    @_template = $template
    
  
  #
  # Set the table heading
  #
  # Can be passed as an array or discreet params
  #
  # @param  [Mixed]
  # @return [Void]
  #
  setHeading: ($args...) ->
    @_heading = @_prep_args($args)
    
  
  #
  # Set columns.  Takes a one-dimensional array as input and creates
  # a multi-dimensional array with a depth equal to the number of
  # columns.  This allows a single array with many elements to  be
  # displayed in a table that has a fixed column count.
  #
  # @param  [Array]
  # @param	[Integer]
  # @return [Void]
  #
  makeColumns: ($array = [], $col_limit = 0) ->
    return false if $array.length is 0
    #  Turn off the auto-heading feature since it's doubtful we
    #  will want headings from a one-dimensional array
    @_auto_heading = false
    return $array if $col_limit is 0

    $new = []
    while $array.length > 0
      $temp = $array.splice(0, $col_limit)
      
      if $temp.length < $col_limit
        for $i in [$temp.length...$col_limit]
          $temp.push '&nbsp;'
      $new.push $temp

    return $new
    
  
  #
  # Set "empty" cells
  #
  # Can be passed as an array or discreet params
  #
  # @param  [Mixed]
  # @return [Void]
  #
  setEmpty: ($value) ->
    @_empty_cells = $value
    
  
  #
  # Add a table row
  #
  # Can be passed as an array or discreet params
  #
  # @param  [Mixed]
  # @return [Void]
  #
  addRow: ($args...) ->
    @_rows.push @_prep_args($args)
    
  
  #
  # Prep Args
  #
  # Ensures a standard associative array format for all cell data
  #
  # @param	type
  # @return	type
  #
  _prep_args : ($args) ->

    #  If there is no $args[0], skip this and treat as an associative array
    #  This can happen if there is only a single key, for example this is passed to table.generate
    #  [{'foo', 'bar'}]
    if $args[0]? and ($args.length is 1 and Array.isArray($args[0]))
      #  args sent as indexed array
      if not $args[0].data? 
        for $key, $val of $args[0]
          if 'object' is typeof($val) and $val?.data?
            $args[$key] = $val
          else
            $args[$key] = data:$val

    else
      for $key, $val of $args
        continue if typeof $val is 'function' # strip functions left over in sql result set
        if 'object' isnt typeof($val)
          $args[$key] = data:$val

    return $args
    
  
  #
  # Add a table caption
  #
  # @param  [String]
  # @return [Void]
  #
  setCaption : ($caption) ->
    @_caption = $caption
    
  
  #
  # Generate the table
  #
  # @param  [Mixed]
  # @return	[String]
  #
  generate : ($table_data = null) ->
    #  The table data can optionally be passed to this function
    #  either as a database result object or an array

    if $table_data?
      if $table_data.result? and typeof $table_data.result is 'function'
        @_set_from_object($table_data)
      else if 'object' is typeof($table_data)
        console.log $table_data
        $set_heading = if (@_heading.length is 0 and @_auto_heading is false) then false else true
        @_set_from_array($table_data, $set_heading)

    #  Is there anything to display?  No?  Smite them!
    if @_heading.length is 0 and @_rows.length is 0
      return 'Undefined table data'
      
    
    #  Compile and validate the template date
    @_compile_template()
    
    #  set a custom cell manipulation function to a locally scoped variable so its callable
    $function = @_function

    #  Build the table!
    
    $out = @_template['table_open']
    $out+=@_newline
    
    #  Add any caption here
    if @_caption
      $out+=@_newline
      $out+='<caption>' + @_caption + '</caption>'
      $out+=@_newline
      
    
    #  Is there a table heading to display?
    if @_heading.length > 0
      $out+=@_template['thead_open']
      $out+=@_newline
      $out+=@_template['heading_row_start']
      $out+=@_newline
      
      for $heading in @_heading
        $temp = @_template['heading_cell_start']
        
        for $key, $val of $heading
          if $key isnt 'data'
            $temp = $temp.replace('<th', "<th #{$key}='#{$val}'")

        $out+=$temp
        $out+= if $heading.data? then $heading.data else ''
        $out+=@_template['heading_cell_end']
        
      
      $out+=@_template['heading_row_end']
      $out+=@_newline
      $out+=@_template['thead_close']
      $out+=@_newline
      
    
    #  Build the table rows
    if @_rows.length > 0
      $out+=@_template['tbody_open']
      $out+=@_newline
      
      $i = 1
      for $row in @_rows
        if 'object' isnt typeof($row)
          break

        #  We use modulus to alternate the row colors
        #$name = if (fmod($i++, 2)) then '' else 'alt_'
        $name = if $i++ % 2 then '' else 'alt_'
        
        $out+=@_template['row_' + $name + 'start']
        $out+=@_newline
        for $k, $cell of $row
          $temp = @_template['cell_' + $name + 'start']

          # ignore methods...
          continue if typeof $cell is 'function'

          for $key, $val of $cell
            if $key isnt 'data'
              $temp = $temp.replace('<td', "<td $key='#{$val}'")

          $cell = if $cell.data? then $cell.data else ''
          $out+=$temp
          
          if $cell is "" or $cell is null
            $out+=@_empty_cells
            
          else
            if $function isnt false and typeof $function is 'function'
              $out+=$function($cell)
              
            else 
              $out+=$cell

          $out+=@_template['cell_' + $name + 'end']

        $out+=@_template['row_' + $name + 'end']
        $out+=@_newline

      $out+=@_template['tbody_close']
      $out+=@_newline

    $out+=@_template['table_close']
    
    #  Clear table class properties before generating the table
    @clear()
    
    return $out
    
  
  #
  # Clears the table arrays.  Useful if multiple tables are being generated
  #
  # @return [Void]
  #
  clear :  ->
    @_rows = []
    @_heading = {}
    @_auto_heading = true
    
  
  #
  # Set table data from a database result object
  #
  # @param  [Object]
  # @return [Void]
  #
  _set_from_object : ($query) ->
    return false if 'object' isnt typeof($query)

    #  First generate the headings from the table column names
    if @_heading.length is 0
      return false if not $query.listFields?
      @_heading = @_prep_args($query.listFields())

    #  Next blast through the result array and build out the rows
    if $query.num_rows > 0
      for $row in $query.resultArray()
        @_rows.push @_prep_args($row)

  #
  # Set table data from an array
  #
  # @param  [Array]
  # @return [Void]
  #
  _set_from_array : ($data, $set_heading = true) ->
    if Array.isArray($data)
      $i = 0
      for $row in $data
        #  If a heading hasn't already been set we'll use the first row of the array as the heading
        if $i is 0 and $data.length > 1 and @_heading.length is 0 and $set_heading is true
          @_heading = @_prep_args($row)
        else
          @_rows.push @_prep_args($row)
        $i++

    else
      for $key, $val of $data
        #  If a heading hasn't already been set we'll use the first row of the array as the heading
        if $i is 0 and $data.length > 1 and @_heading.length is 0 and $set_heading is true
          @_heading = @_prep_args([$key, $val])
        else
          @_rows.push @_prep_args([$key, $val])
        $i++


  #
  # Compile Template
  #
  # @private
  # @return [Void]
  #
  _compile_template :  ->
    if @_template is null
      @_template = @_default_template()
      return 

    @temp = @_default_template()
    for $val in ['table_open', 'thead_open', 'thead_close', 'heading_row_start', 'heading_row_end', 'heading_cell_start', 'heading_cell_end', 'tbody_open', 'tbody_close', 'row_start', 'row_end', 'cell_start', 'cell_end', 'row_alt_start', 'row_alt_end', 'cell_alt_start', 'cell_alt_end', 'table_close']
      if not @_template[$val]? 
        @_template[$val] = @temp[$val]
        
      
    
  
  #
  # Default Template
  #
  # @private
  # @return [Void]
  #
  _default_template :  ->
    table_open          : " <table class=\"table #{@_class}\">",

    thead_open          : '<thead>',
    thead_close         : '</thead>',

    heading_row_start   : '<tr>',
    heading_row_end     : '</tr>',
    heading_cell_start  : '<th>',
    heading_cell_end    : '</th>',

    tbody_open          : '<tbody>',
    tbody_close         : '</tbody>',

    row_start           : '<tr>',
    row_end             : '</tr>',
    cell_start          : '<td>',
    cell_end            : '</td>',

    row_alt_start       : '<tr>',
    row_alt_end         : '</tr>',
    cell_alt_start      : '<td>',
    cell_alt_end        : '</td>',

    table_close         : '</table>'
      
