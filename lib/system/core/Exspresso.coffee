#+--------------------------------------------------------------------+
#  exspresso.coffee
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
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#
# e x s p r e s s o<br />
#
#   Top level controller for exspresso
#
class system.core.Exspresso extends system.core.Object

  os = require('os')  # operating-system related utility functions

  #
  # @property [String] http driver: connect | express
  #
  httpDriver: 'connect'
  #
  # @property [String] db driver: mysql | postgres
  #
  dbDriver: 'mysql'
  #
  # @property [Boolean] cache output?
  #
  useCache: false
  #
  # @property [Boolean] scrub inputs?
  #
  useCsrf: false
  #
  # @property [Boolean] preview locally using appjs (must be installed separately)
  #
  preview: false
  #
  # @property [Boolean] enable profiling?
  #
  profile: false
  #
  # @property [String] exspresso version
  #
  version: ''

  #
  #   Exspresso Version
  #     get the current version info from the npm package
  #
  @define version: require(FCPATH + 'package.json').version

  #
  # Parse the command line options.
  #
  # <br />
  #  --cache      enable cacheing <br />
  #  --csrf       enable xss checks <br />
  #  --preview    preview using appjs <br />
  #  --profile    enable profiling <br />
  #  --nocache    disable cacheing <br />
  #  --nocsrf     disable xss checks <br />
  #  --noprofile  disable profiling <br />
  #  --db <mysql|postgres> set database driver <br />
  #
  # @return [Void]
  #
  parseOptions: () ->

    $driver   = @httpDriver
    $db       = @dbDriver
    $cache    = @useCache
    $csrf     = @useCsrf
    $preview  = @preview
    $profile  = @profile

    $profile = if ENVIRONMENT is 'development' then true else false
    $argv.shift() # node
    $argv.shift() # exspresso
    $set_db = false
    for $arg in $argv
      if $set_db is true
        $db = $arg
        $set_db = false
        continue

      switch $arg
        when '--db'         then $set_db    = true
        when '--cache'      then $cache    = true
        when '--csrf'       then $csrf     = true
        when '--preview'    then $preview  = true
        when '--profile'    then $profile  = true
        when '--nocache'    then $cache    = false
        when '--nocsrf'     then $csrf     = false
        when '--noprofile'  then $profile  = false
        else  $driver = $arg

    @define httpDriver  : $driver
    @define dbDriver    : $db
    @define useCache    : $cache
    @define useCsrf     : $csrf
    @define preview     : $preview
    @define profile     : $profile


  #
  #   Boot exspresso
  #
  #
  # @return [Void]
  #
  boot: () ->

    @parseOptions()

    log_message "debug", "Exspresso Server Boot"

    # Start the benchmark timer
    #
    @define bench : core('Benchmark')
    @bench.mark 'boot_time_start'
    #
    # Pre-system hook
    #
    @define hooks : core('Hooks')
    @hooks.callHook 'pre_system'
    #
    # And the rest...
    #
    @define config : core('Config')
    @define server : core(ucfirst(@httpDriver), @)
    @define router : core('Router')
    @define load   : core('Loader', @)

    #
    # Load the base controller class
    require SYSPATH+'core/Controller.coffee'

    if file_exists(APPPATH + 'core/' + @config.config['subclass_prefix'] + 'Controller' + EXT)
      require APPPATH + 'core/' + @config.config['subclass_prefix'] + 'Controller' + EXT

    for $path, $uri of @router.loadRoutes()
      @bind $path, $uri

    #
    # Start the http server
    #
    @server.start @router


  #
  # Ready
  #
  #   http server is now ready
  #
  # @param  [Integer] port  the port number we're running on
  # @return [Void]
  #
  ready: ($port) =>

    @define port: $port

    $elapsed = @bench.elapsedTime('boot_time_start', 'boot_time_end')
    log_message 'debug', 'Boot time: %dms', $elapsed
    log_message "debug", "Listening on port #{$port}"
    log_message "debug", "e x s p r e s s o  v%s", @version
    log_message "debug", "copyright 2012-2013 Dark Overlord of Data"
    log_message "debug", "%s environment started", ucfirst(ENVIRONMENT)
    if ENVIRONMENT is 'development'
      log_message "debug", "View at http://localhost:" + $port


    if @preview
      #
      # preview in appjs
      #
      {exec} = require('child_process')
      exec "node --harmony bin/preview #{$port}", ($err, $stdout, $stderr) ->
        console.log $stderr if $stderr?
        console.log $stdout if $stdout?
        process.exit()

    return

  #
  # Bind each route to a contoller and bootstrap
  #
  #   Dispatch to the controller method when the request is received
  #
  # @param  [String]  route regexp that matches a request url
  # @param  [String]  uri corresponding controller uri specifier
  # @return [Void]
  #
  bind: ($path, $uri) ->

    @router.setRouting($uri)

    if not file_exists(APPPATH+'controllers/'+@router.getDirectory()+@router.getClass()+EXT)

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

    $module = @router.getModule()
    $class  = @router.getClass()
    $method = @router.getMethod()

    if $method[0] is '_' or system.core.Controller::[$method]?
      log_message "debug", "Controller not found: %s/%s", $class, $method
      return

    #
    #  Load the local application controller
    #
    $klass = require(APPPATH+'controllers/'+@router.getDirectory()+@router.getClass()+EXT)

    #
    # Close over a bootstrap for the page and invoke the contoller method
    #
    #   Instantiates the controller and calls the requested method.
    #   Any URI segments present (besides the class/function) will be passed
    #   to the method for convenience
    #
    # @param  [Object]  the server request object
    # @param  [Object]  the server response object
    # @param  [Function] the next middleware on the stack
    # @param  [Array]  the remaining uri arguments
    # @return [Void]
    #
    @router.routes[$path] = ($req, $res, $next, $args...) =>


      # Bootstrap a controller. Load the core classes first.
      # If we find cached output, just display that and bail.
      # Pass the core objects to the controller constructor,
      # and then dispatch to the controller method.
      try

        #
        #  Start the benchmark timer
        $bench = new_core('Benchmark')
        $bench.mark 'total_execution_time_start'
        $bench.mark 'loading_time:_base_classes_start'

        #
        # Pre-system hook
        #
        $hooks = new_core('Hooks')
        $hooks.callHook 'pre_system'

        $config = new_core('Config')
        $uri = new_core('URI', $req)
        $output = new_core('Output', $req, $res, $bench, $hooks, $config, $uri)

        #
        #	can we just display the cache and be done with it?
        if $hooks.callHook('cache_override') is false
          if $output.displayCache() is true
            return

        # locale support
        $i18n = new_core('I18n', $config)
        # xss and csrf support
        $security = new_core('Security', $req, $res)
        # encoding support
        $utf = new_core('Utf8', $config)
        # Cookies, get & post data, etc...
        $input = new_core('Input', $req, $utf, $security)

        #  Housekeeping...
        $bench.mark 'loading_time:_base_classes_end'
        $hooks.callHook 'pre_controller'
        $bench.mark 'controller_execution_time_( ' + $class + ' / ' + $method + ' )_start'
        #
        #  Create the requested controller
        #
        $controller = new $klass(@server, $bench, $hooks, $config, $uri, $output, $security, $input, $i18n, $req, $res, $module, $class, $method)

      catch $err
        return $next($err)

      #
      # Next ->
      #
      # This function will be called by the controller when it is done.
      # Sends final output to the browser and releases resources.
      #
      $controller.next = ($err) ->

        try

          return $next($err) if $err
          #  More housekeeping...
          $bench.mark 'controller_execution_time_( ' + $class + ' / ' + $method + ' )_end'
          $hooks.callHook 'post_controller'
          #
          #  Send the final rendered output to the browser
          if $hooks.callHook('display_override') is false
            $output.display($controller)
          #
          #  Final hook
          $hooks.callHook 'post_system'
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

          #
          # Dispatch to the requested method.
          #   Any URI segments present (besides the class/function)
          #   will be passed to the method for convenience
          #
          $bench.mark 'post_controller_que_end'
          $controller[$method].apply($controller, $args)

        catch $err
          $next $err


  #
  # Middleware: Parse the Base URL
  #
  #   update the base_url config entry
  #
  # @param  [Object]  req the http request object
  # @param  [Object]  res the http response object
  # @param  [Function]  next  next middleware on stack
  # @return [Void]
  #
  parseBaseUrl: -> ($req, $res, $next) =>

    #
    # Set expected request object properties
    #

    @config.setItem('base_url', $req.protocol+'://'+ $req.headers['host'])
    $next()

  #
  # Middleware: Parse Request Properties
  #
  #   fabricate a table similar to $_SERVER
  #
  # @param  [Object]  req the http request object
  # @param  [Object]  res the http response object
  # @param  [Function]  next  next middleware on stack
  # @return [Void]
  #
  parseProperties: -> ($req, $res, $next) =>

    $_SERVER =
      argv                  : $req.query
      argc                  : count($req.query)
      CONTENT_TYPE          : $req.headers['content-type']
      DOCUMENT_ROOT         : process.cwd()
      HTTP_ACCEPT           : $req.headers['accept']
      HTTP_ACCEPT_CHARSET   : $req.headers['accept-charset']
      HTTP_ACCEPT_ENCODING  : $req.headers['accept-encoding']
      HTTP_ACCEPT_LANGUAGE  : $req.headers['accept-language']
      HTTP_CLIENT_IP        : ($req.headers['x-forwarded-for'] || '').split(',')[0]
      HTTP_CONNECTION       : $req.headers['connection']
      HTTP_HOST             : $req.headers['host']
      HTTP_REFERER          : $req.headers['referer']
      HTTP_USER_AGENT       : $req.headers['user-agent']
      HTTPS                 : if $req.secure then 'on' else 'off'
      ORIG_PATH_INFO        : $req.path
      PATH_INFO             : $req.path
      QUERY_STRING          : if $req.url.split('?')[1]? then $req.url.split('?')[1] else ''
      REMOTE_ADDR           : $req.connection.remoteAddress
      REMOTE_HOST           : ''
      REMOTE_PORT           : ''
      REMOTE_USER           : ''
      REQUEST_METHOD        : $req.method
      REQUEST_TIME          : $req._startTime
      REQUEST_URI           : $req.url
      SERVER_ADDR           : $req.ip
      SERVER_NAME           : $req.host
      SERVER_PORT           : ''+@server.port
      SERVER_PROTOCOL       : strtoupper($req.protocol)+"/"+$req.httpVersion
      SERVER_SOFTWARE       : @version+" (" + os.type() + '/' + os.release() + ") Node.js " + process.version

    for $key, $val of $req.headers
      $_SERVER['HTTP_'+$key.toUpperCase().replace('-','_')] = $val

    defineProperties $req,
      server  : {writeable: false, value: freeze($_SERVER)}

    $next()

  #
  # Middleware: 5xx Error Display
  #
  #   general server error handler
  #
  # @param  [Object]  err the error object
  # @param  [Object]  req the http request object
  # @param  [Object]  res the http response object
  # @param  [Function]  next  next middleware on stack
  # @return [Void]
  #
  error5xx: -> ($err, $req, $res, $next) -> show_error $err


  #
  # Middleware: 404 Display
  #
  #   page not found handler
  #
  # @param  [Object]  req the http request object
  # @param  [Object]  res the http response object
  # @param  [Function]  next  next middleware on stack
  # @return [Void]
  #
  error404: -> ($req, $res, $next) -> show_404 $req.originalUrl



module.exports = system.core.Exspresso

# End of file exspresso.coffee
# Location: ./system/core/exspresso.coffee