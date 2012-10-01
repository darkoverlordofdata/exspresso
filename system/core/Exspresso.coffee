#+--------------------------------------------------------------------+
#  Exspresso.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
# 
#  This file is a part of Exspresso
# 
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the GNU General Public License Version 3
# 
#+--------------------------------------------------------------------+
#
#	Boot an Express server using the Exspresso framework
#
#   http://0.0.0.0:5000/
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{array_merge, dirname, file_exists, is_dir, ltrim, realpath, rtrim, strrchr, trim, ucfirst} = require(FCPATH + 'helper')
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message} = require(BASEPATH + 'core/Common')


cache           = require('connect-cache')              # Caching system for Connect
express         = require('express')                    # Express 3.0 Framework
url             = require('url')                        # node.url
redis           = require('redis')                      # Redis client library.
connectRedis    = require('connect-redis')              # Redis session store for Connect.
middleware      = require(BASEPATH + 'core/Middleware') # Exspresso Middleware module

log_message "debug", "Exspresso copyright 2012 Dark Overlord of Data"

#
# ------------------------------------------------------
#  Create the server application
# ------------------------------------------------------
# 
app = module.exports = express()

#
# ------------------------------------------------------
#  Instantiate the config class
# ------------------------------------------------------
#
$config = load_class('Config', 'core')._config
do ($config) ->

  app.set 'env', ENVIRONMENT
  app.set 'port', $config.port
  app.set 'site_name', $config.site_name
  app.use express.logger($config.logger)

  if $config.sessions

    app.use express.cookieParser($config.cookie_key)
    #
    # use redis to store session data?
    #
    if $config.session_db is 'redis'

      $r   = url.parse $config.redis_url
      $client = redis.createClient $r.port, $r.hostname
      if $r.auth?
        $client.auth $r.auth.split(':')[1] # auth 1st part is username and 2nd is password separated by ":"


      RedisStore = connectRedis(express)
      app.use express.session
        secret:   $config.cookie_key
        maxAge:   new Date Date.now() + 7200000 # 2h Session lifetime
        store:    new RedisStore(client: $client)

    else

      app.use express.session()

  #
  # TODO: {BUG} 'express.csrf' fails
  # with Forbidden on route /travel/hotels
  #
  #app.use express.csrf()
  app.use express.bodyParser()
  app.use express.methodOverride()

  if $config.cache

    if app.get('env') is 'development'
      app.use cache
        rules: [{regex: /.*/, ttl: 3600000}]
        loopback: 'localhost:' + $config.port

    else
      app.use cache
        rules: [{regex: /.*/, ttl: 3600000}]


  if $config.use_layouts
    app.use require('express-partials')() # use 2.x layout style
  app.set 'views', APPPATH + $config.views
  app.use express.static(WEBROOT)
  if $config.template is 'jade'
    app.set 'view engine', 'jade'

  else
    consolidate = require('consolidate')    # for template support
    app.engine $config.template, consolidate[$config.template]
    app.set 'view engine', $config.view_ext
  if $config.css is 'stylus'
    app.use require('stylus').middleware(WEBROOT)

  else if $config.css is 'less'
    app.use require('less-middleware')({ src: WEBROOT })

  if $config.favicon?
    app.use express.favicon(WEBROOT + $config.favicon)

  else
    app.use express.favicon()

  app.use require('connect-flash')()
  app.use middleware.profiler()


#
# ------------------------------------------------------
#  Load the app controller and local controllers
# ------------------------------------------------------
#
#  Load the base controller class
#

require BASEPATH + 'core/Controller'

if file_exists(APPPATH + 'core/' + $config['subclass_prefix'] + 'Controller' + EXT)
  require APPPATH + 'core/' + $config['subclass_prefix'] + 'Controller' + EXT

#
# ------------------------------------------------------
#  Instantiate the routing class and set the routing
# ------------------------------------------------------
#
load_object('Router', 'core').set_routing()

#
# --------------------------------------------------------------------------
#  Start me up...
# --------------------------------------------------------------------------
# 
app.listen app.get('port'), ->

  console.log ""
  console.log ""
  console.log "Exspresso copyright 2012 Dark Overlord of Data"
  console.log ""
  console.log "listening on port #{app.get('port')}"
  console.log ""

  if ENVIRONMENT is 'development'
    console.log "View site at http://localhost:" + app.get('port')

  log_message "debug", "listening on port #{app.get('port')}"
  return


# End of file Exspresso.coffee
# Location: ./system/core/Exspresso.coffee