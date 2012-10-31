#+--------------------------------------------------------------------+
#  Exspresso.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
# 
#  This file is a part of Exspresso
# 
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
# 
#+--------------------------------------------------------------------+
#
#	the Exspresso framework :)
#
#
#
#
# Exspresso Version
#
# @var string
#
#
define 'CI_VERSION', require(FCPATH + 'package.json').version

#
# ------------------------------------------------------
#  Load the global functions
# ------------------------------------------------------
#
require BASEPATH + 'core/Common'

log_message "debug", "Exspresso v%s copyright 2012 Dark Overlord of Data", CI_VERSION
#
# ------------------------------------------------------
#  Load the framework constants
# ------------------------------------------------------
#
if defined('ENVIRONMENT') and file_exists(APPPATH+'config/'+ENVIRONMENT+'/constants.coffee')
  require APPPATH+'config/'+ENVIRONMENT+'/constants.coffee'
else
  require APPPATH+'config/constants.coffee'


#
# ------------------------------------------------------
#  Instantiate the core express app
# ------------------------------------------------------
#
define '$SRV', load_class('Server', 'core')

#
#------------------------------------------------------
# Instantiate the config class
#------------------------------------------------------
#
define '$CFG', (exports.config = load_class('Config', 'core'))

#
# ------------------------------------------------------
#  Instantiate the routing class and set the routing
# ------------------------------------------------------
#
define '$RTR', (exports.router = load_class('Router', 'core'))

#
# ------------------------------------------------------
#  Instantiate the output class
# ------------------------------------------------------
#
define '$OUT', (exports.output = load_class('Output', 'core'))

#
# ------------------------------------------------------
#  Load the Input class and sanitize globals
# ------------------------------------------------------
#
define '$IN', (exports.input = load_class('Input', 'core'))

#
# ------------------------------------------------------
#  Load the Language class
# ------------------------------------------------------
#
define '$LANG', (exports.lang = load_class('Lang', 'core'))

#
# ------------------------------------------------------
#  Load the app controller and local controllers
# ------------------------------------------------------
#
#
# Load the base controller class
require BASEPATH+'core/Controller.coffee'

if file_exists(APPPATH+'core/'+$CFG.config['subclass_prefix']+'Controller.coffee')

  require APPPATH+'core/'+$CFG.config['subclass_prefix']+'Controller.coffee'

for $path, $uri of $RTR._load_routes()

  $RTR._set_routing($uri)
  #log_message 'debug', 'uri:  : %s', $uri
  #log_message 'debug', 'module: %s', $RTR.fetch_module()
  #log_message 'debug', 'dir   : %s', $RTR.fetch_directory()
  #log_message 'debug', 'class : %s', $RTR.fetch_class()
  #log_message 'debug', 'method: %s', $RTR.fetch_method()
  #log_message 'debug', '----------------------------------'

  # Load the local application controller
  # Note: The Router class automatically validates the controller path using the router->_validate_request().
  # If this include fails it means that the default controller in the Routes.php file is not resolving to something valid.
  if not file_exists(APPPATH+'controllers/'+$RTR.fetch_directory()+$RTR.fetch_class()+EXT)

    console.log 'Unable to load controller for ' + $uri
    console.log 'Please make sure the controller specified in your Routes.coffee   file is valid.'
    continue

  #
  # ------------------------------------------------------
  #  Security check
  # ------------------------------------------------------
  #
  #  None of the functions in the $app controller or the
  #  loader class can be called via the URI, nor can
  #  controller functions that begin with an underscore
  #
  $class  = $RTR.fetch_class()
  $method = $RTR.fetch_method()

  if $method[0] is '_' or CI_Controller.__proto__[$method]?

    console.log "Controller not found: #{$class}/#{$method}"
    continue

  #
  # ------------------------------------------------------
  #  Instantiate the requested controller
  # ------------------------------------------------------
  #
  $class = require(APPPATH+'controllers/'+$RTR.fetch_directory()+$RTR.fetch_class()+EXT)

  $RTR.bind $path, $class, $method

#
# ------------------------------------------------------
#  Start me up...
# ------------------------------------------------------
#
$SRV.start $RTR

# End of file Exspresso.coffee
# Location: ./system/core/Exspresso.coffee