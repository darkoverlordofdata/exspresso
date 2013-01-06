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


class CI_Vars

  #  --------------------------------------------------------------------

  #
  # Wrap the options passed to render
  #
  # @access	public
  # @return	void
  #
  constructor: ($args...) ->

    for $data in $args
      @[$key] = $val for $key, $val of $data

#  --------------------------------------------------------------------

#
# Add helpers to the class prototype
#
# @access	public
# @return	void
#
CI_Vars.add_helpers = ($properties) ->

  CI_Vars::[$key] = $val for $key, $val of $properties



class global.CI_Server_appjs extends CI_Server

  _assets           : APPPATH+"themes/default/assets/"
  _driver           : 'appjs'
  _secure           : false
  _protocol         : 'http'
  _host             : 'appjs'
  _httpVersion      : '1.1'
  _ip               : '127.0.0.1'
  _url              : 'http://appjs/'
  _window           :
    width           : 1280
    height          : 920
    icons           : process.cwd() + "/bin/icons"
    left            : -1 			# optional, -1 centers
    top             : -1			# optional, -1 centers
    autoResize      : false 	# resizes in response to html content
    resizable       : true		# controls whether window is resizable by user
    showChrome      : true		# show border and title bar
    opacity         : 1 			# opacity from 0 to 1 (Linux)
    alpha           : false 	# alpha composited background (Windows & Mac)
    fullscreen      : false 	# covers whole screen and has no border
    disableSecurity : true		# allow cross origin requests


  #  --------------------------------------------------------------------

  #
  # Patch the appjs server objects to render templates
  #
  # @access	public
  # @return	void
  #
  constructor: ($config = {}) ->

    log_message('debug', "Server_appjs Class Initialized")

    if not empty($config) then @['_'+$key] = $var for $key, $var of $config

    @CI = get_instance()              # the Exspresso core instance

    locals = (obj) ->
      locals = (obj) ->
        for key of obj
          locals[key] = obj[key]
        obj
        console.log obj
      locals


    @app = appjs.router
    @app.locals = locals(@CI)
    $this = @app

    @app.use ($req, $res, $next) =>

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
      $res.locals       = array_merge($this.locals, $res.locals)
      #
      # Response::render
      #
      $res.render = ($view, $data = {}, $callback) ->
        #
        # $data argument is optional
        #
        if typeof $data is 'function' then [$data, $callback] = [{}, $data]

        $data = array_merge($res.locals, $data)
        #
        # $callback argument is optional
        #
        $callback = $callback ? ($err, $str) ->
          if $err then $next($err) else $res.send($str)
        #
        # load the view and render it using eco
        #

        fs.readFile $view, 'utf8', ($err, $str) ->
          if $err then $callback($err)
          else
            try
              $data.filename = $view
              $callback null, eco.render($str, $data)
            catch $err
              console.log $err
              $next($err)

      $next()


  #  --------------------------------------------------------------------

  #
  # Add view helpers
  #
  # @access	public
  # @return	void
  #
  set_helpers: ($helpers) ->
    @app.locals $helpers

  #  --------------------------------------------------------------------

  #
  # Start me up ...
  #
  # @access	public
  # @return	void
  #
  start: ($router, $autoload = true) ->

    load = load_class('Loader', 'core')
    load.initialize @CI, $autoload

    @app.use load_class('Exceptions',  'core').middleware()
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
      @window.addEventListener 'keydown', (e) =>
        @window.frame.openDevTools()  if e.keyIdentifier is "F12"



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

    @app.use connect.logger($config.config.logger)
    @app.locals
      settings:
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

    $theme ='default'
    @_assets = APPPATH+"themes/"+$theme+"/assets/"
    appjs.serveFilesFrom @_assets
    @app.use $output.middleware()
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

    @app.use connect.query()
    @app.use connect.methodOverride()
    @app.use $input.middleware()

module.exports = CI_Server_appjs

# End of file Server_appjs.coffee
# Location: .application/core/Server/drivers/Server_appjs.coffee