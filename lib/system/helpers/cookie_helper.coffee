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
# Exspresso Cookie Helpers
#
#

#  ------------------------------------------------------------------------

#
# Set cookie
#
# Accepts six parameter, or you can submit an associative
# array in the first parameter containing all the values.
#
# @param  [Mixed]  # @param  [String]  the value of the cookie
# @param  [String]  the number of seconds until expiration
# @param  [String]  the cookie domain.  Usually:  .yourdomain.com
# @param  [String]  the cookie path
# @param  [String]  the cookie prefix
# @return [Void]  #
if not function_exists('setCookie')
  exports.setCookie = setCookie = ($name = '', $value = '', $expire = '', $domain = '', $path = '/', $prefix = '', $secure = false) ->
    #  Set the config file options

    @input.setCookie($name, $value, $expire, $domain, $path, $prefix, $secure)
    
  

#  --------------------------------------------------------------------

#
# Fetch an item from the COOKIE array
#
# @param  [String]  # @return	[Boolean]
# @return [Mixed]  #
if not function_exists('get_cookie')
  exports.get_cookie = get_cookie = ($index = '', $xss_clean = false) ->

    $prefix = ''
    
    if not @req.cookies[$index]?  and config_item('cookie_prefix') isnt ''
      $prefix = config_item('cookie_prefix')
      
    
    return @input.cookie($prefix + $index, $xss_clean)
    
  

#  --------------------------------------------------------------------

#
# Delete a COOKIE
#
# @param  [Mixed]  # @param  [String]  the cookie domain.  Usually:  .yourdomain.com
# @param  [String]  the cookie path
# @param  [String]  the cookie prefix
# @return [Void]  #
if not function_exists('delete_cookie')
  exports.delete_cookie = delete_cookie = ($name = '', $domain = '', $path = '/', $prefix = '') ->
    setCookie($name, '', '', $domain, $path, $prefix)
    
  


#  End of file cookie_helper.php 
#  Location: ./system/helpers/cookie_helper.php 