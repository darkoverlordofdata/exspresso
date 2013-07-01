#+--------------------------------------------------------------------+
#| Connect.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+

#
#	Connect driver
#
#   An adapter to the connect server instance
#   adds render support for views
#   registers all of our middleware in the right order
#   exposes an adapter registration point for sessions
#
module.exports = class system.core.Connect

  dispatch        = require('dispatch')           # URL dispatcher for Connect
  cookie          = require('cookie')             # cookie parsing and serialization
  sign            = require('cookie-signature')   # Sign and unsign cookies
  fs              = require("fs")                 # File system
  os              = require('os')                 # operating-system related utility functions
  path            = require('path')

  protocol = ($secure) -> if $secure then 'https' else 'http'

  #
  # @property [String] http driver: connect
  #
  driver: 'connect'
  #
  # @property [Object] app
  #
  app: null
  #
  # @property [Integer] port
  #
  port: 3000
  #
  # @property [system.core.Exspresso] controller
  #
  controller: null
  #
  # @property [system.core.config] configuration 
  #
  config: null
  #
  # @property [RenderView] render lib
  #
  render: null
  #
  # @property [String] driver version
  #
  version: ''

  #
  # inner class Vars
  #
  class Vars

    #
    # Provides variables to a view
    #
    # @param  [Array] args  a list of hash to merge into this
    #
    constructor: ($args...) ->

      for $data in $args
        for $key, $val of $data
          @[$key] = $val

  #
  # Set the server instance
  #
  # @param  [system.core.Exspresso]
  # @return [Void]
  #
  constructor: (@controller) ->

    @config = @controller.config
    log_message 'debug', "%s Driver Initialized", ucfirst(@driver)

    $driver = require(@driver)
    $version = @driver+' v'+$driver.version
    defineProperties @, version  : {writeable: false, value: $version}
    @initialize($driver)


  #
  # Initialize the driver
  #
  # @param  [Object]  driver  http server object
  # @return [Void]
  #
  initialize:($driver) ->

    @app = $driver()
    @port = @config.item('http_port')
    $render = new_core('Render', @controller)

    #
    # Template for initializing the server
    #
    @initialize_log $driver, $render
    @initialize_assets $driver, $render
    @initialize_request $driver, $render
    @initialize_response $driver, $render

  #
  # Set view helpers
  #
  # Sets the autoloaded helpers on the Variables class
  # prototype. This makes them global to all views.
  #
  # @param  [Object] helpers hash of helpers to add
  # @return [Object] the helpers hash
  #
  setHelpers: ($helpers) ->
    for $key, $val of $helpers
      Vars::[$key] = $val
    $helpers

  #
  # Careful with that axe, Eugene...
  #
  # @param [system.core.Router] router  the routing controller
  # @return [Void]
  #
  start: ($router, $ready) ->
    #
    # check for config/autoload
    #
    @controller.load.initialize()
    #
    # initialize modules
    #
    for $name, $module of @config.modules
      $module.initialize(@app) if $module.initialize?

    #
    # Register the exception handler
    #
    @app.use core('Exceptions').exceptionHandler()
    #
    # Set dispatch routing
    #
    @app.use dispatch($router.routes)
    @app.use ($err, $req, $res, $next) -> show_error $err
    @app.use ($req, $res, $next) -> show_404 $req.originalUrl

    #
    # Run all the tasks that queued up during
    # autoload and start the server running
    #
    @controller.run ($err) =>

      @app.listen @port, =>
        @controller.ready(@port)
        return
      return
    return

  #
  # Sessions
  #
  #   Callback from lib/Session constructor during
  #   autoload sequence to initialize session support
  #
  # @param  [Object]
  # @return [Void]
  #
  session: ($session) ->

    $driver = require(@driver)
    @app.use $driver.cookieParser($session.encryption_key)

    # Set the ession middleware options
    $options =
      secret    : $session.encryption_key
      cookie:
        domain    : $session.cookie_domain
        path      : $session.cookie_path
        name      : $session.sess_cookie_name
        secure    : $session.cookie_secure
        maxAge    : $session.sess_expiration

    #  Are we using a database?  If so, load the driver
    if $session.sess_use_database
      $options.store = $session.loadDriver($session.sess_driver, @controller)
      if @controller.install then $options.store.install()

    @app.use $driver.session($options)
    @app.use $session.parseRequest($session.cookie_prefix + $session.sess_cookie_name)
    return

  #
  # Initialize the log
  #
  # @return [Void]
  #
  initialize_log: ($driver, $render) ->
    @app.use $driver.logger(@config.item('log_http'))


  #
  # Initialize the assets
  #
  # @return [Void]
  #
  initialize_assets:($driver, $render) ->
    #
    # Expose asset folders
    #
    @app.use $driver.static(APPPATH+"assets/")
    @app.use $driver.static(DOCPATH) unless DOCPATH is false
    for $name, $module of @config.modules
      if is_dir($module.path+"/assets/")
        @app.use $driver.static($module.path+"/assets/")
        log_message 'debug', 'Module %s mounted at %s', $module.name, $module.path

    #
    # Favorites icon
    #
    @app.use $driver.favicon(APPPATH+"assets/" + @config.item('favicon'))

  #
  # Initialize the request
  #
  # @return [Void]
  #
  initialize_request: ($driver, $render) ->
    #
    # Request parsing
    #
    @app.use $driver.query()
    @app.use $driver.bodyParser()
    @app.use $driver.methodOverride()


  #
  # Initialize the response
  #
  # @return [Void]
  #
  initialize_response: ($driver, $render) ->
    @app.use ($req, $res, $next) =>

      #
      # Represent
      #
      $res.setHeader 'X-Powered-By', "Exspresso/#{@controller.version}"
      #
      # get the base url?
      #
      if @config.item('base_url') is ''
        @config.setItem('base_url', protocol($req.connection.encrypted)+'://'+ $req.headers['host'])

      #
      # Send JSON
      #
      # Send object as JSON
      #
      # @private
      # @param [Object] data  hash of variables to render with template
      # @return [Void]
      #
      $res.json = ($data = {}) ->
        $res.writeHead 200,
          'Content-Type'    : 'application/json; charset=utf-8'
        $res.end JSON.stringify($data)
        return

      #
      # Redirect
      #
      # Redirect to another url
      #
      # @private
      # @param [String] url url to redirect to
      # @param [String] type  location | refresh
      # @param [String] url url to redirect to
      # @return [Void]
      #
      $res.redirect = ($url, $type='location', $status = 302) ->

        switch $type
          when 'refresh'
            $res.writeHead $status,
              Refresh: 0
              url: $url
            $res.end null
          else
            $res.writeHead $status,
              Location: $url
            $res.end null



      #
      # Render the view
      #
      # Create a new Variable instance to merge the $data param
      # with the flashdata, as well as the config values and
      # helpers that have been added to the prototype
      #
      # @private
      # @param [String] view  path to view template
      # @param [Object] data  hash of variables to render with template
      # @param [Funcion] next optional async callback
      # @return [Void]
      #
      $res.render = ($view, $data = {}, $next) ->
        if typeof $data is 'function' then [$data, $next] = [{}, $data]

        # if it's not a filename, then directly render partial
        if Array.isArray($view)

          $html = $render.eco($view.join(''), new Vars($data))
          return $next(null, $html)

        if not fs.existsSync($view)
          return show_error('Unable to load the requested file: %s', $view)
        #
        # Default terminal next
        #
        $next = $next ? ($err, $str) ->
          return $next($err) if $err
          $res.writeHead 200,
            'Content-Length'  : $str.length
            'Content-Type'    : 'text/html; charset=utf-8'
          $res.end $str
          return

        #
        # Read in the view file
        #
        fs.readFile $view, 'utf8', ($err, $str) ->
          return $next($err) if $err
          $ext = path.extname($view).replace('.','')

          if $render[$ext]?

            try
              $next(null, $render[$ext]($str, new Vars($data, filename: $view, flashdata: $res.flashdata)))

            catch $err
              show_error $err

          else show_error 'Invalid view file type: %s (%s)', $ext, $view

      $next()



