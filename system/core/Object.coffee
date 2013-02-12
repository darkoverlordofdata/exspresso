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

  __hasOwnProperty = Object.hasOwnProperty

  @get $_GET    : -> @input.get()
  @get $_POST   : -> @input.post()
  @get $_SERVER : -> @input.server()
  @get $_COOKIE : -> @input.cookie()

  #
  # Library Class Constructor
  #
  # Copies the config properties with underscore prefix
  # Mixin the Exspresso_Controller public properties
  #
  # @access	public
  # @param	object
  # @param	object
  # @return	void
  #
  constructor: ($Exspresso, $config = {}) ->

    #
    # if 2nd param is boolean, we're cloning a parent object
    #
    if typeof $config is 'boolean'
      @[$key] = $obj for $key, $obj of $Exspresso
      return $config
    #
    # Mixin the base controller members
    #
    for $key, $obj of $Exspresso
      if $key[0] isnt '_' and __hasOwnProperty.call($Exspresso, $key)
        @[$key] = $obj
    #
    # Initialize config preferences
    #
    for $key, $val of $config
      if @['_'+$key]?
        @['_'+$key] = $val


# END CLASS Object
module.exports = Exspresso_Object
# End of file Object.coffee
# Location: .system/core/Object.coffee