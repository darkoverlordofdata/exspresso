#+--------------------------------------------------------------------+
#  Exceptions.coffee
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
# This file was ported from php to coffee-script using php2coffee
#
#
#  ------------------------------------------------------------------------

#
# Error Wrapper Class
#
class global.CI_Error extends Error

  constructor: ($err = {}, $status = 500) ->

    $status = $err.status || $status

    @code     = $status
    @desc     = set_status_header($status)
    @name     = $err.name || 'Error'
    @class    = if $status >= 500 then 'error' else 'info'
    @message  = if $status is 404 then "The page you requested was not found" else $err.message || 'Unknown error'
    @stack    = '<ul>'+($err.stack || '').split('\n').slice(1).map((v) ->
      '<li>' + v + '</li>' ).join('')+'</ul>'

#
# Exceptions Class
#
class global.CI_Exceptions

  constructor: ->

    log_message 'debug', "Exceptions Class Initialized"

  #  --------------------------------------------------------------------

  #
  # Exception Logger
  #
  # This function logs PHP generated error messages
  #
  # @access	private
  # @param	string	the error severity
  # @param	string	the error string
  # @param	string	the error filepath
  # @param	string	the error line number
  # @return	string
  #
  log_exception : ($severity, $message, $filepath, $line) ->
    log_message('error', 'Severity: ' + $severity + '  --> ' + $message + ' ' + $filepath + ' ' + $line, true)

  #  --------------------------------------------------------------------

  #
  # 404 Page Not Found Handler
  #
  # @access	private
  # @param	string
  # @return	string
  #
  show_404 : ($page = '', $log_error = true) ->
    $message = "The page you requested was not found."

    #  By default we log this, but allow a dev to skip it
    if $log_error
      log_message('error', '404 Page Not Found --> ' + $page)


    @show_error($message, '404', 404)

  # --------------------------------------------------------------------
  # Method Stubs
  #
  #   These methods will be overriden by the middleware
  # --------------------------------------------------------------------

  #  --------------------------------------------------------------------

  #
  # General Error Page
  #
  # This function takes an error message as input
  # (either as a string or an array) and displays
  # it using the specified template.
  #
  # @access	private
  # @param	string	the heading
  # @param	string	the message
  # @param	string	the template name
  # @return	string
  #
  show_error : ($message, $template = '5xx', $status_code = 500) ->
    # if we're here, then Exspresso is still booting...
    console.log "Exceptions::show_error --> #{$message}"
    process.exit 1

  #  --------------------------------------------------------------------

  #
  # Native error handler
  #
  # @access	private
  # @param	string	the error severity
  # @param	string	the error string
  # @param	string	the error filepath
  # @param	string	the error line number
  # @return	string
  #
  show_native_error : ($severity, $message, $filepath, $line) ->
    # if we're here, then Exspresso is still booting...
    console.log "Exceptions::show_native_error --> #{$message}"
    console.log " at line #{$line},  #{$filepath}"
    process.exit 1

  # --------------------------------------------------------------------

  #
  # We're booted - now display in browser
  #
  #   @returns function middlware callback
  #
  middleware: ()->

    log_message 'debug',"Exceptions middleware initialized"

    ($req, $res, $next) =>


      #  --------------------------------------------------------------------
      @show_404 = ($page = '', $log_error = true, $callback) =>

        if typeof $log_error is 'function'
          [$log_error, $callback] = [true, $log_error]

        $err =
          status:       404
          stack:        [
            "The page you requested was not found."
            set_status_header(404)+': ' +$req.originalUrl
            ].join("\n")

        #  By default we log this, but allow a dev to skip it
        if $log_error
          log_message('error', '404 Page Not Found --> ' + $page)

        @show_error $err, '404', 404, $callback

      #  --------------------------------------------------------------------
      @show_error = ($err, $template = '5xx', $status_code = 500, $callback) ->

        if typeof $template is 'function'
          [$$template, $status_code, $callback] = ['5xx', 500, $template]

        $error = new CI_Error($err)

        $callback = $callback ? ($err, $content) ->
          $res.render APPPATH+'errors/layout.eco',
            title:      $error.code + ': ' + $error.desc
            content:    $content
            site_name:  config_item('site_name')

        $res.render APPPATH+'errors/'+$template+'.eco', err: $error, $callback

      #  --------------------------------------------------------------------
      @show_native_error = ($severity, $message, $filepath, $line) ->

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

      $next()

module.exports = CI_Exceptions
#  END Exceptions Class

#  End of file Exceptions.php 
#  Location: ./system/core/Exceptions.php 