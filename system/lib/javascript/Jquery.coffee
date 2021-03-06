#+--------------------------------------------------------------------+
#  Jquery.coffee
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
# Jquery Class
#

class system.lib.javascript.Jquery extends system.lib.Javascript
  
  _javascript_folder: 'js'
  jquery_code_for_load: {}
  jquery_code_for_compile: {}
  jquery_corner_active: false
  jquery_table_sorter_active: false
  jquery_table_sorter_pager_active: false
  jquery_ajax_img: ''
  
  __construct($params)
  {
  extract($params)
  
  if $autoload is true
    @script()
    
  
  log_message('debug', "Jquery Class Initialized")
  }
  
  #  --------------------------------------------------------------------
  #  Event Code
  #
  # Blur
  #
  # Outputs a jQuery blur event
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  _blur : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'blur')
    
  
  #
  # Change
  #
  # Outputs a jQuery change event
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  _change : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'change')
    
  
  #
  # Click
  #
  # Outputs a jQuery click event
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[Boolean]ean	whether or not to return false
  # @return	[String]
  #
  _click : ($element = 'this', $js = '', $ret_false = true) ->
    if not is_array($js)
      $js = [$js]
      
    
    if $ret_false
      $js.push "return false;"
      
    
    return @_add_event($element, $js, 'click')
    
  
  #
  # Double Click
  #
  # Outputs a jQuery dblclick event
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  _dblclick : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'dblclick')
    
  
  #
  # Error
  #
  # Outputs a jQuery error event
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  _error : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'error')
    
  
  #
  # Focus
  #
  # Outputs a jQuery focus event
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  _focus : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'focus')
    
  
  #
  # Hover
  #
  # Outputs a jQuery hover event
  #
  # @private
  # @param  [String]  - element
  # @param  [String]  - Javascript code for mouse over
  # @param  [String]  - Javascript code for mouse out
  # @return	[String]
  #
  _hover : ($element = 'this', $over, $out) ->
    $event = "\n\t$(" + @_prep_element($element) + ").hover(\n\t\tfunction()\n\t\t{\n\t\t\t{$over}\n\t\t}, \n\t\tfunction()\n\t\t{\n\t\t\t{$out}\n\t\t});\n"
    
    @jquery_code_for_compile.push $event
    
    return $event
    
  
  #
  # Keydown
  #
  # Outputs a jQuery keydown event
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  _keydown : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'keydown')
    
  
  #
  # Keyup
  #
  # Outputs a jQuery keydown event
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  _keyup : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'keyup')
    
  
  #
  # Load
  #
  # Outputs a jQuery load event
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  _load : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'load')
    
  
  #
  # Mousedown
  #
  # Outputs a jQuery mousedown event
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  _mousedown : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'mousedown')
    
  
  #
  # Mouse Out
  #
  # Outputs a jQuery mouseout event
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  _mouseout : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'mouseout')
    
  
  #
  # Mouse Over
  #
  # Outputs a jQuery mouseover event
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  _mouseover : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'mouseover')
    
  
  #
  # Mouseup
  #
  # Outputs a jQuery mouseup event
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  _mouseup : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'mouseup')
    
  
  #
  # Output
  #
  # Outputs script directly
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  _output : ($array_js = '') ->
    if not is_array($array_js)
      $array_js = [$array_js]
      
    
    for $js in $array_js
      @jquery_code_for_compile.push "\t$js\n"
      
    
  
  #
  # Resize
  #
  # Outputs a jQuery resize event
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  _resize : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'resize')
    
  
  #
  # Scroll
  #
  # Outputs a jQuery scroll event
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  _scroll : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'scroll')
    
  
  #
  # Unload
  #
  # Outputs a jQuery unload event
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @return	[String]
  #
  _unload : ($element = 'this', $js = '') ->
    return @_add_event($element, $js, 'unload')
    
  
  #  --------------------------------------------------------------------
  #  Effects
  #
  # Add Class
  #
  # Outputs a jQuery addClass event
  #
  # @private
  # @param  [String]  - element
  # @return	[String]
  #
  _addClass : ($element = 'this', $class = '') ->
    $element = @_prep_element($element)
    $str = "$({$element}).addClass(\"$class\");"
    return $str
    
  
  #
  # Animate
  #
  # Outputs a jQuery animate event
  #
  # @private
  # @param  [String]  - element
  # @param  [String]  - One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param  [String]  - Javascript callback function
  # @return	[String]
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
    
  
  #
  # Fade In
  #
  # Outputs a jQuery hide event
  #
  # @private
  # @param  [String]  - element
  # @param  [String]  - One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param  [String]  - Javascript callback function
  # @return	[String]
  #
  _fadeIn : ($element = 'this', $speed = '', $next = '') ->
    $element = @_prep_element($element)
    $speed = @_validate_speed($speed)
    
    if $next isnt ''
      $next = ", function(){\n{$next}\n}"
      
    
    $str = "$({$element}).fadeIn({$speed}{$next});"
    
    return $str
    
  
  #
  # Fade Out
  #
  # Outputs a jQuery hide event
  #
  # @private
  # @param  [String]  - element
  # @param  [String]  - One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param  [String]  - Javascript callback function
  # @return	[String]
  #
  _fadeOut : ($element = 'this', $speed = '', $next = '') ->
    $element = @_prep_element($element)
    $speed = @_validate_speed($speed)
    
    if $next isnt ''
      $next = ", function(){\n{$next}\n}"
      
    
    $str = "$({$element}).fadeOut({$speed}{$next});"
    
    return $str
    
  
  #
  # Hide
  #
  # Outputs a jQuery hide action
  #
  # @private
  # @param  [String]  - element
  # @param  [String]  - One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param  [String]  - Javascript callback function
  # @return	[String]
  #
  _hide : ($element = 'this', $speed = '', $next = '') ->
    $element = @_prep_element($element)
    $speed = @_validate_speed($speed)
    
    if $next isnt ''
      $next = ", function(){\n{$next}\n}"
      
    
    $str = "$({$element}).hide({$speed}{$next});"
    
    return $str
    
  
  #
  # Remove Class
  #
  # Outputs a jQuery remove class event
  #
  # @private
  # @param  [String]  - element
  # @return	[String]
  #
  _removeClass : ($element = 'this', $class = '') ->
    $element = @_prep_element($element)
    $str = "$({$element}).removeClass(\"$class\");"
    return $str
    
  
  #
  # Slide Up
  #
  # Outputs a jQuery slideUp event
  #
  # @private
  # @param  [String]  - element
  # @param  [String]  - One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param  [String]  - Javascript callback function
  # @return	[String]
  #
  _slideUp : ($element = 'this', $speed = '', $next = '') ->
    $element = @_prep_element($element)
    $speed = @_validate_speed($speed)
    
    if $next isnt ''
      $next = ", function(){\n{$next}\n}"
      
    
    $str = "$({$element}).slideUp({$speed}{$next});"
    
    return $str
    
  
  #
  # Slide Down
  #
  # Outputs a jQuery slideDown event
  #
  # @private
  # @param  [String]  - element
  # @param  [String]  - One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param  [String]  - Javascript callback function
  # @return	[String]
  #
  _slideDown : ($element = 'this', $speed = '', $next = '') ->
    $element = @_prep_element($element)
    $speed = @_validate_speed($speed)
    
    if $next isnt ''
      $next = ", function(){\n{$next}\n}"
      
    
    $str = "$({$element}).slideDown({$speed}{$next});"
    
    return $str
    
  
  #
  # Slide Toggle
  #
  # Outputs a jQuery slideToggle event
  #
    # @param  [String]  - element
  # @param  [String]  - One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param  [String]  - Javascript callback function
  # @return	[String]
  #
  _slideToggle : ($element = 'this', $speed = '', $next = '') ->
    $element = @_prep_element($element)
    $speed = @_validate_speed($speed)
    
    if $next isnt ''
      $next = ", function(){\n{$next}\n}"
      
    
    $str = "$({$element}).slideToggle({$speed}{$next});"
    
    return $str
    
  
  #
  # Toggle
  #
  # Outputs a jQuery toggle event
  #
  # @private
  # @param  [String]  - element
  # @return	[String]
  #
  _toggle : ($element = 'this') ->
    $element = @_prep_element($element)
    $str = "$({$element}).toggle();"
    return $str
    
  
  #
  # Toggle Class
  #
  # Outputs a jQuery toggle class event
  #
  # @private
  # @param  [String]  - element
  # @return	[String]
  #
  _toggleClass : ($element = 'this', $class = '') ->
    $element = @_prep_element($element)
    $str = "$({$element}).toggleClass(\"$class\");"
    return $str
    
  
  #
  # Show
  #
  # Outputs a jQuery show event
  #
  # @private
  # @param  [String]  - element
  # @param  [String]  - One of 'slow', 'normal', 'fast', or time in milliseconds
  # @param  [String]  - Javascript callback function
  # @return	[String]
  #
  _show : ($element = 'this', $speed = '', $next = '') ->
    $element = @_prep_element($element)
    $speed = @_validate_speed($speed)
    
    if $next isnt ''
      $next = ", function(){\n{$next}\n}"
      
    
    $str = "$({$element}).show({$speed}{$next});"
    
    return $str
    
  
  #
  # Updater
  #
  # An Ajax call that populates the designated DOM node with
  # returned content
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  the controller to run the call against
  # @param  [String]  optional parameters
  # @return	[String]
  #
  
  _updater : ($container = 'this', $controller, $options = '') ->
    $container = @_prep_element($container)
    
    $controller = if (strpos('://', $controller) is false) then $controller else @config.siteUrl($controller)
    
    #  ajaxStart and ajaxStop are better choices here... but this is a stop gap
    if @config.item('javascript_ajax_img') is ''
      $loading_notifier = "Loading..."
      
    else 
      $loading_notifier = '<img src=\'' + @config.slashItem('base_url') + @config.item('javascript_ajax_img') + '\' alt=\'Loading\' />'
      
    
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
  #
  # Zebra tables
  #
  # @private
  # @param  [String]  table name
  # @param  [String]  plugin location
  # @return	[String]
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
  #
  # Corner Plugin
  #
  # http://www.malsup.com/jquery/corner/
  #
    # @param  [String]  target
  # @return	[String]
  #
  corner : ($element = '', $corner_style = '') ->
    #  may want to make this configurable down the road
    $corner_location = '/plugins/jquery.corner.js'
    
    if $corner_style isnt ''
      $corner_style = '"' + $corner_style + '"'
      
    
    return "$(" + @_prep_element($element) + ").corner(" + $corner_style + ");"
    
  
  #
  # modal window
  #
  # Load a thickbox modal window
  #
    # @return [Void]  #
  modal : ($src, $relative = false) ->
    @jquery_code_for_load.push @external($src, $relative)
    
  
  #
  # Effect
  #
  # Load an Effect library
  #
    # @return [Void]  #
  effect : ($src, $relative = false) ->
    @jquery_code_for_load.push @external($src, $relative)
    
  
  #
  # Plugin
  #
  # Load a plugin library
  #
    # @return [Void]  #
  plugin : ($src, $relative = false) ->
    @jquery_code_for_load.push @external($src, $relative)
    
  
  #
  # UI
  #
  # Load a user interface library
  #
    # @return [Void]  #
  ui : ($src, $relative = false) ->
    @jquery_code_for_load.push @external($src, $relative)
    
  #
  # Sortable
  #
  # Creates a jQuery sortable
  #
    # @return [Void]  #
  sortable : ($element, $options = {}) ->
    
    if count($options) > 0
      $sort_options = {}
      for $k, $v of $options
        $sort_options.push "\n\t\t" + $k + ': ' + $v + ""
        
      $sort_options = implode(",", $sort_options)
      
    else 
      $sort_options = ''
      
    
    return "$(" + @_prep_element($element) + ").sortable({" + $sort_options + "\n\t});"
    
  
  #
  # Table Sorter Plugin
  #
    # @param  [String]  table name
  # @param  [String]  plugin location
  # @return	[String]
  #
  tablesorter : ($table = '', $options = '') ->
    @jquery_code_for_compile.push "\t$(" + @_prep_element($table) + ").tablesorter($options);\n"
    
  
  #  --------------------------------------------------------------------
  #  Class functions
  #
  # Add Event
  #
  # Constructs the syntax for an event, and adds to into the array for compilation
  #
  # @private
  # @param  [String]  The element to attach the event to
  # @param  [String]  The code to execute
  # @param  [String]  The event to pass
  # @return	[String]
  #
  _add_event : ($element, $js, $event) ->
    if is_array($js)
      $js = implode("\n\t\t", $js)
      
      
    
    $event = "\n\t$(" + @_prep_element($element) + ").{$event}(function(){\n\t\t{$js}\n\t});\n"
    @jquery_code_for_compile.push $event
    return $event
    
  
  #
  # Compile
  #
  # As events are specified, they are stored in an array
  # This funciton compiles them all for output on a page
  #
  # @private
  # @return	[String]
  #
  _compile : ($view_var = 'script_foot', $script_tags = true) ->
    #  External references
    $external_scripts = implode('', @jquery_code_for_load)
    @load.vars('library_src':$external_scripts)
    
    if count(@jquery_code_for_compile) is 0
      #  no inline references, let's just return
      return 
      
    
    #  Inline references
    $script = '$(document).ready(function() {' + "\n"
    $script+=implode('', @jquery_code_for_compile)
    $script+='});'
    
    $output = if ($script_tags is false) then $script else @inline($script)
    
    @load.vars($view_var:$output)
    
    
  
  #
  # Clear Compile
  #
  # Clears the array of script events collected for output
  #
    # @return [Void]  #
  _clear_compile :  ->
    @jquery_code_for_compile = {}
    
  
  #
  # Document Ready
  #
  # A wrapper for writing document.ready()
  #
  # @private
  # @return	[String]
  #
  _document_ready : ($js) ->
    if not is_array($js)
      $js = [$js]
      
      
    
    for $script in $js
      @jquery_code_for_compile.push $script
      
    
  
  #
  # Script Tag
  #
  # Outputs the script tag that loads the jquery.js file into an HTML document
  #
    # @param  [String]    # @return	[String]
  #
  script : ($library_src = '', $relative = false) ->
    $library_src = @external($library_src, $relative)
    @jquery_code_for_load.push $library_src
    return $library_src
    
  
  #
  # Prep Element
  #
  # Puts HTML element in quotes for use in jQuery code
  # unless the supplied element is the Javascript 'this'
  # object, in which case no quotes are added
  #
    # @param  [String]    # @return	[String]
  #
  _prep_element : ($element) ->
    if $element isnt 'this'
      $element = '"' + $element + '"'
      
    
    return $element
    
  
  #
  # Validate Speed
  #
  # Ensures the speed parameter is valid for jQuery
  #
  # @private
  # @param  [String]    # @return	[String]
  #
  _validate_speed : ($speed) ->
    if in_array($speed, ['slow', 'normal', 'fast'])
      $speed = '"' + $speed + '"'
      
    else if preg_match("/[^0-9]/", $speed)
      $speed = ''
      
    
    return $speed
    
  
  

register_class 'ExspressoJquery', ExspressoJquery
module.exports = ExspressoJquery

#  End of file Jquery.php 
#  Location: ./system/lib/Jquery.php