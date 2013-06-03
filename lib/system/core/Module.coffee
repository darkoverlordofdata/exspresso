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
#	Class application.core.Module
#
module.exports = class system.core.Module

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

