#+--------------------------------------------------------------------+
#  language_helper.coffee
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
{defined, function_exists, get_instance, line}  = require(FCPATH + 'pal')


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
# CodeIgniter Language Helpers
#
# @package		CodeIgniter
# @subpackage	Helpers
# @category	Helpers
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/helpers/language_helper.html
#

#  ------------------------------------------------------------------------

#
# Lang
#
# Fetches a language variable and optionally outputs a form label
#
# @access	public
# @param	string	the language line
# @param	string	the id of the form element
# @return	string
#
if not function_exists('lang')
  exports.lang = lang = ($line, $id = '') ->
    $CI = get_instance()
    $line = $CI.lang.line($line)
    
    if $id isnt ''
      $line = '<label for="' + $id + '">' + $line + "</label>"
      
    
    return $line
    
  

#  ------------------------------------------------------------------------
#  End of file language_helper.php 
#  Location: ./system/helpers/language_helper.php 