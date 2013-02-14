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
  # Copies the config properties with underscore prefix
  # Mixin the Exspresso_Controller public properties
  #
  # @access	public
  # @param	object  the parent controller object
  # @param	mixed   initial config values, or true to clone from parent
  # @return	void
  #
  constructor: ($controller, $config = {}) ->

    if typeof $config is 'boolean'
      #
      # clone the parent object
      #
      $properties = {}
      for $key in __getOwnPropertyNames($controller)
        $properties[$key] = __getOwnPropertyDescriptor($controller, $key)
      __defineProperties @, $properties
      return $config

    #
    # Mixin the controller public members
    #
    $properties = {}
    for $key in __getOwnPropertyNames($controller)
      #
      # skip protected members
      # don't override
      #
      if $key[0] isnt '_' and not @[$key]?
        $properties[$key] = __getOwnPropertyDescriptor($controller, $key)
    __defineProperties @, $properties
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