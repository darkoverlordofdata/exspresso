#+--------------------------------------------------------------------+
#  typography_helper.coffee
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
# Exspresso Typography Helpers
#
#

#  ------------------------------------------------------------------------

#
# Convert newlines to HTML line breaks except within PRE tags
#
# @param  [String]  # @return	[String]
#
if not function_exists('nl2br_except_pre')
  exports.nl2br_except_pre = nl2br_except_pre = ($str) ->

    @load.library('typography')
    
    return @typography.nl2br_except_pre($str)
    
  

#  ------------------------------------------------------------------------

#
# Auto Typography Wrapper Function
#
#
# @param  [String]  # @return	[Boolean]	whether to allow javascript event handlers
# @return	[Boolean]	whether to reduce multiple instances of double newlines to two
# @return	[String]
#
if not function_exists('auto_typography')
  exports.auto_typography = auto_typography = ($str, $strip_js_event_handlers = true, $reduce_linebreaks = false) ->

    @load.library('typography')
    return @typography.auto_typography($str, $strip_js_event_handlers, $reduce_linebreaks)
    
  


#  --------------------------------------------------------------------

#
# HTML Entities Decode
#
# This function is a replacement for html_entityDecode()
#
# @param  [String]  # @return	[String]
#
if not function_exists('entityDecode')
  exports.entityDecode = entityDecode = ($str, $charset = 'UTF-8') ->

    return $SEC.entityDecode($str, $charset)
    
  

#  End of file typography_helper.php 
#  Location: ./system/helpers/typography_helper.php 