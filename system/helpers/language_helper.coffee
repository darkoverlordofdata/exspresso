#+--------------------------------------------------------------------+
#  language_helper.coffee
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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package		Exspresso
# @author		darkoverlordofdata
# @copyright	Copyright (c) 2012, Dark Overlord of Data
# @license		MIT License
# @link		http://darkoverlordofdata.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# Exspresso Language Helpers
#
# @package		Exspresso
# @subpackage	Helpers
# @category	Helpers
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/helpers/language_helper.html
#

#  ------------------------------------------------------------------------

#
# Lang
#
# Fetches a language variable and optionally outputs a form label
#
# @access	public
# @param	string	the language line
# @param	string	the id of the form element
# @return	string
#
if not function_exists('lang')
  exports.lang = lang = ($line, $id = '') ->
    $CI = Exspresso
    $line = $CI.lang.line($line)
    
    if $id isnt ''
      $line = '<label for="' + $id + '">' + $line + "</label>"
      
    
    return $line

#  ------------------------------------------------------------------------
#
# Export helpers to the global namespace
#
#
for $name, $body of module.exports
  define $name, $body



#  ------------------------------------------------------------------------
#  End of file language_helper.php 
#  Location: ./system/helpers/language_helper.php 