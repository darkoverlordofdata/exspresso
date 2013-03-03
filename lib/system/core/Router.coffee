#+--------------------------------------------------------------------+
#  Router.coffee
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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package		Exspresso
# @author		  darkoverlordofdata
# @copyright	Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright	Copyright (c) 2011 Wiredesignz
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		MIT License
# @link		    http://darkoverlordofdata.com
# @since		  Version 1.0
#
#  ------------------------------------------------------------------------
#
# Exspresso Router Class
#
require BASEPATH+'core/Modules.coffee'
require BASEPATH+'core/URI.coffee'

class global.ExspressoRouter

  fs = require('fs')

  routes                  : null        # route dispatch bindings

  _default_controller     : false       # matches route '/'
  _404_override           : false       # when the specified controller is not found
  _directory              : ''          # parsed directory
  _module                 : ''          # parsed module
  _class                  : ''          # parsed class
  _method                 : ''          # parsed method

  constructor: ->

    @config = Exspresso.config
    @routes = {}
    log_message('debug', "Router Class Initialized")


  #
  # Set the route mapping
  #
  # This function determines what should be served based on the URI request,
  # as well as any "routes" that have been set in the routing config file.
  #
  # @access	private
  # @return	void
  #
  setRouting: ($uri) ->

    @_directory = ''
    @_module = ''
    @_class = ''
    @_method = ''
    @_set_request $uri.split('/')


  #
  # Set the default controller
  #
  # @access	private
  # @return	void
  #
  _set_default_controller: ->

    if @_default_controller is false
      show_error "Unable to determine what should be displayed. A default route has not been specified in the routing file."

    # Is the method being specified?
    if @_default_controller.indexOf('/') isnt -1

      $x = @_default_controller.split('/')
      @setClass $x[0]
      @setMethod $x[1]
      @_set_request $x

    else

      @setClass @_default_controller
      @setMethod 'index'
      @_set_request [@_default_controller, 'index']

    log_message 'debug', "No URI present. Default controller set."

  #
  # Set the Route
  #
  # This takes an array of URI segments as
  # input, and sets the current class/method
  #
  # @access	private
  # @param	array
  # @param	bool
  # @return	void
  #
  _set_request: ($segments = []) ->

    $segments = @_validate_request($segments)

    if $segments.length is 0
      return @_set_default_controller()

    @setClass $segments[0]

    if $segments[1]?

      # A standard method request
      @setMethod $segments[1]

    else

      # This lets the "routed" segment array identify that the default
      # index method is being used.
      $segments[1] = 'index'


  #
  # Validates the supplied segments.  Attempts to determine the path to
  # the controller.
  #
  # @access	private
  # @param	array
  # @return	array
  #
  _validate_request: ($segments) ->

    if (count($segments) is 0) then return $segments

    # locate module controller
    #if ($located = @locate($segments)) then return $located
    $located = @locate($segments)
    if ($located) then return $located


    # use a default 404_override controller
    if @_404_override
      $segments = explode('/', @_404_override)
      if ($located = @locate($segments)) then return $located


    # no controller found
    #show_404()
    # Nothing else to do at this point but show a 404
    log_message 'error', "Unable to validate uri %j", $segments
    return []


  #
  # Validates the supplied segments.  Attempts to determine the path to
  # the controller.
  #
  # @access	private
  # @param	array
  # @return	array
  #
  _application_validate_request: ($segments) ->

    if $segments.length is 0
      return $segments


    # Does the requested controller exist in the root folder?
    if file_exists(APPPATH + 'controllers/' + $segments[0] + EXT)
      return $segments


    # Is the controller in a sub-folder?
    if is_dir(APPPATH + 'controllers/' + $segments[0])

      # Set the directory and remove it from the segment array
      @setDirectory $segments[0]
      $segments = $segments.shift()

      if $segments.length > 0

        # Does the requested controller exist in the sub-folder?
        if not file_exists(APPPATH + 'controllers/' + @getDirectory() + $segments[0] + EXT)
          console.log "Unable to validate" + @getDirectory() + $segments[0]
          return []

      else

        # Is the method being specified in the route?
        if @_default_controller.indexOf('/') isnt -1

          $x = @_default_controller.split('/')

          @setClass $x[0]
          @setMethod $x[1]

        else

          @setClass @_default_controller
          @setMethod 'index'

        # Does the default controller exist in the sub-folder?
        if not file_exists(APPPATH + 'controllers/' + @getDirectory() + @_default_controller + EXT)
          @_directory = ''
          return []

      return $segments

    # If we've gotten this far it means that the URI does not correlate to a valid
    # controller class.  We will now see if there is an override
    if @_404_override isnt false

      $x = @_404_override.split('/')

      @setClass $x[0]
      @setMethod $x[1] ? 'index'

      return $x


    # Nothing else to do at this point but show a 404
    log_message 'error', "Unable to validate uri %j", $segments
    return []

  #
  #  Load Routes
  #
  # This function loads routes that may exist in
  # the module/config/routes.php file
  #
  # @access	private
  # @return	object routes
  #
  loadRoutes: ->

    $routes = @_application_load_routes()

    for $location, $offset of Modules.locations
      $modules = fs.readdirSync($location)
      for $module in $modules
        $path = $location + $module + '/config/'

        if file_exists($path+'routes.coffee')
          $routes = array_merge($routes, Modules.loadFile('routes', $path, 'route'))

    return $routes

  #
  #  Load Routes
  #
  # This function loads routes that may exist in
  # the config/routes.php file
  #
  # @access	private
  # @return	object routes
  #
  _application_load_routes: ->

    if not @config.load('routes', true, true)
      show_error 'The config/routes file does not exist.'

    $routes = @config.config.routes

    # Set the default controller so we can display it in the event
    # the URI doesn't correlated to a valid controller.
    @_default_controller = $routes['default_controller'] ? false
    @_404_override = $routes['404_override'] ? false

    delete $routes['default_controller']
    delete $routes['404_override']
    $routes['/'] = @_default_controller
    $routes

  #
  # Locate the controller
  #
  # @access	private
  # @param	array
  # @return	array
  #
  locate: ($segments) ->

    @_module = ''
    @_directory = ''
    $ext = @config.item('controller_suffix')+EXT

    # use module route if available
    #if $segments[0]? and $routes = Modules.parse_routes($segments[0], implode('/', $segments))
    #$segments = $routes

    # get the segments array elements
    [$module, $directory, $controller] = array_pad($segments, 3, null)

    # check modules
    for $location, $offset of Modules.locations

      # module exists?
      if (is_dir($source = $location+$module+'/controllers/'))

        @_module = $module
        @_directory = $offset+$module+'/controllers/'

        # module sub-controller exists?
        if($directory and is_file($source+$directory+$ext))
          return array_slice($segments, 1)

        # module sub-directory exists?
        if($directory and is_dir($source+$directory+'/'))

          $source = $source+$directory+'/'
          @_directory += $directory+'/'

          # module sub-directory controller exists?
          if(is_file($source+$directory+$ext))
            return array_slice($segments, 1)

          # module sub-directory sub-controller exists?
          if($controller and is_file($source+$controller+$ext))
            return array_slice($segments, 2)

        # module controller exists?
        if(is_file($source+$module+$ext))
          return $segments

    # application controller exists?
    if (is_file(APPPATH+'controllers/'+$module+$ext))
      return $segments

    # application sub-directory controller exists?
    if($directory and is_file(APPPATH+'controllers/'+$module+'/'+$directory+$ext))
      @_directory = $module+'/'
      return array_slice($segments, 1)

    # application sub-directory default controller exists?
    if (is_file(APPPATH+'controllers/'+$module+'/'+@default_controller+$ext))
      @_directory = $module+'/'
      return array(@default_controller)

  #
  # Set the class name
  #
  # @access	public
  # @param	string
  # @return	void
  #
  setClass: ($class) ->
    @_class = $class+@config.item('controller_suffix')
  # - pre module - @_class = $class.replace('/', '').replace('.', '')


  #
  # Fetch the current class
  #
  # @access	public
  # @return	string
  #
  getClass: ->
    return @_class


  #
  #  Set the method name
  #
  # @access	public
  # @param	string
  # @return	void
  #
  setMethod: ($method) ->
    @_method = $method


  #
  #  Fetch the current method
  #
  # @access	public
  # @return	string
  #
  getMethod: ->
    if @_method is @getClass()
      return 'index'

    return @_method || 'index'

  #
  #  Set the directory name
  #
  # @access	public
  # @param	string
  # @return	void
  #
  setDirectory: ($dir) ->
    @_directory = $dir.replace('/', '').replace('.', '') + '/'


  #
  #  Fetch the sub-directory (if any) that contains the requested controller class
  #
  # @access	public
  # @return	string
  #
  getDirectory: ->
    return @_directory

  #
  # Fetch the current module
  #
  # @access	public
  # @return	string
  #
  getModule: ->
    @_module


# END ExspressoRouter class

module.exports = ExspressoRouter

# End of file Router.coffee
# Location: ./system/core/Router.coffee