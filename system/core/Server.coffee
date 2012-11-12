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
#   this class is an adapter to the inner express app
#   it exposes adapter registration points for each of these core classes:
#
#       * Config
#       * Output
#       * Input
#       * Session
#
dispatch        = require('dispatch')                   # URL dispatcher for Connect
express         = require('express')                    # Web development framework 3.0

class global.CI_Server

  #  --------------------------------------------------------------------

  #
  # get server instance
  #
  # @access	public
  # @return	void
  #
  constructor: ->

    @CI = get_instance()        # the Expresso core instance
    @app = express()            # inner express object

  #  --------------------------------------------------------------------

  #
  # Start me up ...
  #
  # @access	public
  # @return	void
  #
  start: ($router) ->

    load = load_class('Loader', 'core')
    load.initialize @CI, true  # Autoload
    @app.use load_class('Exceptions',  'core').middleware()
    @app.use @authenticate()
    @app.use @app.router
    @app.use @error_5xx()
    @app.use dispatch($router.routes)
    @app.use @error_404()

    if @app.get('env') is 'development'
      @app.use express.errorHandler
        dumpExceptions: true
        showStack: true

    if @app.get('env') is 'production'
      @app.use express.errorHandler()

    @app.listen @app.get('port'), =>

      console.log " "
      console.log " "
      console.log "Exspresso v"+CI_VERSION
      console.log "copyright 2012 Dark Overlord of Data"
      console.log " "
      console.log "listening on port #{@app.get('port')}"
      console.log " "

      if @app.get('env') is 'development'
        console.log "View site at http://localhost:" + @app.get('port')

      log_message "debug", "listening on port #{@app.get('port')}"
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

    @app.set 'env', ENVIRONMENT
    @app.set 'port', $config.config.port
    @app.set 'site_name', $config.config.site_name
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

    if $config.use_layouts
      @app.use require('express-partials')() # use 2.x layout style

    #
    # Expose folders
    #
    @app.set 'views', APPPATH + $config.views
    @app.use express.static(WEBROOT)

    #
    # Use Jade templating?
    #
    if $config.template is 'jade'
      @app.set 'view engine', 'jade'

      #
      # Use some other templating?
      #
    else
      consolidate = require('consolidate')    # for template support
      @app.engine $config.view_ext, consolidate[$config.template]
      @app.set 'view engine', $config.template

    if $config.use_layouts
      require('express-partials').register($config.view_ext, $config.template)

    #
    # CSS asset middleware
    #
    if $config.css is 'stylus'
      @app.use require('stylus').middleware(WEBROOT)

    else if $config.css is 'less'
      @app.use require('less-middleware')({ src: WEBROOT })

    #
    # Favorites icon
    #
    if $config.favicon?
      @app.use express.favicon(WEBROOT + $config.favicon)

    else
      @app.use express.favicon()

    #
    # Profiler
    #
    @app.use @profiler($output)
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

        @app.use express.session()

    else

      @app.use express.session()

    return


  # --------------------------------------------------------------------

  #
  # Controller binding
  #
  #   Routing call back to invoke the controller when the request is received
  #
  #   @param object $class
  #   @param string method
  #   @return function
  #
  controllerz: ($class, $method) ->

    #
    # Invoke the contoller
    #
    #   Instantiates the controller and calls the requested method.
    #   Any URI segments present (besides the class/function) will be passed
    #   to the method for convenience
    #
    #   @param {Object} the server request object
    #   @param {Object} the server response object
    #   @param {Function} the next middleware on the stack
    #   @param {Array} the remaining arguments
    #
    ($req, $res, $next, $args...) ->

      # a new copy of the controller class for each request:
      $CI = new $class()

      $CI.redirect = ($path) -> $res.redirect $path

      if $CI.db?
        $CI.db.initialize -> $CI[$method].apply $CI, $args
      else
        $CI[$method].apply $CI, $args

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

  # --------------------------------------------------------------------

  #
  # Profile
  #
  #   middleware profile metrics collector
  #
  #   @param {Object} $req
  #   @param {Object} $res
  #   @param {Function} $next
  #
  profiler: ($output) ->

    log_message 'debug',"Profiler middleware initialized"
    #
    # profiler middleware
    #
    #   @param {Object} server request object
    #   @param {Object} server response object
    #   @param {Object} $next middleware
    #
    ($req, $res, $next) ->

      if $output.parse_exec_vars is false
        return $next()
      #
      # profile snapshot
      #
      snapshot = ->

        mem: process.memoryUsage()
        time: new Date

      $start = snapshot() # starting metrics

      #
      # link our custom render function into the call chain
      #
      $render = $res.render
      $res.render = ($view, $data) ->

        $res.render = $render
        $data = $data ? {}

        #
        # callback with rendered output
        #
        $res.render $view, $data, ($err, $html) ->

          $end = snapshot()
          $elapsed_time = $end.time - $start.time
          #
          # TODO: what if there is an $err value?
          #
          # replace metrics in output:
          #
          #   {elapsed_time}
          #   {memory_usage}
          #
          if $html?
            $res.send $html.replace(/{elapsed_time}/g, $elapsed_time)
          return

      $next()
      return



module.exports = CI_Server

# End of file Server.coffee
# Location: ./system/core/Server.coffee