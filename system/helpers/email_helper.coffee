#+--------------------------------------------------------------------+
#  email_helper.coffee
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
# CodeIgniter Email Helpers
#
# @package		CodeIgniter
# @subpackage	Helpers
# @category	Helpers
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/helpers/email_helper.html
#

#  ------------------------------------------------------------------------

#
# Validate email address
#
# @access	public
# @return	bool
#
if not function_exists('valid_email')
  exports.valid_email = valid_email = ($address) ->
    return if ( not preg_match("/^([a-z0-9\+_\-]+)(\.[a-z0-9\+_\-]+)*@([a-z0-9\-]+\.)+[a-z]{2,6}$/ix", $address)) then false else true
    
  

#  ------------------------------------------------------------------------

#
# Send an email
#
# @access	public
# @return	bool
#
if not function_exists('send_email')
  exports.send_email = send_email = ($recipient, $subject = 'Test email', $message = 'Hello World') ->
    return mail($recipient, $subject, $message)
    
  


#  End of file email_helper.php 
#  Location: ./system/helpers/email_helper.php 