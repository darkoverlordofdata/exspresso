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
#   node [--harmony] index <appjs|connect|express> [--flag]
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
# top level object
#
define 'Exspresso', module.exports
#
#
# Exspresso Version
#
# @var string
#
#
define 'Exspresso_VERSION', require(FCPATH + 'package.json').version
#
# ------------------------------------------------------
#  Load the global functions
# ------------------------------------------------------
#
require BASEPATH + 'core/Common.coffee'

log_message "debug", "Exspresso v%s copyright 2012 Dark Overlord of Data", Exspresso_VERSION
#
# ------------------------------------------------------
#  Load the framework constants
# ------------------------------------------------------
#
if defined('ENVIRONMENT') and file_exists(APPPATH+'config/'+ENVIRONMENT+'/constants.coffee')
  require APPPATH+'config/'+ENVIRONMENT+'/constants.coffee'
else
  require APPPATH+'config/constants.coffee'

exports.is_running = ->
  if Exspresso.server? then Exspresso.server._running else false

#------------------------------------------------------
# Instantiate the config class
#------------------------------------------------------
#
exports.config = load_driver('Config', 'core', 'hmvc')

#
# ------------------------------------------------------
#  Instantiate the core server app (default to expressjs)
# ------------------------------------------------------
#
exports.server = load_driver('Server', 'core', $argv[2] ? 'express')

#
#
# ------------------------------------------------------
#  Instantiate the URI class
# ------------------------------------------------------
#
exports.uri = load_class('URI', 'core')

#
# ------------------------------------------------------
#  Instantiate the routing class and set the routing
# ------------------------------------------------------
#
exports.router = load_driver('Router', 'core', 'hmvc')

#
# ------------------------------------------------------
#  Instantiate the output class
# ------------------------------------------------------
#
exports.output = load_class('Output', 'core')

#
# ------------------------------------------------------
#  Load the Input class
# ------------------------------------------------------
#
exports.input = load_class('Input', 'core')

#
# ------------------------------------------------------
#  Load the Language class
# ------------------------------------------------------
#
exports.lang = load_driver('Lang', 'core', 'hmvc')

#
# ------------------------------------------------------
#  Load the app controller and local controllers
# ------------------------------------------------------
#
#
# Load the base controller class
require BASEPATH+'core/Controller.coffee'

if file_exists(APPPATH+'core/'+Exspresso.config.config['subclass_prefix']+'Controller.coffee')

  require APPPATH+'core/'+Exspresso.config.config['subclass_prefix']+'Controller.coffee'

for $path, $uri of Exspresso.router._load_routes()

  Exspresso.router._set_routing($uri)

  # Load the local application controller
  # Note: The Router class automatically validates the controller path using the router->_validate_request().
  # If this include fails it means that the default controller in the Routes.php file is not resolving to something valid.
  if not file_exists(APPPATH+'controllers/'+Exspresso.router.fetch_directory()+Exspresso.router.fetch_class()+EXT)

    log_message "debug", 'Unable to load controller for ' + $uri
    log_message "debug", 'Please make sure the controller specified in your Routes.coffee   file is valid.'
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
  $class  = Exspresso.router.fetch_class()
  $method = Exspresso.router.fetch_method()

  if $method[0] is '_' or Exspresso_Controller::[$method]?

    log_message "debug", "Controller not found: #{$class}/#{$method}"
    continue

  #
  # ------------------------------------------------------
  #  Instantiate the requested controller
  # ------------------------------------------------------
  #
  $class = require(APPPATH+'controllers/'+Exspresso.router.fetch_directory()+Exspresso.router.fetch_class()+EXT)

  Exspresso.router.bind $path, $class, $method

#
# ------------------------------------------------------
#  Start me up...
# ------------------------------------------------------
#
Exspresso.server.start Exspresso.router

# End of file Exspresso.coffee
# Location: ./system/core/Exspresso.coffee