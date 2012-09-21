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
#

#
# External dependencies.
#
express = require('express')            # Express 3.0 Server App

#
# load local modules
#
config = require('./application/config/config')       # settings
autoload = require('./application/config/autoload')   # application modules

##
#|--------------------------------------------------------------------------
#| Create the server application
#|--------------------------------------------------------------------------
#|
app = module.exports = express()

#
# Set configuration variables
#
app.set 'port', config.port
app.set 'site_name', config.site_name

#
# logging middleware
#
app.use express.logger(config.logger)

#|
#|--------------------------------------------------------------------------
#| Configure the web app environment
#|--------------------------------------------------------------------------
#|
if config.use_layouts
  app.use require('express-partials')() # use 2.x layout style

#
# use a templating engine?
#
if config.template is 'jade'
  app.set 'view engine', 'jade'

else
  consolidate = require('consolidate')    # for template support
  app.engine config.template, consolidate[config.template]
  app.set 'view engine', config.view_ext

#
# use css middleware?
#
if config.css is 'stylus'
  app.use require('stylus').middleware(__dirname + config.webroot)

else if config.css is 'less'
  app.use require('less-middleware')({ src: __dirname + config.webroot })

#
# the root folder for view templates
#
app.set 'views', __dirname + config.views

#
# the root folder for static assets
#
app.use express.static(__dirname + config.webroot)

#
# the favorites icon
#
if config.favicon?
  app.use express.favicon(__dirname + config.webroot + config.favicon)

else
  app.use express.favicon()


#|
#|--------------------------------------------------------------------------
#| Session Storage
#|--------------------------------------------------------------------------
#|


if config.sessions
  #
  # use a cookie encryption key?
  #
  if config.cookie_key?
    app.use express.cookieParser(config.cookie_key)

  else
    app.use express.cookieParser()
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

  app.use express.csrf()

#|
#|--------------------------------------------------------------------------
#| Core
#|--------------------------------------------------------------------------
#|
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.responseTime() # res.setHeader('X-Response-Time', duration + 'ms');

#|
#|--------------------------------------------------------------------------
#| Autoloaded modules
#|--------------------------------------------------------------------------
#|

#
# autoload helpers
#
for helper in autoload.helper
  require('./system/helpers/' + helper)(app, config)

#
# autoload models
#
for model in autoload.model
  require('./system/model/' + model)(app, config)

#
# autoload middleware
#
for middleware in autoload.middleware
  require('./system/middleware/' + middleware)(app, config)

#
# autoload controllers
#
require('./application/controllers/' + config.default_controller)(app, config)
for controller in autoload.controllers
  require('./application/controllers/' + controller)(app, config)



#|
#|--------------------------------------------------------------------------
#| Error handlers
#|--------------------------------------------------------------------------
#|
require('./system/middleware/5xx')(app, config)
require('./system/middleware/404')(app, config)

if app.get('env') is 'development'
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

if app.get('env') is 'production'
  app.use express.errorHandler()

app.use app.router

#|
#|--------------------------------------------------------------------------
#| Start it up...
#|--------------------------------------------------------------------------
#|
app.listen app.get('port'), ->

  console.log "DarkRoast/Express server listening on port %d", app.get('port')
  return

# End of file server.coffee
# Location: ./server.coffee