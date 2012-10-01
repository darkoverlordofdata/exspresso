#+--------------------------------------------------------------------+
#  Router.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
# 
#  This file is a part of Expresso
# 
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the GNU General Public License Version 3
# 
#+--------------------------------------------------------------------+
#
# Router Component
#
# Parses URIs and determines routing
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{array_merge, dirname, file_exists, is_dir, ltrim, realpath, rtrim, strrchr, trim, ucfirst} = require(FCPATH + 'helper')
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message} = require(BASEPATH + 'core/Common')
{load_object} = require(BASEPATH + 'core/Common')

express         = require('express')                    # Web development framework 3.0
dispatch        = require('dispatch')                   # URL dispatcher for Connect
app             = require(BASEPATH + 'core/Exspresso')  # Exspresso application module
middleware      = require(BASEPATH + 'core/Middleware') # Exspresso Middleware module



_config                 = null
_routes                 = {}
_handler                = {}
_default_controller     = false
_404_override           = false

_config = load_class('Config', 'core')
log_message 'debug', "Router Component Initialized"

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

  # Load the routes.coffee file.
  _routes = {}
  $found = false
  $check_files = ['routes', ENVIRONMENT + '/routes']
  for $file in $check_files

    $file_path = APPPATH + 'config/' + $file + EXT

    if file_exists($file_path)
      _routes = array_merge(_routes, require($file_path))
      $found = true

  if not $found
    console.log 'The config/routes file does not exist.'
    process.exit 1

  # Set the default controller so we can display it in the event
  # the URI doesn't correlated to a valid controller.
  _default_controller = _routes['default_controller'] ? false
  _404_override = _routes['404_override'] ? false

  # Parse any custom routing that may exist
  _parse_routes()
  app.use dispatch(_handler)

  # 
  # ------------------------------------------------------
  #  Error handlers
  # ------------------------------------------------------
  #

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
#  Parse Routes
#
# This matches any routes that may exist in
# the config/routes.php file against the URI to
# determine if the class/method need to be remapped.
#
# @access	private
# @return	void
#
_parse_routes = ->

  #
  # ------------------------------------------------------
  #  Collect each route mapping
  # ------------------------------------------------------
  #
  #   Make it consumable by the dispatch middleware
  #
  _handler = {} # dispatch urls
  for url, uri of _routes
    if url is '404_override' then continue
    if url is 'default_controller' then url = '/'

    $RTR = new CI_Router(uri)
    $RTR._set_routing()

    # Load the local application controller
    # Note: The Router class automatically validates the controller path using the router->_validate_request().
    # If this include fails it means that the default controller in the Routes.php file is not resolving to something valid.
    if not file_exists(APPPATH+'controllers/'+$RTR.fetch_directory()+$RTR.fetch_class()+EXT)

      console.log 'Unable to load controller for ' + url
      console.log 'Please make sure the controller specified in your Routes.php file is valid.'
      continue

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
      continue


    #
    # ------------------------------------------------------
    #  Instantiate the requested controller
    # ------------------------------------------------------
    #
    $class = require APPPATH+'controllers/'+$RTR.fetch_directory()+$RTR.fetch_class()+EXT

    #
    # ------------------------------------------------------
    #  Wrap the call to the requested method
    # ------------------------------------------------------
    #
    #   The call is deferred until the url is recieved
    #   from the browser. Wrapping it in a closure protects
    #   the value of $function. Otherwise, all urls will map
    #   to the last uri in routes.
    #
    do ($class, $method) =>

      #
      # Anonymous function
      #
      #   Recieves a call from the dispatch middleware
      #
      #   @param {Object} the server request object
      #   @param {Object} the server response object
      #   @param {Function} the next middleware on the stack
      #   @param {Array} the remaining arguments
      #
      _handler[url] = (req, res, next, args...) ->

        $CI = new $class()
        #
        # Patch the object
        #
        $CI.req       = req # request object
        $CI.res       = res # response object
        $CI.render    = res.render  # shortcut
        #
        # Call the requested method.
        # Any URI segments present (besides the class/function) will be passed to the method for convenience
        #
        $CI[$method].apply $CI, args
        return

  return

#
# Route Class
#
# Takes a routing destination, and returns:
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
    
    if _default_controller is false
      show_error "Unable to determine what should be displayed. A default route has not been specified in the routing file."

    # Is the method being specified?
    if _default_controller.indexOf('/') isnt -1

      $x = _default_controller.split('/')
      @set_class $x[0]
      @set_method $x[1]
      @_set_request $x
      
    else
      
      @set_class _default_controller
      @set_method 'index'
      @_set_request [_default_controller, 'index']

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
        if _default_controller.indexOf('/') isnt -1

          $x = _default_controller.split('/')

          @set_class $x[0]
          @set_method $x[1]

        else

          @set_class _default_controller
          @set_method 'index'

        # Does the default controller exist in the sub-folder?
        if not file_exists(APPPATH + 'controllers/' + @fetch_directory() + _default_controller + EXT)
          @directory = ''
          return []

      return $segments

    # If we've gotten this far it means that the URI does not correlate to a valid
    # controller class.  We will now see if there is an override
    if _404_override isnt false

      $x = _404_override.split('/')

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

  # --------------------------------------------------------------------

  #
  #  Set the controller overrides
  #
  # @access	public
  # @param	array
  # @return	null
  #
  _set_overrides: ($routing)->

    if not $routing?
      return

    if $routing['directory']?
      @set_directory $routing['directory']

    if $routing['controller']? and $routing['controller'] isnt ''
      @set_class $routing['controller']

    if $routing['function']?

      $routing['function'] = $routing['function']  ? 'index'
      @set_method $routing['function']

# END CI_Router class


# End of file Router.coffee
# Location: ./Router.coffee