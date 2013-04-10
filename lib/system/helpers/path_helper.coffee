#+--------------------------------------------------------------------+
#  path_helper.coffee
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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Path Helpers
#
#

#  ------------------------------------------------------------------------

#
# Set Realpath
#
# @param  [String]  # @return	[Boolean]	checks to see if the path exists
# @return	[String]
#
if not function_exists('set_realpath')
  exports.set_realpath = set_realpath = ($path, $check_existance = false) ->
    #  Security check to make sure the path is NOT a URL.  No remote file inclusion!
    #if preg_match("#^(http:\/\/|https:\/\/|www\.|ftp|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})#i", $path)
    if /^(http:\/\/|https:\/\/|www\.|ftp|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})/i.test($path)
      show_error('The path you submitted must be a local server path, not a URL')
      
    
    #  Resolve the path
    if realpath($path) isnt false
      $path = realpath($path) + '/'
      
    
    #  Add a trailing slash
    $path = $path.replace(/([^\/])\/*$/, "$1/")
    
    #  Make sure the path exists
    if $check_existance is true
      if not is_dir($path)
        show_error('Not a valid path: %s', $path)
        
      
    
    return $path


#  ------------------------------------------------------------------------
#
# Export helpers to the global namespace
#
#
for $name, $body of module.exports
  define $name, $body



#  End of file path_helper.php 
#  Location: ./system/helpers/path_helper.php 