#+--------------------------------------------------------------------+
#  security_helper.coffee
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
# @copyright  Copyright (c) 2012, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Security Helpers
#
# @package		Exspresso
# @subpackage	Helpers
# @category	Helpers
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/helpers/security_helper.html
#

#  ------------------------------------------------------------------------

#
# XSS Filtering
#
# @access	public
# @param	string
# @param	bool	whether or not the content is an image file
# @return	string
#
if not function_exists('xss_clean')
  exports.xss_clean = xss_clean = ($str, $is_image = false) ->
    return Exspresso.security.xss_clean($str, $is_image)
    
  

#  ------------------------------------------------------------------------

#
# Sanitize Filename
#
# @access	public
# @param	string
# @return	string
#
if not function_exists('sanitize_filename')
  exports.sanitize_filename = sanitize_filename = ($filename) ->
    return Exspresso.security.sanitize_filename($filename)
    
  

#  --------------------------------------------------------------------

#
# Hash encode a string
#
# @access	public
# @param	string
# @return	string
#
if not function_exists('do_hash')
  exports.do_hash = do_hash = ($str, $type = 'sha1') ->
    if $type is 'sha1'
      return sha1($str)
      
    else 
      return md5($str)
      
    
  

#  ------------------------------------------------------------------------

#
# Strip Image Tags
#
# @access	public
# @param	string
# @return	string
#
if not function_exists('strip_image_tags')
  exports.strip_image_tags = strip_image_tags = ($str) ->
    $str = preg_replace("#<img\s+.*?src\s*=\s*[\"'](.+?)[\"'].*?\>#", "\\1", $str)
    $str = preg_replace("#<img\s+.*?src\s*=\s*(.+?).*?\>#", "\\1", $str)
    
    return $str
    
  

#  ------------------------------------------------------------------------

#
# Convert PHP tags to entities
#
# @access	public
# @param	string
# @return	string
#
if not function_exists('encode_php_tags')
  exports.encode_php_tags = encode_php_tags = ($str) ->
    return str_replace(['<?php', '<?PHP', '<?', '?>'], ['&lt;?php', '&lt;?PHP', '&lt;?', '?&gt;'], $str)
    
  


#  End of file security_helper.php 
#  Location: ./system/helpers/security_helper.php 