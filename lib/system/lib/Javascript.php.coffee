#+--------------------------------------------------------------------+
#  Javascript.coffee
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
# Javascript Class
#
# @package		Exspresso
# @subpackage	Libraries
# @category	Javascript
# @author		darkoverlordofdata
# @see 		http://darkoverlordofdata.com/user_guide/lib/javascript.html
#
class ExspressoJavascript
  
  _javascript_location: 'js'
  
  __construct($params = {})
  {
  $defaults = 'js_library_driver':'jquery', 'autoload':true
  
  for $key, $val of $defaults
    if $params[$key]?  and $params[$key] isnt ""
      $defaults[$key] = $params[$key]
      
    
  
  extract($defaults)
  

  #  load the requested js library
  @load.library('javascript/' + $js_library_driver, 'autoload':$autoload)
  #  make js to refer to current library
  @js = @[$js_library_driver]
  
  log_message('debug', "Javascript Class Initialized and loaded.  Driver used: $js_library_driver")
  }
  
  #  --------------------------------------------------------------------
  #  Event Code
  #
  # Blur
  #
  # Outputs a javascript library blur event
  #
    # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  blur : ($element = 'this', $js = '') ->
    return @js._blur($element, $js)
    
  
  #
  # Change
  #
  # Outputs a javascript library change event
  #
    # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  change : ($element = 'this', $js = '') ->
    return @js._change($element, $js)
    
  
  #
  # Click
  #
  # Outputs a javascript library click event
  #
    # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[Boolean]ean	whether or not to return false
  # @return	[String]
  #
  click : ($element = 'this', $js = '', $ret_false = true) ->
    return @js._click($element, $js, $ret_false)
    
  
  #
  # Double Click
  #
  # Outputs a javascript library dblclick event
  #
    # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  dblclick : ($element = 'this', $js = '') ->
    return @js._dblclick($element, $js)
    
  
  #
  # Error
  #
  # Outputs a javascript library error event
  #
    # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  error : ($element = 'this', $js = '') ->
    return @js._error($element, $js)
    
  
  #
  # Focus
  #
  # Outputs a javascript library focus event
  #
    # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  focus : ($element = 'this', $js = '') ->
    return @js.__add_event($focus, $js)
    
  
  #
  # Hover
  #
  # Outputs a javascript library hover event
  #
    # @param  [String]  - element
  # @param  [String]  - Javascript code for mouse over
  # @param  [String]  - Javascript code for mouse out
  # @return	[String]
  #
  hover : ($element = 'this', $over, $out) ->
    return @js.__hover($element, $over, $out)
    
  
  #
  # Keydown
  #
  # Outputs a javascript library keydown event
  #
    # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  keydown : ($element = 'this', $js = '') ->
    return @js._keydown($element, $js)
    
  
  #
  # Keyup
  #
  # Outputs a javascript library keydown event
  #
    # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  keyup : ($element = 'this', $js = '') ->
    return @js._keyup($element, $js)
    
  
  #
  # Load
  #
  # Outputs a javascript library load event
  #
    # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  load : ($element = 'this', $js = '') ->
    return @js._load($element, $js)
    
  
  #
  # Mousedown
  #
  # Outputs a javascript library mousedown event
  #
    # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  mousedown : ($element = 'this', $js = '') ->
    return @js._mousedown($element, $js)
    
  
  #
  # Mouse Out
  #
  # Outputs a javascript library mouseout event
  #
    # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  mouseout : ($element = 'this', $js = '') ->
    return @js._mouseout($element, $js)
    
  
  #
  # Mouse Over
  #
  # Outputs a javascript library mouseover event
  #
    # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  mouseover : ($element = 'this', $js = '') ->
    return @js._mouseover($element, $js)
    
  
  #
  # Mouseup
  #
  # Outputs a javascript library mouseup event
  #
    # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  mouseup : ($element = 'this', $js = '') ->
    return @js._mouseup($element, $js)
    
  
  #
  # Output
  #
  # Outputs the called javascript to the screen
  #
    # @param  [String]  The code to output
  # @return	[String]
  #
  output : ($js) ->
    return @js._output($js)
    
  
  #
  # Ready
  #
  # Outputs a javascript library mouseup event
  #
    # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  ready : ($js) ->
    return @js._document_ready($js)
    
  
  #
  # Resize
  #
  # Outputs a javascript library resize event
  #
    # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  resize : ($element = 'this', $js = '') ->
    return @js._resize($element, $js)
    
  
  #
  # Scroll
  #
  # Outputs a javascript library scroll event
  #
    # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  scroll : ($element = 'this', $js = '') ->
    return @js._scroll($element, $js)
    
  
  #
  # Unload
  #
  # Outputs a javascript library unload event
  #
    # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  unload : ($element = 'this', $js = '') ->
    return @js._unload($element, $js)
    
  
  #  --------------------------------------------------------------------
  #  Effects

  #
  # Add Class
  #
  # Outputs a javascript library addClass event
  #
    # @param  [String]  - element
  # @param  [String]  - Class to add
  # @return	[String]
  #
  addClass : ($element = 'this', $class = '') ->
    return @js._addClass($element, $class)
    
  
  #
  # Animate
  #
  # Outputs a javascript library animate event
  #
    # @param  [String]  - element
  # @param  [String]  - One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param  [String]  - Javascript callback function
  # @return	[String]
  #
  animate : ($element = 'this', $params = {}, $speed = '', $extra = '') ->
    return @js._animate($element, $params, $speed, $extra)
    
  
  #
  # Fade In
  #
  # Outputs a javascript library hide event
  #
    # @param  [String]  - element
  # @param  [String]  - One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param  [String]  - Javascript callback function
  # @return	[String]
  #
  fadeIn : ($element = 'this', $speed = '', $next = '') ->
    return @js._fadeIn($element, $speed, $next)
    
  
  #
  # Fade Out
  #
  # Outputs a javascript library hide event
  #
    # @param  [String]  - element
  # @param  [String]  - One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param  [String]  - Javascript callback function
  # @return	[String]
  #
  fadeOut : ($element = 'this', $speed = '', $next = '') ->
    return @js._fadeOut($element, $speed, $next)
    
  #
  # Slide Up
  #
  # Outputs a javascript library slideUp event
  #
    # @param  [String]  - element
  # @param  [String]  - One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param  [String]  - Javascript callback function
  # @return	[String]
  #
  slideUp : ($element = 'this', $speed = '', $next = '') ->
    return @js._slideUp($element, $speed, $next)
    
    
  
  #
  # Remove Class
  #
  # Outputs a javascript library removeClass event
  #
    # @param  [String]  - element
  # @param  [String]  - Class to add
  # @return	[String]
  #
  removeClass : ($element = 'this', $class = '') ->
    return @js._removeClass($element, $class)
    
  
  #
  # Slide Down
  #
  # Outputs a javascript library slideDown event
  #
    # @param  [String]  - element
  # @param  [String]  - One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param  [String]  - Javascript callback function
  # @return	[String]
  #
  slideDown : ($element = 'this', $speed = '', $next = '') ->
    return @js._slideDown($element, $speed, $next)
    
  
  #
  # Slide Toggle
  #
  # Outputs a javascript library slideToggle event
  #
    # @param  [String]  - element
  # @param  [String]  - One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param  [String]  - Javascript callback function
  # @return	[String]
  #
  slideToggle : ($element = 'this', $speed = '', $next = '') ->
    return @js._slideToggle($element, $speed, $next)
    
    
  
  #
  # Hide
  #
  # Outputs a javascript library hide action
  #
    # @param  [String]  - element
  # @param  [String]  - One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param  [String]  - Javascript callback function
  # @return	[String]
  #
  hide : ($element = 'this', $speed = '', $next = '') ->
    return @js._hide($element, $speed, $next)
    
  
  #
  # Toggle
  #
  # Outputs a javascript library toggle event
  #
    # @param  [String]  - element
  # @return	[String]
  #
  toggle : ($element = 'this') ->
    return @js._toggle($element)
    
    
  
  #
  # Toggle Class
  #
  # Outputs a javascript library toggle class event
  #
    # @param  [String]  - element
  # @return	[String]
  #
  toggleClass : ($element = 'this', $class = '') ->
    return @js._toggleClass($element, $class)
    
  
  #
  # Show
  #
  # Outputs a javascript library show event
  #
    # @param  [String]  - element
  # @param  [String]  - One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param  [String]  - Javascript callback function
  # @return	[String]
  #
  show : ($element = 'this', $speed = '', $next = '') ->
    return @js._show($element, $speed, $next)
    
  
  
  #
  # Compile
  #
  # gather together all script needing to be output
  #
    # @param  [String]  The element to attach the event to
  # @return	[String]
  #
  compile : ($view_var = 'script_foot', $script_tags = true) ->
    @js._compile($view_var, $script_tags)
    
  
  #
  # Clear Compile
  #
  # Clears any previous javascript collected for output
  #
    # @return [Void]  #
  clear_compile :  ->
    @js._clear_compile()
    
  
  #
  # External
  #
  # Outputs a <script> tag with the source as an external js file
  #
    # @param  [String]  The element to attach the event to
  # @return	[String]
  #
  external : ($external_file = '', $relative = false) ->
    if $external_file isnt ''
      @_javascript_location = $external_file
      
    else 
      if @config.item('javascript_location') isnt ''
        @_javascript_location = @config.item('javascript_location')
        
      
    
    if $relative is true or strncmp($external_file, 'http://', 7) is 0 or strncmp($external_file, 'https://', 8) is 0
      $str = @_open_script($external_file)
      
    else if strpos(@_javascript_location, 'http://') isnt false
      $str = @_open_script(@_javascript_location + $external_file)
      
    else 
      $str = @_open_script(@config.slashItem('base_url') + @_javascript_location + $external_file)
      
    
    $str+=@_close_script()
    return $str
    
  
  #
  # Inline
  #
  # Outputs a <script> tag
  #
    # @param  [String]  The element to attach the event to
  # @return	[Boolean]ean	If a CDATA section should be added
  # @return	[String]
  #
  inline : ($script, $cdata = true) ->
    $str = @_open_script()
    $str+=($cdata) then "\n// <![CDATA[\n{$script}\n// ]]>\n" else "\n{$script}\n"
    $str+=@_close_script()
    
    return $str
    
  
  #
  # Open Script
  #
  # Outputs an opening <script>
  #
  # @private
  # @param  [String]    # @return	[String]
  #
  _open_script : ($src = '') ->
    $str = '<script type="text/javascript" charset="' + strtolower(@config.item('charset')) + '"'
    $str+=($src is '') then '>' else ' src="' + $src + '">'
    return $str
    
  
  #
  # Close Script
  #
  # Outputs an closing </script>
  #
  # @private
  # @param  [String]    # @return	[String]
  #
  _close_script : ($extra = "\n") ->
    return "</script>$extra"
    
  
  
  #  --------------------------------------------------------------------
  #  --------------------------------------------------------------------
  #  AJAX-Y STUFF - still a testbed
  #  --------------------------------------------------------------------
  #
  # Update
  #
  # Outputs a javascript library slideDown event
  #
    # @param  [String]  - element
  # @param  [String]  - One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param  [String]  - Javascript callback function
  # @return	[String]
  #
  update : ($element = 'this', $speed = '', $next = '') ->
    return @js._updater($element, $speed, $next)
    
  
  #
  # Generate JSON
  #
  # Can be passed a database result or associative array and returns a JSON formatted string
  #
  # @param  [Mixed]  result set or array
  # @return	[Boolean]	match array types (defaults to objects)
  # @return	[String]	a json formatted string
  #
  generate_json : ($result = null, $match_array_type = false) ->
    #  JSON data can optionally be passed to this function
    #  either as a database result object or an array, or a user supplied array
    if not is_null($result)
      if is_object($result)
        $json_result = $result.result_array()
        
      else if is_array($result)
        $json_result = $result
        
      else 
        return @_prep_args($result)
        
      
    else 
      return 'null'
      
    
    $json = {}
    $_is_assoc = true
    
    if not is_array($json_result) and empty($json_result)
      show_error("Generate JSON Failed - Illegal key, value pair.")
      
    else if $match_array_type
      $_is_assoc = @_is_associative_array($json_result)
      
    
    for $k, $v of $json_result
      if $_is_assoc
        $json.push @_prep_args($k, true) + ':' + @generate_json($v, $match_array_type)
        
      else 
        $json.push @generate_json($v, $match_array_type)
        
      
    
    $json = implode(',', $json)
    
    return if $_is_assoc then "{" + $json + "}" else "[" + $json + "]"
    
    
  
  #
  # Is associative array
  #
  # Checks for an associative array
  #
    # @param	type
  # @return	type
  #
  _is_associative_array : ($arr) ->
    for $key, $val of array_keys($arr)
      if $key isnt $val
        return true
        
      
    
    return false
    
  
  #
  # Prep Args
  #
  # Ensures a standard json value and escapes values
  #
    # @param	type
  # @return	type
  #
  _prep_args : ($result, $is_key = false) ->
    if is_null($result)
      return 'null'
      
    else if is_bool($result)
      return if ($result is true) then 'true' else 'false'
      
    else if is_string($result) or $is_key
      return '"' + str_replace(['\\', "\t", "\n", "\r", '"', '/'], ['\\\\', '\\t', '\\n', "\\r", '\"', '\/'], $result) + '"'
      
    else if is_scalar($result)
      return $result
      
    
  

register_class 'ExspressoJavascript', ExspressoJavascript
module.exports = ExspressoJavascript
#  END Javascript Class

#  End of file Javascript.php 
#  Location: ./system/lib/Javascript.php