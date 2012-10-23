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
#	the Exspresso framework
#
#
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{is_loaded, load_class, log_message, show_error} = require(BASEPATH + 'core/Common')


log_message "debug", "Exspresso copyright 2012 Dark Overlord of Data"

express = require('express')      # Express 3.0 Framework

exports.app = app = express()     # Exspresso 0.5.x" Framework

#
# ------------------------------------------------------
#  Bootstrap the core classes
# ------------------------------------------------------
#

exports.exceptions  = load_class('Exceptions',  'core')
exports.config      = load_class('Config',      'core')
exports.load        = load_class('Loader',      'core')
exports.load.initialize module.exports, true  # Autoload

exports.lang        = load_class('Lang',        'core')
exports.input       = load_class('Input',       'core')
exports.cache       = load_class('Cache',       'core')
exports.output      = load_class('Output',      'core')
exports.controller  = load_class('Controller',  'core')
exports.router      = load_class('Router',      'core')

#
# ------------------------------------------------------
#  Start me up...
# ------------------------------------------------------
#

app.listen app.get('port'), ->

  console.log " "
  console.log " "
  console.log "Exspresso copyright 2012 Dark Overlord of Data"
  console.log " "
  console.log "listening on port #{app.get('port')}"
  console.log " "

  if app.get('env') is 'development'
    console.log "View site at http://localhost:" + app.get('port')

  log_message "debug", "listening on port #{app.get('port')}"
  return



# End of file Exspresso.coffee
# Location: ./system/core/Exspresso.coffee