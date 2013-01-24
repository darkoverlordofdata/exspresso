#+--------------------------------------------------------------------+
#| Server.coffee
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
        $db = $arg
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
  _run: ($queue, $next) ->

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
  start: ($router, $autoload = true, $next) ->

    Exspresso.load = load_class('Loader', 'core')
    Exspresso.load.initialize Exspresso, $autoload
    @app.use load_class('Exceptions',  'core').middleware()
    @app.use dispatch($router.routes)
    @_run Exspresso.queue().concat(@queue()), ($err) ->
      if not $err then $next()


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
      Exspresso.db.table_exists 'ex_sessions', ($err, $table_exists) ->

        if $err then return $next $err
        if $table_exists then return $next null

        Exspresso.load.dbforge()
        Exspresso.dbforge.add_field
          session_id:
            type: 'VARCHAR'
            constraint: 40
            default: '0'
            null: false
          ip_address:
            type: 'VARCHAR'
            constraint: 45
            default: '0'
            null: false
          user_agent:
            type: 'VARCHAR'
            constraint: 255
            null: false
          last_activity:
            type: 'INT'
            constraint: 10
            unsigned: true
            default: 0
            null: false
          user_data:
            type: ' TEXT'
            null: false

        Exspresso.dbforge.add_key 'last_activity'
        Exspresso.dbforge.add_key 'session_id', true
        Exspresso.dbforge.create_table 'ex_sessions', $next


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
  # Output registration
  #
  #   called by the core/Output class constructor
  #
  # @access	public
  # @param	object Exspresso.output
  # @return	void
  #
  output: ($output) ->

    $output.enable_profiler @_profile
    @app.use $output.middleware()

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
    
    @app.use $input.middleware()

  #  --------------------------------------------------------------------

  #
  # URI registration
  #
  #   called by the core/URI class constructor
  #
  # @access	public
  # @param	object Exspresso.uri
  # @return	void
  #
  uri: ($uri) ->

    @app.use $uri.middleware()

  #  --------------------------------------------------------------------

  #
  # Sessions registration
  #
  #   called by the libraries/Session/Session class constructor
  #
  # @access	public
  # @param	object $SESSION
  # @return	void
  #
  session: ($session) ->

    @app.use $session.middleware()


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

    log_message 'debug',"Authenticate middleware initialized"
    ($req, $res, $next) ->

      $next()

module.exports = Exspresso_Server

# End of file Server.coffee
# Location: ./application/core/Server.coffee