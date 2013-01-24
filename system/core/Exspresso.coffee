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
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
#
#	the top level Exspresso controller
#
#
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
#
# Async job queue
#
# @var array
#
#
_queue = []
exports.queue = ($fn) ->
  if $fn then _queue.push($fn) else _queue

#
# ------------------------------------------------------
#  Load the framework constants
# ------------------------------------------------------
#
if defined('ENVIRONMENT') and file_exists(APPPATH+'config/'+ENVIRONMENT+'/constants.coffee')
  require APPPATH+'config/'+ENVIRONMENT+'/constants.coffee'
else
  require APPPATH+'config/constants.coffee'

#------------------------------------------------------
# Instantiate the config class
#------------------------------------------------------
#
exports.config = load_class('Config', 'core')

#
# ------------------------------------------------------
#  Instantiate the core server app
# ------------------------------------------------------
#
#   Get the 1st command line arg
#     if it's not an option, then it's the driver name
#
$driver = if ~($argv[2] ? '').indexOf('-') then '' else $argv[2] ? ''

exports.server = load_driver('Server', 'core', $driver)

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
exports.router = load_class('Router', 'core')

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
exports.lang = load_class('Lang', 'core')

#
# ------------------------------------------------------
#  Load the app controller and local controllers
# ------------------------------------------------------
#
#
# Load the base controller class
require BASEPATH+'core/Controller.coffee'

if file_exists(APPPATH+'core/'+config_item('subclass_prefix')+'Controller.coffee')

  require APPPATH+'core/'+config_item('subclass_prefix')+'Controller.coffee'

for $path, $uri of Exspresso.router.load_routes()

  Exspresso.router.set_routing($uri)

  # Load the local application controller
  # Note: The Router class automatically validates the controller path using the router->_validate_request().
  # If this include fails it means that the default controller in the Routes.php file is not resolving to something valid.
  if not file_exists(APPPATH+'controllers/'+Exspresso.router.fetch_directory()+Exspresso.router.fetch_class()+EXT)

    log_message "debug", 'Unable to load controller for %s', $uri
    log_message "debug", 'Please make sure the controller specified in your Routes.coffee file is valid.'
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

    log_message "debug", "Controller not found: %s/%s", $class, $method
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