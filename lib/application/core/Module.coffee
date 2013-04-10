#+--------------------------------------------------------------------+
#| Module.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#  ------------------------------------------------------------------------
#
#	Class application.core.Module
#
class application.core.Module

  name          : ''
  description   : ''
  active        : true

  #
  # Set the properties
  #
  # @param  [system.core.Exspresso] controller  the system controller
  #
  constructor: ($controller) ->

    defineProperties @, controller : {writeable: false, value: $controller}

  install: ->


  uninstall: ->



# END CLASS Module
module.exports = application.core.Module
# End of file Module.coffee
# Location: .application/lib/Module.coffee