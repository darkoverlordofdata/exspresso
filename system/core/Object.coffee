#+--------------------------------------------------------------------+
#| Object.coffee
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
#	Exspresso Object
#
# Reset the prototype so that we inherit the controller instance members
# The load property is bound so that objects are loaded into the controller
# and thus propogated to all child members via the protototype.
# This mimicks the 'magic __get' code used in the original php.
#
#

class global.Exspresso_Object

  __SELF__ = @  # reference to this class

  #
  # Exspresso Constructor
  #
  # Mixin the Exspresso_Controller properties
  # Set the config property preferences
  #
  # @access	public
  # @param	object  the parent controller object
  # @param	mixed   initial config values, or true to clone from parent
  # @return	void
  #
  constructor: ($controller, $config = {}) ->

    if typeof $config is 'boolean'
      #
      # The controller is a parent object, we just want to
      # perform a shallow clone of all the properties.
      #
      copyOwnProperties @, $controller
      return $config


    if USE__PROTO__
      # Copy the prototype properties to 'this' context, so we
      # don't lose them when we reset the prototype
      copyOwnProperties @, @__proto__

      # Staring at 'this' object, follow the
      # prototype chain to 'this' class
      $proto = @__proto__
      until $proto is __SELF__::
        $proto = $proto.__proto__

      # set the prototype to the main controller instance
      $proto.__proto__ = $controller

    #
    # Initialize the config preferences
    for $key, $val of $config
      if @['_'+$key]?
        @['_'+$key] = $val


# END CLASS Object
module.exports = Exspresso_Object
# End of file Object.coffee
# Location: .system/core/Object.coffee