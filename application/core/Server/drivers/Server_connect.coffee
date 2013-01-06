#+--------------------------------------------------------------------+
#| Server_connect.coffee
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
#	Server_connect - Server driver for connectjs
#
#
#
#	Server_connect Class
#
#   An adapter to the connect server instance
#   it exposes adapter registration points for each of these core classes:
#
#       * Config
#       * Output
#       * Input
#       * Session
#       * URI
#
#
connect         = require("connect")    # Web development framework 2.x
eco             = require('eco')        # Eco templating
fs              = require("fs")         # File system


class Variables

#  --------------------------------------------------------------------

#
# Wrap the data array passed to render
#
# @access	public
# @return	void
#
  constructor: ($args...) ->

    for $data in $args
      for $key, $val of $data
        @[$key] = $val



class global.CI_Server_connect extends CI_Server

  _driver           : 'connect'

  #  --------------------------------------------------------------------

  #
  # Set the server instance
  #
  # @access	public
  # @return	void
  #
  constructor: ($config = {}) ->

    super $config
    log_message('debug', "Server_connect driver Class Initialized")

    @app = connect()

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

    if typeof @_port is 'undefined'
      @_port = 3000

    @app.use @authenticate()
    #@app.use @app.router
    @app.use @error_5xx()
    @app.use @error_404()

    if ENVIRONMENT is 'development'
      @app.use connect.errorHandler
        dumpExceptions: true
        showStack: true

    if ENVIRONMENT is 'production'
      @app.use connect.errorHandler()


    @app.listen @_port, =>

      console.log " "
      console.log " "
      console.log "Exspresso v"+CI_VERSION
      console.log "copyright 2012 Dark Overlord of Data"
      console.log " "
      console.log "listening on port #{@_port}"
      console.log " "

      if ENVIRONMENT is 'development'
        console.log "View site at http://localhost:" + @_port

      log_message "debug", "listening on port #{@_port}"

      for $arg in process.argv
        if $arg is '--preview'
          #
          # preview in appjs
          #
          {exec} = require('child_process')
          exec "node --harmony bin/preview #{@_port}", ($err, $stdout, $stderr) ->
            console.log $stderr if $stderr?
            console.log $stdout if $stdout?
            process.exit()

      return
    return


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
    return


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

    $config = @CI.config.config

    #
    # Expose asset folders
    #
    @app.use connect.static(APPPATH+"themes/default/assets/")
    #
    # Embedded coffee-script rendering engine
    #

    #
    # Favorites icon
    #
    if $config.favicon?
      @app.use connect.favicon(APPPATH+"themes/all/assets/" + $config.favicon)

    else
      @app.use connect.favicon()

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
    @app.use connect.bodyParser()
    @app.use connect.methodOverride()
    return

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
    return

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
    return


  # --------------------------------------------------------------------

  #
  # Server middleware
  #
  #   @returns function middlware callback
  #
  middleware: ->

    log_message 'debug',"connect middleware initialized"

    #  --------------------------------------------------------------------

    #
    # Patch the appjs server objects to render templates
    #
    # @access	private
    # @return	void
    #
    ($req, $res, $next) =>

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
        # load the view and render it with data+helpers
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



module.exports = CI_Server_connect

# End of file Server_connect.coffee
# Location: .application/core/Server/drivers/Server_connect.coffee