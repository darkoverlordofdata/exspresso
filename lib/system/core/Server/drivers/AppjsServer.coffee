#+--------------------------------------------------------------------+
#| AppjsServer.coffee
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
#	Server_appjs - Server driver for appjs
#
#
#	Server_appjs Class
#
#   An adapter to the appjs server instance
#   it exposes adapter registration points for each of these core classes:
#
#       * Config
#       * Output
#       * Input
#       * Session
#       * URI
#
#
appjs           = require("appjs")          # Desktop SDK
#
# Appjs has minimal server support functionality.
# I'm using connect middleware and custom patching to fill the gap.
#
# appjs v0.0.20 known issues:
#
#   the dropdown widget (select/option tags) is only accessible via keyboard.
#   connect sessions are not compatible - no fix yet
#
#   requires 2 modifications:
#
#   request.body not populated with form fields
#
#     appjs/lib/router/bodyParser.js;25:
#
#     //  var str = req.headers['Content-Type'] || '';
#     var str = req.headers['content-type'] || '';
#
#   program does not exit consistently
#
#     appjs/lib/App.js;108:
#
#     //process.kill(process.pid);
#     process.exit();
#
#
#
connect         = require("connect")        # High performance middleware framework
eco             = require('eco')            # Embedded CoffeeScript templates
fs              = require("fs")             # File system
qs              = require("querystring")    # Query string utilities



class Variables

  #  --------------------------------------------------------------------

  #
  # Wrap the data array passed to render
  #
  #   Add data local to this request in the constructor.
  #   Helpers are added to the prototype as they are loaded.
  #
  # @access	public
  # @param array of arrays to merge together for rendering
  # @return	void
  #
  constructor: ($args...) ->

    for $data in $args
      for $key, $val of $data
        @[$key] = $val



class global.ExspressoAppjsServer extends ExspressoServer

  __defineProperties = {}.defineProperties
  _driver           : 'appjs'
  _secure           : false
  _protocol         : ''
  _host             : ''
  _httpVersion      : ''
  _ip               : ''
  _url              : ''
  _window           : null

  #  --------------------------------------------------------------------

  #
  # Set the server instance
  #
  # @access	public
  # @return	void
  #
  constructor: ($config = {}) ->

    log_message('debug', "Server_appjs driver Class Initialized")

    super $config, appjs.router
    @app.use @middleware()

  #  --------------------------------------------------------------------

  #
  # Add view helpers
  #
  #   The helpers are added to the prototype of the variable wrapper class.
  #   When the class is newed, all helpers are included via the prototype chain.
  #
  # @access	public
  # @return	void
  #
  setHelpers: ($helpers) ->
    for $key, $val of $helpers
      Variables::[$key] = $val
    $helpers

  #  --------------------------------------------------------------------

  #
  # Start me up ...
  #
  # @access	public
  # @return	void
  #
  start: ($router, $autoload = true) ->

    super $router, $autoload

    @app.use @error_404()

    #
    # create the application window
    #
    $window = appjs.createWindow(@_url, @_window)

    #
    # show the window after initialization
    #
    $window.on 'create', ->
      $window.frame.show()
      $window.frame.center()
      return

    #
    # add require/process/module to the window global object for debugging from the DevTools
    #
    $window.on 'ready', ->
      $window.require = require
      $window.process = process
      $window.module = module
      $window.addEventListener 'keydown', (event) ->
        $window.frame.openDevTools() if event.keyIdentifier is "F12"
        return
      return
    return


  #  --------------------------------------------------------------------

  #
  # Config registration
  #
  #   called by the core/Config class constructor
  #
  # @access	public
  # @param	object Exspresso.config
  # @return	void
  #
  config: ($config) ->

    super $config
    @app.use connect.logger(@_logger)
    Variables::['settings'] =
      site_name:    @_site_name
      site_slogan:  @_site_slogan
    return


  #  --------------------------------------------------------------------

  #
  # Output registration
  #
  #   called by the core/Output class constructor
  #
  # @access	public
  # @param	object Exspresso.output
  # @return	void
  #
  output: ($output) ->

    super $output
    appjs.serveFilesFrom APPPATH+"assets/"
    return


  #  --------------------------------------------------------------------

  #
  # Input registration
  #
  #   called by the core/Input class constructor
  #
  # @access	public
  # @param	object Exspresso.input
  # @return	void
  #
  input: ($input) ->

    super $input
    @app.use connect.query()
    @app.use connect.methodOverride()
    return

  #  --------------------------------------------------------------------

  #
  # URI registration
  #
  #   called by the core/URI class constructor
  #
  # @access	public
  # @param	object Exspresso.input
  # @return	void
  #
  uri: ($uri) ->

    super $uri
    return

  #  --------------------------------------------------------------------

  #
  # Sessions registration
  #
  #   called by the lib/Session/Session class constructor
  #
  # @access	public
  # @param	object Exspresso.input
  # @return	void
  #
  session: ($session) ->

    super $session
    @app.use connect.cookieParser($session.encryption_key)
    @app.use connect.session(secret: $session.encryption_key)
    return


  # --------------------------------------------------------------------

  #
  # Server middleware
  #
  #   @returns function middlware callback
  #
  middleware: ->

    log_message 'debug',"appjs middleware initialized"

    #  --------------------------------------------------------------------

    #
    # Patch the appjs server objects to render templates
    #
    # @access	private
    # @return	void
    #
    ($req, $res, $next) =>

      $req.session = $req.session ? {}
      #  --------------------------------------------------------------------

      #
      # Set expected request object properties
      #
      __defineProperties $req,
        secure:       get: -> if $req.protocol is 'https' then true else false
        ip:           value: $req.ip ? @_ip
        host:         value: $req.host ? @_host
        protocol:     value: $req.protocol ? @_protocol
        httpVersion:  value: $req.httpVersion ? @_httpVersion
        originalUrl:  value: $req.url
        path:         value: $req.pathname


      Exspresso.config.config.base_url = $req.protocol+'://'+ $req.host


      $res.writeHead = ($status, $headers) ->
        for $header in $headers
          for $name, $val in $header
            $res.setHeader $name, $val
        $res.send $status

      $res._error_handler = ($err) ->
        $next $err

      #  --------------------------------------------------------------------

      #
      # Render
      #
      #   called by a controller to display the view
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
              $html = eco.render($str, new Variables($data, flashdata: $res.flashdata))
              $next null, $html
            catch $err
              console.log $err.stack
              $next($err)

      $next()


module.exports = ExspressoAppjsServer

# End of file AppjsServer.coffee
# Location: .application/core/Server/drivers/AppjsServer.coffee