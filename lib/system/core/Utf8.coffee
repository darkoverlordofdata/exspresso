#+--------------------------------------------------------------------+
#  Utf8.coffee
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

#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package		Exspresso
# @author		  darkoverlordofdata
# @copyright	Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		MIT License
# @see 		    http://darkoverlordofdata.com
# @since		  Version 1.0
#

#
# Utf8 Class
#
# Provides support for UTF-8 environments
#
#
class system.core.Utf8

  utf8 = require('utf8')
  #
  # Constructor
  #
  # Determines if UTF-8 support is to be enabled
  #
  # @param  [system.core.Config]  config  The application configuratin
  #
  constructor : ($config) ->
    log_message('debug', "Utf8 Class Initialized")
    
    if /./.test('é') and $config.item('charset') is 'UTF-8'
    #  RegExp must support UTF-8
    #  Application charset must be UTF-8 then
      log_message('debug', "UTF-8 Support Enabled")
      define('UTF8_ENABLED', true)
      

    else 
      log_message('debug', "UTF-8 Support Disabled")
      define('UTF8_ENABLED', false)
      
    
  
  #
  # Clean UTF-8 strings
  #
  # Ensures strings are UTF-8
  #
  # @param  [String]  str string to clean
  # @return	[String] cleaned string
  #
  cleanString : ($str) ->
    if @_is_ascii($str) is false
      $str = utf8.decode($str)
      $str = utf8.encode(remove_invisible_characters($str, false))
    return $str
    
  
  #
  # Remove ASCII control characters
  #
  # Removes all ASCII control characters except horizontal tabs,
  # line feeds, and carriage returns, as all others can cause
  # problems in XML
  #
  # @param  [String]  str string to clean
  # @return	[String] cleaned string
  #
  safeAsciiForXml : ($str) ->
    return remove_invisible_characters($str, false)
    
  
  #
  # Convert to UTF-8
  #
  # Attempts to convert a string to UTF-8
  #
  # @param  [String]  str string to convert
  # @param  [String]  encoding  encoding to use
  # @return	[String] converted string
  #
  convertToUtf8 : ($str, $encoding) ->
    utf8.encode($str)
    
  
  #
  # Is ASCII?
  #
  # Tests if a string is standard 7-bit ASCII or not
  #
  # @private
  # @param  [String]
  # @return	bool
  #
  _is_ascii : ($str) ->
    not /[^\x00-\x7F]/.test($str)

    
  

module.exports = system.core.Utf8
#  End Utf8 Class

#  End of file Utf8.coffee
#  Location: .system/core/Utf8.coffee