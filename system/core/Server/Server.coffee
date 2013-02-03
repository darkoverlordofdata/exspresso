#+--------------------------------------------------------------------+
#| Server.coffee
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
#	Server Class
#
#   Base class for Server/drivers
#   it exposes adapter registration points for each of these core classes:
#
#       * Config
#       * Output
#       * Input
#       * Session
#       * URI
#
dispatch        = require('dispatch')   # URL dispatcher for Connect

class global.Exspresso_Server

  urldecode   = decodeURIComponent
  #
  # config settings
  #
  _driver       : 'express'
  _db           : 'mysql'
  _cache        : false
  _csrf         : false
  _preview      : false
  _profile      : false
  _port         : 3000
  _logger       : 'dev'
  _site_name    : 'My Site'
  _site_slogan  : 'My Slogan'
  _queue        : null

  #  --------------------------------------------------------------------

  #
  # Load the driver subclass
  #
  # @access	public
  # @param string   Driver name <express|connect|appjs>
  # @param object   config array
  # @return	object
  #
  @load = ($driver, $args...) ->
    $class = require(BASEPATH+'core/Server/drivers/Server_'+$driver)
    new $class($args...)

  #  --------------------------------------------------------------------

  #
  # Set server config
  #
  # @access	public
  # @return	void
  #
  constructor: ($config, @app) ->

    log_message('debug', "Server Class Initialized")

    @_queue = []
    #
    # get the config values
    #
    if not empty($config)
      for $key, $var of $config
        @['_'+$key] = $var

    #
    # get the command line options
    #
    @_profile = if ENVIRONMENT is 'development' then true else false
    $set_db = false
    for $arg in $argv
      if $set_db is true
        @_db = $arg
        $set_db = false

      switch $arg
        when '--db'         then $set_db    = true
        when '--cache'      then @_cache    = true
        when '--csrf'       then @_csrf     = true
        when '--preview'    then @_preview  = true
        when '--profile'    then @_profile  = true
        when '--nocache'    then @_cache    = false
        when '--nocsrf'     then @_csrf     = false
        when '--noprofile'  then @_profile  = false
    #
    # the Expresso core instance
    #
    @config get_config()


  #  --------------------------------------------------------------------

  #
  # Add view helpers
  #
  # @access	public
  # @return	void
  #
  set_helpers: ($helpers) -> # abstract method

  #  --------------------------------------------------------------------

  #
  # Get the driver version
  #
  # @access	public
  # @return	void
  #
  get_version: () ->
    @_driver + ' v' + require(process.cwd()+'/node_modules/'+@_driver+'/package.json').version


  #  --------------------------------------------------------------------

  #
  # Add a function to the async queue
  #
  # @access	public
  # @return	void
  #
  queue: ($fn) ->
    if $fn then @_queue.push($fn) else @_queue

  #  --------------------------------------------------------------------

  #
  # Run the async queue
  #
  # @access	public
  # @return	void
  #
  run: ($queue, $next) ->

    if typeof $next isnt 'function'
      [$queue, $next] = [@_queue, $queue]

    $index = 0
    $iterate = ->

      if $queue.length is 0 then $next null
      else
        #
        # call the function at index
        #
        $fn = $queue[$index]
        $fn ($err)->
          if $err
            log_message 'debug', 'Server::run'
            console.log $err
            return $next $err

          $index += 1
          if $index is $queue.length then $next null
          else $iterate()

    $iterate()

  #  --------------------------------------------------------------------

  #
  # Start me up ...
  #
  # @access	public
  # @return	void
  #
  start: ($router, $next) ->

    Exspresso.load.initialize()
    @app.use load_class('Exceptions',  'core').middleware()
    @app.use dispatch($router.routes)
    @run Exspresso.queue().concat(@queue()), ($err) ->
      $next($err)




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

    @_logger      = $config.logger
    @_port        = $config.port
    @_site_name   = $config.site_name
    @_site_slogan = $config.site_slogan


  #  --------------------------------------------------------------------

  #
  # Sessions 
  #
  #   called by the libraries/Session/Session class constructor
  #
  # @access	public
  # @param	object
  # @return	void
  #
  session: ($session) ->

    $driver = require(@_driver)
    @app.use $driver.cookieParser($session.encryption_key)
    #  Are we using a database?  If so, load it
    if $session.sess_use_database isnt false and $session.sess_table_name isnt ''

      if $session.sess_use_database is true
        $sess_store = 'sql'
      else
        $sess_store = parse_url($session.sess_use_database).scheme

      $found = false
      for $path in [BASEPATH, APPPATH]

        if file_exists($path+'libraries/Session/drivers/Session_'+$sess_store+EXT)

          $found = true

          $store_driver = require($path+'libraries/Session/drivers/Session_'+$sess_store+EXT)
          $store = new $store_driver($session)
          $store.setup()

          @app.use $driver.session
            secret    : $session.encryption_key
            store     : $store
            cookie:
                        domain    : $session.cookie_domain
                        path      : $session.cookie_path
                        name      : $session.sess_cookie_name
                        secure    : $session.cookie_secure
                        maxAge    : $session.sess_expiration

      log_message('error', "Driver not found: Session_%s", $sess_store) if not $found

    else

      @app.use $driver.session
        secret    : $session.encryption_key
        cookie:
                    domain    : $session.cookie_domain
                    path      : $session.cookie_path
                    name      : $session.sess_cookie_name
                    secure    : $session.cookie_secure
                    maxAge    : $session.sess_expiration


    @app.use @session_middleware($session.cookie_prefix + $session.sess_cookie_name)
    @app.use $driver.csrf() if @_csrf
    return

  # --------------------------------------------------------------------

  #
  # Session middleware
  #
  #   @returns function middlware callback
  #
  session_middleware: ($cookie_name) =>

    log_message 'debug',"session middleware initialized [%s]", $cookie_name

    #  --------------------------------------------------------------------

    #
    # Patch the session object
    #
    # @access	private
    # @return	void
    #
    ($req, $res, $next) ->

      # set reasonable session defaults
      $req.session.uid            = $req.session.uid || 1
      $req.session.ip_address     = ($req.headers['x-forwarded-for'] || '').split(',')[0] || $req.connection.remoteAddress
      $req.session.user_agent     = $req.headers['user-agent']
      $req.session.last_activity  = (new Date()).getTime()
      $req.session.userdata       = $req.session.userdata || {}

      if $req.headers.cookie?
        $m = preg_match("/#{$cookie_name}=([^ ,;]*)/", $req.headers.cookie)
        if $m?
          $m = $m[1].split('.')[0]
          $req.session.session_id = urldecode($m).split(':')[1]

      #  --------------------------------------------------------------------

      #
      #   Get user data
      #
      Exspresso.db.reconnect ($err) ->

        return $next($err) if log_message('error', 'Server::session middleware %s', $err) if $err
        Exspresso.db.where 'uid', $req.session.uid
        Exspresso.db.get 'users', ($err, $result) ->

          return $next($err) if log_message('error', 'Server::session middleware %s', $err) if $err
          $user = $result.row()
          delete $user.password
          delete $user.salt

          #  --------------------------------------------------------------------

          #
          # User
          #
          #   return logged in user data
          #
          $req.user = () -> $user
          $next()

  # --------------------------------------------------------------------

  #
  # 5xx Error Display
  #
  #   middleware error handler
  #
  #   @param object $req
  #   @param object $res
  #   @param function $next
  #
  error_5xx: ->

    log_message 'debug',"5xx middleware initialized"
    #
    # Internal server error
    #
    ($err, $req, $res, $next) -> show_error $err


  # --------------------------------------------------------------------

  #
  # 404 Display
  #
  #   middleware page not found
  #
  #   @param object $req
  #   @param object $res
  #   @param function $next
  #
  error_404: ->

    log_message 'debug',"404 middleware initialized"
    #
    # handle 404 not found error
    #
    ($req, $res, $next) -> show_404 $req.originalUrl

  # --------------------------------------------------------------------

  #
  # Authentication
  #
  #   middleware hook for authentication
  #
  #   @param object $req
  #   @param object $res
  #   @param function $next
  #

  authenticate: ->

    log_message 'debug',"Authentication middleware initialized"
    ($req, $res, $next) ->

      $next()

module.exports = Exspresso_Server

# End of file Server.coffee
# Location: ./application/core/Server.coffee