#+--------------------------------------------------------------------+
#  xml_helper.coffee
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
{defined, function_exists, preg_replace, str_replace}  = require(FCPATH + 'lib')


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
# CodeIgniter XML Helpers
#
# @package		CodeIgniter
# @subpackage	Helpers
# @category	Helpers
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/helpers/xml_helper.html
#

#  ------------------------------------------------------------------------

#
# Convert Reserved XML characters to Entities
#
# @access	public
# @param	string
# @return	string
#
if not function_exists('xml_convert')
  exports.xml_convert = xml_convert = ($str, $protect_all = false) ->
    $temp = '__TEMP_AMPERSANDS__'
    
    #  Replace entities to temporary markers so that
    #  ampersands won't get messed up
    $str = preg_replace("/&#(\d+);/", "$temp\\1;", $str)
    
    if $protect_all is true
      $str = preg_replace("/&(\w+);/", "$temp\\1;", $str)
      
    
    $str = str_replace(["&", "<", ">", "\"", "'", "-"], 
    ["&amp;", "&lt;", "&gt;", "&quot;", "&apos;", "&#45;"], 
    $str)
    
    #  Decode the temp markers back to entities
    $str = preg_replace("/$temp(\d+);/", "&#\\1;", $str)
    
    if $protect_all is true
      $str = preg_replace("/$temp(\w+);/", "&\\1;", $str)
      
    
    return $str
    
  

#  ------------------------------------------------------------------------

#  End of file xml_helper.php 
#  Location: ./system/helpers/xml_helper.php 