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
# Exceptions Class
#
class CI_Exceptions

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
      @show_error = ($message, $template = '5xx', $status_code = 500) ->

        #set_status_header($status_code)
        $res.render 'errors/' + $template,
          message: $message


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




register_class 'CI_Exceptions', CI_Exceptions
module.exports = CI_Exceptions
#  END Exceptions Class

#  End of file Exceptions.php 
#  Location: ./system/core/Exceptions.php 