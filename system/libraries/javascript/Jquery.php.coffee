#+--------------------------------------------------------------------+
#  Jquery.coffee
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
# This file was ported from php to coffee-script using php2coffee
#
#


{__construct, config, count, defined, external, extract, get_instance, hover, implode, in_array, inline, is_array, item, load, preg_match, site_url, slash_item, str_replace, strpos, substr, vars}  = require(FCPATH + 'lib')


if not defined('BASEPATH') then die 'No direct script access allowed'

#
# CodeIgniter
#
# An open source application development framework for PHP 4.3.2 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		http://www.codeigniter.com/user_guide/license.html
# @link		http://www.codeigniter.com
# @since		Version 1.0
# @filesource
#

#
# Jquery Class
#
# @package		CodeIgniter
# @subpackage	Libraries
# @author		ExpressionEngine Dev Team
# @category	Loader
# @link		http://www.codeigniter.com/user_guide/libraries/javascript.html
#

class CI_Jquery extends CI_Javascript
  
  _javascript_folder: 'js'
  jquery_code_for_load: {}
  jquery_code_for_compile: {}
  jquery_corner_active: false
  jquery_table_sorter_active: false
  jquery_table_sorter_pager_active: false
  jquery_ajax_img: ''
  
  __construct($params)
  {
  @CI = Exspresso
  extract($params)
  
  if $autoload is true
    @script()
    
  
  log_message('debug', "Jquery Class Initialized")
  }
  
  #  --------------------------------------------------------------------
  #  Event Code
  #  --------------------------------------------------------------------
  
  #
  # Blur
  #
  # Outputs a jQuery blur event
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  _blur : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'blur')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Change
  #
  # Outputs a jQuery change event
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  _change : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'change')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Click
  #
  # Outputs a jQuery click event
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @param	boolean	whether or not to return false
  # @return	string
  #
  _click : ($element = 'this', $js = '', $ret_false = true) ->
    if not is_array($js)
      $js = [$js]
      
    
    if $ret_false
      $js.push "return false;"
      
    
    return @_add_event($element, $js, 'click')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Double Click
  #
  # Outputs a jQuery dblclick event
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  _dblclick : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'dblclick')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Error
  #
  # Outputs a jQuery error event
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  _error : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'error')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Focus
  #
  # Outputs a jQuery focus event
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  _focus : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'focus')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Hover
  #
  # Outputs a jQuery hover event
  #
  # @access	private
  # @param	string	- element
  # @param	string	- Javascript code for mouse over
  # @param	string	- Javascript code for mouse out
  # @return	string
  #
  _hover : ($element = 'this', $over, $out) ->
    $event = "\n\t$(" + @_prep_element($element) + ").hover(\n\t\tfunction()\n\t\t{\n\t\t\t{$over}\n\t\t}, \n\t\tfunction()\n\t\t{\n\t\t\t{$out}\n\t\t});\n"
    
    @jquery_code_for_compile.push $event
    
    return $event
    
  
  #  --------------------------------------------------------------------
  
  #
  # Keydown
  #
  # Outputs a jQuery keydown event
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  _keydown : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'keydown')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Keyup
  #
  # Outputs a jQuery keydown event
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  _keyup : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'keyup')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Load
  #
  # Outputs a jQuery load event
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  _load : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'load')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Mousedown
  #
  # Outputs a jQuery mousedown event
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  _mousedown : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'mousedown')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Mouse Out
  #
  # Outputs a jQuery mouseout event
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  _mouseout : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'mouseout')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Mouse Over
  #
  # Outputs a jQuery mouseover event
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  _mouseover : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'mouseover')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Mouseup
  #
  # Outputs a jQuery mouseup event
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  _mouseup : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'mouseup')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Output
  #
  # Outputs script directly
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  _output : ($array_js = '') ->
    if not is_array($array_js)
      $array_js = [$array_js]
      
    
    for $js in $array_js
      @jquery_code_for_compile.push "\t$js\n"
      
    
  
  #  --------------------------------------------------------------------
  
  #
  # Resize
  #
  # Outputs a jQuery resize event
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  _resize : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'resize')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Scroll
  #
  # Outputs a jQuery scroll event
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  _scroll : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'scroll')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Unload
  #
  # Outputs a jQuery unload event
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @return	string
  #
  _unload : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'unload')
    
  
  #  --------------------------------------------------------------------
  #  Effects
  #  --------------------------------------------------------------------
  
  #
  # Add Class
  #
  # Outputs a jQuery addClass event
  #
  # @access	private
  # @param	string	- element
  # @return	string
  #
  _addClass : ($element = 'this', $class = '') ->
    $element = @_prep_element($element)
    $str = "$({$element}).addClass(\"$class\");"
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Animate
  #
  # Outputs a jQuery animate event
  #
  # @access	private
  # @param	string	- element
  # @param	string	- One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param	string	- Javascript callback function
  # @return	string
  #
  _animate : ($element = 'this', $params = {}, $speed = '', $extra = '') ->
    $element = @_prep_element($element)
    $speed = @_validate_speed($speed)
    
    $animations = "\t\t\t"
    
    for $param, $value of $params
      $animations+=$param + ': \'' + $value + '\', '
      
    
    $animations = substr($animations, 0,  - 2)#  remove the last ", "
    
    if $speed isnt ''
      $speed = ', ' + $speed
      
    
    if $extra isnt ''
      $extra = ', ' + $extra
      
    
    $str = "$({$element}).animate({\n$animations\n\t\t}" + $speed + $extra + ");"
    
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Fade In
  #
  # Outputs a jQuery hide event
  #
  # @access	private
  # @param	string	- element
  # @param	string	- One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param	string	- Javascript callback function
  # @return	string
  #
  _fadeIn : ($element = 'this', $speed = '', $callback = '') ->
    $element = @_prep_element($element)
    $speed = @_validate_speed($speed)
    
    if $callback isnt ''
      $callback = ", function(){\n{$callback}\n}"
      
    
    $str = "$({$element}).fadeIn({$speed}{$callback});"
    
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Fade Out
  #
  # Outputs a jQuery hide event
  #
  # @access	private
  # @param	string	- element
  # @param	string	- One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param	string	- Javascript callback function
  # @return	string
  #
  _fadeOut : ($element = 'this', $speed = '', $callback = '') ->
    $element = @_prep_element($element)
    $speed = @_validate_speed($speed)
    
    if $callback isnt ''
      $callback = ", function(){\n{$callback}\n}"
      
    
    $str = "$({$element}).fadeOut({$speed}{$callback});"
    
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Hide
  #
  # Outputs a jQuery hide action
  #
  # @access	private
  # @param	string	- element
  # @param	string	- One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param	string	- Javascript callback function
  # @return	string
  #
  _hide : ($element = 'this', $speed = '', $callback = '') ->
    $element = @_prep_element($element)
    $speed = @_validate_speed($speed)
    
    if $callback isnt ''
      $callback = ", function(){\n{$callback}\n}"
      
    
    $str = "$({$element}).hide({$speed}{$callback});"
    
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Remove Class
  #
  # Outputs a jQuery remove class event
  #
  # @access	private
  # @param	string	- element
  # @return	string
  #
  _removeClass : ($element = 'this', $class = '') ->
    $element = @_prep_element($element)
    $str = "$({$element}).removeClass(\"$class\");"
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Slide Up
  #
  # Outputs a jQuery slideUp event
  #
  # @access	private
  # @param	string	- element
  # @param	string	- One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param	string	- Javascript callback function
  # @return	string
  #
  _slideUp : ($element = 'this', $speed = '', $callback = '') ->
    $element = @_prep_element($element)
    $speed = @_validate_speed($speed)
    
    if $callback isnt ''
      $callback = ", function(){\n{$callback}\n}"
      
    
    $str = "$({$element}).slideUp({$speed}{$callback});"
    
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Slide Down
  #
  # Outputs a jQuery slideDown event
  #
  # @access	private
  # @param	string	- element
  # @param	string	- One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param	string	- Javascript callback function
  # @return	string
  #
  _slideDown : ($element = 'this', $speed = '', $callback = '') ->
    $element = @_prep_element($element)
    $speed = @_validate_speed($speed)
    
    if $callback isnt ''
      $callback = ", function(){\n{$callback}\n}"
      
    
    $str = "$({$element}).slideDown({$speed}{$callback});"
    
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Slide Toggle
  #
  # Outputs a jQuery slideToggle event
  #
  # @access	public
  # @param	string	- element
  # @param	string	- One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param	string	- Javascript callback function
  # @return	string
  #
  _slideToggle : ($element = 'this', $speed = '', $callback = '') ->
    $element = @_prep_element($element)
    $speed = @_validate_speed($speed)
    
    if $callback isnt ''
      $callback = ", function(){\n{$callback}\n}"
      
    
    $str = "$({$element}).slideToggle({$speed}{$callback});"
    
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Toggle
  #
  # Outputs a jQuery toggle event
  #
  # @access	private
  # @param	string	- element
  # @return	string
  #
  _toggle : ($element = 'this') ->
    $element = @_prep_element($element)
    $str = "$({$element}).toggle();"
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Toggle Class
  #
  # Outputs a jQuery toggle class event
  #
  # @access	private
  # @param	string	- element
  # @return	string
  #
  _toggleClass : ($element = 'this', $class = '') ->
    $element = @_prep_element($element)
    $str = "$({$element}).toggleClass(\"$class\");"
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Show
  #
  # Outputs a jQuery show event
  #
  # @access	private
  # @param	string	- element
  # @param	string	- One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param	string	- Javascript callback function
  # @return	string
  #
  _show : ($element = 'this', $speed = '', $callback = '') ->
    $element = @_prep_element($element)
    $speed = @_validate_speed($speed)
    
    if $callback isnt ''
      $callback = ", function(){\n{$callback}\n}"
      
    
    $str = "$({$element}).show({$speed}{$callback});"
    
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Updater
  #
  # An Ajax call that populates the designated DOM node with
  # returned content
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	the controller to run the call against
  # @param	string	optional parameters
  # @return	string
  #
  
  _updater : ($container = 'this', $controller, $options = '') ->
    $container = @_prep_element($container)
    
    $controller = if (strpos('://', $controller) is false) then $controller else @CI.config.site_url($controller)
    
    #  ajaxStart and ajaxStop are better choices here... but this is a stop gap
    if @CI.config.item('javascript_ajax_img') is ''
      $loading_notifier = "Loading..."
      
    else 
      $loading_notifier = '<img src=\'' + @CI.config.slash_item('base_url') + @CI.config.item('javascript_ajax_img') + '\' alt=\'Loading\' />'
      
    
    $updater = "$($container).empty();\n"#  anything that was in... get it out
    $updater+="\t\t$($container).prepend(\"$loading_notifier\");\n"#  to replace with an image
    
    $request_options = ''
    if $options isnt ''
      $request_options+=", {"
      $request_options+=(is_array($options)) then "'" + implode("', '", $options) + "'" else "'" + str_replace(":", "':'", $options) + "'"
      $request_options+="}"
      
    
    $updater+="\t\t$($container).load('$controller'$request_options);"
    return $updater
    
  
  
  #  --------------------------------------------------------------------
  #  Pre-written handy stuff
  #  --------------------------------------------------------------------
  
  #
  # Zebra tables
  #
  # @access	private
  # @param	string	table name
  # @param	string	plugin location
  # @return	string
  #
  _zebraTables : ($class = '', $odd = 'odd', $hover = '') ->
    $class = if ($class isnt '') then '.' + $class else ''
    
    $zebra = "\t\$(\"table{$class} tbody tr:nth-child(even)\").addClass(\"{$odd}\");"
    
    @jquery_code_for_compile.push $zebra
    
    if $hover isnt ''
      $hover = @hover("table{$class} tbody tr", "$(this).addClass('hover');", "$(this).removeClass('hover');")
      
    
    return $zebra
    
  
  
  
  #  --------------------------------------------------------------------
  #  Plugins
  #  --------------------------------------------------------------------
  
  #
  # Corner Plugin
  #
  # http://www.malsup.com/jquery/corner/
  #
  # @access	public
  # @param	string	target
  # @return	string
  #
  corner : ($element = '', $corner_style = '') ->
    #  may want to make this configurable down the road
    $corner_location = '/plugins/jquery.corner.js'
    
    if $corner_style isnt ''
      $corner_style = '"' + $corner_style + '"'
      
    
    return "$(" + @_prep_element($element) + ").corner(" + $corner_style + ");"
    
  
  #  --------------------------------------------------------------------
  
  #
  # modal window
  #
  # Load a thickbox modal window
  #
  # @access	public
  # @return	void
  #
  modal : ($src, $relative = false) ->
    @jquery_code_for_load.push @external($src, $relative)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Effect
  #
  # Load an Effect library
  #
  # @access	public
  # @return	void
  #
  effect : ($src, $relative = false) ->
    @jquery_code_for_load.push @external($src, $relative)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Plugin
  #
  # Load a plugin library
  #
  # @access	public
  # @return	void
  #
  plugin : ($src, $relative = false) ->
    @jquery_code_for_load.push @external($src, $relative)
    
  
  #  --------------------------------------------------------------------
  
  #
  # UI
  #
  # Load a user interface library
  #
  # @access	public
  # @return	void
  #
  ui : ($src, $relative = false) ->
    @jquery_code_for_load.push @external($src, $relative)
    
  #  --------------------------------------------------------------------
  
  #
  # Sortable
  #
  # Creates a jQuery sortable
  #
  # @access	public
  # @return	void
  #
  sortable : ($element, $options = {}) ->
    
    if count($options) > 0
      $sort_options = {}
      for $k, $v of $options
        $sort_options.push "\n\t\t" + $k + ': ' + $v + ""
        
      $sort_options = implode(",", $sort_options)
      
    else 
      $sort_options = ''
      
    
    return "$(" + @_prep_element($element) + ").sortable({" + $sort_options + "\n\t});"
    
  
  #  --------------------------------------------------------------------
  
  #
  # Table Sorter Plugin
  #
  # @access	public
  # @param	string	table name
  # @param	string	plugin location
  # @return	string
  #
  tablesorter : ($table = '', $options = '') ->
    @jquery_code_for_compile.push "\t$(" + @_prep_element($table) + ").tablesorter($options);\n"
    
  
  #  --------------------------------------------------------------------
  #  Class functions
  #  --------------------------------------------------------------------
  
  #
  # Add Event
  #
  # Constructs the syntax for an event, and adds to into the array for compilation
  #
  # @access	private
  # @param	string	The element to attach the event to
  # @param	string	The code to execute
  # @param	string	The event to pass
  # @return	string
  #
  _add_event : ($element, $js, $event) ->
    if is_array($js)
      $js = implode("\n\t\t", $js)
      
      
    
    $event = "\n\t$(" + @_prep_element($element) + ").{$event}(function(){\n\t\t{$js}\n\t});\n"
    @jquery_code_for_compile.push $event
    return $event
    
  
  #  --------------------------------------------------------------------
  
  #
  # Compile
  #
  # As events are specified, they are stored in an array
  # This funciton compiles them all for output on a page
  #
  # @access	private
  # @return	string
  #
  _compile : ($view_var = 'script_foot', $script_tags = true) ->
    #  External references
    $external_scripts = implode('', @jquery_code_for_load)
    @CI.load.vars('library_src':$external_scripts)
    
    if count(@jquery_code_for_compile) is 0
      #  no inline references, let's just return
      return 
      
    
    #  Inline references
    $script = '$(document).ready(function() {' + "\n"
    $script+=implode('', @jquery_code_for_compile)
    $script+='});'
    
    $output = if ($script_tags is false) then $script else @inline($script)
    
    @CI.load.vars($view_var:$output)
    
    
  
  #  --------------------------------------------------------------------
  
  #
  # Clear Compile
  #
  # Clears the array of script events collected for output
  #
  # @access	public
  # @return	void
  #
  _clear_compile :  ->
    @jquery_code_for_compile = {}
    
  
  #  --------------------------------------------------------------------
  
  #
  # Document Ready
  #
  # A wrapper for writing document.ready()
  #
  # @access	private
  # @return	string
  #
  _document_ready : ($js) ->
    if not is_array($js)
      $js = [$js]
      
      
    
    for $script in $js
      @jquery_code_for_compile.push $script
      
    
  
  #  --------------------------------------------------------------------
  
  #
  # Script Tag
  #
  # Outputs the script tag that loads the jquery.js file into an HTML document
  #
  # @access	public
  # @param	string
  # @return	string
  #
  script : ($library_src = '', $relative = false) ->
    $library_src = @external($library_src, $relative)
    @jquery_code_for_load.push $library_src
    return $library_src
    
  
  #  --------------------------------------------------------------------
  
  #
  # Prep Element
  #
  # Puts HTML element in quotes for use in jQuery code
  # unless the supplied element is the Javascript 'this'
  # object, in which case no quotes are added
  #
  # @access	public
  # @param	string
  # @return	string
  #
  _prep_element : ($element) ->
    if $element isnt 'this'
      $element = '"' + $element + '"'
      
    
    return $element
    
  
  #  --------------------------------------------------------------------
  
  #
  # Validate Speed
  #
  # Ensures the speed parameter is valid for jQuery
  #
  # @access	private
  # @param	string
  # @return	string
  #
  _validate_speed : ($speed) ->
    if in_array($speed, ['slow', 'normal', 'fast'])
      $speed = '"' + $speed + '"'
      
    else if preg_match("/[^0-9]/", $speed)
      $speed = ''
      
    
    return $speed
    
  
  

register_class 'CI_Jquery', CI_Jquery
module.exports = CI_Jquery

#  End of file Jquery.php 
#  Location: ./system/libraries/Jquery.php 