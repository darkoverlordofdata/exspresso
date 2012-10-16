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
#	Boot an Express server using the Exspresso framework
#
#   http://0.0.0.0:5000/
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{array_merge, array_unshift, dirname, explode, file_exists, implode, in_array, is_dir, is_null, is_string,
  ltrim, realpath, rtrim, strpos, strtolower, strrchr, str_replace, substr, trim, ucfirst} = require(FCPATH + 'lib')
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message} = require(BASEPATH + 'core/Common')


express         = require('express')                    # Express 3.0 Framework
middleware      = require(BASEPATH + 'core/Middleware') # Exspresso Middleware module

log_message "debug", "Exspresso copyright 2012 Dark Overlord of Data"

#
# ------------------------------------------------------
#  Create the server application
# ------------------------------------------------------
# 
app = module.exports = express()

#
# ------------------------------------------------------
#  Instantiate the config class
# ------------------------------------------------------
#
$config = load_class('Config', 'core')._config

app.set 'env', ENVIRONMENT
app.set 'port', $config.port
app.set 'site_name', $config.site_name
app.use express.logger($config.logger)

load_object('Sessions', 'core').initialize(app)
#
# TODO: {BUG} 'express.csrf' fails
# with Forbidden on route /travel/hotels
#
#app.use express.csrf()
app.use express.bodyParser()
app.use express.methodOverride()

load_object('Cache', 'core').initialize(app)
load_object('Output', 'core').initialize(app)

app.use require('connect-flash')()
app.use middleware.profiler()


#
# ------------------------------------------------------
#  Load the app controller and local controllers
# ------------------------------------------------------
#
#  Load the base controller class
#

require BASEPATH + 'core/Controller'

if file_exists(APPPATH + 'core/' + $config['subclass_prefix'] + 'Controller' + EXT)
  require APPPATH + 'core/' + $config['subclass_prefix'] + 'Controller' + EXT

#
# ------------------------------------------------------
#  Instantiate the routing class and set the routing
# ------------------------------------------------------
#
load_object('Router', 'core').initialize(app)

#
# --------------------------------------------------------------------------
#  Start me up...
# --------------------------------------------------------------------------
#
app.listen app.get('port'), ->

  console.log ""
  console.log ""
  console.log "Exspresso copyright 2012 Dark Overlord of Data"
  console.log ""
  console.log "listening on port #{app.get('port')}"
  console.log ""

  if app.get('env') is 'development'
    console.log "View site at http://localhost:" + app.get('port')

  log_message "debug", "listening on port #{app.get('port')}"
  return



# End of file Exspresso.coffee
# Location: ./system/core/Exspresso.coffee