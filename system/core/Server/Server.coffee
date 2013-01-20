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

  _running      : false
  _port         : 3000
  _logger       : 'dev'
  _site_name    : 'My Site'
  _site_slogan  : 'My Slogan'
  _config       : null

  #  --------------------------------------------------------------------

  #
  # Set server config
  #
  # @access	public
  # @return	void
  #
  constructor: ($config, @app) ->

    log_message('debug', "Server Class Initialized")

    #
    # get the config values
    #
    if not empty($config)
      for $key, $var of $config
        @['_'+$key] = $var
    #
    # the Expresso core instance
    #
    @CI = Exspresso
    @config Exspresso.config


  #  --------------------------------------------------------------------

  #
  # Add view helpers
  #
  # @access	public
  # @return	void
  #
  set_helpers: ($helpers) -> # abstract method



  get_version: () ->
    @_driver + ' v' + require(process.cwd()+'/node_modules/'+@_driver+'/package.json').version


  #  --------------------------------------------------------------------

  #
  # Start me up ...
  #
  # @access	public
  # @return	void
  #
  start: ($router, $autoload = true) ->

    @CI.load = load_driver('Loader', 'core', Exspresso__MVC)
    @CI.load.initialize @CI, $autoload
    @app.use load_class('Exceptions',  'core').middleware()
    @app.use dispatch($router.routes)
    @_running = true
    log_message 'debug', 'Exspresso boot sequence complete'


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

    @_config      = $config
    @_logger      = $config.config.logger
    @_port        = $config.config.port
    @_site_name   = $config.config.site_name
    @_site_slogan = $config.config.site_slogan


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

    $output.enable_profiler Exspresso__PROFILE
    @app.use $output.middleware(@_config)

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
    
    @app.use $input.middleware(@_config)

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

    @app.use $uri.middleware(@_config)

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

    @app.use $session.middleware(@_config)


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