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
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#  ------------------------------------------------------------------------
#
#	  Server Class
#
#   Base class for Servers
#

class system.core.Server

  dispatch      = require('dispatch')   # URL dispatcher for Connect
  os            = require('os')         # A few basic operating-system related utility functions

  #
  # config settings
  #

  _port         : 3000
  _logger       : 'dev'
  _site_name    : 'My Site'
  _site_slogan  : 'My Slogan'
  _queue        : null


  #
  # Set server config
  #
    # @return [Void]  #
  constructor: ($config, @app) ->

    log_message('debug', "Server Class Initialized")

    @_queue = []
    #
    # get the config values
    #
    #if not empty($config)
    #  for $key, $var of $config
    #    @['_'+$key] = $var

    @config get_config()


  #
  # Add view helpers
  #
    # @return [Void]  #
  setHelpers: ($helpers) -> # abstract method

  #
  # Start me up ...
  #
    # @return [Void]  #
  start: ($router, $next) ->

    @app.use @server()
    exspresso.load.initialize()
    @app.use core('Exceptions').exception_handler()
    @app.use dispatch($router.routes)
    exspresso.run ($err) ->
      $next($err)


  #
  # Banner
  #
  #   display a startup banner
  #
    # @param  [Object]  exspresso.config
  # @return [Void]  #
  banner: ->

    $elapsed = core('Benchmark').elapsedTime('boot_time_start', 'boot_time_end')
    log_message 'debug', 'Boot time: %dms', $elapsed
    log_message "debug", "Listening on port #{@_port}"
    log_message "debug", "e x s p r e s s o  v%s", exspresso.version
    log_message "debug", "copyright 2012-2013 Dark Overlord of Data"
    log_message "debug", "%s environment started", ucfirst(ENVIRONMENT)
    if ENVIRONMENT is 'development'
      log_message "debug", "View at http://localhost:" + @_port

    return

  #
  # Config registration
  #
  #   called by the core/Config class constructor
  #
    # @param  [Object]  exspresso.config
  # @return [Void]  #
  config: ($config) ->

    @_logger      = $config.logger
    @_port        = $config.port
    @_site_name   = $config.site_name
    @_site_slogan = $config.site_slogan


  #
  # Sessions 
  #
  #   Callback from lib/Session constructor to
  #   initialize session support
  #
    # @param  [Object]    # @return [Void]  #
  session: ($session) ->

    $server = require(exspresso.httpDriver)
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
      $options['store'] = $session.loadDriver($session.sess_driver).installCheck()

    @app.use $server.session($options)
    @app.use $session.parseRequest($session.cookie_prefix + $session.sess_cookie_name)
    return


  #
  # 5xx Error Display
  #
  #   middleware error handler
  #
  # @param  [Object]  $req
  # @param  [Object]  $res
  #   @param function $next
  #
  error_5xx: ->

    log_message 'debug',"5xx middleware initialized"
    #
    # Internal server error
    #
    ($err, $req, $res, $next) -> show_error $err


  #
  # 404 Display
  #
  #   middleware page not found
  #
  # @param  [Object]  $req
  # @param  [Object]  $res
  #   @param function $next
  #
  error_404: ->

    log_message 'debug',"404 middleware initialized"
    #
    # handle 404 not found error
    #
    ($req, $res, $next) -> show_404 $req.originalUrl


  #
  # Patch the express server objects
  #
  #   fabricate a table similar to $_SERVER
  #
    # @param  [Object]    # @param  [Object]    # @param  [Function]    # @return [Void]  #
  server: -> ($req, $res, $next) =>


    $_SERVER =
      argv                  : $req.query
      argc                  : count($req.query)
      CONTENT_TYPE          : $req.headers['content-type']
      DOCUMENT_ROOT         : process.cwd()
      HTTP_ACCEPT           : $req.headers['accept']
      HTTP_ACCEPT_CHARSET   : $req.headers['accept-charset']
      HTTP_ACCEPT_ENCODING  : $req.headers['accept-encoding']
      HTTP_ACCEPT_LANGUAGE  : $req.headers['accept-language']
      HTTP_CLIENT_IP        : ($req.headers['x-forwarded-for'] || '').split(',')[0]
      HTTP_CONNECTION       : $req.headers['connection']
      HTTP_HOST             : $req.headers['host']
      HTTP_REFERER          : $req.headers['referer']
      HTTP_USER_AGENT       : $req.headers['user-agent']
      HTTPS                 : if $req.secure then 'on' else 'off'
      ORIG_PATH_INFO        : $req.path
      PATH_INFO             : $req.path
      QUERY_STRING          : if $req.url.split('?')[1]? then $req.url.split('?')[1] else ''
      REMOTE_ADDR           : $req.connection.remoteAddress
      REMOTE_HOST           : ''
      REMOTE_PORT           : ''
      REMOTE_USER           : ''
      REQUEST_METHOD        : $req.method
      REQUEST_TIME          : $req._startTime
      REQUEST_URI           : $req.url
      SERVER_ADDR           : $req.ip
      SERVER_NAME           : $req.host
      SERVER_PORT           : ''+@_port
      SERVER_PROTOCOL       : strtoupper($req.protocol)+"/"+$req.httpVersion
      SERVER_SOFTWARE       : exspresso.version+" (" + os.type() + '/' + os.release() + ") Node.js " + process.version

    for $key, $val of $req.headers
      $_SERVER['HTTP_'+$key.toUpperCase().replace('-','_')] = $val

    $req.server = freeze($_SERVER)

    $next()

module.exports = system.core.Server

# End of file Server.coffee
# Location: ./system/core/Server.coffee