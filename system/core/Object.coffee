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

  __SELF__ = @  # reference to this class
  __defineProperties          = Object.defineProperties
  __getOwnPropertyNames       = Object.getOwnPropertyNames
  __getOwnPropertyDescriptor  = Object.getOwnPropertyDescriptor

  #
  # Copy Own Properties
  #
  # Copy all properties from a source or template object
  # Getters, setters, read only, and other custom attributes
  # are safely copied
  #
  # @access	private
  # @param	object	destination object
  # @param	object	source object
  # @return	object
  #
  __copyOwnProperties = ($dst, $src) ->
  
    $properties = {}
    for $key in __getOwnPropertyNames($src)
      $properties[$key] = __getOwnPropertyDescriptor($src, $key)
  
    __defineProperties $dst, $properties
  
  #
  # Insert Super Prototype
  #
  # Follow the __proto__ chain to insert a new prototype object
  #
  # @access	private
  # @param	object  class instance
  # @param	mixed   the prototype to insert
  # @return	void
  #
  __insertProto = ($object, $super, $marker = __SELF__::) ->

    $proto = $object.__proto__
    while ($proto isnt $marker)
      $proto = $proto.__proto__

    $proto.__proto__ = $super
    return


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
      __copyOwnProperties @, $controller
      return $config


    #
    # Copy the prototype properties to 'this' context, so we
    # don't lose them when we reset the prototype
    #
    __copyOwnProperties @, @__proto__

    #
    # Reset the prototype so that we inherit the active controller members
    # The load property is bound so that objects are loaded into the controller
    # and thus propogated to all child members via the protototype.
    # This mimicks the 'magic __get' code used in the original php.
    #
    __insertProto @, $controller

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