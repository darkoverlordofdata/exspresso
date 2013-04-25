#+--------------------------------------------------------------------+
#  Unit.coffee
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
# Unit Testing Class
#
module.exports = class system.lib.Unit

  #
  # Helper functions to test boolean true/false
  #
  is_true = ($test) -> if ('boolean' is typeof($test) and $test is true) then true else false

  is_false = ($test) -> if ('boolean' is typeof($test) and $test is false) then true else false

  _active               : true
  _results              : null
  _strict               : false
  _template             : null
  _template_rows        : null
  _test_items_visible   : null
  _class                : 'table-striped table-hover table-condensed'

  constructor: ($controller, $config = {}) ->
    #  These are the default items visible when a test is run.
    @_test_items_visible = [
      'test_name',
      'test_datatype',
      'res_datatype',
      'result',
      'file',
      'line',
      'notes'
      ]
    @_results = []

    log_message 'debug', "Unit Testing Class Initialized"

  #
  # Run the tests
  #
  # Runs the supplied tests
  #
  # @param  [Array]
  # @return [Void]
  #
  setTestItems: ($items = []) ->
    if Array.isArray($items) and $items.length>0
      @_test_items_visible = $items
      
    
  
  #
  # Run the tests
  #
  # Runs the supplied tests
  #
  # @param  [Mixed]
  # @param  [Mixed]
  # @param  [String]
  # @return	[String]
  #
  run: ($test, $expected = true, $test_name = 'undefined', $notes = '') ->
    if @_active is false
      return false
      
    if ['is_object', 'is_string', 'is_boolean', 'is_true', 'is_false', 'is_number', 'is_null'].indexOf($expected) isnt -1

      $result = typeof($test) is $expected.replace('is_', '')

    else 
      if @_strict is true
        $result = if ($test is $expected) then true else false
      else
        $result = if ($test is $expected) then true else false
        $extype = typeof($expected)

    $back = @_backtrace()
    $report =
      test_name       : $test_name
      test_datatype   : typeof($test)
      res_datatype    : $extype
      result          : if ($result is true) then 'passed' else 'failed'
      file            : $back['file']
      line            : $back['line']
      notes           : $notes
    @_results.push $report
    @report(@result($report))
    
  
  #
  # Generate a report
  #
  # Displays a table with the test data
  #
  # @return	[String]
  #
  report: ($result = []) ->
    if $result.length is 0
      $result = @result()
      
    @load.language('unit_test')
    
    @_parse_template()
    
    $r = ''
    for $res in $result
      $table = ''
      
      for $key, $val of $res
        if $key is @i18n.line('ut_result')
          if $val is @i18n.line('ut_passed')
            $val = '<span style="color: #0C0;">' + $val + '</span>'
            
          else if $val is @i18n.line('ut_failed')
            $val = '<span style="color: #C00;">' + $val + '</span>'

        $temp = @_template_rows
        $temp = $temp.replace('{item}', $key)
        $temp = $temp.replace('{result}', $val)
        $table+=$temp

      $r+=@_template.replace('{rows}', $table)
      
    return $r
    
  
  #
  # Use strict comparison
  #
  # Causes the evaluation to use === rather than ==
  #
  # @return	[Boolean]
  # @return	null
  #
  useStrict: ($state = true) ->
    @_strict = if ($state is false) then false else true
    
  
  #
  # Make Unit testing active
  #
  # Enables/disables unit testing
  #
  # @return	[Boolean]
  # @return	null
  #
  active: ($state = true) ->
    @_active = if ($state is false) then false else true
    
  
  #
  # Result Array
  #
  # Returns the raw result data
  #
  # @return	array
  #
  result: ($results = []) ->

    @load.language('unit_test')
    
    if $results.length is 0
      $results = @_results

    $retval = []
    for $result in $results
      $temp = {}
      for $key, $val of $result
        if @_test_items_visible.indexOf($key) is -1
          continue

        if is_array($val)
          for $k, $v of $val
            if false isnt ($line = @i18n.line('ut_' + $v.toLowerCase()))
              $v = $line
              
            $temp[@i18n.line('ut_' + $k)] = $v

        else 
          if false isnt ($line = @i18n.line('ut_' + $val.toLowerCase()))
            $val = $line
            
          $temp[@i18n.line('ut_' + $key)] = $val

      $retval.push $temp

    return $retval
    
  
  #
  # Set the template
  #
  # This lets us set the template to be used to display results
  #
  # @param  [String]
  # @return [Void]
  #
  setTemplate: ($template) ->
    @_template = $template
    
  
  #
  # Generate a backtrace
  #
  # This lets us show file names and line numbers
  #
  # @private
  # @return	array
  #
  _backtrace:  ->
    if function_exists('debug_backtrace')
      $back = debug_backtrace()
      
      $file = if ( not $back['1']['file']? ) then '' else $back['1']['file']
      $line = if ( not $back['1']['line']? ) then '' else $back['1']['line']
      
      return file:$file, line:$line
      
    return file:'Unknown', line:'Unknown'
    
  
  #
  # Get Default Template
  #
  # @private
  # @return	[String]
  #
  _default_template:  ->
    @_template = "\n<table class=\"table #{@_class}\">"
    @_template+='{rows}'
    @_template+="\n" + '</table>'
    
    @_template_rows = "\n\t" + '<tr>'
    @_template_rows+= "\n\t\t" + '<th style="text-align: left; border-bottom:1px solid #CCC;">{item}</th>'
    @_template_rows+= "\n\t\t" + '<td style="border-bottom:1px solid #CCC;">{result}</td>'
    @_template_rows+= "\n\t" + '</tr>'
    
  
  #
  # Parse Template
  #
  # Harvests the data within the template {pseudo-variables}
  #
  # @private
  # @return [Void]
  #
  _parse_template:  ->
    if @_template_rows isnt null
      return

    if @_template is null
      @_default_template()
      return


    if not ($match = /\{rows\}(.*?)\{\/rows\}/igm.match(@_template))?
      @_default_template()
      return 
      
    
    @_template_rows = $match['1']
    @_template = @_template.replace($match['0'], '{rows}')
    
  
