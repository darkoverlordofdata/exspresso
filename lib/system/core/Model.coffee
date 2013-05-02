#+--------------------------------------------------------------------+
#  Model.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+

#
# Exspresso Model Class
#
module.exports = class system.core.Model

  #
  # Model Constructor
  #
  # Copies the ExspressoControllers public base class properties
  #
  # @param  [core.system.Object]  Controller Instance mixin
  # @return [Void]
  #
  constructor: ($controller) ->

    log_message 'debug', "Model Class Initialized"
    defineProperties @, controller : {writeable: false, value: $controller}

  #
  # Do installation processing
  #
  # @return [Void]
  #
  install: () ->
