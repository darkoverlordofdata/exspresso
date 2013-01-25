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
# Exspresso Typography Helpers
#
# @package		Exspresso
# @subpackage	Helpers
# @category	Helpers
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/helpers/typography_helper.html
#

#  ------------------------------------------------------------------------

#
# Convert newlines to HTML line breaks except within PRE tags
#
# @access	public
# @param	string
# @return	string
#
if not function_exists('nl2br_except_pre')
  exports.nl2br_except_pre = nl2br_except_pre = ($str) ->

    @Exspresso.load.library('typography')
    
    return @Exspresso.typography.nl2br_except_pre($str)
    
  

#  ------------------------------------------------------------------------

#
# Auto Typography Wrapper Function
#
#
# @access	public
# @param	string
# @param	bool	whether to allow javascript event handlers
# @param	bool	whether to reduce multiple instances of double newlines to two
# @return	string
#
if not function_exists('auto_typography')
  exports.auto_typography = auto_typography = ($str, $strip_js_event_handlers = true, $reduce_linebreaks = false) ->

    @Exspresso.load.library('typography')
    return @Exspresso.typography.auto_typography($str, $strip_js_event_handlers, $reduce_linebreaks)
    
  


#  --------------------------------------------------------------------

#
# HTML Entities Decode
#
# This function is a replacement for html_entity_decode()
#
# @access	public
# @param	string
# @return	string
#
if not function_exists('entity_decode')
  exports.entity_decode = entity_decode = ($str, $charset = 'UTF-8') ->

    return $SEC.entity_decode($str, $charset)
    
  

#  End of file typography_helper.php 
#  Location: ./system/helpers/typography_helper.php 