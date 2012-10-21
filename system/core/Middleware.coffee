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
{array_merge, dirname, file_exists, is_dir, ltrim, realpath, rtrim, strrchr, trim, ucfirst} = require(FCPATH + 'lib')
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message} = require(BASEPATH + 'core/Common')
{load_object} = require(BASEPATH + 'core/Common')

app             = require(BASEPATH + 'core/Exspresso').app  # Exspresso bootstrap module
format = require('util').format

# --------------------------------------------------------------------

#
# 5xx Error Display
#
#   @param {Object} $req
#   @param {Object} $res
#   @param {Function} $next
#
exports.error_5xx = ->

  log_message 'debug',"5xx middleware initialized"

  ($err, $req, $res, $next) ->

    # error page
    $res.status($err.status or 500).render 'errors/5xx'
    return


# --------------------------------------------------------------------

#
# 404 Display
#
#   @param {Object} $req
#   @param {Object} $res
#   @param {Function} $next
#
exports.error_404 = ->

  log_message 'debug',"404 middleware initialized"
  #
  # handle 404 not found error
  #
  ($req, $res, $next) ->

    $res.status(404).render 'errors/404', url: $req.originalUrl
    return


# --------------------------------------------------------------------

#
# Authentication
#
#   @param {Object} $req
#   @param {Object} $res
#   @param {Function} $next
#

exports.authenticate = ->

  log_message 'debug',"Authenticate middleware initialized"
  #
  # handle authentication
  #
  ($req, $res, $next) ->

    ###
    if $req.url.indexOf('/mytravel') is 0
      if $req.session.user?
        $next()
      else
        $res.redirect "/login?url="+$req.url
    else
      $next()
    ###
    $next()

# --------------------------------------------------------------------

#
# Profile
#
#   @param {Object} $req
#   @param {Object} $res
#   @param {Function} $next
#
exports.profiler = ($output) ->

  log_message 'debug',"Profiler middleware initialized"
  #
  # profiler middleware
  #
  #   @param {Object} server request object
  #   @param {Object} server response object
  #   @param {Object} $next middleware
  #
  ($req, $res, $next) ->

    if $output.parse_exec_vars is false
      return $next()
    #
    # profile snapshot
    #
    snapshot = ->

      mem: process.memoryUsage()
      time: new Date

    $start = snapshot() # starting metrics

    #
    # link our custom render function into the call chain
    #
    $render = $res.render
    $res.render = ($view, $data) ->

      $res.render = $render
      $data = $data ? {}

      #
      # callback with rendered output
      #
      $res.render $view, $data, ($err, $html) ->

        $end = snapshot()
        $elapsed_time = $end.time - $start.time
        #
        # TODO: what if there is an $err value?
        #
        # replace metrics in output:
        #
        #   {elapsed_time}
        #   {memory_usage}
        #
        if $html?
          $res.send $html.replace(/{elapsed_time}/g, $elapsed_time)
        return

    $next()
    return

# --------------------------------------------------------------------

#
# Messages
#
#   @param {Object} $req
#   @param {Object} $res
#   @param {Function} $next
#
exports.messages =  ->

  ##
  # add messages to the flash message
  # queue for this session
  ##
  app.response.message = ($msg) ->

    $sess = @req.session

    # ensure the seesion has a messages queue
    $sess.messages = sess.messages ? []

    # add to the message queue
    $sess.messages.push $msg
    return @

  ##
  # expose messages to template engine
  # while the views are rendering
  ##
  ($req, $res, $next) ->

    # make the message queue available the template engine
    $res.locals.messages = $req.session.messages ? []

    # clear session messages for $next time through
    $req.session.messages = []

    # do the $next middleware in the queue
    $next()
    return

# End of file Middleware.coffee
# Location: ./system/core/Middleware.coffee