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
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#  ------------------------------------------------------------------------
#
#	  Server Class
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
  os            = require('os')         # A few basic operating-system related utility functions

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

      $next (null) if $queue.length is 0
      #
      # call the function at index
      #
      $function = $queue[$index]
      $function ($err) ->
        return $next($err) if $err
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

    @app.use @server()
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
      $options['store'] = $session.load_driver($session.sess_driver).install_check()

    @app.use $server.session($options)
    @app.use $session.parse_request($session.cookie_prefix + $session.sess_cookie_name)
    @app.use $server.csrf() if @_csrf
    return


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


  #
  # Patch the express server objects
  #
  #   fabricate a table similar to $_SERVER
  #
  # @access	public
  # @param object
  # @param object
  # @param function
  # @return	void
  #
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
      SERVER_SOFTWARE       : @get_version()+" (" + os.type() + '/' + os.release() + ") Node.js " + process.version

    for $key, $val of $req.headers
      $_SERVER['HTTP_'+$key.toUpperCase().replace('-','_')] = $val

    $req.server = freeze($_SERVER)

    $next()

module.exports = Exspresso_Server

# End of file Server.coffee
# Location: ./application/core/Server.coffee