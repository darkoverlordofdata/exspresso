#+--------------------------------------------------------------------+
#| Object.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software you can copy, modify, and distribute
#| it under the terms of the MIT License
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

class system.core.Object

#
# define a property
#
# @access	public
# @param	object  propery attributes
# @return	void
#
  property: ($def) ->
    for $name, $object of $def
      defineProperty @, $name,
        enumerable  : if $name[0] is '_' then false else true
        writeable   : false
        value       : $object
      return

  #
  # define a list of properties
  #
  # @access	public
  # @param	object  propery attributes
  # @return	void
  #
  properties: ($def) ->

    $properties = {}
    for $name, $object of $def
      $properties[$name] =
        enumerable  : if $name[0] is '_' then false else true
        writeable   : false
        value       : $object

    defineProperties @, $properties




# END CLASS Object
module.exports = system.core.Object
# End of file Object.coffee
# Location: .system/core/Object.coffee