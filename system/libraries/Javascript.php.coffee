#+--------------------------------------------------------------------+
#  Javascript.coffee
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
{__add_event, __construct, __hover, _addClass, _animate, _blur, _change, _clear_compile, _click, _compile, _dblclick, _document_ready, _error, _fadeIn, _fadeOut, _hide, _keydown, _keyup, _load, _mousedown, _mouseout, _mouseover, _mouseup, _output, _removeClass, _resize, _scroll, _show, _slideDown, _slideToggle, _slideUp, _toggle, _toggleClass, _unload, _updater, array_keys, config, defined, extract, get_instance, implode, is_array, is_bool, is_null, is_object, is_scalar, is_string, item, js, library, result_array, slash_item, str_replace, strncmp, strpos, strtolower}  = require(FCPATH + 'lib')
{config_item, get_class, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

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
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# Javascript Class
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Javascript
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/libraries/javascript.html
#
class CI_Javascript
  
  _javascript_location: 'js'
  
  __construct($params = {})
  {
  $defaults = 'js_library_driver':'jquery', 'autoload':true
  
  for $key, $val of $defaults
    if $params[$key]?  and $params[$key] isnt ""
      $defaults[$key] = $params[$key]
      
    
  
  extract($defaults)
  
  @CI = get_instance()
  
  #  load the requested js library
  @CI.load.library('javascript/' + $js_library_driver, 'autoload':$autoload)
  #  make js to refer to current library
  @js = @CI.$js_library_driver
  
  log_message('debug', "Javascript Class Initialized and loaded.  Driver used: $js_library_driver")
  }
  
  #  --------------------------------------------------------------------
  #  Event Code
  #  --------------------------------------------------------------------
  
  #
  # Blur
  #
  # Outputs a javascript library blur event
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  blur : ($element = 'this', $js = '') ->
    return @js._blur($element, $js)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Change
  #
  # Outputs a javascript library change event
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  change : ($element = 'this', $js = '') ->
    return @js._change($element, $js)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Click
  #
  # Outputs a javascript library click event
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @param	boolean	whether or not to return false
  # @return	string
  #
  click : ($element = 'this', $js = '', $ret_false = true) ->
    return @js._click($element, $js, $ret_false)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Double Click
  #
  # Outputs a javascript library dblclick event
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  dblclick : ($element = 'this', $js = '') ->
    return @js._dblclick($element, $js)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Error
  #
  # Outputs a javascript library error event
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  error : ($element = 'this', $js = '') ->
    return @js._error($element, $js)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Focus
  #
  # Outputs a javascript library focus event
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  focus : ($element = 'this', $js = '') ->
    return @js.__add_event($focus, $js)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Hover
  #
  # Outputs a javascript library hover event
  #
  # @access	public
  # @param	string	- element
  # @param	string	- Javascript code for mouse over
  # @param	string	- Javascript code for mouse out
  # @return	string
  #
  hover : ($element = 'this', $over, $out) ->
    return @js.__hover($element, $over, $out)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Keydown
  #
  # Outputs a javascript library keydown event
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  keydown : ($element = 'this', $js = '') ->
    return @js._keydown($element, $js)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Keyup
  #
  # Outputs a javascript library keydown event
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  keyup : ($element = 'this', $js = '') ->
    return @js._keyup($element, $js)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Load
  #
  # Outputs a javascript library load event
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  load : ($element = 'this', $js = '') ->
    return @js._load($element, $js)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Mousedown
  #
  # Outputs a javascript library mousedown event
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  mousedown : ($element = 'this', $js = '') ->
    return @js._mousedown($element, $js)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Mouse Out
  #
  # Outputs a javascript library mouseout event
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  mouseout : ($element = 'this', $js = '') ->
    return @js._mouseout($element, $js)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Mouse Over
  #
  # Outputs a javascript library mouseover event
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  mouseover : ($element = 'this', $js = '') ->
    return @js._mouseover($element, $js)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Mouseup
  #
  # Outputs a javascript library mouseup event
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  mouseup : ($element = 'this', $js = '') ->
    return @js._mouseup($element, $js)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Output
  #
  # Outputs the called javascript to the screen
  #
  # @access	public
  # @param	string	The code to output
  # @return	string
  #
  output : ($js) ->
    return @js._output($js)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Ready
  #
  # Outputs a javascript library mouseup event
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  ready : ($js) ->
    return @js._document_ready($js)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Resize
  #
  # Outputs a javascript library resize event
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  resize : ($element = 'this', $js = '') ->
    return @js._resize($element, $js)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Scroll
  #
  # Outputs a javascript library scroll event
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  scroll : ($element = 'this', $js = '') ->
    return @js._scroll($element, $js)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Unload
  #
  # Outputs a javascript library unload event
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  unload : ($element = 'this', $js = '') ->
    return @js._unload($element, $js)
    
  
  #  --------------------------------------------------------------------
  #  Effects
  #  --------------------------------------------------------------------
  
  
  #
  # Add Class
  #
  # Outputs a javascript library addClass event
  #
  # @access	public
  # @param	string	- element
  # @param	string	- Class to add
  # @return	string
  #
  addClass : ($element = 'this', $class = '') ->
    return @js._addClass($element, $class)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Animate
  #
  # Outputs a javascript library animate event
  #
  # @access	public
  # @param	string	- element
  # @param	string	- One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param	string	- Javascript callback function
  # @return	string
  #
  animate : ($element = 'this', $params = {}, $speed = '', $extra = '') ->
    return @js._animate($element, $params, $speed, $extra)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Fade In
  #
  # Outputs a javascript library hide event
  #
  # @access	public
  # @param	string	- element
  # @param	string	- One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param	string	- Javascript callback function
  # @return	string
  #
  fadeIn : ($element = 'this', $speed = '', $callback = '') ->
    return @js._fadeIn($element, $speed, $callback)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Fade Out
  #
  # Outputs a javascript library hide event
  #
  # @access	public
  # @param	string	- element
  # @param	string	- One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param	string	- Javascript callback function
  # @return	string
  #
  fadeOut : ($element = 'this', $speed = '', $callback = '') ->
    return @js._fadeOut($element, $speed, $callback)
    
  #  --------------------------------------------------------------------
  
  #
  # Slide Up
  #
  # Outputs a javascript library slideUp event
  #
  # @access	public
  # @param	string	- element
  # @param	string	- One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param	string	- Javascript callback function
  # @return	string
  #
  slideUp : ($element = 'this', $speed = '', $callback = '') ->
    return @js._slideUp($element, $speed, $callback)
    
    
  
  #  --------------------------------------------------------------------
  
  #
  # Remove Class
  #
  # Outputs a javascript library removeClass event
  #
  # @access	public
  # @param	string	- element
  # @param	string	- Class to add
  # @return	string
  #
  removeClass : ($element = 'this', $class = '') ->
    return @js._removeClass($element, $class)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Slide Down
  #
  # Outputs a javascript library slideDown event
  #
  # @access	public
  # @param	string	- element
  # @param	string	- One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param	string	- Javascript callback function
  # @return	string
  #
  slideDown : ($element = 'this', $speed = '', $callback = '') ->
    return @js._slideDown($element, $speed, $callback)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Slide Toggle
  #
  # Outputs a javascript library slideToggle event
  #
  # @access	public
  # @param	string	- element
  # @param	string	- One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param	string	- Javascript callback function
  # @return	string
  #
  slideToggle : ($element = 'this', $speed = '', $callback = '') ->
    return @js._slideToggle($element, $speed, $callback)
    
    
  
  #  --------------------------------------------------------------------
  
  #
  # Hide
  #
  # Outputs a javascript library hide action
  #
  # @access	public
  # @param	string	- element
  # @param	string	- One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param	string	- Javascript callback function
  # @return	string
  #
  hide : ($element = 'this', $speed = '', $callback = '') ->
    return @js._hide($element, $speed, $callback)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Toggle
  #
  # Outputs a javascript library toggle event
  #
  # @access	public
  # @param	string	- element
  # @return	string
  #
  toggle : ($element = 'this') ->
    return @js._toggle($element)
    
    
  
  #  --------------------------------------------------------------------
  
  #
  # Toggle Class
  #
  # Outputs a javascript library toggle class event
  #
  # @access	public
  # @param	string	- element
  # @return	string
  #
  toggleClass : ($element = 'this', $class = '') ->
    return @js._toggleClass($element, $class)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Show
  #
  # Outputs a javascript library show event
  #
  # @access	public
  # @param	string	- element
  # @param	string	- One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param	string	- Javascript callback function
  # @return	string
  #
  show : ($element = 'this', $speed = '', $callback = '') ->
    return @js._show($element, $speed, $callback)
    
  
  
  #  --------------------------------------------------------------------
  
  #
  # Compile
  #
  # gather together all script needing to be output
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @return	string
  #
  compile : ($view_var = 'script_foot', $script_tags = true) ->
    @js._compile($view_var, $script_tags)
    
  
  #
  # Clear Compile
  #
  # Clears any previous javascript collected for output
  #
  # @access	public
  # @return	void
  #
  clear_compile :  ->
    @js._clear_compile()
    
  
  #  --------------------------------------------------------------------
  
  #
  # External
  #
  # Outputs a <script> tag with the source as an external js file
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @return	string
  #
  external : ($external_file = '', $relative = false) ->
    if $external_file isnt ''
      @_javascript_location = $external_file
      
    else 
      if @CI.config.item('javascript_location') isnt ''
        @_javascript_location = @CI.config.item('javascript_location')
        
      
    
    if $relative is true or strncmp($external_file, 'http://', 7) is 0 or strncmp($external_file, 'https://', 8) is 0
      $str = @_open_script($external_file)
      
    else if strpos(@_javascript_location, 'http://') isnt false
      $str = @_open_script(@_javascript_location + $external_file)
      
    else 
      $str = @_open_script(@CI.config.slash_item('base_url') + @_javascript_location + $external_file)
      
    
    $str+=@_close_script()
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Inline
  #
  # Outputs a <script> tag
  #
  # @access	public
  # @param	string	The element to attach the event to
  # @param	boolean	If a CDATA section should be added
  # @return	string
  #
  inline : ($script, $cdata = true) ->
    $str = @_open_script()
    $str+=($cdata) then "\n// <![CDATA[\n{$script}\n// ]]>\n" else "\n{$script}\n"
    $str+=@_close_script()
    
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Open Script
  #
  # Outputs an opening <script>
  #
  # @access	private
  # @param	string
  # @return	string
  #
  _open_script : ($src = '') ->
    $str = '<script type="text/javascript" charset="' + strtolower(@CI.config.item('charset')) + '"'
    $str+=($src is '') then '>' else ' src="' + $src + '">'
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Close Script
  #
  # Outputs an closing </script>
  #
  # @access	private
  # @param	string
  # @return	string
  #
  _close_script : ($extra = "\n") ->
    return "</script>$extra"
    
  
  
  #  --------------------------------------------------------------------
  #  --------------------------------------------------------------------
  #  AJAX-Y STUFF - still a testbed
  #  --------------------------------------------------------------------
  #  --------------------------------------------------------------------
  
  #
  # Update
  #
  # Outputs a javascript library slideDown event
  #
  # @access	public
  # @param	string	- element
  # @param	string	- One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param	string	- Javascript callback function
  # @return	string
  #
  update : ($element = 'this', $speed = '', $callback = '') ->
    return @js._updater($element, $speed, $callback)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Generate JSON
  #
  # Can be passed a database result or associative array and returns a JSON formatted string
  #
  # @param	mixed	result set or array
  # @param	bool	match array types (defaults to objects)
  # @return	string	a json formatted string
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
    
    
  
  #  --------------------------------------------------------------------
  
  #
  # Is associative array
  #
  # Checks for an associative array
  #
  # @access	public
  # @param	type
  # @return	type
  #
  _is_associative_array : ($arr) ->
    for $key, $val of array_keys($arr)
      if $key isnt $val
        return true
        
      
    
    return false
    
  
  #  --------------------------------------------------------------------
  
  #
  # Prep Args
  #
  # Ensures a standard json value and escapes values
  #
  # @access	public
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
      
    
  
  #  --------------------------------------------------------------------
  

register_class 'CI_Javascript', CI_Javascript
module.exports = CI_Javascript
#  END Javascript Class

#  End of file Javascript.php 
#  Location: ./system/libraries/Javascript.php 