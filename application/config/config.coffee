#+--------------------------------------------------------------------+
#| config.coffee
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
#	config - Main application
#

##
#|--------------------------------------------------------------------------
#| Site Name
#|--------------------------------------------------------------------------
#|
#| the site name
#|
##
exports['site_name'] = 'Dark Overlord of Data'

##
#|--------------------------------------------------------------------------
#| Favorites Icon
#|--------------------------------------------------------------------------
#|
#| Path to application icon
#|
##
exports['favicon'] = '/icons/favicon.png'

##
#|--------------------------------------------------------------------------
#| Default Controller
#|--------------------------------------------------------------------------
#|
#| Default controller - url =  '/'
#|
##
exports['default_controller'] = 'welcome'

##
#|--------------------------------------------------------------------------
#| WebRoot
#|--------------------------------------------------------------------------
#|
#| Root folder for static assets
#|
##
exports['webroot'] = '/public'

##
#|--------------------------------------------------------------------------
#| Port
#|--------------------------------------------------------------------------
#|
#| Port used by node server
#|
##
exports['port'] = process.env.PORT || 3000

##
#|--------------------------------------------------------------------------
#| Logger
#|--------------------------------------------------------------------------
#|
#| Logger format
#|
##
exports['logger'] = 'dev'

##
#|--------------------------------------------------------------------------
#| Views folder
#|--------------------------------------------------------------------------
#|
#| Path to the views folder
#|
##
exports['views'] = '/application/views'

##
#|--------------------------------------------------------------------------
#| Template Engine
#|--------------------------------------------------------------------------
#|
#| The consolidate templating engine to use:
#|
#|    jade
#|    dust
#|    swig
#|    liquor
#|    ejs
#|    eco
#|    jazz
#|    jqtpl
#|    haml
#|    whiskers
#|    haml-coffee
#|    hogan
#|    handlebars
#|    underscore
#|    qejs
#|    walrus
#|    mustache
#|    dot
#|
##
exports['template'] = 'jade'

##
#|--------------------------------------------------------------------------
#| View Extension
#|--------------------------------------------------------------------------
#|
#| The default file extension used for view templates
#|
##
exports['view_ext'] = 'jade'

##
#|--------------------------------------------------------------------------
#| Use Layout
#|--------------------------------------------------------------------------
#|
#| Layout strategy
#|
#|    true              use Express.js 2.x layouts
#|    false             use Templating Engine default style
#|
exports['use_layouts'] = false

##
#|--------------------------------------------------------------------------
#| Use CSS Middleware?
#|--------------------------------------------------------------------------
#|
#| css middleware to use:
#|
#|    option            npm install:
#|    -------------------------------
#|    css               none
#|    less              less-middleware
#|    stylus            stylus
#|
##
exports['css'] = 'css'

##
#|--------------------------------------------------------------------------
#| Use Sessions?
#|--------------------------------------------------------------------------
#|
#| Encryption key
#|
#|
##
exports['sessions'] = true

##
#|--------------------------------------------------------------------------
#| Cookies
#|--------------------------------------------------------------------------
#|
#| Encryption key
#|
#|    Check process.env.CLIENT_SECRET first, this is set by Heroku
#|    If not set, use hard coded 256 bit key
#|
##
exports['cookie_key'] = process.env.CLIENT_SECRET ? 'ZAHvYIu8u1iRS6Hox7jADpnCMYKf57ex0BEWc8bM0/4='

##
#|--------------------------------------------------------------------------
#| Session Database
#|--------------------------------------------------------------------------
#|
#| Session storage to use:
#|
#|
#|    option            npm install:
#|    -------------------------------
#|    cassandra         connect-cassandra
#|    cookie            cookie-sessions
#|    couchdb           connect-couchdb
#|    memcached         connect-memcached
#|    mongo             connect-mongo
#|    mongodb           connect-mongodb
#|    mysql             connect-mysql
#|    nstore            nstore-session
#|    orientdb          connect-orientdb
#|    pg                connect-pg
#|    redis             connect-redis
#|    sqlite3           connect-sqlite3
#|
##
exports['session_db'] = 'redis'

exports['redis_url'] = process.env.REDISTOGO_URL ? 'redis://localhost:6379'


# End of file config.coffee
# Location: .application/config/config.coffee