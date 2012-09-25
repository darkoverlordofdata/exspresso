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
exports['db_url'] = process.env.CLEARDB_DATABASE_URL ? "mysql://tagsobe:tagsobe@localhost/tagsobe"
#exports['db_url'] = process.env.DATABASE_URL ? "postgres://tagsobe:tagsobe@localhost:5432/tagsobe"
#exports['db_url'] = process.env.DATABASE_URL ? "sqlite://localhost/tagsobe.db"
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
exports['views'] = '/views'

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

exports['cache'] = false

#
#|--------------------------------------------------------------------------
#| Class Extension Prefix
#|--------------------------------------------------------------------------
#|
#| This item allows you to set the filename/classname prefix when extending
#| native libraries.  For more information please see the user guide:
#|
#| http://codeigniter.com/user_guide/general/core_classes.html
#| http://codeigniter.com/user_guide/general/creating_libraries.html
#|
#
exports['subclass_prefix'] = 'MY_'


# End of file config.coffee
# Location: .application/config/config.coffee