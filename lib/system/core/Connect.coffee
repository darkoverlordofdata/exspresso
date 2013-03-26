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
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#	Connect driver
#
#   An adapter to the connect server instance
#   adds render support for views
#   registers all of our middleware in the right order
#   exposes an adapter registration point for sessions
#
class system.core.Connect

  dispatch        = require('dispatch')           # URL dispatcher for Connect
  eco             = require('eco')                # Embedded CoffeeScript templates
  cookie          = require('cookie')             # cookie parsing and serialization
  sign            = require('cookie-signature')   # Sign and unsign cookies
  fs              = require("fs")                 # File system
  os              = require('os')                 # operating-system related utility functions

  protocol = ($secure) -> if $secure then 'https' else 'http'

  Modules = system.core.Modules


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
  # @property [String] driver version
  #
  version: ''

  #
  # inner class Variables
  #
  class Variables

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
    log_message('debug', "%s Driver Initialized", ucfirst(@driver))

    $driver = require(@driver)
    $version = @driver+' v'+$driver.version
    defineProperties @, version  : {writeable: false, value: $version}
    @initialize($driver)


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
      Variables::[$key] = $val
    $helpers

  #
  # Careful with that axe, Eugene...
  #
  # @param [system.core.Router] router  the routing controller
  # @return [Void]
  #
  start: ($router) ->
    #
    # check for config/autoload
    #
    @controller.load.initialize()
    #
    # initialize modules
    #
    for $name, $module of Modules::list()
      $module.initialize() if $module.initialize?

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
      $options['store'] = $session.loadDriver($session.sess_driver).installCheck()

    @app.use $driver.session($options)
    @app.use $session.parseRequest($session.cookie_prefix + $session.sess_cookie_name)
    return
  #
  # Initialize the driver
  #
  # @param  [Object]  driver  http server object
  # @return [Void]
  #
  initialize:($driver) ->

    @app = $driver()
    parseUrl = $driver.utils.parseUrl
    @port = @config.item('port') || 3000

    @app.use $driver.logger(@config.item('logger'))
    #
    # Expose asset folders
    #
    @app.use $driver.static(APPPATH+"assets/")
    @app.use $driver.static(DOCPATH) unless DOCPATH is false

    #
    # Favorites icon
    #
    @app.use $driver.favicon(APPPATH+"assets/" + @config.item('favicon'))

    #
    # Request parsing
    #
    @app.use $driver.query()
    @app.use $driver.bodyParser()
    @app.use $driver.methodOverride()
    @app.use ($req, $res, $next) =>

      #
      # get the base url?
      #
      if @config.item('base_url') is ''
        @config.setItem('base_url', protocol($req.connection.encrypted)+'://'+ $req.headers['host'])

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
      # @param [Funcion] next async callback
      # @return [Void]
      #
      $res.render = ($view, $data = {}, $next) ->
        if typeof $data is 'function' then [$data, $next] = [{}, $data]
        $next = $next ? ($err, $str) ->
          return $next($err) if $err
          $res.writeHead 200,
            'Content-Length'  : $str.length
            'Content-Type'    : 'text/html; charset=utf-8'
          $res.end $str
          return

        fs.readFile $view, 'utf8', ($err, $str) ->
          if $err then $next($err)
          else
            try
              $data.filename = $view
              $next null, eco.render($str, new Variables($data, flashdata: $res.flashdata))
            catch $err
              console.log $err
              $next($err)

      $next()

module.exports = system.core.Connect


# End of file Connect.coffee
# Location: .system/core/Connect.coffee