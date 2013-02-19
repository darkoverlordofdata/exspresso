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
#	Exspresso Base Object
#
class global.Exspresso_Object

  __hasOwnProperty            = Object.hasOwnProperty
  __defineProperty            = Object.defineProperty
  __defineProperties          = Object.defineProperties
  __getOwnPropertyNames       = Object.getOwnPropertyNames
  __getOwnPropertyDescriptor  = Object.getOwnPropertyDescriptor


  #
  # Exspresso Constructor
  #
  # Mixin the Exspresso_Controller public properties
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
      # perform a shallow clone all of the properties as is.
      #
      $properties = {}
      for $key in __getOwnPropertyNames($controller)
        $properties[$key] = __getOwnPropertyDescriptor($controller, $key)
      __defineProperties @, $properties
      return $config


    #
    # Copy the prototype properties to 'this' context, so we
    # don't lose them when we reset the prototype
    #
    $properties = {}
    for $key in __getOwnPropertyNames(@__proto__)
      $properties[$key] = __getOwnPropertyDescriptor(@__proto__, $key)
    __defineProperties @, $properties
    #
    # Reset the prototype so that we inherit the active controller members
    # The load property is bound so that objects are loaded into the controller
    # and thus propogated to all child members via the protototype, thus
    # mimicking the 'magic __get' used in the original php.
    #
    @__proto__ = $controller

    #
    # Initialize the config preferences
    #
    for $key, $val of $config
      if @['_'+$key]?
        @['_'+$key] = $val


# END CLASS Object
module.exports = Exspresso_Object
# End of file Object.coffee
# Location: .system/core/Object.coffee