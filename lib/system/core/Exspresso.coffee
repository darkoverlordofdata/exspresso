#+--------------------------------------------------------------------+
#  Exspresso.coffee
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
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
#
#	the server level Exspresso controller
#
#
#
define 'Exspresso', module.exports

#   Exspresso Version
#
define 'EXSPRESSO_VERSION', require(FCPATH + 'package.json').version

#   Get the 1st command line arg
#     if it's not an option, then it's the driver name
#
$driver = ucfirst(if ~($argv[2] ? '').indexOf('-') then 'connect' else $argv[2] ? 'connect')

#   Async queue
#
_queue = []
exports.queue = ($fn) ->
  if $fn then _queue.push($fn) else _queue



#
# ------------------------------------------------------
#  Load the core functions
# ------------------------------------------------------
#
require BASEPATH + 'core/Common'+EXT

#
# ------------------------------------------------------
#  Load the framework constants
# ------------------------------------------------------
#
if defined('ENVIRONMENT') and file_exists(APPPATH+'config/'+ENVIRONMENT+'/constants.coffee')
  require APPPATH+'config/'+ENVIRONMENT+'/constants.coffee'
else
  require APPPATH+'config/constants.coffee'

log_message "debug", "Exspresso v%s copyright 2012 Dark Overlord of Data", EXSPRESSO_VERSION

#
# ------------------------------------------------------
#  Start the timer... tick tock tick tock...
# ------------------------------------------------------
#
$BM = exports.BM = load_new('Benchmark', 'core')
$BM.mark 'total_execution_time_start'
$BM.mark 'loading_time:_base_classes_start'

#
# ------------------------------------------------------
#  Instantiate the hooks class
# ------------------------------------------------------
#
$EXT = exports.hooks = load_class('Hooks', 'core')

#
# ------------------------------------------------------
#  Is there a "pre_system" hook?
# ------------------------------------------------------
#
$EXT.callHook 'pre_system'

#------------------------------------------------------
# Instantiate the config class
#------------------------------------------------------
#
$CFG = exports.config = load_class('Config', 'core')

#
# ------------------------------------------------------
#  Load the Language class
# ------------------------------------------------------
#
$LANG = exports.lang = load_class('Lang', 'core', $CFG)

#
# ------------------------------------------------------
#  Instantiate the core server app
# ------------------------------------------------------
#

$SRV = exports.server = load_class('Server', 'core', $driver)
#
# ------------------------------------------------------
#  Instantiate the routing class and set the routing
# ------------------------------------------------------
#
$RTR = exports.router = load_class('Router', 'core')

#
# ------------------------------------------------------
#  Instantiate the loader class
# ------------------------------------------------------
#
exports.load = load_class('Loader', 'core', Exspresso)

#
# ------------------------------------------------------
#  Load the app controller and local controllers
# ------------------------------------------------------
#
#
# Load the base controller class
require BASEPATH+'core/Controller.coffee'

if file_exists(APPPATH + 'core/' + $CFG.config['subclass_prefix'] + 'Controller' + EXT)
  requireAPPPATH + 'core/' + $CFG.config['subclass_prefix'] + 'Controller' + EXT


#
# ------------------------------------------------------
# Bind each route to a contoller
# ------------------------------------------------------
#
#   Invoke the controller when the request is received
#
#   @param string route
#   @param string uti
#   @return void
#
bind_route = ($path, $uri) ->

  $RTR.setRouting($uri)

  # Note: The Router class automatically validates the controller path using the router->_validate_request().
  # If this include fails it means that the default controller in the Routes.php file is not resolving to something valid.
  if not file_exists(APPPATH+'controllers/'+$RTR.getDirectory()+$RTR.getClass()+EXT)

    log_message "debug", 'Unable to load controller for %s', $uri
    log_message "debug", 'Please make sure the controller specified in your Routes.coffee file is valid.'
    return

  #
  # ------------------------------------------------------
  #  Security check
  # ------------------------------------------------------
  #
  #  None of the functions in the $app controller or the
  #  loader class can be called via the URI, nor can
  #  controller functions that begin with an underscore
  #
  $module = $RTR.getModule()
  $class  = $RTR.getClass()
  $method = $RTR.getMethod()

  if $method[0] is '_' or system.core.Controller::[$method]?
    log_message "debug", "Controller not found: %s/%s", $class, $method
    return

  #
  # ------------------------------------------------------
  #  Load the local application controller
  # ------------------------------------------------------
  #
  $Class = require(APPPATH+'controllers/'+$RTR.getDirectory()+$RTR.getClass()+EXT)

  #
  # Close over a bootstrap for the page and invoke the contoller method
  #
  #   Instantiates the controller and calls the requested method.
  #   Any URI segments present (besides the class/function) will be passed
  #   to the method for convenience
  #
  #   @param object   the server request object
  #   @param object   the server response object
  #   @param function the next middleware on the stack
  #   @param array    the remaining uri arguments
  #   @return void
  #
  $RTR.routes[$path] = ($req, $res, $next, $args...) =>


    # Bootstrap a controller. Load the core classes first.
    # If we find cached output, just display that and bail.
    # Pass the core objects to the controller constructor.
    # Invoke the controller method.
    try

    #
    # ------------------------------------------------------
    #  Start the timer... tick tock tick tock...
    # ------------------------------------------------------
    #
      $BM = load_new('Benchmark', 'core')
      $BM.mark 'total_execution_time_start'
      $BM.mark 'loading_time:_base_classes_start'

      #
      # ------------------------------------------------------
      #  Instantiate the hooks class
      # ------------------------------------------------------
      #
      $EXT = load_new('Hooks', 'core')

      #
      # ------------------------------------------------------
      #  Is there a "pre_system" hook?
      # ------------------------------------------------------
      #
      $EXT.callHook('pre_system')

      #
      # ------------------------------------------------------
      #  Instantiate the config class
      # ------------------------------------------------------
      #
      $CFG = load_new('Config', 'core')

      #
      # ------------------------------------------------------
      #  Instantiate the UTF-8 class
      # ------------------------------------------------------
      #
      # Note: Order here is rather important as the UTF-8
      # class needs to be used very early on, but it cannot
      # properly determine if UTf-8 can be supported until
      # after the Config class is instantiated.
      #
      #
      $UNI = load_new('Utf8', 'core', $CFG)

      #
      # ------------------------------------------------------
      #  Instantiate the URI class
      # ------------------------------------------------------
      #
      $URI = load_new('URI', 'core', $req)

      #
      # ------------------------------------------------------
      #  Instantiate the output class
      # ------------------------------------------------------
      #
      $OUT = load_new('Output', 'core', $req, $res, $EXT, $BM, $CFG, $URI)

      #
      # ------------------------------------------------------
      #	Is there a valid cache file?  If so, we're done...
      # ------------------------------------------------------
      #
      if $EXT.callHook('cache_override') is false
        if $OUT.displayCache($CFG, $URI) is true
          return

      #
      # -----------------------------------------------------
      # Load the security class for xss and csrf support
      # -----------------------------------------------------
      #
      $SEC = load_new('Security','core', $req.cookies, $req.query, $req.body, $req.server)

      #
      # ------------------------------------------------------
      #  Load the Input class and sanitize globals
      # ------------------------------------------------------
      #
      $IN = load_new('Input', 'core', $UNI, $SEC, $req.cookies, $req.query, $req.body, $req.server)

      #
      # ------------------------------------------------------
      #  Load the Language class
      # ------------------------------------------------------
      #
      $LANG = load_new('Lang', 'core', $CFG)

      #  Set a mark point for benchmarking
      $BM.mark('loading_time:_base_classes_end')


      # ------------------------------------------------------
      #  Is there a "pre_controller" hook?
      # ------------------------------------------------------
      #
      $EXT.callHook 'pre_controller'

      #
      # ------------------------------------------------------
      #  Instantiate the requested controller
      # ------------------------------------------------------
      #
      # Mark a start point so we can benchmark the controller
      $BM.mark('controller_execution_time_( ' + $class + ' / ' + $method + ' )_start')

      $controller = new $Class($SRV, $BM, $EXT, $CFG, $UNI, $URI, $RTR, $OUT, $SEC, $IN, $LANG, $req, $res, $module, $class, $method)
      #
      # ------------------------------------------------------
      #  Is there a "post_controller_constructor" hook?
      # ------------------------------------------------------
      #
      $EXT.callHook 'post_controller_constructor', $controller

    catch $err
      return $next($err)

    #
    # Next ->
    #
    # This function is called by the controller when done.
    # Send output to the browser and release resources.
    #
    $controller.next = ($err) ->

      try
        return $next($err) if $err
        #  Mark a benchmark end point
        $BM.mark('controller_execution_time_( ' + $class + ' / ' + $method + ' )_end')

        #
        # ------------------------------------------------------
        #  Is there a "post_controller" hook?
        # ------------------------------------------------------
        #
        $EXT.callHook('post_controller')

        #
        # ------------------------------------------------------
        #  Send the final rendered output to the browser
        # ------------------------------------------------------
        #
        if $EXT.callHook('display_override') is false
          $OUT.display($controller)


        #
        # ------------------------------------------------------
        #  Is there a "post_system" hook?
        # ------------------------------------------------------
        #
        $EXT.callHook('post_system')

        #
        # ------------------------------------------------------
        #  Close the DB connection if one exists
        # ------------------------------------------------------
        #
        if class_exists('CI_DB') and $controller.db?
          $controller.db.close()

      catch $err
        return $next($err)

    #
    # ------------------------------------------------------
    #  Run items in the post constructor queue
    # ------------------------------------------------------
    #
    $BM.mark 'post_controller_que_start'
    $controller.run ($err) ->
      return $next($err) if $err
      try

        #  Call the requested method.
        #  Any URI segments present (besides the class/function) will be passed to the method for convenience
        $BM.mark 'post_controller_que_end'
        $controller[$method].apply($controller, $args)

      catch $err
        $next $err



#
# ------------------------------------------------------
#  Start me up...
# ------------------------------------------------------
#
for $path, $uri of $RTR.loadRoutes()
  bind_route $path, $uri

$SRV.start $RTR

# End of file Exspresso.coffee
# Location: ./system/core/Exspresso.coffee