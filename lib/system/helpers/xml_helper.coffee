#+--------------------------------------------------------------------+
#  xml_helper.coffee
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
# Exspresso XML Helpers
#
#

#  ------------------------------------------------------------------------

#
# Convert Reserved XML characters to Entities
#
# @param  [String]  # @return	[String]
#
if not function_exists('xml_convert')
  exports.xml_convert = xml_convert = ($str, $protect_all = false) ->
    $temp = '__TEMP_AMPERSANDS__'
    
    #  Replace entities to temporary markers so that
    #  ampersands won't get messed up
    $str = preg_replace("/&#(\\d+);/", "#{$temp}$1;", $str)
    
    if $protect_all is true
      $str = preg_replace("/&(\\w+);/", "#{$temp}$1;", $str)
      
    
    $str = str_replace(["&", "<", ">", "\"", "'", "-"], 
    ["&amp;", "&lt;", "&gt;", "&quot;", "&apos;", "&#45;"], 
    $str)
    
    #  Decode the temp markers back to entities
    $str = preg_replace("/#{$temp}(\\d+);/", "&#$1;", $str)
    
    if $protect_all is true
      $str = preg_replace("/#{$temp}(\\w+);/", "&$1;", $str)
      
    
    return $str


#  ------------------------------------------------------------------------
#
# Export helpers to the global namespace
#
#
for $name, $body of module.exports
  define $name, $body

#  ------------------------------------------------------------------------

#  End of file xml_helper.php 
#  Location: ./system/helpers/xml_helper.php 