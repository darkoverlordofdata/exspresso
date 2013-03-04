#+--------------------------------------------------------------------+
#  number_helper.coffee
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
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Number Helpers
#
#

#  ------------------------------------------------------------------------

#
# Formats a numbers as bytes, based on size, and adds the appropriate suffix
#
# @access	public
# @param	mixed	// will be cast as int
# @return	string
#
if not function_exists('byte_format')
  exports.byte_format = byte_format = ($num, $precision = 1) ->
    Exspresso.lang.load('number')
    
    if $num>=1000000000000
      $num = round($num / 1099511627776, $precision)
      $unit = Exspresso.lang.line('terabyte_abbr')
      
    else if $num>=1000000000
      $num = round($num / 1073741824, $precision)
      $unit = Exspresso.lang.line('gigabyte_abbr')
      
    else if $num>=1000000
      $num = round($num / 1048576, $precision)
      $unit = Exspresso.lang.line('megabyte_abbr')
      
    else if $num>=1000
      $num = round($num / 1024, $precision)
      $unit = Exspresso.lang.line('kilobyte_abbr')
      
    else 
      $unit = Exspresso.lang.line('bytes')
      return number_format($num) + ' ' + $unit
      
    
    return number_format($num, $precision) + ' ' + $unit


#  ------------------------------------------------------------------------
#
# Export helpers to the global namespace
#
#
for $name, $body of module.exports
  define $name, $body


#  End of file number_helper.php 
#  Location: ./system/helpers/number_helper.php 