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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Path Helpers
#
# @package		Exspresso
# @subpackage	Helpers
# @category	Helpers
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/helpers/xml_helper.html
#

#  ------------------------------------------------------------------------

#
# Set Realpath
#
# @access	public
# @param	string
# @param	bool	checks to see if the path exists
# @return	string
#
if not function_exists('set_realpath')
  exports.set_realpath = set_realpath = ($path, $check_existance = false) ->
    #  Security check to make sure the path is NOT a URL.  No remote file inclusion!
    #if preg_match("#^(http:\/\/|https:\/\/|www\.|ftp|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})#i", $path)
    if preg_match("#^(http:\\/\\/|https:\\/\\/|www\\.|ftp|[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3})#i", $path)?
      show_error('The path you submitted must be a local server path, not a URL')
      
    
    #  Resolve the path
    if function_exists('realpath') and realpath($path) isnt false
      $path = realpath($path) + '/'
      
    
    #  Add a trailing slash
    $path = preg_replace("#([^/])/*$#", "$1/", $path)
    
    #  Make sure the path exists
    if $check_existance is true
      if not is_dir($path)
        show_error('Not a valid path: %s', $path)
        
      
    
    return $path
    
  


#  End of file path_helper.php 
#  Location: ./system/helpers/path_helper.php 