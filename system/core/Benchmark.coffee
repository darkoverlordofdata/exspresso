#+--------------------------------------------------------------------+
#  Benchmark.coffee
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
{defined, explode, microtime, number_format}	= require(FCPATH + 'pal')
{config_item, get_class, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')


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
# CodeIgniter Benchmark Class
#
# This class enables you to mark points and calculate the time difference
# between them.  Memory consumption can also be displayed.
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Libraries
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/libraries/benchmark.html
#
class CI_Benchmark
	
	$marker: {}
	
	#  --------------------------------------------------------------------
	
	#
	# Set a benchmark marker
	#
	# Multiple calls to this function can be made so that several
	# execution points can be timed
	#
	# @access	public
	# @param	string	$name	name of the marker
	# @return	void
	#
	mark : ($name) ->
		@marker[$name] = microtime()
		
	
	#  --------------------------------------------------------------------
	
	#
	# Calculates the time difference between two marked points.
	#
	# If the first parameter is empty this function instead returns the
	# {elapsed_time} pseudo-variable. This permits the full system
	# execution time to be shown in a template. The output class will
	# swap the real value for this variable.
	#
	# @access	public
	# @param	string	a particular marked point
	# @param	string	a particular marked point
	# @param	integer	the number of decimal places
	# @return	mixed
	#
	elapsed_time : ($point1 = '', $point2 = '', $decimals = 4) ->
		if $point1 is ''
			return '{elapsed_time}'
			
		
		if not @marker[$point1]? 
			return ''
			
		
		if not @marker[$point2]? 
			@marker[$point2] = microtime()
			
		
		[$sm, $ss] = explode(' ', @marker[$point1])
		[$em, $es] = explode(' ', @marker[$point2])
		
		return number_format(($em + $es) - ($sm + $ss), $decimals)
		
	
	#  --------------------------------------------------------------------
	
	#
	# Memory Usage
	#
	# This function returns the {memory_usage} pseudo-variable.
	# This permits it to be put it anywhere in a template
	# without the memory being calculated until the end.
	# The output class will swap the real value for this variable.
	#
	# @access	public
	# @return	string
	#
	memory_usage :  ->
		return '{memory_usage}'
		
	
	

register_class 'CI_Benchmark', CI_Benchmark
module.exports = CI_Benchmark

#  END CI_Benchmark class

#  End of file Benchmark.php 
#  Location: ./system/core/Benchmark.php 