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
# e x s p r e s s o<br />
#
#   Top level controller for exspresso
#
module.exports = class system.core.Exspresso extends system.core.Object

  {exec} = require('child_process')

  #
  # @property [String] db driver: mysql | postgres
  #
  dbDriver: 'default'
  #
  # @property [Boolean] cache output?
  #
  useCache: false
  #
  # @property [Boolean] scrub inputs?
  #
  useCsrf: false
  #
  # @property [Boolean] preview locally in webkit
  #
  preview: false
  #
  # @property [Boolean] enable profiling?
  #
  profile: false
  #
  # @property [Boolean] do install checks
  #
  install: false
  #
  # @property [String] exspresso version
  #
  version: ''
  #
  # @property [Object] config overrides
  #
  configOverride: null
  #
  # @property [Object] module environment
  #
  modules: null
  #
  # @property [Object] args environment
  #
  argv: ''

  #
  #   Exspresso Version
  #     get the current version info from the npm package
  #
  @define version: require(FCPATH + 'package.json').version

  constructor: ->
    @configOverride = {}

  #
  # Parse the command line options.
  #
  # <br />
  #   --cache      enable cacheing <br />
  #   --csrf       enable xss checks <br />
  #   --preview    preview using webkat <br />
  #   --profile    enable profiling <br />
  #   --install    run install checks
  #   --subclass   set the subclass prefix
  #   --nocache    disable cacheing <br />
  #   --nocsrf     disable xss checks <br />
  #   --noprofile  disable profiling <br />
  #   --db <mysql|postgres> set database driver <br />
  #
  #
  # @return [Void]
  #
  parseOptions: () ->

    $db       = @dbDriver
    $cache    = @useCache
    $csrf     = @useCsrf
    $desktop  = @desktop
    $preview  = @preview
    $profile  = @profile
    $install  = false
    $argv     = []

    $profile = if ENVIRONMENT is 'development' then true else false
    process.argv.shift() # node
    process.argv.shift() # exspresso
    $set_db = false
    $set_pfx = false
    for $arg in process.argv

      if $set_db is true
        $db = $arg
        $set_db = false
        continue

      if $set_pfx is true
        @setConfig subclass_prefix: $arg
        $set_pfx = false
        continue

      switch $arg
        when '--db'         then $set_db  = true
        when '--cache'      then $cache   = true
        when '--csrf'       then $csrf    = true
        when '--desktop'    then $desktop = true
        when '--preview'    then $preview = true
        when '--profile'    then $profile = true
        when '--install'    then $install = true
        when '--nocache'    then $cache   = false
        when '--nocsrf'     then $csrf    = false
        when '--noprofile'  then $profile = false
        when '--subclass'   then $set_pfx = true
        else $argv.push $arg
          #console.log 'WARNING unknown option "'+$arg+'"'

    @define dbDriver    : $db
    @define useCache    : $cache
    @define useCsrf     : $csrf
    @define desktop     : $desktop
    @define preview     : $preview
    @define profile     : $profile
    @define install     : $install
    @argv = $argv.join(" ")

  setConfig: ($config) ->

    for $key, $value of $config
      @configOverride[$key] = $value

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
    @define config : core('Config', @)
    @config.setItem @configOverride
    @define server : core('Connect', @)
    @define router : core('Router', @)
    @define load   : core('Loader', @)

    #
    # Load the base controller class
    require SYSPATH+'core/Controller.coffee'

    if file_exists(APPPATH + 'core/' + @config.item('subclass_prefix') + 'Controller.coffee')
      require APPPATH + 'core/' + @config.item('subclass_prefix') + 'Controller.coffee'

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


    #
    # run as desktop app?
    #
    if @desktop
      exec "webkat #{@argv} http://localhost:#{$port}", ($err, $stdout, $stderr) =>
        console.log $stderr if $stderr?
        console.log $stdout if $stdout?
        log_message "debug", "e x s p r e s s o  v%s", @version
        log_message "debug", "exiting %s environment", ENVIRONMENT
        process.exit()

      #
      # preview locally?
      #
    else if @preview
      exec "webkat --debug #{@argv} http://localhost:#{$port}", ($err, $stdout, $stderr) =>
        console.log $stderr if $stderr?
        console.log $stdout if $stdout?
        log_message "debug", "e x s p r e s s o  v%s", @version
        log_message "debug", "exiting %s environment", ENVIRONMENT
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
  bind: ($route, $uri) ->

    return unless @router.setMapping($uri)

    $path   = @router.getPath()
    $module = @router.getModule()
    $class  = @router.getClass()
    $method = @router.getMethod()

    #
    # Don't allow 'private' methods to be invoked:
    #
    return log_message('error', 'Invalid method name: %s', $method) if $method[0] is '_'

    #
    # Load the local application controller
    #
    $klass = require($path+$class+EXT)

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
    @router.setRoute $route, ($req, $res, $next, $args...) =>


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

        $config = core('Config')
        $uri = new_core('Uri', $req)
        $output = new_core('Output', $req, $res, $bench, $hooks, $config, $uri)

      catch $err
        return $next($err)

      #
      #
      #
      create_content = ($err, $cached) =>

        #
        #	if we can display from cache, we're done
        #
        return if $cached

        try

          # locale support
          $i18n = new_core('I18n', $config, $module)
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
            if not $hooks.callHook('display_override')
              $output.display($controller)
            #
            #  Final hook
            $hooks.callHook 'post_system'
            #
            #  Close the DB connection if one exists
            if system.db?.DbDriver? and $controller.db?
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
      #	If there is no cache override hook,
      # use system.core.Output::displayCache
      #
      if not @hooks.callHook('cache_override', $output, create_content)
        $output.displayCache create_content


