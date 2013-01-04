#+--------------------------------------------------------------------+
#| MY_Server.coffee
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
#	MY_Server Class
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

class global.MY_Server extends CI_Server

  assets            : ''
  window            : null
  secure            : false
  protocol          : 'http'
  host              : 'appjs'
  httpVersion       : '1.1'
  ip                : '127.0.0.1'


  constructor: ->

    log_message('debug', "MY_Server Class Initialized")

    @CI = get_instance()              # the Exspresso core instance

    locals = (obj) ->
      locals = (obj) ->
        for key of obj
          locals[key] = obj[key]
        obj
        console.log obj
      locals


    @app = appjs.router
    $this = @app
    @app.locals = locals(@CI)

    @app.use ($req, $res, $next) =>

      #
      # set missing request properties
      #
      $req.path         = $req.pathname
      $req.originalUrl  = $req.url
      $req.host         = $req.host ? @host
      $req.protocol     = $req.protocol ? @protocol
      $req.httpVersion  = $req.httpVersion ? @httpVersion
      $req.secure       = $req.secure ? @secure
      $req.ip           = $req.ip ? @ip
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
    #@window = appjs.createWindow(@config.url, @config.window)
    $dim =
      width           : 1280
      height          : 920
      icons						: process.cwd() + "/bin/icons"

    @window = appjs.createWindow('http://appjs/', $dim)

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
    @assets = APPPATH+"themes/"+$theme+"/assets/"
    appjs.serveFilesFrom @assets
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



# End of file MY_Server.coffee
# Location: .application/core/MY_Server.coffee