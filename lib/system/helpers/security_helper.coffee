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
# Exspresso Security Helpers
#
#

#
# XSS Filtering
#
# @param  [String]
# @return	[Boolean]	whether or not the content is an image file
# @return	[String]
#
exports.xssClean = xssClean = ($str, $is_image = false) ->
  return @security.xssClean($str, $is_image)

#
# Sanitize Filename
#
# @param  [String]
# @return	[String]
#
exports.sanitizeFilename = sanitizeFilename = ($filename) ->
  return @security.sanitizeFilename($filename)

#
# Hash encode a string
#
# @param  [String]
# @return	[String]
#
exports.do_hash = do_hash = ($str, $type = 'sha1') ->
  if $type is 'sha1'
    return sha1($str)

  else
    return md5($str)


#
# Strip Image Tags
#
# @param  [String]
# @return	[String]
#
exports.strip_image_tags = strip_image_tags = ($str) ->
  $str = preg_replace("#<img\\s+.*?src\\s*=\\s*[\\\"\'](.+?)[\\\"\'].*?\>#", "$1", $str)
  $str = preg_replace("#<img\\s+.*?src\\s*=\\s*(.+?).*?\\>#", "$1", $str)

  return $str

