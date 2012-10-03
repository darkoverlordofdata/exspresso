#+--------------------------------------------------------------------+
#  typography_helper.coffee
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
{defined, function_exists, get_instance, library, load, typography}	= require(FCPATH + 'helper')



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
# CodeIgniter Typography Helpers
#
# @package		CodeIgniter
# @subpackage	Helpers
# @category	Helpers
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/helpers/typography_helper.html
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
		$CI = get_instance()
		
		$CI.load.library('typography')
		
		return $CI.typography.nl2br_except_pre($str)
		
	

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
		$CI = get_instance()
		$CI.load.library('typography')
		return $CI.typography.auto_typography($str, $strip_js_event_handlers, $reduce_linebreaks)
		
	


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
		exports.$SEC
		return $SEC.entity_decode($str, $charset)
		
	

#  End of file typography_helper.php 
#  Location: ./system/helpers/typography_helper.php 