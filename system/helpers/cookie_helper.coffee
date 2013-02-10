#+--------------------------------------------------------------------+
#  cookie_helper.coffee
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
# Exspresso Cookie Helpers
#
# @package		Exspresso
# @subpackage	Helpers
# @category	Helpers
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/helpers/cookie_helper.html
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

    Exspresso.input.set_cookie($name, $value, $expire, $domain, $path, $prefix, $secure)
    
  

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

    $prefix = ''
    
    if not @Exspresso.$_COOKIE[$index]?  and config_item('cookie_prefix') isnt ''
      $prefix = config_item('cookie_prefix')
      
    
    return Exspresso.input.cookie($prefix + $index, $xss_clean)
    
  

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