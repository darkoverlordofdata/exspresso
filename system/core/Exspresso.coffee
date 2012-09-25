#+--------------------------------------------------------------------+
#| server.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	Start an Express server using the Exspresso framework
#
#https://github.com/senchalabs/connect/wiki

{file_exists} = require('not-php')
{load_class, get_config, config_item} = require(BASEPATH + 'core/Common')

#
# External dependencies.
#
express   = require('express')                    # Express 3.0 Server App
dispatch  = require('dispatch')                   # Connect dispatch routing

#
# load application modules
#
config = require(APPPATH + 'config/config')       # application settings
routes = require(APPPATH + 'config/routes')       # application route mappings
autoload = require(APPPATH + 'config/autoload')   # application modules

##
#|--------------------------------------------------------------------------
#| Create the server application
#|--------------------------------------------------------------------------
#|
app = module.exports = express()

#|
#|--------------------------------------------------------------------------
#| Set configuration variables
#|--------------------------------------------------------------------------
#|
app.set 'port', config.port
app.set 'site_name', config.site_name
app.set 'env', ENVIRONMENT

#|
#|--------------------------------------------------------------------------
#| Setup logging
#|--------------------------------------------------------------------------
#|
app.use express.logger(config.logger)

#|
#|--------------------------------------------------------------------------
#| Configure the web app environment
#|--------------------------------------------------------------------------
#|
if config.use_layouts
  app.use require('express-partials')() # use 2.x layout style

#|
#|--------------------------------------------------------------------------
#| Set templating engine for dynamic content
#|--------------------------------------------------------------------------
#|
if config.template is 'jade'
  app.set 'view engine', 'jade'

else
  consolidate = require('consolidate')    # for template support
  app.engine config.template, consolidate[config.template]
  app.set 'view engine', config.view_ext

#|
#|--------------------------------------------------------------------------
#| Load css middleware?
#|--------------------------------------------------------------------------
#|
if config.css is 'stylus'
  app.use require('stylus').middleware(WEBROOT)

else if config.css is 'less'
  app.use require('less-middleware')({ src: WEBROOT })

#|
#|--------------------------------------------------------------------------
#| Static and dynamic content roots
#|--------------------------------------------------------------------------
#|
app.set 'views', APPPATH + config.views
app.use express.static(WEBROOT)

#|
#|--------------------------------------------------------------------------
#| Set favourites icon
#|--------------------------------------------------------------------------
#|
if config.favicon?
  app.use express.favicon(WEBROOT + config.favicon)

else
  app.use express.favicon()


#|
#|--------------------------------------------------------------------------
#| Session Storage
#|--------------------------------------------------------------------------
#|
if config.sessions

  app.use express.cookieParser(config.cookie_key)
  #
  # use redis to store session data?
  #
  if config.session_db is 'redis'

    r   = require('url').parse config.redis_url
    redis = require('redis').createClient r.port, r.hostname
    if r.auth?
      redis.auth r.auth.split(':')[1] # auth 1st part is username and 2nd is password separated by ":"


    RedisStore = require('connect-redis')(express)
    app.use express.session
      secret:   config.cookie_key
      maxAge:   new Date Date.now() + 7200000 # 2h Session lifetime
      store:    new RedisStore(client: redis)

  else

    app.use express.session()

  #app.use express.csrf()

#|
#|--------------------------------------------------------------------------
#| Core
#|--------------------------------------------------------------------------
#|
app.use express.bodyParser()
app.use express.methodOverride()
#app.use express.responseTime() # res.setHeader('X-Response-Time', duration + 'ms');

#|
#|--------------------------------------------------------------------------
#| Cacheing
#|--------------------------------------------------------------------------
#|
if config.cache

  cache = require('connect-cache')
  if app.get('env') is 'development'
    app.use cache
      rules: [{regex: /.*/, ttl: 3600000}]
      loopback: 'localhost:' + config.port

  else
    app.use cache
      rules: [{regex: /.*/, ttl: 3600000}]


#|
#|--------------------------------------------------------------------------
#| Autoload helpers
#|--------------------------------------------------------------------------
#|
for helper in autoload.helper

  f = BASEPATH + 'helpers/' + helper + '.coffee'
  if file_exists(f)
    require(f)(app)

  f = APPPATH + 'helpers/' + helper + '.coffee'
  if file_exists(f)
    require(f)(app)

#|
#|--------------------------------------------------------------------------
#| Autoload models
#|--------------------------------------------------------------------------
#|
models = {}
for model in autoload.model
  models[model] = require(APPPATH + 'models/' + model)

#|
#|--------------------------------------------------------------------------
#| Autoload middleware
#|--------------------------------------------------------------------------
#|
app.use require('connect-flash')()

for middleware in autoload.middleware

  f = BASEPATH + 'middleware/' + middleware + '.coffee'
  if file_exists(f)
    require(f)(app)

  f = APPPATH + 'middleware/' + middleware + '.coffee'
  if file_exists(f)
    require(f)(app)

if app.get('env') is 'development'
  require(BASEPATH + 'middleware/profiler')(app)
#
# ------------------------------------------------------
#  Load the app controller and local controllers
# ------------------------------------------------------
#
#
#  Load the base controller class
require BASEPATH + 'core/Controller'

if file_exists(APPPATH + 'core/' + config['subclass_prefix'] + 'Controller' + EXT)
  require APPPATH + 'core/' + config['subclass_prefix'] + 'Controller' + EXT


#
# ------------------------------------------------------
#  Collect each route mapping
# ------------------------------------------------------
#
#   Make it consumable by the dispatch middleware
#
urls = {} # dispatch urls
for url, uri of routes

  #
  # ------------------------------------------------------
  # Special cases
  # ------------------------------------------------------
  #
  if url is '404_override' then continue
  if url is 'default_controller' then url = "/"

  #
  # ------------------------------------------------------
  #  Parse the uri
  # ------------------------------------------------------
  #
  segments = uri.split('/')
  $method = segments.pop()

  #
  # ------------------------------------------------------
  #  Security check
  # ------------------------------------------------------
  #
  #  controller functions that begin with an underscore
  #  cannot be invoked using the uri
  #
  if $method[0] is '_'
    console.log "Can't call private methods: #{$method}"
    continue

  #
  # ------------------------------------------------------
  #  Load the controller
  # ------------------------------------------------------
  #
  $directory = segments.join('/')
  $path = APPPATH + 'controllers/' + $directory
  if not file_exists($path + EXT)
    console.log "Controller #{$directory} not found"
    continue

  $class = require($path)
  $object = new $class()

  #
  # ------------------------------------------------------
  #  Call the requested method
  # ------------------------------------------------------
  #
  if not $object[$method]?
    console.log "No method #{$method} of #{$path}"
    continue

  $function = $object[$method]

  #
  # ------------------------------------------------------
  #  Wrap the call
  # ------------------------------------------------------
  #
  #   The call is deferred until the url is recieved
  #   from the browser. Wrapping it in a closure protects
  #   the value of $function. Otherwise, all urls will map
  #   to the last uri in routes.
  #
  do ($object, $function) ->

    #
    # Anonymous function
    #
    #   Recieves a call from the dispatch middleware
    #
    #   @param {Object} the server request object
    #   @param {Object} the server response object
    #   @param {Functin} the next middleware on the stack
    #   @param {Array} the remaining arguments
    #
    urls[url] = (req, res, next, args...) ->

      #
      # Patch the object
      #
      $object.req       = req # request object
      $object.res       = res # response object
      $object.render    = res.render  # shortcut

      $object.load = {}
      # @load.model('travel')
      # @travel.Hotels...
      #
      #
      # Call the requested method.
      # Any URI segments present (besides the class/function) will be passed to the method for convenience
      #
      $function.apply $object, args


app.use dispatch(urls)


#|
#|--------------------------------------------------------------------------
#| Error handlers
#|--------------------------------------------------------------------------
#|
require(BASEPATH + 'middleware/5xx')(app)
require(BASEPATH + 'middleware/404')(app)

if app.get('env') is 'development'
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

if app.get('env') is 'production'
  app.use express.errorHandler()

app.use app.router

#|
#|--------------------------------------------------------------------------
#| Start me up...
#|--------------------------------------------------------------------------
#|
app.listen app.get('port'), ->

  console.log "Exspresso server listening on port %d", app.get('port')

  console.log "Visit at http://localhost:" + app.get('port')
  return

# End of file server.coffee
# Location: ./server.coffee