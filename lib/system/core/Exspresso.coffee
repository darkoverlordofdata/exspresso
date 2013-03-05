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

#
#   E x s p r e s s o
#
define 'Exspresso', module.exports

#   Exspresso Version
#
define 'EXSPRESSO_VERSION', require(FCPATH + 'package.json').version

#   Get the 1st command line arg
#     if it's not an option, then it's the driver name
#
$driver = ucfirst(if ~($argv[2] ? '').indexOf('-') then 'connect' else $argv[2] ? 'connect')

#
#  Load the core functions
#
require BASEPATH + 'core/Common'+EXT

#
# Load the framework constants
if defined('ENVIRONMENT') and file_exists(APPPATH+'config/'+ENVIRONMENT+'/constants.coffee')
  require APPPATH+'config/'+ENVIRONMENT+'/constants.coffee'
else
  require APPPATH+'config/constants.coffee'

log_message "debug", "Exspresso Server Boot"

#   Async queue
#
_queue = []
exports.queue = ($fn) ->
  if $fn then _queue.push($fn) else _queue

#
# Start the benchmark timer
exports.bench = core('Benchmark')
core('Benchmark').mark 'total_execution_time_start'
core('Benchmark').mark 'loading_time:_base_classes_start'

#
# Instantiate the hooks class
exports.hooks = core('Hooks')

# Is there a "pre_system" hook?
core('Hooks').callHook 'pre_system'

#
# Instantiate the config class
exports.config = core('Config')

#
# Instantiate the core server app
exports.server = core(class: 'Server', subclass: $driver)

#
# Instantiate the routing class and set the routing
exports.router = core('Router')

#
# Instantiate the loader class
exports.load = core('Loader', Exspresso)

#
# Load the base controller class
require BASEPATH+'core/Controller.coffee'

if file_exists(APPPATH + 'core/' + core('Config').config['subclass_prefix'] + 'Controller' + EXT)
  require APPPATH + 'core/' + core('Config').config['subclass_prefix'] + 'Controller' + EXT


#
# Bind each route to a contoller
#
#   Invoke the controller when the request is received
#
#   @param string route
#   @param string uti
#   @return void
#
#
for $path, $uri of core('Router').loadRoutes()

  do ($path, $uri) ->

    core('Router').setRouting($uri)

    # Note: The Router class automatically validates the controller path using the router->_validate_request().
    # If this include fails it means that the default controller in the Routes.php file is not resolving to something valid.
    if not file_exists(APPPATH+'controllers/'+core('Router').getDirectory()+core('Router').getClass()+EXT)

      log_message "debug", 'Unable to load controller for %s', $uri
      log_message "debug", 'Please make sure the controller specified in your Routes.coffee file is valid.'
      return

    #
    #  Security check
    #
    #  None of the functions in the $app controller or the
    #  loader class can be called via the URI, nor can
    #  controller functions that begin with an underscore
    #
    $module = core('Router').getModule()
    $class  = core('Router').getClass()
    $method = core('Router').getMethod()

    if $method[0] is '_' or system.core.Controller::[$method]?
      log_message "debug", "Controller not found: %s/%s", $class, $method
      return

    #
    #  Load the local application controller
    #
    $klass = require(APPPATH+'controllers/'+core('Router').getDirectory()+core('Router').getClass()+EXT)

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
    core('Router').routes[$path] = ($req, $res, $next, $args...) =>


      # Bootstrap a controller. Load the core classes first.
      # If we find cached output, just display that and bail.
      # Pass the core objects to the controller constructor.
      # Invoke the controller method.
      try

        #
        #  Start the benchmark timer
        $bench = new_core('Benchmark')
        $bench.mark 'total_execution_time_start'
        $bench.mark 'loading_time:_base_classes_start'

        #
        #  Instantiate the hooks class
        $hooks = new_core('Hooks')

        #
        #  Is there a "pre_system" hook?
        $hooks.callHook('pre_system')

        #
        #  Instantiate the config class
        $config = new_core('Config')

        #
        #  Instantiate the UTF-8 class
        $utf = new_core('Utf8', $config)

        #
        #  Instantiate the URI class
        $uri = new_core('URI', $req)

        #
        #  Instantiate the output class
        $output = new_core('Output', $req, $res, $hooks, $bench, $config, $uri)

        #
        #	Is there a valid cache file?  If so, we're done...
        if $hooks.callHook('cache_override') is false
          if $output.displayCache() is true
            return

        #
        # Load the security class for xss and csrf support
        $security = new_core('Security', $req, $res)

        #
        #  Load the Input class and sanitize globals
        $input = new_core('Input', $req, $utf, $security)

        #
        #  Load the Localization class
        $i18n = new_core('I18n', $config)

        #  Set a mark point for benchmarking
        $bench.mark('loading_time:_base_classes_end')

        #  Is there a "pre_controller" hook?
        $hooks.callHook 'pre_controller'

        #
        #  Instantiate the requested controller
        #
        # Mark a start point so we can benchmark the controller
        $bench.mark('controller_execution_time_( ' + $class + ' / ' + $method + ' )_start')

        $controller = new $klass(core('Server'), $bench, $hooks, $config, $uri, $output, $security, $input, $i18n, $req, $res, $module, $class, $method)

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
          $bench.mark('controller_execution_time_( ' + $class + ' / ' + $method + ' )_end')

          #
          #  Is there a "post_controller" hook?
          $hooks.callHook('post_controller')

          #
          #  Send the final rendered output to the browser
          if $hooks.callHook('display_override') is false
            $output.display($controller)


          #
          #  Is there a "post_system" hook?
          $hooks.callHook('post_system')

          #
          #  Close the DB connection if one exists
          if system.db.DbDriver? and $controller.db?
            $controller.db.close()

        catch $err
          return $next($err)

      #
      #  Run items in the post constructor queue
      $bench.mark 'post_controller_que_start'
      $controller.run ($err) ->
        return $next($err) if $err
        try

          #  Call the requested method.
          #  Any URI segments present (besides the class/function) will be passed to the method for convenience
          $bench.mark 'post_controller_que_end'
          $controller[$method].apply($controller, $args)

        catch $err
          $next $err



#
# ------------------------------------------------------
#  Start me up...
# ------------------------------------------------------
#
core('Server').start core('Router')

# End of file Exspresso.coffee
# Location: ./system/core/Exspresso.coffee