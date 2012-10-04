#+--------------------------------------------------------------------+
#  path_helper.coffee
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
# This file was ported from php to coffee-script using php2coffee v6.6.6
#
#

{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{defined, function_exists, is_dir, preg_match, preg_replace, realpath}  = require(FCPATH + 'helper')
{config_item, get_class, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

if not defined('BASEPATH') then die 'No direct script access allowed'
#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# CodeIgniter Path Helpers
#
# @package		CodeIgniter
# @subpackage	Helpers
# @category	Helpers
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/helpers/xml_helper.html
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
    if preg_match("#^(http:\/\/|https:\/\/|www\.|ftp|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})#i", $path)
      show_error('The path you submitted must be a local server path, not a URL')
      
    
    #  Resolve the path
    if function_exists('realpath') and realpath($path) isnt false
      $path = realpath($path) + '/'
      
    
    #  Add a trailing slash
    $path = preg_replace("#([^/])/*$#", "\\1/", $path)
    
    #  Make sure the path exists
    if $check_existance is true
      if not is_dir($path)
        show_error('Not a valid path: ' + $path)
        
      
    
    return $path
    
  


#  End of file path_helper.php 
#  Location: ./system/helpers/path_helper.php 