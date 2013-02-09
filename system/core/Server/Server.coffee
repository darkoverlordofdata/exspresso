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

class global.Exspresso_Server

  dispatch      = require('dispatch')   # URL dispatcher for Connect
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
    @app.use load_class('Exceptions',  'core').exception_handler()
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
  #   called by the Session driver constructor
  #
  # @access	public
  # @param	object
  # @return	void
  #
  session: ($session) ->

    $server = require(@_driver) # connect | express
    @app.use $server.cookieParser($session.encryption_key)

    # Session middleware options
    $options =
      secret    : $session.encryption_key
      cookie:
          domain    : $session.cookie_domain
          path      : $session.cookie_path
          name      : $session.sess_cookie_name
          secure    : $session.cookie_secure
          maxAge    : $session.sess_expiration

    #  Are we using a database?  If so, load the driver
    if $session.sess_use_database
      $options['store'] = $session.load_driver($session.sess_driver).setup()

    @app.use $server.session($options)
    @app.use $session.parse()
    @app.use $server.csrf() if @_csrf
    return


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