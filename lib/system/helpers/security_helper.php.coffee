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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Security Helpers
#
#

#  ------------------------------------------------------------------------

#
# XSS Filtering
#
# @param  [String]  # @return	[Boolean]	whether or not the content is an image file
# @return	[String]
#
if not function_exists('xssClean')
  exports.xssClean = xssClean = ($str, $is_image = false) ->
    return @security.xssClean($str, $is_image)
    
  

#  ------------------------------------------------------------------------

#
# Sanitize Filename
#
# @param  [String]  # @return	[String]
#
if not function_exists('sanitizeFilename')
  exports.sanitizeFilename = sanitizeFilename = ($filename) ->
    return @security.sanitizeFilename($filename)
    
  

#  --------------------------------------------------------------------

#
# Hash encode a string
#
# @param  [String]  # @return	[String]
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
# @param  [String]  # @return	[String]
#
if not function_exists('strip_image_tags')
  exports.strip_image_tags = strip_image_tags = ($str) ->
    $str = preg_replace("#<img\\s+.*?src\\s*=\\s*[\\\"\'](.+?)[\\\"\'].*?\>#", "$1", $str)
    $str = preg_replace("#<img\\s+.*?src\\s*=\\s*(.+?).*?\\>#", "$1", $str)
    
    return $str
    
  




#  End of file security_helper.php 
#  Location: ./system/helpers/security_helper.php 