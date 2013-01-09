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

class global.CI_Server

  _cache        : false
  _csrf         : false
  _logger       : 'dev'
  _port         : 3000
  _preview      : false
  _site_name    : 'My Site'
  _site_slogan  : 'My Slogan'

  #  --------------------------------------------------------------------

  #
  # Set server config
  #
  # @access	public
  # @return	void
  #
  constructor: ($config) ->

    log_message('debug', "Server Class Initialized")

    #
    # get the config values
    #
    if not empty($config)
      for $key, $var of $config
        @['_'+$key] = $var
    #
    # get command line switches
    #
    for $arg in process.argv
      switch $arg
        when '--cache'    then @_cache = true
        when '--csrf'     then @_csrf = true
        when '--preview'  then @_preview = true
    #
    # the Expresso core instance
    #
    @CI = get_instance()



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

    @_cache       = false
    @_csrf        = false
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
  # @param	object $OUT
  # @return	void
  #
  output: ($output) ->

    @app.use $output.middleware()

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
    
    @app.use $input.middleware()

  #  --------------------------------------------------------------------

  #
  # URI registration
  #
  #   called by the core/URI class constructor
  #
  # @access	public
  # @param	object $URI
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
    ($err, $req, $res, $next) =>

      $err.status = $err.status || 500
      $error =
        code:     $err.status
        desc:     set_status_header($err.status)
        level:    if $err.status >= 500 then 'error' else 'info'
        message:  ($err.stack || '').split('\n')[0]
        stack:    ($err.stack || '').split('\n').slice(1).map((v) ->
          return '<li>' + v + '</li>' ).join('')

      $res.render APPPATH+'views/errors/5xx.eco', err: $error, ($err, $content) =>
        $res.render APPPATH+'views/errors/layout.eco',
          title:      $error.code + ': ' + $error.desc
          content:    $content
          site_name:  @_site_name



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
    ($req, $res, $next) =>

      $res.render APPPATH+'views/errors/404.eco', originalUrl: $req.originalUrl, ($err, $content) =>
        $res.render APPPATH+'views/errors/layout.eco',
          title:      '404: Not Found'
          content:    $content
          site_name:  @_site_name

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


module.exports = CI_Server

# End of file Server.coffee
# Location: ./application/core/Server.coffee