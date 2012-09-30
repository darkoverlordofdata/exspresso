#+--------------------------------------------------------------------+
#| _5xx.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	internal error 5xx
#
{FCPATH}        = require(process.cwd() + '/index')     # '/var/www/Exspresso/'
{APPPATH}       = require(FCPATH + '/index')            # '/var/www/Exspresso/application/'
{BASEPATH}      = require(FCPATH + '/index')            # '/var/www/Exspresso/system/'
{WEBROOT}       = require(FCPATH + '/index')            # '/var/www/Exspresso/public/'
{EXT}           = require(FCPATH + '/index')            # '.coffee'
{ENVIRONMENT}   = require(FCPATH + '/index')            # 'development'
app             = require(BASEPATH + 'core/Exspresso')  # Exspresso bootstrap module
{log_message}   = require(BASEPATH + 'core/Common')     # Error Logging Interface.

module.exports = () ->

  app.use (err, req, res, next) ->

    # treat as 404?
    if err.message.indexOf('not found') >= 0 then return next()

    # log it
    console.error err.stack

    # error page
    res.status(500).render 'errors/5xx'
    return
