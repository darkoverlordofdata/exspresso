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
# Exspresso Number Helpers
#
#

#  ------------------------------------------------------------------------

#
# Formats a numbers as bytes, based on size, and adds the appropriate suffix
#
# @param  [Mixed]  // will be cast as int
# @return	[String]
#
if not function_exists('byte_format')
  exports.byte_format = byte_format = ($num, $precision = 1) ->
    exspresso.lang.load('number')
    
    if $num>=1000000000000
      $num = Math.round($num / 1099511627776, $precision)
      $unit = exspresso.lang.line('terabyte_abbr')
      
    else if $num>=1000000000
      $num = Math.round($num / 1073741824, $precision)
      $unit = exspresso.lang.line('gigabyte_abbr')
      
    else if $num>=1000000
      $num = Math.round($num / 1048576, $precision)
      $unit = exspresso.lang.line('megabyte_abbr')
      
    else if $num>=1000
      $num = Math.round($num / 1024, $precision)
      $unit = exspresso.lang.line('kilobyte_abbr')
      
    else 
      $unit = exspresso.lang.line('bytes')
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