#+--------------------------------------------------------------------+
#| Exspresso.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	Exspresso
#
#   Defines the global Exspresso environment
#
{array_merge, dirname, file_exists, is_dir, ltrim, realpath, rtrim, strrchr, trim, ucfirst} = require('./helper')

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
# NOTE: If you change these, also change the error_reporting() code below
#
#
exports.ENVIRONMENT = ENVIRONMENT = 'development'

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
# http://codeigniter.com/user_guide/general/managing_apps.html
#
# NO TRAILING SLASH!
#
#
$application_folder = 'application'

#
#---------------------------------------------------------------
# PUBLIC FOLDER NAME
#---------------------------------------------------------------
#
# If you want this front controller to use a different "public"
# folder then the default one you can set its name here. The folder
# can also be renamed or relocated anywhere on your server.  If
# you do, use a full server path.
#
# NO TRAILING SLASH!
#
#
$public_folder = 'public'

#
# ---------------------------------------------------------------
#  Resolve the path's for increased reliability
# ---------------------------------------------------------------
#

$system_path = realpath($system_folder) + '/'
# ensure there's a trailing slash
$system_path = rtrim($system_path, '/') + '/';


if not is_dir($system_path)
  console.log "Your system folder path is not set correctly:"
  console.log "Please open the following file and correct this: "
  console.log "\t#{__filename}"
  process.exit 1

$public_path = realpath($public_folder) + '/';
$public_path = rtrim($public_path, '/') + '/';

if not is_dir($public_path)
  console.log "Your public folder path is not set correctly."
  console.log "Please open the following file and correct this: "
  console.log "\t#{__filename}"
  process.exit 1

#
# -------------------------------------------------------------------
#  Now that we know the path, set the main path defants
# -------------------------------------------------------------------
#

#  The coffee-script file extension

exports.EXT = EXT = '.coffee'

#  Path to the system folder
exports.BASEPATH = BASEPATH = $system_path

#  Path to the front controller (this file)
$fc_path = rtrim(__dirname + '/', '/') + '/';
#$fc_path = rtrim($fc_path, '/') + '/';
exports.FCPATH = FCPATH = $fc_path

# Name of the "system folder"
exports.SYSDIR = SYSDIR = trim(strrchr(trim(BASEPATH, '/'), '/'), '/')

#  The path to the "webroot" folder
exports.WEBROOT = WEBROOT = $public_path

#  The path to the "application" folder
$application_path = realpath($application_folder) + '/';
$application_path = rtrim($application_path, '/') + '/';

if not is_dir($application_path)
  $application_path = realpath(BASEPATH + $application_folder) + '/';
  $application_path = rtrim($application_path, '/') + '/';
  if not is_dir($application_path)
    console.log "Your application folder path is not set correctly."
    console.log "Please open the following file and correct this: "
    console.log "\t#{__filename}"
    process.exit 1


exports.APPPATH = APPPATH = $application_path

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
