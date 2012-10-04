#+--------------------------------------------------------------------+
#  cookie_helper.coffee
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
{cookie, defined, function_exists, get_instance, input}  = require(FCPATH + 'helper')
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
# CodeIgniter Cookie Helpers
#
# @package		CodeIgniter
# @subpackage	Helpers
# @category	Helpers
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/helpers/cookie_helper.html
#

#  ------------------------------------------------------------------------

#
# Set cookie
#
# Accepts six parameter, or you can submit an associative
# array in the first parameter containing all the values.
#
# @access	public
# @param	mixed
# @param	string	the value of the cookie
# @param	string	the number of seconds until expiration
# @param	string	the cookie domain.  Usually:  .yourdomain.com
# @param	string	the cookie path
# @param	string	the cookie prefix
# @return	void
#
if not function_exists('set_cookie')
  exports.set_cookie = set_cookie = ($name = '', $value = '', $expire = '', $domain = '', $path = '/', $prefix = '', $secure = false) ->
    #  Set the config file options
    $CI = get_instance()
    $CI.input.set_cookie($name, $value, $expire, $domain, $path, $prefix, $secure)
    
  

#  --------------------------------------------------------------------

#
# Fetch an item from the COOKIE array
#
# @access	public
# @param	string
# @param	bool
# @return	mixed
#
if not function_exists('get_cookie')
  exports.get_cookie = get_cookie = ($index = '', $xss_clean = false) ->
    $CI = get_instance()
    
    $prefix = ''
    
    if not $_COOKIE[$index]?  and config_item('cookie_prefix') isnt ''
      $prefix = config_item('cookie_prefix')
      
    
    return $CI.input.cookie($prefix + $index, $xss_clean)
    
  

#  --------------------------------------------------------------------

#
# Delete a COOKIE
#
# @param	mixed
# @param	string	the cookie domain.  Usually:  .yourdomain.com
# @param	string	the cookie path
# @param	string	the cookie prefix
# @return	void
#
if not function_exists('delete_cookie')
  exports.delete_cookie = delete_cookie = ($name = '', $domain = '', $path = '/', $prefix = '') ->
    set_cookie($name, '', '', $domain, $path, $prefix)
    
  


#  End of file cookie_helper.php 
#  Location: ./system/helpers/cookie_helper.php 