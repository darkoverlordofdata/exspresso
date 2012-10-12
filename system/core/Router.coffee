#+--------------------------------------------------------------------+
#  Router.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
# 
#  This file is a part of Expresso
# 
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
# 
#+--------------------------------------------------------------------+
#
# Router Component
#
# Parses URIs and determines routing
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{array_merge, file_exists, is_dir} = require(FCPATH + 'lib')
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message} = require(BASEPATH + 'core/Common')

dispatch        = require('dispatch')                   # URL dispatcher for Connect
express         = require('express')                    # Web development framework 3.0

app             = require(BASEPATH + 'core/Exspresso')  # Exspresso application module
middleware      = require(BASEPATH + 'core/Middleware') # Exspresso Middleware module



$default_controller     = false     # matches route '/'
$404_override           = false     # when the specified controller is not found

# --------------------------------------------------------------------

#
# Set the route mapping
#
# This determines what should be served based on the URI request,
# as well as any "routes" that have been set in the routing config file.
#
# @access	private
# @return	void
#
exports.set_routing = ->

  app.use dispatch(load_routes())

  # wire up the error handlers
  app.use middleware.error_5xx()
  app.use middleware.error_404()

  if app.get('env') is 'development'
    app.use express.errorHandler
      dumpExceptions: true
      showStack: true

  if app.get('env') is 'production'
    app.use express.errorHandler()

  app.use app.router

# --------------------------------------------------------------------

#
#  Load Routes
#
#   load routes from config/routes
#   bind each route to the associated cntroller/method
#
# @access	private
# @return	object table of route bindings
#
load_routes = () ->

  $config = {}
  $routes = {}
  $found = false

  # Load the routes.coffee file.
  $check_files = ['routes', ENVIRONMENT + '/routes']
  for $file in $check_files

    $file_path = APPPATH + 'config/' + $file + EXT

    if file_exists($file_path)
      $config = array_merge($config, require($file_path))
      $found = true

  if not $found
    #
    # ------------------------------------------------------
    #  No paths have been defined!!!
    # ------------------------------------------------------
    #
    console.log 'The config/routes file does not exist.'
    process.exit 1

  # Set the default controller so we can display it in the event
  # the URI doesn't correlated to a valid controller.
  $default_controller = $config['default_controller'] ? false
  $404_override = $config['404_override'] ? false

  for $path, $uri of $config
    bind_route $path, $uri, $routes

  return $routes

# --------------------------------------------------------------------

#
#  Bind Route
#
#   Finds the controller that maps to the uri
#   and bind it to the path in a callback
#
#
# @access	private
# @return	void
#
bind_route = ($path, $uri, $routes) ->

  if $path is '404_override' then return
  if $path is 'default_controller' then $path = '/'

  $RTR = new CI_Router($uri)
  $RTR._set_routing()

  # Load the local application controller
  # Note: The Router class automatically validates the controller path using the router->_validate_request().
  # If this include fails it means that the default controller in the Routes.php file is not resolving to something valid.
  if not file_exists(APPPATH+'controllers/'+$RTR.fetch_directory()+$RTR.fetch_class()+EXT)

    console.log 'Unable to load controller for ' + $uri
    console.log 'Please make sure the controller specified in your Routes.php file is valid.'
    return

  #
  # ------------------------------------------------------
  #  Security check
  # ------------------------------------------------------
  #
  #  None of the functions in the app controller or the
  #  loader class can be called via the URI, nor can
  #  controller functions that begin with an underscore
  #
  $class  = $RTR.fetch_class()
  $method = $RTR.fetch_method()


  if $method[0] is '_' or Exspresso.CI_Controller.__proto__[$method]?

    console.log "Controller not found: #{$class}/#{$method}"
    return

  #
  # ------------------------------------------------------
  #  Instantiate the requested controller
  # ------------------------------------------------------
  #
  $class = require APPPATH+'controllers/'+$RTR.fetch_directory()+$RTR.fetch_class()+EXT

  $routes[$path] = controller_callback($class, $method)
  return


# --------------------------------------------------------------------

#
# Controller Callback
#
#   Routing call back to invoke the controller when the request is received
#
#   @param object $class
#   @param string method
#   @return void
#
controller_callback = ($class, $method) ->

  # --------------------------------------------------------------------

  #
  # Invoke the contoller
  #
  #   Instantiates the controller and calls the requested method.
  #   Any URI segments present (besides the class/function) will be passed
  #   to the method for convenience
  #
  #   @param {Object} the server request object
  #   @param {Object} the server response object
  #   @param {Function} the next middleware on the stack
  #   @param {Array} the remaining arguments
  #
  return ($req, $res, $next, $args...) ->

    # a new copy of the controller class for each request:
    $CI = new $class()

    # mix-ins:
    $CI.req       = $req # request object
    $CI.res       = $res # response object
    $CI.render    = $res.render  # shortcut

    # was database added by the controller constructor?
    if $CI.db?
      # initialize the database connection
      $CI.db.initialize ->
        # now call the controller method
        $CI[$method].apply $CI, $args
    else
      # just call the controller method
      $CI[$method].apply $CI, $args

    return

# --------------------------------------------------------------------

#
# Map a route:
#
#   route.fetch_directory()
#   route.fetch_class()
#   route.fetch_method()
#
#
class CI_Router

  _path:                  false
  _directory:             ''
  _class:                 ''
  _method:                ''

  constructor: (@_path) ->

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
  _set_routing: ->

    @_set_request @_path.split('/')

  # --------------------------------------------------------------------

  #
  # Set the default controller
  #
  # @access	private
  # @return	void
  #
  _set_default_controller: ->
    
    if $default_controller is false
      show_error "Unable to determine what should be displayed. A default route has not been specified in the routing file."

    # Is the method being specified?
    if $default_controller.indexOf('/') isnt -1

      $x = $default_controller.split('/')
      @set_class $x[0]
      @set_method $x[1]
      @_set_request $x
      
    else
      
      @set_class $default_controller
      @set_method 'index'
      @_set_request [$default_controller, 'index']

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
        if $default_controller.indexOf('/') isnt -1

          $x = $default_controller.split('/')

          @set_class $x[0]
          @set_method $x[1]

        else

          @set_class $default_controller
          @set_method 'index'

        # Does the default controller exist in the sub-folder?
        if not file_exists(APPPATH + 'controllers/' + @fetch_directory() + $default_controller + EXT)
          @directory = ''
          return []

      return $segments

    # If we've gotten this far it means that the URI does not correlate to a valid
    # controller class.  We will now see if there is an override
    if $404_override isnt false

      $x = $404_override.split('/')

      @set_class $x[0]
      @set_method $x[1] ? 'index'

      return $x


    # Nothing else to do at this point but show a 404
    console.log "Unable to validate" + $segments[0]
    return []

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

    return @_method

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


# END CI_Router class


# End of file Router.coffee
# Location: ./Router.coffee