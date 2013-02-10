#+--------------------------------------------------------------------+
#| Class.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#  ------------------------------------------------------------------------
#
#	Base Library Class
#
class global.Exspresso_Class

  __hasOwnProperty = Object.hasOwnProperty
  __defineProperty = Object.defineProperty

  #
  # Library Class Constructor
  #
  # Copies the config properties with underscore prefix
  # Copies the Exspresso_Controllers public base class properties
  #
  # @access	public
  # @param	object
  # @return	void
  #
  constructor: ($config = {}, $Exspresso) ->

    for $key, $val of $config
      if @['_'+$key]?
        @['_'+$key] = $val

    for $key, $obj of $Exspresso
      if $key[0] isnt '_' and __hasOwnProperty.call($Exspresso, $key)
        __defineProperty @, $key, {value: $obj, writeable: false}


# END CLASS Class
module.exports = Exspresso_Class
# End of file Class.coffee
# Location: ./libraries/Class.coffee