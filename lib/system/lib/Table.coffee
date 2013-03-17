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

#  ------------------------------------------------------------------------

#
# HTML Table Generating Class
#
# Lets you create tables manually or from database result objects, or arrays.
#
#

class system.lib.Table
  
  _rows             : null
  _heading          : null
  _auto_heading     : true
  _caption          : null
  _template         : null
  _newline          : "\n"
  _empty_cells      : ""
  _function         : false
  
  constructor: () ->
    log_message('debug', "Table Class Initialized")
    @_rows = []
    @_heading = {}
  
  #
  # Set the template
  #
    # @param  [Array]  # @return [Void]  #
  setTemplate : ($template) ->
    if not is_array($template)
      return false
      
    
    @_template = $template
    
  
  #
  # Set the table heading
  #
  # Can be passed as an array or discreet params
  #
    # @param  [Mixed]  # @return [Void]  #
  setHeading :  ->
    $args = func_get_args()
    @_heading = @_prep_args($args)
    
  
  #
  # Set columns.  Takes a one-dimensional array as input and creates
  # a multi-dimensional array with a depth equal to the number of
  # columns.  This allows a single array with many elements to  be
  # displayed in a table that has a fixed column count.
  #
    # @param  [Array]  # @param	int
  # @return [Void]  #
  makeColumns : ($array = {}, $col_limit = 0) ->
    if not is_array($array) or count($array) is 0
      return false
      
    
    #  Turn off the auto-heading feature since it's doubtful we
    #  will want headings from a one-dimensional array
    @_auto_heading = false
    
    if $col_limit is 0
      return $array
      
    
    $new = []
    while count($array) > 0
      $temp = $array.splice(0, $col_limit)
      
      if count($temp) < $col_limit
        for $i in [count($temp)...$col_limit]
          $temp.push '&nbsp;'

      
      $new.push $temp
      
    
    return $new
    
  
  #
  # Set "empty" cells
  #
  # Can be passed as an array or discreet params
  #
    # @param  [Mixed]  # @return [Void]  #
  setEmpty : ($value) ->
    @_empty_cells = $value
    
  
  #
  # Add a table row
  #
  # Can be passed as an array or discreet params
  #
    # @param  [Mixed]  # @return [Void]  #
  addRow :  ->
    $args = func_get_args()
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
    #  This can happen if there is only a single key, for example this is passed to table->generate
    #  array(array('foo'=>'bar'))
    if $args[0]?  and (count($args) is 1 and is_array($args[0]))
      #  args sent as indexed array
      if not $args[0]['data']? 
        for $key, $val of $args[0]
          if is_array($val) and $val['data']? 
            $args[$key] = $val
            
          else 
            $args[$key] = 'data':$val

    else
      for $key, $val of $args
        continue if typeof $val is 'function' # strip functions left over from sql driver
        if not is_array($val)
          $args[$key] = 'data':$val

    return $args
    
  
  #
  # Add a table caption
  #
    # @param  [String]    # @return [Void]  #
  setCaption : ($caption) ->
    @_caption = $caption
    
  
  #
  # Generate the table
  #
    # @param  [Mixed]  # @return	[String]
  #
  generate : ($table_data = null) ->
    #  The table data can optionally be passed to this function
    #  either as a database result object or an array
    if $table_data?
      if 'object' is typeof($table_data)
        @_set_from_object($table_data)
        
      else if is_array($table_data)
        $set_heading = if (count(@_heading) is 0 and @_auto_heading is false) then false else true
        @_set_from_array($table_data, $set_heading)
        
      
    
    #  Is there anything to display?  No?  Smite them!
    if count(@_heading) is 0 and count(@_rows) is 0
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
    if count(@_heading) > 0
      $out+=@_template['thead_open']
      $out+=@_newline
      $out+=@_template['heading_row_start']
      $out+=@_newline
      
      for $heading in @_heading
        $temp = @_template['heading_cell_start']
        
        for $key, $val of $heading
          if $key isnt 'data'
            $temp = str_replace('<th', "<th $key='$val'", $temp)
            
          
        
        $out+=$temp
        $out+= if $heading['data']?  then $heading['data'] else ''
        $out+=@_template['heading_cell_end']
        
      
      $out+=@_template['heading_row_end']
      $out+=@_newline
      $out+=@_template['thead_close']
      $out+=@_newline
      
    
    #  Build the table rows
    if count(@_rows) > 0
      $out+=@_template['tbody_open']
      $out+=@_newline
      
      $i = 1
      for $row in @_rows
        if not is_array($row)
          break

        #  We use modulus to alternate the row colors
        #$name = if (fmod($i++, 2)) then '' else 'alt_'
        $name = if $i++ % 2 then '' else 'alt_'
        
        $out+=@_template['row_' + $name + 'start']
        $out+=@_newline
        for $k, $cell of $row
          $temp = @_template['cell_' + $name + 'start']
          
          for $key, $val of $cell
            if $key isnt 'data'
              $temp = str_replace('<td', "<td $key='#{$val}'", $temp)

          $cell = if $cell['data']?  then $cell['data'] else ''
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
    # @return [Void]  #
  clear :  ->
    @_rows = []
    @_heading = {}
    @_auto_heading = true
    
  
  #
  # Set table data from a database result object
  #
    # @param  [Object]    # @return [Void]  #
  _set_from_object : ($query) ->
    if not 'object' is typeof($query)
      return false
      
    #  First generate the headings from the table column names
    if count(@_heading) is 0
      if not $query.list_fields?
        return false
        
      
      @_heading = @_prep_args($query.list_fields())
      
    
    #  Next blast through the result array and build out the rows

    if $query.num_rows > 0
      for $row in $query.result_array()
        @_rows.push @_prep_args($row)

  #
  # Set table data from an array
  #
    # @param  [Array]  # @return [Void]  #
  _set_from_array : ($data, $set_heading = true) ->
    if not is_array($data) or count($data) is 0
      return false
      
    
    $i = 0
    for $row in $data
      #  If a heading hasn't already been set we'll use the first row of the array as the heading
      if $i is 0 and count($data) > 1 and count(@_heading) is 0 and $set_heading is true
        @_heading = @_prep_args($row)
        
      else
        @_rows.push @_prep_args($row)

      $i++
      
    
  
  #
  # Compile Template
  #
  # @private
  # @return [Void]  #
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
  # @return [Void]  #
  _default_template :  ->
    table_open          :'<table border="0" cellpadding="4" cellspacing="0">',

    thead_open          :'<thead>',
    thead_close         :'</thead>',

    heading_row_start   :'<tr>',
    heading_row_end     :'</tr>',
    heading_cell_start  :'<th>',
    heading_cell_end    :'</th>',

    tbody_open          :'<tbody>',
    tbody_close         :'</tbody>',

    row_start           :'<tr>',
    row_end             :'</tr>',
    cell_start          :'<td>',
    cell_end            :'</td>',

    row_alt_start       :'<tr>',
    row_alt_end         :'</tr>',
    cell_alt_start      :'<td>',
    cell_alt_end        :'</td>',

    table_close         :'</table>'
      
module.exports = system.lib.Table


#  End of file Table.php 
#  Location: .system/lib/Table.php