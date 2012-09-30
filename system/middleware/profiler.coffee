#+--------------------------------------------------------------------+
#| profiler.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	Display profile data on rendered page
#
{FCPATH}        = require(process.cwd() + '/index')     # '/var/www/Exspresso/'
{APPPATH}       = require(FCPATH + '/index')            # '/var/www/Exspresso/application/'
{BASEPATH}      = require(FCPATH + '/index')            # '/var/www/Exspresso/system/'
{WEBROOT}       = require(FCPATH + '/index')            # '/var/www/Exspresso/public/'
{EXT}           = require(FCPATH + '/index')            # '.coffee'
{ENVIRONMENT}   = require(FCPATH + '/index')            # 'development'
app             = require(BASEPATH + 'core/Exspresso')  # Exspresso bootstrap module
{log_message}   = require(BASEPATH + 'core/Common')     # Error Logging Interface.

#
# register the middleware with the server
#
#   @param {Object} express connect server
#   @param {Object} Exspresso configuration
#
module.exports = ()->

  #
  # profiler middleware
  #
  #   @param {Object} server request object
  #   @param {Object} server response object
  #   @param {Object} next middleware
  #
  app.use (req, res, next) ->

    #
    # profile snapshot
    #
    snapshot = ->

      mem: process.memoryUsage()
      time: new Date

    start = snapshot() # starting metrics

    #
    # link our custom render function into the call chain
    #
    render = res.render
    res.render = (view, data) ->

      res.render = render
      data = data ? {}

      #
      # callback with rendered output
      #
      res.render view, data, (err, html) ->

        end = snapshot()
        elapsed_time = end.time - start.time
        #
        # TODO: what if there is an err value?
        #
        # replace metrics in output
        #
        res.send html.replace(/{elapsed_time}/g, elapsed_time)
        return

    next()
    return

  log_message 'debug',"Middleware profiler initialized"



# End of file profiler.coffee
# Location: ./system/middleware/profiler.coffee