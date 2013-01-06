#+--------------------------------------------------------------------+
#| Server_appjs.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
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
appjs           = require("appjs")                      # Desktop development framework 0.0.20
dispatch        = require('dispatch')                   # URL dispatcher for Connect
connect         = require("connect")                    # Web development framework
eco             = require('eco')
fs              = require("fs")
path            = require("path")
utils           = require("util")


class Variables

  #  --------------------------------------------------------------------

  #
  # Wrap the options passed to render
  #
  # @access	public
  # @return	void
  #
  constructor: ($args...) ->

    for $data in $args
      for $key, $val of $data
        @[$key] = $val



class global.CI_Server_appjs extends CI_Server

  _utils            : connect # use connect middleware utils

  _assets           : APPPATH+"themes/default/assets/"
  _driver           : 'appjs'

  _secure           : false
  _protocol         : ''
  _host             : ''
  _httpVersion      : ''
  _ip               : ''
  _url              : ''
  _window           : null

  constructor: ($config = {}) ->

    super $config
    log_message('debug', "Server_appjs driver Class Initialized")

    @app = appjs.router
    @app.use @middleware()

  #  --------------------------------------------------------------------

  #
  # Add view helpers
  #
  # @access	public
  # @return	void
  #
  set_helpers: ($helpers) ->
    for $key, $val of $helpers
      Variables::[$key] = $val

  #  --------------------------------------------------------------------

  #
  # Start me up ...
  #
  # @access	public
  # @return	void
  #
  start: ($router, $autoload = true) ->

    super $router, $autoload

    @app.use dispatch($router.routes)

    #
    # create the application window
    #
    @window = appjs.createWindow(@_url, @_window)

    #
    # show the window after initialization
    #
    @window.on 'create', =>
      @window.frame.show()
      @window.frame.center()

    #
    # add require/process/module to the window global object for debugging from the DevTools
    #
    @window.on 'ready', =>
      @window.require = require
      @window.process = process
      @window.module = module
      @window.addEventListener 'keydown', (event) =>
        @window.frame.openDevTools()  if event.keyIdentifier is "F12"



  #  --------------------------------------------------------------------

  #
  # Config registration
  #
  #   called by the core/Config class constructor
  #
  # @access	public
  # @param	object $CFG
  # @return	void
  #
  config: ($config) ->

    super $config
    @app.use connect.logger($config.config.logger)
    Variables::['settings'] =
      site_name:    $config.config.site_name
      site_slogan:  $config.config.site_slogan


  #  --------------------------------------------------------------------

  #
  # Output registration
  #
  #   called by the core/Output class constructor
  #
  # @access	public
  # @param	object $OUT
  # @return	void
  #
  output: ($output) ->

    super $output
    $theme ='default'
    @_assets = APPPATH+"themes/"+$theme+"/assets/"
    appjs.serveFilesFrom @_assets
    return


  #  --------------------------------------------------------------------

  #
  # Input registration
  #
  #   called by the core/Input class constructor
  #
  # @access	public
  # @param	object $IN
  # @return	void
  #
  input: ($input) ->

    super $input
    @app.use connect.query()
    @app.use connect.methodOverride()

  #  --------------------------------------------------------------------

  #
  # URI registration
  #
  #   called by the core/URI class constructor
  #
  # @access	public
  # @param	object $IN
  # @return	void
  #
  uri: ($uri) ->

    super $uri

  #  --------------------------------------------------------------------

  #
  # Sessions registration
  #
  #   called by the libraries/Session/Session class constructor
  #
  # @access	public
  # @param	object $IN
  # @return	void
  #
  session: ($session) ->

    super $session
    @app.use connect.cookieParser($session.encryption_key)
    @app.use connect.session(secret: $session.encryption_key)


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

      #
      # set missing request properties
      #
      $req.path         = $req.pathname
      $req.originalUrl  = $req.url
      $req.host         = $req.host ? @_host
      $req.protocol     = $req.protocol ? @_protocol
      $req.httpVersion  = $req.httpVersion ? @_httpVersion
      $req.secure       = $req.secure ? @_secure
      $req.ip           = $req.ip ? @_ip

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
      $res.render = ($view, $data = {}, $callback) ->

        #
        # $data argument is optional
        #
        if typeof $data is 'function' then [$data, $callback] = [{}, $data]

        #
        # $callback argument is optional
        #
        $callback = $callback ? ($err, $str) -> if $err then $next($err) else $res.send($str)

        #
        # load the view and render it using eco
        #
        fs.readFile $view, 'utf8', ($err, $str) ->
          if $err then $callback($err)
          else
            try
              $data.filename = $view
              $callback null, eco.render($str, new Variables($data, flashdata: $res.flashdata))
            catch $err
              console.log $err
              $next($err)

      $next()



module.exports = CI_Server_appjs

# End of file Server_appjs.coffee
# Location: .application/core/Server/drivers/Server_appjs.coffee