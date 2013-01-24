#+--------------------------------------------------------------------+
#| Server_express.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
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
useragent       = require('connect-useragent')

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

    $app = if express.version[0] is '3' then express() else express.createServer()
    super $config, $app
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
  start: ($router, $autoload = true) ->
    super $router, $autoload, =>

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

    $config = Exspresso.config.config

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
      @app.engine $config.view_ext, ($view, $data, $callback) ->

        fs.readFile $view, 'utf8', ($err, $str) ->
          if $err then $callback($err)
          else
            try
              $data.filename = $view
              $callback null, eco.render($str, $data)
            catch $err
              $callback $err

    else
      @app.register $config.view_ext, eco
      # Exspresso has it's own templating, so don't use express layouts
      @app.set('view options', { layout: false });
    #
    # Favorites icon
    #
    if $config.favicon?
      @app.use express.favicon(APPPATH+"assets/" + $config.favicon)

    else
      @app.use express.favicon()

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

    @app.use express.bodyParser()
    @app.use express.methodOverride()
    @app.use useragent()
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
  # Session Database setup
  #
  #   create session table
  #
  # @access	public
  # @return	void
  #
  session_db: ->

    @queue ($next) ->
      Exspresso.db.table_exists 'ex_session', ($err, $table_exists) ->

        if $err then return $next $err
        if $table_exists then return $next null

        Exspresso.load.dbforge()
        Exspresso.dbforge.add_field
          session_id:
            type: 'VARCHAR'
            constraint: 255
          session:
            type: 'TEXT'
          expires:
            type: 'INT'

        Exspresso.dbforge.add_key 'session_id', true
        Exspresso.dbforge.create_table 'ex_session', $next

    @queue ($next) ->
      Exspresso.db.close $next

  #  --------------------------------------------------------------------

  #
  # Sessions registration
  #
  #   called by the libraries/Session/Session class constructor
  #
  # @access	public
  # @param	object Exspresso.input
  # @return	void
  #
  session: ($session) ->

    @app.use express.cookieParser($session.encryption_key)
    #  Are we using a database?  If so, load it
    if $session.sess_use_database isnt false and $session.sess_table_name isnt ''

      if $session.sess_use_database is true
        $sess_driver = Exspresso.db.dbdriver
        @session_db()
      else
        $sess_driver = parse_url($session.sess_use_database).scheme

      $found = false
      for $path in [BASEPATH, APPPATH]

        if file_exists($path+'libraries/Session/drivers/Session_'+$sess_driver+EXT)

          $found = true

          $driver = require($path+'libraries/Session/drivers/Session_'+$sess_driver+EXT)
          $store = new $driver($session)

          @app.use express.session
            key:      'session_id'
            secret:   $session.encryption_key
            store:    $store
            cookie:
              domain:   $session.cookie_domain
              path:     $session.cookie_path
              secure:   $session.cookie_secure
              maxAge:   $session.sess_expiration * 1000

      if not $found

        show_error "Driver not found: Session_%s", $sess_driver

    else

      @app.use express.session
        key:      'session_id'
        secret:   $session.encryption_key
        cookie:
          domain:   $session.cookie_domain
          path:     $session.cookie_path
          secure:   $session.cookie_secure
          maxAge:   $session.sess_expiration * 1000

    @app.use express.csrf() if @_csrf
    super $session

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