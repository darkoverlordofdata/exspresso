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
#   registers all of our middleware in the right order
#   exposes an adapter registration point for sessions
#
#
#

class application.core.Connect

  dispatch        = require('dispatch')           # URL dispatcher for Connect
  eco             = require('eco')                # Embedded CoffeeScript templates
  cookie          = require('cookie')             # cookie parsing and serialization
  sign            = require('cookie-signature')   # Sign and unsign cookies
  fs              = require("fs")                 # File system

  driver          : 'connect'
  app             : null
  port            : 3000
  controller      : null

  #
  # Set the server instance
  #
  # @access	public
  # @param object
  # @return	void
  #
  constructor: ($controller) ->

    $driver = require(@driver)
    @app = $driver()

    log_message('debug', "Connect Driver Initialized")

    @port = $controller.config.item('port')

    Variables::['settings'] =
      site_name:    $controller.config.item('site_name')
      site_slogan:  $controller.config.item('site_slogan')

    @app.use $driver.logger($controller.config.item('logger'))
    #
    # Expose asset folders
    #
    @app.use $driver.static(APPPATH+"assets/")
    @app.use $driver.static(DOCPATH)

    #
    # Favorites icon
    #
    @app.use $driver.favicon(APPPATH+"assets/" + $controller.config.item('favicon'))

    #
    # Request parsing
    #
    @app.use $driver.query()
    @app.use $driver.bodyParser()
    @app.use $driver.methodOverride()
    @app.use @patch($driver.utils.parseUrl)
    @app.use $controller.parseBaseUrl()

    @controller = $controller

  #
  # Add view helpers
  #
  # @access	public
  # @param array
  # @return	object
  #
  setHelpers: ($helpers) ->
    for $key, $val of $helpers
      Variables::[$key] = $val
    $helpers

  #
  # Careful with that axe, Eugene...
  #
  # @access	public
  # @return	void
  #
  start: ($router) ->
    #
    # Connect is now configured, so set the properites
    #
    @app.use @controller.parseProperties()
    #
    # Do the autoloads
    #
    @controller.load.initialize()
    #
    # Create the exception handler
    #
    @app.use core('Exceptions').exceptionHandler()
    #
    # Set route dispatching
    #
    @app.use dispatch($router.routes)
    #
    # Run all the tasks that queued up during autoload

    @controller.run ($err) =>

      @port = @port || 3000

      #
      # Connect the error handlers
      #
      @app.use @controller.error5xx()
      @app.use @controller.error404()

      #
      #
      # and go
      @app.listen @port, =>
        @controller.ready(@port)
        return
      return
    return

  #
  # Sessions
  #
  #   Callback from lib/Session constructor to
  #   initialize session support
  #
  # @access	public
  # @param	object
  # @return	void
  #
  session: ($session) ->

    $server = require(@controller.httpDriver)
    @app.use $server.cookieParser($session.encryption_key)

    # Session middleware options
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

    @app.use $server.session($options)
    @app.use $session.parseRequest($session.cookie_prefix + $session.sess_cookie_name)
    return



  #
  # Middleware: Patch
  #
  #   Fill in some properties on the request object
  #
  # @access	public
  # @param object
  # @param object
  # @param function
  # @return	void
  #
  patch: ($parseUrl) -> ($req, $res, $next) =>

    #
    # Set expected request object properties
    #

    defineProperties $req,
      protocol  : get: -> if $req.connection.encrypted then 'https' else 'http'
      secure    : get: -> if $req.protocol is 'https' then true else false
      path      : value: $parseUrl($req).pathname
      host      : value: $req.headers.host
      ip        : value: $req.connection.remoteAddress


    #
    # Send
    #
    #   send response string
    #
    # @access	public
    # @param	string
    # @return	void
    #
    $res.send = ($data) ->
      $res.writeHead 200,
        'Content-Length'  : $data.length
        'Content-Type'    : 'text/html; charset=utf-8'
      $res.end $data


    #
    # Redirect
    #
    #   Redirect to url
    #
    # @access	public
    # @param	string
    # @return	void
    #
    $res.redirect = ($url) ->
      $res.writeHead 302,
        'Location': $url
      $res.end null

    #$res._error_handler = ($err) ->
    #  $next $err

    #
    # Render
    #
    #   called by the controller to display a view
    #
    # @access	public
    # @param	string    path to view
    # @param	object    data to render in the view
    # @param	function  callback
    # @return	void
    #
    $res.render = ($view, $data = {}, $next) ->

      #
      # $data argument is optional
      #
      if typeof $data is 'function' then [$data, $next] = [{}, $data]

      #
      # $next argument is optional
      #
      $next = $next ? ($err, $str) -> if $err then $next($err) else $res.send($str)

      #
      # load the view and render it with data+helpers
      #
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



module.exports = application.core.Connect

class Variables

  #
  # Provides variables to a view
  #
  # @access	public
  # @param array
  # @return	void
  #
  constructor: ($args...) ->

    for $data in $args
      for $key, $val of $data
        @[$key] = $val




# End of file ConnectServer.coffee
# Location: .application/core/ConnectServer.coffee