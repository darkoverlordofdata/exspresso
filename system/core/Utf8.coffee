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
# Utf8 Class
#
# Provides support for UTF-8 environments
#
#
module.exports = class system.core.Utf8

  utf8 = require('utf8')

  #
  # Regexp to match invalid utf8
  #
  is_invalid = ///
    [\xC0-\xDF]([^\x80-\x8F]|$)
    |[\xE0-\xEF].{0,1}([^\x80-\x8F]|$)
    |[\xF0-\xF7].{0,2}([^\x80-\x8F]|$)
    |[\xF8-\xFB].{0,3}([^\x80-\x8F]|$)
    |[\xFC-\xFD].{0,4}([^\x80-\x8F]|$)
    |[\xFE-\xFE].{0,5}([^\x80-\x8F]|$)
    |[\x00-\x7F][\x80-\xBF]
    |[\xC0-\xDF].[\x80-\xBF]
    |[\xE0-\xEF]..[\x80-\xBF]
    |[\xF0-\xF7]...[\x80-\xBF]
    |[\xF8-\xFB]....[\x80-\xBF]
    |[\xFC-\xFD].....[\x80-\xBF]
    |[\xFE-\xFE]......[\x80-\xBF]
    |[\x80-\xBF]
    ///

  #
  # Constructor
  #
  # Determines if UTF-8 support is to be enabled
  #
  # @param  [system.core.Config]  config  The application configuratin
  #
  constructor : ($config) ->
    log_message 'debug', "Utf8 Class Initialized"

    #  RegExp must support UTF-8
    #  Application charset must be UTF-8 then
    if /./.test('é') and $config.item('charset') is 'UTF-8'
      log_message 'debug', "UTF-8 Support Enabled"
      define 'UTF8_ENABLED', true
    else
      log_message 'debug', "UTF-8 Support Disabled"
      define 'UTF8_ENABLED', false
      
    
  
  #
  # Clean UTF-8 strings
  #
  # Ensures strings are UTF-8
  #
  # @param  [String]  str string to clean
  # @return	[String] cleaned string
  #
  cleanString : ($str) ->
    if is_invalid.test($str)
      $str = utf8.decode($str)
      $str = utf8.encode(remove_invisible_characters($str, false))

    $str
    
  
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
    remove_invisible_characters($str, false)
    
  
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


  isValidUtf8: ($str) ->
    validate.test($str)
  
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

