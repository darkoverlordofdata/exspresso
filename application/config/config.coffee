#+--------------------------------------------------------------------+
# config.coffee
#+--------------------------------------------------------------------+
# Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#
# This file is a part of Exspresso
#
# Exspresso is free software; you can copy, modify, and distribute
# it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#

#exports['db_url'] = process.env.CLEARDB_DATABASE_URL ? "mysql://tagsobe:tagsobe@localhost/tagsobe"
#exports['db_url'] = process.env.HEROKU_POSTGRESQL_ROSE_URL ? "postgres://tagsobe:tagsobe@localhost:5432/tagsobe"
#exports['db_url'] = "sqlite:///tagsobe"

#
#--------------------------------------------------------------------------
# Site Name
#--------------------------------------------------------------------------
#
# the site name
#
#
exports['site_name'] = 'Dark Overlord of Data'

#
#--------------------------------------------------------------------------
# Favorites Icon
#--------------------------------------------------------------------------
#
# Path to application icon
#
#
exports['favicon'] = '/icons/favicon.png'

#
#--------------------------------------------------------------------------
# WebRoot
#--------------------------------------------------------------------------
#
# Root folder for static assets
#
#
exports['webroot'] = '/public'

#
#--------------------------------------------------------------------------
# Port
#--------------------------------------------------------------------------
#
# Port used by node server
#
#
exports['port'] = process.env.PORT # 3000

#
#--------------------------------------------------------------------------
# Logger
#--------------------------------------------------------------------------
#
# Logger format
#
#
exports['logger'] = 'dev'

#
#--------------------------------------------------------------------------
# Views folder
#--------------------------------------------------------------------------
#
# Path to the views folder
#
#
exports['views'] = 'views'

#
#--------------------------------------------------------------------------
# Template Engine
#--------------------------------------------------------------------------
#
# The consolidate templating engine to use:
#
#    jade
#    dust
#    swig
#    liquor
#    ejs
#    eco
#    jazz
#    jqtpl
#    haml
#    whiskers
#    haml-coffee
#    hogan
#    handlebars
#    underscore
#    qejs
#    walrus
#    mustache
#    dot
#
#
exports['template'] = 'jade'

#
#--------------------------------------------------------------------------
# View Extension
#--------------------------------------------------------------------------
#
# The default file extension used for view templates
#
#
exports['view_ext'] = 'jade'

#
#--------------------------------------------------------------------------
# Use Layout
#--------------------------------------------------------------------------
#
# Layout strategy
#
#    true              use Express.js 2.x layouts
#    false             use Templating Engine default style
#
exports['use_layouts'] = false

#
#--------------------------------------------------------------------------
# Use CSS Middleware?
#--------------------------------------------------------------------------
#
# css middleware to use:
#
#    option            npm install:
#    -------------------------------
#    css               none
#    less              less-middleware
#    stylus            stylus
#
#
exports['css'] = 'css'

exports['cache'] = false

#
#--------------------------------------------------------------------------
# Class Extension Prefix
#--------------------------------------------------------------------------
#
# This item allows you to set the filename/classname prefix when extending
# native libraries.  For more information please see the user guide:
#
# http://codeigniter.com/user_guide/general/core_classes.html
# http://codeigniter.com/user_guide/general/creating_libraries.html
#
#
exports['subclass_prefix'] = 'MY_'

#
#--------------------------------------------------------------------------
# Error Logging Threshold
#--------------------------------------------------------------------------
#
# If you have enabled error logging, you can set an error threshold to
# determine what gets logged. Threshold options are:
# You can enable error logging by setting a threshold over zero. The
# threshold determines what gets logged. Threshold options are:
#
#	0 = Disables logging, Error logging TURNED OFF
#	1 = Error Messages (including PHP errors)
#	2 = Debug Messages
#	3 = Informational Messages
#	4 = All Messages
#
# For a live site you'll usually only enable Errors (1) to be logged otherwise
# your log files will fill up very fast.
#
#
exports['log_threshold'] = 4

#
#--------------------------------------------------------------------------
# Error Logging Directory Path
#--------------------------------------------------------------------------
#
# Leave this BLANK unless you would like to set something other than the default
# application/logs/ folder. Use a full server path with trailing slash.
#
#
exports['log_path'] = ''

#
#--------------------------------------------------------------------------
# Date Format for Logs
#--------------------------------------------------------------------------
#
# Each item that is logged has an associated date. You can use PHP date
# codes to set your own date formatting
#
#
exports['log_date_format'] = 'Y-m-d H:i:s'

#
#--------------------------------------------------------------------------
# Encryption Key
#--------------------------------------------------------------------------
#
# If you use the Encryption class or the Session class you
# MUST set an encryption key.  See the user guide for info.
#
#
exports['encryption_key'] = process.env.CLIENT_SECRET ? 'ZAHvYIu8u1iRS6Hox7jADpnCMYKf57ex0BEWc8bM0/4='

#
#--------------------------------------------------------------------------
# Session Variables
#--------------------------------------------------------------------------
#
# 'sess_cookie_name'		  = the name you want for the cookie
# 'sess_expiration'			  = the number of SECONDS you want the session to last.
#   by default sessions last 7200 seconds (two hours).  Set to zero for no expiration.
# 'sess_expire_on_close'	= Whether to cause the session to expire automatically
#   when the browser window is closed
# 'sess_encrypt_cookie'		= Whether to encrypt the cookie
# 'sess_use_database'		  = Whether to save the session data to a database
# 'sess_table_name'			  = The name of the session database table
# 'sess_match_ip'			    = Whether to match the user's IP address when reading the session data
# 'sess_match_useragent'	= Whether to match the User Agent when reading the session data
# 'sess_time_to_update'		= how many seconds between CI refreshing Session Information
#

exports['sess_cookie_name']		= 'ci_session'
exports['sess_expiration']		= 7200
exports['sess_expire_on_close']	= false
exports['sess_encrypt_cookie']	= false
exports['sess_use_database']	= process.env.REDISTOGO_URL ? 'redis://localhost:6379'
exports['sess_table_name']		= 'ci_sessions'
exports['sess_match_ip']		= false
exports['sess_match_useragent']	= true
exports['sess_time_to_update']	= 300


#
#--------------------------------------------------------------------------
# Cookie Related Variables
#--------------------------------------------------------------------------
#
# 'cookie_prefix' = Set a prefix if you need to avoid collisions
# 'cookie_domain' = Set to .your-domain.com for site-wide cookies
# 'cookie_path'   =  Typically will be a forward slash
# 'cookie_secure' =  Cookies will only be set if a secure HTTPS connection exists.
#
#
exports['cookie_prefix']	= ""
exports['cookie_domain']	= ""
exports['cookie_path']		= "/"
exports['cookie_secure']	= false


#
#--------------------------------------------------------------------------
# Module Locations
#--------------------------------------------------------------------------
#
# Modular Extensions: Where are modules located?
#
#
###
exports['modules_locations'] =
  APPPATH+'modules/':                 '../modules/'
  ADDON_FOLDER+'default/modules/':    '../../../addons/default/modules/'
  SHARED_ADDONPATH+'modules/':        '../../../addons/shared_addons/modules/'
###

#

# End of file config.coffee
# Location: .application/config/config.coffee