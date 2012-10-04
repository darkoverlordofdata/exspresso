#+--------------------------------------------------------------------+
#| dependencies.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#     M A S T E R     D E P E N D E N C Y     L I S T
#
#
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{array_merge, count, dirname, file_exists, is_dir, ltrim, realpath, rtrim, strrchr, trim, ucfirst} = require(FCPATH + 'pal')
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message} = require(BASEPATH + 'core/Common')


FCPATH, SYSDIR, WEBROOT}
## --------------------------------------------------------------------

#
# CodeIgniter constants
#

{FCPATH}        = require(process.cwd() + '/index')     # '/var/www/Exspresso/'
{APPPATH}       = require(FCPATH + 'index')             # '/var/www/Exspresso/application/'
{BASEPATH}      = require(FCPATH + 'index')             # '/var/www/Exspresso/system/'
{WEBROOT}       = require(FCPATH + 'index')             # '/var/www/Exspresso/public/'
{EXT}           = require(FCPATH + 'index')             # '.coffee'
{ENVIRONMENT}   = require(FCPATH + 'index')             # 'development'

## --------------------------------------------------------------------

#
# 3rd Party Node modules
#

cache           = require('connect-cache')              # Caching system for Connect
connectRedis    = require('connect-redis')              # Redis session store for Connect.
dispatch        = require('dispatch')                   # URL dispatcher for Connect
express         = require('express')                    # Express 3.0 Framework
fs              = require('fs')                         # Standard POSIX file i/o
path            = require('path')                       # File path utilities
redis           = require('redis')                      # Redis client library.
querystring     = require('querystring')                # Utilities for dealing with query strings.
Sequelize       = require("sequelize")                  # Sequelize 1.5 ORM
url             = require('url')                        # Utilities for URL resolution and parsing.

## --------------------------------------------------------------------

#
# Not-PHP helper API
#

{array_merge}   = require(FCPATH + 'pal')              # Merge one or more arrays.
{file_exists}   = require(FCPATH + 'pal')              # Checks whether a file or directory exists.
{is_dir}        = require(FCPATH + 'pal')              # Tells whether the filename is a directory.
{ltrim}         = require(FCPATH + 'pal')              # Strip chars from end of a string.
{realpath}      = require(FCPATH + 'pal')              # Returns canonicalized absolute pathname.
{rtrim}         = require(FCPATH + 'pal')              # Strip chars from beginning of a string.
{trim}          = require(FCPATH + 'pal')              # Strip chars from both ends of a string.
{ucfirst}       = require(FCPATH + 'pal')              # Make a string's first character uppercase.

## --------------------------------------------------------------------

#
# CodeIgniter core/Common API
#

{config_item}   = require(BASEPATH + 'core/Common')     # Returns the specified config item.
{get_config}    = require(BASEPATH + 'core/Common')     # Loads the main config.coffee file.
{get_instance}  = require(BASEPATH + 'core/Common')     # Load the base controller class.
{is_loaded}     = require(BASEPATH + 'core/Common')     # Keeps track of which libraries have been loaded.
{load_class}    = require(BASEPATH + 'core/Common')     # Class registry.
{log_message}   = require(BASEPATH + 'core/Common')     # Error Logging Interface.
{show_error}    = require(BASEPATH + 'core/Common')     # Error Handler.
{show_404}      = require(BASEPATH + 'core/Common')     # 404 Page Handler.
{Exspresso}     = require(BASEPATH + 'core/Common')     # Core framework library
## --------------------------------------------------------------------

#
# CodeIgniter core application modules
#

app             = require(BASEPATH + 'core/Exspresso')  # Exspresso bootstrap module
middleware      = require(BASEPATH + 'core/Middleware') # Exspresso Middleware module
CI_Benchmark    = require(BASEPATH + 'core/Benchmark')  # Exspresso Benchmark Base Class
CI_Config       = require(BASEPATH + 'core/Config')     # Exspresso Config Base Class
CI_Controller   = require(BASEPATH + 'core/Controller') # Exspresso Controller Base Class
CI_Lang         = require(BASEPATH + 'core/Lang')       # Exspresso Lang Base Class
CI_Loader       = require(BASEPATH + 'core/Loader')     # Exspresso Loader Base Class
CI_Model        = require(BASEPATH + 'core/Model')      # Exspresso Model Base Class
CI_Output       = require(BASEPATH + 'core/Output')     # Exspresso Output Base Class
CI_Router       = require(BASEPATH + 'core/Router')     # Exspresso Router Base Class
CI_Security     = require(BASEPATH + 'core/Security')   # Exspresso Security Base Class

# End of file dependencies.coffee
# Location: ./dependencies.coffee