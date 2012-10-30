#+--------------------------------------------------------------------+
#  Unit_test.coffee
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


{__construct, count, debug_backtrace, defined, function_exists, get_instance, gettype, in_array, is_array, is_bool, is_null, lang, language, line, load, preg_match, str_replace, strtolower}  = require(FCPATH + 'lib')


if not defined('BASEPATH') then die 'No direct script access allowed'
#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 1.3.1
# @filesource
#

#  ------------------------------------------------------------------------

#
# Unit Testing Class
#
# Simple testing class
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	UnitTesting
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/libraries/uri.html
#
class CI_Unit_test
  
  active: true
  results: {}
  strict: false
  _template: null
  _template_rows: null
  _test_items_visible: {}
  
  __construct()
  {
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
  
  log_message('debug', "Unit Testing Class Initialized")
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Run the tests
  #
  # Runs the supplied tests
  #
  # @access	public
  # @param	array
  # @return	void
  #
  set_test_items : ($items = {}) ->
    if not empty($items) and is_array($items)
      @_test_items_visible = $items
      
    
  
  #  --------------------------------------------------------------------
  
  #
  # Run the tests
  #
  # Runs the supplied tests
  #
  # @access	public
  # @param	mixed
  # @param	mixed
  # @param	string
  # @return	string
  #
  run : ($test, $expected = true, $test_name = 'undefined', $notes = '') ->
    if @active is false
      return false
      
    
    if in_array($expected, ['is_object', 'is_string', 'is_bool', 'is_true', 'is_false', 'is_int', 'is_numeric', 'is_float', 'is_double', 'is_array', 'is_null'], true)
      $expected = str_replace('is_float', 'is_double', $expected)
      $result = if ($expected($test)) then true else false
      $extype = str_replace(['true', 'false'], 'bool', str_replace('is_', '', $expected))
      
    else 
      if @strict is true then $result = if ($test is $expected) then true else falseelse $result = if ($test is $expected) then true else false$extype = gettype($expected)}$back = @_backtrace()$report.push 
        'test_name':$test_name, 
        'test_datatype':gettype($test, 'res_datatype':$extype, 'result':($result is true) then 'passed' else 'failed', 'file':$back['file'], 'line':$back['line'], 'notes':$notes)@results.push $report
    return (@report(@result($report)))
    
  
  #  --------------------------------------------------------------------
  
  #
  # Generate a report
  #
  # Displays a table with the test data
  #
  # @access	public
  # @return	string
  #
  report : ($result = {}) ->
    if count($result) is 0
      $result = @result()
      
    
    $CI = get_instance()
    $CI.load.language('unit_test')
    
    @_parse_template()
    
    $r = ''
    for $res in $result
      $table = ''
      
      for $key, $val of $res
        if $key is $CI.lang.line('ut_result')
          if $val is $CI.lang.line('ut_passed')
            $val = '<span style="color: #0C0;">' + $val + '</span>'
            
          else if $val is $CI.lang.line('ut_failed')
            $val = '<span style="color: #C00;">' + $val + '</span>'
            
          
        
        $temp = @_template_rows
        $temp = str_replace('{item}', $key, $temp)
        $temp = str_replace('{result}', $val, $temp)
        $table+=$temp
        
      
      $r+=str_replace('{rows}', $table, @_template)
      
    
    return $r
    
  
  #  --------------------------------------------------------------------
  
  #
  # Use strict comparison
  #
  # Causes the evaluation to use === rather than ==
  #
  # @access	public
  # @param	bool
  # @return	null
  #
  use_strict : ($state = true) ->
    @strict = if ($state is false) then false else true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Make Unit testing active
  #
  # Enables/disables unit testing
  #
  # @access	public
  # @param	bool
  # @return	null
  #
  active : ($state = true) ->
    @active = if ($state is false) then false else true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Result Array
  #
  # Returns the raw result data
  #
  # @access	public
  # @return	array
  #
  result : ($results = {}) ->
    $CI = get_instance()
    $CI.load.language('unit_test')
    
    if count($results) is 0
      $results = @results
      
    
    $retval = {}
    for $result in $results
      $temp = {}
      for $key, $val of $result
        if not in_array($key, @_test_items_visible)
          continue
          
        
        if is_array($val)
          for $k, $v of $val
            if false isnt ($line = $CI.lang.line(strtolower('ut_' + $v)))
              $v = $line
              
            $temp[$CI.lang.line('ut_' + $k)] = $v
            
          
        else 
          if false isnt ($line = $CI.lang.line(strtolower('ut_' + $val)))
            $val = $line
            
          $temp[$CI.lang.line('ut_' + $key)] = $val
          
        
      
      $retval.push $temp
      
    
    return $retval
    
  
  #  --------------------------------------------------------------------
  
  #
  # Set the template
  #
  # This lets us set the template to be used to display results
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_template : ($template) ->
    @_template = $template
    
  
  #  --------------------------------------------------------------------
  
  #
  # Generate a backtrace
  #
  # This lets us show file names and line numbers
  #
  # @access	private
  # @return	array
  #
  _backtrace :  ->
    if function_exists('debug_backtrace')
      $back = debug_backtrace()
      
      $file = if ( not $back['1']['file']? ) then '' else $back['1']['file']
      $line = if ( not $back['1']['line']? ) then '' else $back['1']['line']
      
      return 'file':$file, 'line':$line
      
    return 'file':'Unknown', 'line':'Unknown'
    
  
  #  --------------------------------------------------------------------
  
  #
  # Get Default Template
  #
  # @access	private
  # @return	string
  #
  _default_template :  ->
    @_template = "\n" + '<table style="width:100%; font-size:small; margin:10px 0; border-collapse:collapse; border:1px solid #CCC;">'
    @_template+='{rows}'
    @_template+="\n" + '</table>'
    
    @_template_rows = "\n\t" + '<tr>'
    @_template_rows+="\n\t\t" + '<th style="text-align: left; border-bottom:1px solid #CCC;">{item}</th>'
    @_template_rows+="\n\t\t" + '<td style="border-bottom:1px solid #CCC;">{result}</td>'
    @_template_rows+="\n\t" + '</tr>'
    
  
  #  --------------------------------------------------------------------
  
  #
  # Parse Template
  #
  # Harvests the data within the template {pseudo-variables}
  #
  # @access	private
  # @return	void
  #
  _parse_template :  ->
    if not is_null(@_template_rows)
      return 
      
    
    if is_null(@_template)
      @_default_template()
      return 
      
    
    if not preg_match("/\{rows\}(.*?)\{\/rows\}/si", @_template, $match)
      @_default_template()
      return 
      
    
    @_template_rows = $match['1']
    @_template = str_replace($match['0'], '{rows}', @_template)
    
  
  

register_class 'CI_Unit_test', CI_Unit_test
module.exports = CI_Unit_test
#  END Unit_test Class

#
# Helper functions to test boolean true/false
#
#
# @access	private
# @return	bool
#
exports.is_true = is_true = ($test) ->
  return if (is_bool($test) and $test is true) then true else false
  
exports.is_false = is_false = ($test) ->
  return if (is_bool($test) and $test is false) then true else false
  


#  End of file Unit_test.php 
#  Location: ./system/libraries/Unit_test.php 