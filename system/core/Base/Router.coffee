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
# @copyright	Copyright (c) 2012, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		MIT License
# @link		    http://darkoverlordofdata.com
# @since		  Version 1.0
#
#  ------------------------------------------------------------------------
#
# Exspresso Router Class
#
require BASEPATH+'core/URI.coffee'

class global.Base_Router

  routes:                 {}          # route dispatch bindings

  _default_controller:    false       # matches route '/'
  _404_override:          false       # when the specified controller is not found
  _directory:             ''          # parsed directory
  _class:                 ''          # parsed class
  _method:                ''          # parsed method

  constructor: ->

    #@config = load_class('Config', 'core')
    @config = Exspresso.config
    log_message('debug', "Router Class Initialized")


  # --------------------------------------------------------------------

  #
  # Set the route mapping
  #
  # This function determines what should be served based on the URI request,
  # as well as any "routes" that have been set in the routing config file.
  #
  # @access	private
  # @return	void
  #
  set_routing: ($uri) ->

    @_directory = ''
    @_class = ''
    @_method = ''
    @_set_request $uri.split('/')

  # --------------------------------------------------------------------

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
      @set_class $x[0]
      @set_method $x[1]
      @_set_request $x
      
    else
      
      @set_class @_default_controller
      @set_method 'index'
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
    
    @set_class $segments[0]
    
    if $segments[1]?

      # A standard method request
      @set_method $segments[1]

    else

      # This lets the "routed" segment array identify that the default
      # index method is being used.
      $segments[1] = 'index'


  # --------------------------------------------------------------------

  #
  # Validates the supplied segments.  Attempts to determine the path to
  # the controller.
  #
  # @access	private
  # @param	array
  # @return	array
  #
  _validate_request: ($segments) ->

    if $segments.length is 0
      return $segments


    # Does the requested controller exist in the root folder?
    if file_exists(APPPATH + 'controllers/' + $segments[0] + EXT)
      return $segments


    # Is the controller in a sub-folder?
    if is_dir(APPPATH + 'controllers/' + $segments[0])

      # Set the directory and remove it from the segment array
      @set_directory $segments[0]
      $segments = $segments.shift()

      if $segments.length > 0

        # Does the requested controller exist in the sub-folder?
        if not file_exists(APPPATH + 'controllers/' + @fetch_directory() + $segments[0] + EXT)
          console.log "Unable to validate" + @fetch_directory() + $segments[0]
          return []

      else

        # Is the method being specified in the route?
        if @_default_controller.indexOf('/') isnt -1

          $x = @_default_controller.split('/')

          @set_class $x[0]
          @set_method $x[1]

        else

          @set_class @_default_controller
          @set_method 'index'

        # Does the default controller exist in the sub-folder?
        if not file_exists(APPPATH + 'controllers/' + @fetch_directory() + @_default_controller + EXT)
          @_directory = ''
          return []

      return $segments

    # If we've gotten this far it means that the URI does not correlate to a valid
    # controller class.  We will now see if there is an override
    if @_404_override isnt false

      $x = @_404_override.split('/')

      @set_class $x[0]
      @set_method $x[1] ? 'index'

      return $x


    # Nothing else to do at this point but show a 404
    log_message 'error', "Unable to validate uri %j", $segments
    return []

  # --------------------------------------------------------------------

  #
  #  Load Routes
  #
  # This function loads routes that may exist in
  # the config/routes.php file
  #
  # @access	private
  # @return	object routes
  #
  load_routes: ->

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


  # --------------------------------------------------------------------

  #
  # Controller binding
  #
  #   Invoke the controller when the request is received
  #
  #   @param string route
  #   @param object $class
  #   @param string method
  #   @return void
  #
  bind: ($route, $class, $method) ->

    #
    # Invoke the contoller method
    #
    #   Instantiates the controller and calls the requested method.
    #   Any URI segments present (besides the class/function) will be passed
    #   to the method for convenience
    #
    #   @param object   the server request object
    #   @param object   the server response object
    #   @param function the next middleware on the stack
    #   @param array    the remaining arguments
    #   @return void
    #
    @routes[$route] = ($req, $res, $next, $args...) =>

      try
        $Exspresso = new $class($req, $res, $next, $class.name, $method)
      catch $err
        return $next($err)

      $Exspresso.run ($err) ->
        return $next($err) if $err
        try
          $Exspresso[$method].apply($Exspresso, $args)
        catch $err
          $next $err

  # --------------------------------------------------------------------

  #
  # Set the class name
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_class: ($class) ->
    @_class = $class.replace('/', '').replace('.', '')
  

  # --------------------------------------------------------------------

  #
  # Fetch the current class
  #
  # @access	public
  # @return	string
  #
  fetch_class: ->
    return @_class
  

  # --------------------------------------------------------------------

  #
  #  Set the method name
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_method: ($method) ->
    @_method = $method


  # --------------------------------------------------------------------

  #
  #  Fetch the current method
  #
  # @access	public
  # @return	string
  #
  fetch_method: ->
    if @_method is @fetch_class()
      return 'index'

    return @_method || 'index'

  # --------------------------------------------------------------------

  #
  #  Set the directory name
  #
  # @access	public
  # @param	string
  # @return	void
  #
  set_directory: ($dir) ->
    @_directory = $dir.replace('/', '').replace('.', '') + '/'

  # --------------------------------------------------------------------

  #
  #  Fetch the sub-directory (if any) that contains the requested controller class
  #
  # @access	public
  # @return	string
  #
  fetch_directory: ->
    return @_directory

  #  --------------------------------------------------------------------

  #
  #  Set the controller overrides
  #
  # @access	public
  # @param	array
  # @return	null
  #
  _set_overrides : ($routing) ->
    if not is_array($routing)
      return


    if $routing['directory']?
      @set_directory($routing['directory'])


    if $routing['controller']?  and $routing['controller'] isnt ''
      @set_class($routing['controller'])


    if $routing['function']?
      $routing['function'] = if ($routing['function'] is '') then 'index' else $routing['function']
      @set_method($routing['function'])

# END Base_Router class

module.exports = Base_Router

# End of file Router.coffee
# Location: ./system/core/Base/Router.coffee