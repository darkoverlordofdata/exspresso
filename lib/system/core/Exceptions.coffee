#+--------------------------------------------------------------------+
#  Exceptions.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#
# Error Wrapper Class
#
class system.core.ExspressoError extends Error

  constructor: ($err = {}, $status = 500) ->

    $status = $err.status || $status

    @code     = $status
    @desc     = get_status_text($status)
    @name     = $err.name || 'Error'
    @class    = if $status >= 500 then 'error' else 'info'
    @message  = if $status is 404 then "The page you requested was not found" else $err.message || 'Unknown error'
    @stack    = '<ul>'+($err.stack || '').split('\n').slice(1).map((v) ->
      '<li>' + v + '</li>' ).join('')+'</ul>'


#
# Authorization Error Class
#
class system.core.AuthorizationError extends Error

  constructor: ($msg, $status = 401) ->

    @code     = $status
    @desc     = get_status_text($status)
    @name     = 'Authorization Check Failed'
    @class    = 'info'
    @message  = get_status_text($status)
    @stack    = "\nAuthorization Check Failed\n#{$msg}"



#
# Exceptions Class
#
class system.core.Exceptions

  constructor: ->

    log_message 'debug', "Exceptions Class Initialized"

  #
  # Exception Logger
  #
  #
  # @param  [String]  severity  the error severity
  # @param  [String]  message the error string
  # @param  [String]  filepath  the error filepath
  # @param  [String]  line  the error line number
  # @return	[Void]
  #
  logException : ($severity, $message, $filepath, $line) ->
    log_message('error', 'Severity: ' + $severity + '  --> ' + $message + ' ' + $filepath + ' ' + $line, true)
    return

  #
  # 404 Page Not Found Handler
  #
  #   Show the custom 404 page
  #
  # @param  [String]  page  the requested url
  # @param  [String]  status_code the status/error code
  # @param  [Function]  next  callback
  # @return	[Boolean] true
  #
  show404 : ($page = '', $log_error = true) ->
    $message = "The page you requested was not found."

    #  By default we log this, but allow a dev to skip it
    if $log_error
      log_message('error', '404 Page Not Found --> ' + $page)


    @show5xx($message, '404', 404)

  #
  # General Server Error Page
  #
  # This function takes an error message as input
  # (either as a string or an array) and displays
  # it using the specified template.
  #
  # @param  [String]  err the error object
  # @param  [String]  template  the template name
  # @param  [String]  status_code the status/error code
  # @param  [Function]  next  callback
  # @return	[Boolean] true
  #
  show5xx : ($message, $template = '5xx', $status_code = 500) ->
    # if we're here, then Exspresso is still booting...
    console.log "Exceptions::show_error --> #{$message}"
    process.exit 1

  #
  # Native error handler
  #
  #   Displays node.js error
  #
  # @param  [String]  severity  the error severity
  # @param  [String]  message the error string
  # @param  [String]  filepath  the error filepath
  # @param  [String]  line  the error line number
  # @return	[Boolean] true
  #
  showError : ($severity, $message, $filepath, $line) ->
    # if we're here, then Exspresso is still booting...
    console.log "Exceptions::show_native_error --> #{$message}"
    console.log " at line #{$line},  #{$filepath}"
    process.exit 1

  #
  # Exception handler
  #
  #   Middleware hook to display custom exception pages
  #
  # @param  [Object]  req the http request object
  # @param  [Object]  res the http response object
  # @param  [Function]  next  callback
  # @return [Void]
  #
  exceptionHandler: -> ($req, $res, $next) =>

    #
    # 404 Page Not Found Handler
    #
    #   Show the custom 404 page
    #
    # @param  [String]  page  the requested url
    # @param  [String]  status_code the status/error code
    # @param  [Function]  next  callback
    # @return	[Boolean] true
    #
    @show404 = ($page = '', $log_error = true, $next) =>

      if typeof $log_error is 'function'
        [$log_error, $next] = [true, $log_error]

      $err =
        status:       404
        stack:        [
          "The page you requested was not found."
          get_status_text(404)+': ' +$req.originalUrl
          ].join("\n")

      #  By default we log this, but allow a dev to skip it
      if $log_error
        log_message('error', '404 Page Not Found --> ' + $page)

      @show5xx $err, '404', 404, $next


    #
    # General Server Error Page
    #
    # This function takes an error message as input
    # (either as a string or an array) and displays
    # it using the specified template.
    #
    # @param  [String]  err the error object
    # @param  [String]  template  the template name
    # @param  [String]  status_code the status/error code
    # @param  [Function]  next  callback
    # @return	[Boolean] true
    #
    @show5xx = ($err, $template = '5xx', $status_code = 500, $next) ->

      if typeof $template is 'function'
        [$$template, $status_code, $next] = ['5xx', 500, $template]

      $error = new system.core.ExspressoError($err)

      $next = $next ? ($err, $content) ->
        $res.render APPPATH+'errors/layout.eco',
          title       : $error.code + ': ' + $error.desc
          content     : $content
          site_name   : config_item('site_name')

      $res.render APPPATH+'errors/'+$template+'.eco', err: $error, $next
      return true


    #
    # Native error handler
    #
    #   Displays node.js error
    #
    # @param  [String]  severity  the error severity
    # @param  [String]  message the error string
    # @param  [String]  filepath  the error filepath
    # @param  [String]  line  the error line number
    # @return	[Boolean] true
    #
    @showError = ($severity, $message, $filepath, $line) ->

      $filepath = str_replace("\\", "/", $filepath)

      #  For safety reasons we do not show the full file path
      if false isnt strpos($filepath, '/')
        $x = explode('/', $filepath)
        $filepath = $x[count($x) - 2] + '/' + end($x)


      $res.render 'errors/native',
        severity: $severity
        message:  $message
        filepath: $filepath
        line:     $line

      return true

    $next()

module.exports = system.core.Exceptions
#  END Exceptions Class

#  End of file Exceptions.coffee
#  Location: .system/core/Exceptions.cofee