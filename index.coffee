#+--------------------------------------------------------------------+
#| exspresso.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Exspresso is free software you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#	Exspresso
#
#   node [--harmony] index <appjs|connect|express> <mvc|hmvc> [--option]
#
#     options:
#     --cache
#     --csrf
#     --preview
#     --profile
#     --nocache
#     --nocsrf
#     --noprofile
#     --db <mysql|postgres>
#
#   examples:
#     node --harmony index appjs
#     node index connect
#     node index express
#
#
# Set global path constants, load the api and boot exspresso
#


#
# Load the core api module
#
core = require('./lib/system/core.coffee')
#
#   Add a php-ish api
#
require('./not-php').export global, core

#
# set the environment
#
define 'ENVIRONMENT', process.env.ENVIRONMENT ? 'development'

#
# Set the default paths:
#
$system_folder  = 'lib/system'        # expresso system libraries
$app_folder     = 'lib/application'   # expresso application
$asset_folder   = "lib/assets"        # document root,
$module_folder  = "lib/modules"       # expresso modules

#
#  Resolve the path's
#
$system_path = realpath($system_folder) + '/'

#   Is the system path correct?
#
if not is_dir($system_path)
  exit "Your system folder path is not set correctly. Please open the following file and correct this: "+__filename

#  The coffee-script file extension
#
define 'EXT', '.coffee'

#  Path to the system folder
#
define 'SYSPATH', $system_path

#  Path to the front controller (this file)
#
define 'FCPATH', realpath(__dirname) + '/'

#
# The path to the "application" folder
#
if is_dir($app_folder)
  define 'APPPATH', realpath($app_folder) + '/'
else
  if not is_dir(SYSPATH+$app_folder+'/')
    exit "Your application folder path does not appear to be set correctly. Please open the following file and correct this: "+__filename

  define 'APPPATH', SYSPATH+$app_folder+'/'

#
# The path to the "assets" folder
#
if is_dir($asset_folder)
  define 'DOCPATH', realpath($asset_folder) + '/'
else
  if not is_dir(SYSPATH+$asset_folder+'/')
    #exit "Your asset folder path does not appear to be set correctly. Please open the following file and correct this: "+__filename
    define 'DOCPATH', false

  define 'DOCPATH', SYSPATH+$asset_folder+'/'


#
# The path to the "modules" folder
#
if is_dir($module_folder)
  define 'MODPATH', realpath($module_folder) + '/'
else
  if not is_dir(SYSPATH+$module_folder+'/')
    exit "Your module folder path does not appear to be set correctly. Please open the following file and correct this: "+__filename

  define 'MODPATH', SYSPATH+$module_folder+'/'

#
#   Initialize the API
#
core()
#
#   Create the main controller
#
define 'exspresso', new system.core.Exspresso

#
#   e x s p r e s s o
#
exspresso.boot()


# End of file index.coffee
# Location: ./index.coffee
