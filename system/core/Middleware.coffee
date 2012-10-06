#+--------------------------------------------------------------------+
#| Middleware.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#	Exspresso Core Middleware:
#
#   5xx Error Handler
#   404 Error Handler
#   Profiler
#
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{array_merge, dirname, file_exists, is_dir, ltrim, realpath, rtrim, strrchr, trim, ucfirst} = require(FCPATH + 'pal')
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message} = require(BASEPATH + 'core/Common')
{load_object} = require(BASEPATH + 'core/Common')

app             = require(BASEPATH + 'core/Exspresso')  # Exspresso bootstrap module

# --------------------------------------------------------------------

#
# 5xx Error Display
#
#   @param {Object} req
#   @param {Object} res
#   @param {Function} next
#
exports.error_5xx = ->

  log_message 'debug',"5xx Middleware initialized"

  (err, req, res, next) ->

    # treat as 404?
    if err.message.indexOf('not found') >= 0 then return next()

    # log it
    console.error err.stack

    # error page
    res.status(500).render 'errors/5xx'
    return


# --------------------------------------------------------------------

#
# 404 Display
#
#   @param {Object} req
#   @param {Object} res
#   @param {Function} next
#
exports.error_404 = ->

  log_message 'debug',"404 Middleware initialized"
  #
  # handle 404 not found error
  #
  (req, res, next) ->

    res.status(404).render 'errors/404', url: req.originalUrl
    return

# --------------------------------------------------------------------

#
# Profile
#
#   @param {Object} req
#   @param {Object} res
#   @param {Function} next
#
exports.profiler = ->

  log_message 'debug',"Profiler Middleware initialized"
  #
  # profiler middleware
  #
  #   @param {Object} server request object
  #   @param {Object} server response object
  #   @param {Object} next middleware
  #
  (req, res, next) ->

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
        if html?
          res.send html.replace(/{elapsed_time}/g, elapsed_time)
        return

    next()
    return

# --------------------------------------------------------------------

#
# Messages
#
#   @param {Object} req
#   @param {Object} res
#   @param {Function} next
#
exports.messages =  ->

  ##
  # add messages to the flash message
  # queue for this session
  ##
  app.response.message = (msg) ->

    sess = @req.session

    # ensure the seesion has a messages queue
    sess.messages = sess.messages ? []

    # add to the message queue
    sess.messages.push msg
    return @

  ##
  # expose messages to template engine
  # while the views are rendering
  ##
  (req, res, next) ->

    # make the message queue available the template engine
    res.locals.messages = req.session.messages ? []

    # clear session messages for next time through
    req.session.messages = []

    # do the next middleware in the queue
    next()
    return

# End of file Middleware.coffee
# Location: ./system/core/Middleware.coffee