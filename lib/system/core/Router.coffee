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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author		  darkoverlordofdata
# @copyright	Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright	Copyright (c) 2011 Wiredesignz
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see 		    http://darkoverlordofdata.com
# @since		  Version 1.0
#

#
# Exspresso Router Class
#

class system.core.Router

  fs = require('fs')
  Modules = require(SYSPATH+'core/Modules.coffee')
  URI = require(SYSPATH+'core/URI.coffee')

  #
  # @property [Object] Hash of bindings for each route
  #
  routes                  : null        # route dispatch bindings

  _default_controller     : false       # matches route '/'
  _not_found              : false       # when the specified controller is not found
  _directory              : ''          # parsed directory
  _module                 : ''          # parsed module
  _class                  : ''          # parsed class
  _method                 : ''          # parsed method

  #
  # Initialize the router hash
  #
  constructor: ($controller) ->

    @config = $controller.config
    @routes = {}
    log_message('debug', "Router Class Initialized")


  #
  # Set the route mapping
  #
  # This function determines what should be served based on the URI request,
  # as well as any "routes" that have been set in the routing config file.
  #
  # @param [String] uri the uri to parse
  # @return [Void]
  #
  setRouting: ($uri) ->

    @_not_found = false
    @_directory = ''
    @_module = ''
    @_class = ''
    @_method = ''
    @_set_request $uri.split('/')
    not @_not_found


  #
  # Set the default controller
  #
  # @private
  # @return [Void]
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
  # @private
  # @param  [Array]
  # @return	[Boolean]
  # @return [Void]
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
  # @private
  # @param  [Array]
  # @return	array
  #
  _validate_request: ($segments) ->

    return $segments if $segments.length is 0

    # locate module controller
    #if ($located = @locate($segments)) then return $located
    $located = @locate($segments)
    if ($located) then return $located

    # no controller found
    @_not_found = true
    log_message 'error', "Unable to validate uri %j", $segments
    return false


  #
  # Validates the supplied segments.  Attempts to determine the path to
  # the controller.
  #
  # @private
  # @param  [Array]
  # @return	array
  #
  _application_validate_request: ($segments) ->

    if $segments.length is 0
      return $segments


    # Does the requested controller exist in the root folder?
    if fs.existsSync(APPPATH + 'controllers/' + $segments[0] + EXT)
      return $segments


    # Is the controller in a sub-folder?
    if is_dir(APPPATH + 'controllers/' + $segments[0])

      # Set the directory and remove it from the segment array
      @setDirectory $segments[0]
      $segments = $segments.shift()

      if $segments.length > 0

        # Does the requested controller exist in the sub-folder?
        if not fs.existsSync(APPPATH + 'controllers/' + @getDirectory() + $segments[0] + EXT)
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
        if not fs.existsSync(APPPATH + 'controllers/' + @getDirectory() + @_default_controller + EXT)
          @_directory = ''
          return []

      return $segments

    @_not_found = true
    log_message 'error', "Unable to validate uri %j", $segments
    return []

  #
  #  Load Routes
  #
  # This function loads routes that may exist in
  # the module/config/routes.php file
  #
  # @return [Object] a hash of all the allowed routing
  #
  loadRoutes: ->

    $routes = @_application_load_routes()

    for $location, $offset of Modules::locations
      $modules = fs.readdirSync($location)
      for $module in $modules
        $path = $location + $module + '/config/'

        if fs.existsSync($path+'routes.coffee')
          for $key, $val of Modules::load('routes', $path)
            $routes[$key] = $val

    return $routes

  #
  #  Load Routes
  #
  # This function loads routes that may exist in
  # the config/routes.php file
  #
  # @private
  # @return [Object]  routes
  #
  _application_load_routes: ->

    if not @config.load('routes', true, true)
      show_error 'The config/routes file does not exist.'

    $routes = @config.config.routes

    # Set the default controller so we can display it in the event
    # the URI doesn't correlated to a valid controller.
    @_default_controller = $routes['default_controller'] ? false

    delete $routes['default_controller']
    $routes['/'] = @_default_controller
    $routes

  #
  # Locate the controller
  #
  # @param  [Array] segments  array of uri segments
  # @return [Array] uri segments that specify the controller
  #
  locate: ($segments) ->

    @_module = ''
    @_directory = ''
    $ext = @config.item('controller_suffix')+EXT

    # get the segments array elements
    if $segments.length < 3
      $segments = $segments.concat([null, null, null].slice(0, 3-$segments.length))
    [$module, $directory, $controller] = $segments

    # check modules
    for $location, $offset of Modules::locations

      # module exists?
      if (is_dir($source = $location+$module+'/controllers/'))

        return false unless Modules::getModule($module).active

        @_module = $module
        @_directory = $offset+$module+'/controllers/'

        # module sub-controller exists?
        if($directory and is_file($source+$directory+$ext))
          return $segments.slice(1)

        # module sub-directory exists?
        if($directory and is_dir($source+$directory+'/'))

          $source = $source+$directory+'/'
          @_directory += $directory+'/'

          # module sub-directory controller exists?
          if(is_file($source+$directory+$ext))
            return $segments.slice(1)

          # module sub-directory sub-controller exists?
          if($controller and is_file($source+$controller+$ext))
            return $segments.slice(2)

        # module controller exists?
        if(is_file($source+$module+$ext))
          return $segments

    # application controller exists?
    if (is_file(APPPATH+'controllers/'+$module+$ext))
      return $segments

    # application sub-directory controller exists?
    if($directory and is_file(APPPATH+'controllers/'+$module+'/'+$directory+$ext))
      @_directory = $module+'/'
      return $segments.slice(1)

    # application sub-directory default controller exists?
    if (is_file(APPPATH+'controllers/'+$module+'/'+@default_controller+$ext))
      @_directory = $module+'/'
      return array(@default_controller)

  #
  # Set the class name
  #
  # @param  [String]  class the class name
  # @return [Void]
  #
  setClass: ($class) ->
    @_class = $class+@config.item('controller_suffix')


  #
  # Fetch the current class
  #
  # @return	[String] the class name
  #
  getClass: ->
    return @_class


  #
  #  Set the method name
  #
  # @param  [String]  method  the method name
  # @return [Void]
  #
  setMethod: ($method) ->
    @_method = $method


  #
  #  Fetch the current method
  #
  # @return	[String] the method name
  #
  getMethod: ->
    if @_method is @getClass()
      return 'index'

    return @_method || 'index'

  #
  #  Set the directory name
  #
  # @param  [String] dir  the directory name
  # @return [Void]
  #
  setDirectory: ($dir) ->
    @_directory = $dir.replace('/', '').replace('.', '') + '/'


  #
  #  Fetch the sub-directory (if any) that contains the requested controller class
  #
  # @return	[String] the directory
  #
  getDirectory: ->
    return @_directory

  #
  # Fetch the current module
  #
  # @return	[String] the module
  #
  getModule: ->
    @_module


# END Router class

module.exports = system.core.Router

# End of file Router.coffee
# Location: .system/core/Router.coffee