#+--------------------------------------------------------------------+
#| Server.coffee
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
dispatch        = require('dispatch')                   # URL dispatcher for Connect
express         = require('express')                    # Web development framework 3.0
fs              = require('fs')
eco             = require('eco')


class global.CI_Server
  
  _port: 0

  #  --------------------------------------------------------------------

  #
  # get server instance
  #
  # @access	public
  # @return	void
  #
  constructor: ->

    log_message('debug', "Server Class Initialized")
    @CI = get_instance()              # the Expresso core instance

    @app = if express.version[0] is '3' then express() else express.createServer()

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

    if typeof @_port is 'undefined'
      @_port = 3000

    @app.use @authenticate()
    @app.use @app.router
    @app.use @error_5xx()
    @app.use dispatch($router.routes)
    @app.use @error_404()

    if ENVIRONMENT is 'development'
      @app.use express.errorHandler
        dumpExceptions: true
        showStack: true

    if ENVIRONMENT is 'production'
      @app.use express.errorHandler()


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

    @_port = $config.config.port
    @app.set 'env', ENVIRONMENT
    @app.set 'port', @_port
    @app.set 'site_name', $config.config.site_name
    @app.set 'site_slogan', $config.config.site_slogan
    @app.use express.logger($config.config.logger)
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

    $config = @CI.config.config

    $theme ='default'
    $webroot = APPPATH+"themes/"+$theme+"/assets/"
    #
    # Expose asset folders
    #
    @app.set 'views', APPPATH + $config.views
    @app.use express.static(APPPATH+"themes/all/assets/")
    @app.use express.static($webroot)
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
      @app.use express.favicon(APPPATH+"themes/all/assets/" + $config.favicon)

    else
      @app.use express.favicon()

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
    
    @app.use express.bodyParser()
    @app.use express.methodOverride()
    @app.use $input.middleware()
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

    @app.use $uri.middleware()
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

    @app.use $session.middleware()
    @app.use express.cookieParser($session.encryption_key)


    #  Are we using a database?  If so, load it
    if $session.sess_use_database isnt false and $session.sess_table_name isnt ''

      if $session.sess_use_database is true
        @CI.load.database()
        $sess_driver = @CI.db.dbdriver
      else
        $sess_driver = parse_url($session.sess_use_database).scheme

      $found = false
      for $path in [BASEPATH, APPPATH]

        if file_exists($path+'libraries/Session/drivers/Session_'+$sess_driver+EXT)

          $found = true

          $driver = require($path+'libraries/Session/drivers/Session_'+$sess_driver+EXT)
          $store = new $driver($session)

          @app.use express.session
            secret:   $session.encryption_key
            maxAge:   Date.now() + ($session.sess_expiration * 1000)
            store:    $store

      if not $found

        show_error "Driver not found: Session_"+$sess_driver

        @app.use express.session(secret: $session.encryption_key)

    else

      @app.use express.session(secret: $session.encryption_key)

    return


  # --------------------------------------------------------------------

  #
  # 5xx Error Display
  #
  #   middleware error handler
  #
  #   @param {Object} $req
  #   @param {Object} $res
  #   @param {Function} $next
  #
  error_5xx: ->

    log_message 'debug',"5xx middleware initialized"
    #
    # Internal server error
    #
    ($err, $req, $res, $next) ->

      console.log $err
      # error page
      $res.status($err.status or 500).render 'errors/5xx'
      return


  # --------------------------------------------------------------------

  #
  # 404 Display
  #
  #   middleware page not found
  #
  #   @param {Object} $req
  #   @param {Object} $res
  #   @param {Function} $next
  #
  error_404: ->

    log_message 'debug',"404 middleware initialized"
    #
    # handle 404 not found error
    #
    ($req, $res, $next) ->

      $res.status(404).render 'errors/404', url: $req.originalUrl
      return


  # --------------------------------------------------------------------

  #
  # Authentication
  #
  #   middleware hook for authentication
  #
  #   @param {Object} $req
  #   @param {Object} $res
  #   @param {Function} $next
  #

  authenticate: ->

    log_message 'debug',"Authenticate middleware initialized"
    ($req, $res, $next) ->

      $next()


module.exports = CI_Server

# End of file Server.coffee
# Location: ./application/core/Server.coffee