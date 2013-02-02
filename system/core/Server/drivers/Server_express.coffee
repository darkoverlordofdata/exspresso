#+--------------------------------------------------------------------+
#| Server_express.coffee
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
#	Server_express - Server driver for expressjs
#
#
#
#
#	Server Class
#
#   An adapter to the express.js server instance
#   it exposes adapter registration points for each of these core classes:
#
#       * Config
#       * Output
#       * Input
#       * Session
#       * URI
#
express         = require('express')        # Web development framework
cache           = require("connect-cache")  # Caching system for Connect
eco             = require('eco')            # Embedded CoffeeScript templates
fs              = require("fs")             # File system

class global.Exspresso_Server_express extends Exspresso_Server

  _driver           : 'express'

  #  --------------------------------------------------------------------

  #
  # Set the server instance
  #
  # @access	public
  # @return	void
  #
  constructor: ($config = {}) ->

    log_message('debug', "Server_express driver Class Initialized")

    super $config, if express.version[0] is '3' then express() else express.createServer()
    @app.use @middleware()

  #  --------------------------------------------------------------------

  #
  # Add view helpers
  #
  # @access	public
  # @return	void
  #
  set_helpers: ($helpers) ->

    @app.locals $helpers
    $helpers


  #  --------------------------------------------------------------------

  #
  # Start me up ...
  #
  # @access	public
  # @return	void
  #
  start: ($router) ->
    super $router, =>

      if typeof @_port is 'undefined'
        @_port = 3000

      @app.use @authenticate()
      @app.use @app.router
      @app.use @error_5xx()
      @app.use @error_404()

      @app.listen @_port, =>

        console.log " "
        console.log " "
        console.log "Exspresso v"+Exspresso_VERSION
        console.log "copyright 2012 Dark Overlord of Data"
        console.log " "
        console.log "listening on port #{@_port}"
        console.log " "

        if ENVIRONMENT is 'development'
          console.log "View site at http://localhost:" + @_port

        log_message "debug", "listening on port #{@_port}"

        if @_preview
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
    return

  #  --------------------------------------------------------------------

  #
  # Config registration
  #
  #   called by the Server class constructor
  #
  # @access	public
  # @param	object Exspresso.config
  # @return	void
  #
  config: ($config) ->

    super $config
    @app.use express.logger(@_logger)
    @app.use cache({rules: [{regex: /.*/, ttl: 60000}]}) if @_cache

    @app.set 'env', ENVIRONMENT
    @app.set 'port', @_port
    @app.set 'site_name', @_site_name
    @app.set 'site_slogan', @_site_slogan
    #
    # Expose asset folders
    #
    @app.set 'views', APPPATH + $config.views
    @app.use express.static(APPPATH+"assets/")
    #
    # Embedded coffee-script rendering engine
    #
    @app.set 'view engine', ltrim($config.view_ext, '.')
    if express.version[0] is '3'
      @app.engine $config.view_ext, ($view, $data, $next) ->

        fs.readFile $view, 'utf8', ($err, $str) ->
          if $err then $next($err)
          else
            try
              $data.filename = $view
              $next null, eco.render($str, $data)
            catch $err
              $next $err

    else
      @app.register $config.view_ext, eco
      # don't use express layouts,
      # Exspresso has it's own templating
      @app.set('view options', { layout: false });
    #
    # Favorites icon
    #
    if $config.favicon?
      @app.use express.favicon(APPPATH+"assets/" + $config.favicon)

    else
      @app.use express.favicon()

    @app.use express.bodyParser()
    @app.use express.methodOverride()
    return



  # --------------------------------------------------------------------

  #
  # Server middleware
  #
  #   @returns function middlware callback
  #
  middleware: ->

    log_message 'debug',"express middleware initialized"

    #  --------------------------------------------------------------------

    #
    # Patch the express server objects
    #
    # @access	private
    # @return	void
    #
    ($req, $res, $next) =>

      Exspresso.config.config.base_url = $req.protocol+'://'+ $req.headers['host']

      $res._error_handler = ($err) ->
        $next $err


      $next()


module.exports = Exspresso_Server_express

# End of file Server_express.coffee
# Location: .application/core/Server/drivers/Server_express.coffee