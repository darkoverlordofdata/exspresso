#+--------------------------------------------------------------------+
#| Benchmark.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Exspresso is free software you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
# Benchmark Class
#
# Parses URIs and determines routing
#
{FCPATH}        = require(process.cwd() + '/index')     # '/var/www/Exspresso/'
{BASEPATH}      = require(FCPATH + '/index')            # '/var/www/Exspresso/system/'
{array_merge}   = require(FCPATH + '/helper')           # Merge one or more arrays.
{file_exists}   = require(FCPATH + '/helper')           # Checks whether a file or directory exists.
{is_dir}        = require(FCPATH + '/helper')           # Tells whether the filename is a directory.
{load_class}    = require(BASEPATH + 'core/Common')     # Class registry.
{log_message}   = require(BASEPATH + 'core/Common')     # Error Logging Interface.
{Exspresso}     = require(BASEPATH + 'core/Common')     # Core framework library


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
	mark : ($name) =>
		@marker[$name] = new Date().getTime()
		
	
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
	elapsed_time : ($point1 = '', $point2 = '', $decimals = 4) =>
		if $point1 is ''
			return '{elapsed_time}'

		if not @marker[$point1]?
			return ''
			
		
		if not @marker[$point2]? 
			@marker[$point2] = new Date().getTime()
			
		return (@marker[$point2] - @marker[$point1]) + ' ms'

	
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
	memory_usage :  =>
		return '{memory_usage}'
		
	
	

#  END CI_Benchmark class

Exspresso.CI_Benchmark = CI_Benchmark
module.exports = CI_Benchmark

#  End of file Benchmark.php 
#  Location: ./system/core/Benchmark.php 