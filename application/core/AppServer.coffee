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
eco             = require('eco')
utils           = require("util")
fs              = require("fs")
path            = require("path")

class global.MY_Server extends CI_Server

  assets:   ''
  options:  null
  window:   null
  appjs:    null



  constructor: ->

    log_message('debug', "MY_Server Class Initialized")

    @CI = get_instance()              # the Exspresso core instance

    @app = require('appjs')

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

    $render = ($view, $data, $callback) ->

      fs.readFile $view, 'utf8', ($err, $str) ->
        if $err then $callback($err)
        else
          try
            $data.filename = $view
            $callback null, eco.render($str, $data)
          catch $err
            $callback $err

    # Get a copy of the original handle function
    $handle = appjs.router.handle

    #
    # override the appjs router
    #
    appjs.router.handle = ($req, $res) ->

      # Check if this is a request for static content
      $fullpath = path.join(@assets, $req.pathname)
      if file_exists($fullpath) and is_file($fullpath)
        #
        # Serve static content: *.css, *.js, *.html, etc.
        #
        $handle.apply appjs.router, arguments
      else
        #
        # Serve routed virtual content
        #
        $req.originalUrl = $req.url
        $req.url = $req.pathname
        #$server.handle.apply $server, arguments

    #
    # create the application window
    #
    @window = @app.createWindow(@appjs.url, @appjs.window)

    #
    # show the window after initialization
    #
    @window.on 'create', ->
      @window.frame.show()
      @window.frame.center()

    #
    # add require/process/module to the window global object for debugging from the DevTools
    #
    @window.on 'ready', ->
      @window.require = require
      @window.process = process
      @window.module = module
      @window.addEventListener 'keydown', (e) ->
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

    @appjs = $config['appjs']

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
    @app.serveFilesFrom @assets



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


# End of file MY_Server.coffee
# Location: .application/core/MY_Server.coffee