#+--------------------------------------------------------------------+
#| Exspresso.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
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
#   Define the global Exspresso environment to mimic php
#
require('not-php').export global,
  $_POST:   get: -> Exspresso.input.post()
  $_GET:    get: -> Exspresso.input.get()
  $_COOKIE: get: -> Exspresso.input.cookie()
  $_SERVER: get: -> Exspresso.input.server()


#
#---------------------------------------------------------------
# APPLICATION ENVIRONMENT
#---------------------------------------------------------------
#
# You can load different configurations depending on your
# current environment. Setting the environment also influences
# things like logging and error reporting.
#
# This can be set to anything, but default usage is:
#
#     development
#     test
#     production
#
#
define 'ENVIRONMENT', process.env.ENVIRONMENT ? 'development'

#
#
#---------------------------------------------------------------
# SYSTEM FOLDER NAME
#---------------------------------------------------------------
#
# This variable must contain the name of your "system" folder.
# Include the path if the folder is not in the same  directory
# as this file.
#
#
$system_folder = 'system'

#
#---------------------------------------------------------------
# APPLICATION FOLDER NAME
#---------------------------------------------------------------
#
# If you want this front controller to use a different "application"
# folder then the default one you can set its name here. The folder
# can also be renamed or relocated anywhere on your server.  If
# you do, use a full server path. For more info please see the user guide:
# http://darkoverlordofdata.com/user_guide/general/managing_apps.html
#
# NO TRAILING SLASH!
#
#
$application_folder = 'application'

# --------------------------------------------------------------------
# END OF USER CONFIGURABLE SETTINGS.  DO NOT EDIT BELOW THIS LINE
# --------------------------------------------------------------------

#
# ---------------------------------------------------------------
#  Resolve the path's for increased reliability
# ---------------------------------------------------------------
#

$system_path = realpath($system_folder) + '/'

# ensure there's a trailing slash
$system_path = rtrim($system_path, '/') + '/';

# Is the system path correct?
if not is_dir($system_path)
  exit "Your system folder path is not set correctly. Please open the following file and correct this: "+__filename

#
# -------------------------------------------------------------------
#  Now that we know the path, set the main path defants
# -------------------------------------------------------------------
#

#  The coffee-script file extension
define 'EXT', '.coffee'

#  Path to the system folder
define 'BASEPATH', $system_path

#  Path to the front controller (this file)
define 'FCPATH', rtrim(__dirname + '/', '/') + '/';

# Name of the "system folder"
define 'SYSDIR', trim(strrchr(trim(BASEPATH, '/'), '/'), '/')

#  The path to the "application" folder
if is_dir($application_folder)
  define 'APPPATH', realpath($application_folder) + '/';
else
  if not is_dir(BASEPATH+$application_folder+'/')
    exit "Your application folder path does not appear to be set correctly. Please open the following file and correct this: "+__filename

  define 'APPPATH', BASEPATH+$application_folder+'/'

# --------------------------------------------------------------------
# LOAD THE BOOTSTRAP FILE
# --------------------------------------------------------------------
#
# And away we go...
#
#
require BASEPATH + 'core/Exspresso'

# End of file index.coffee
# Location: ./index.coffee
