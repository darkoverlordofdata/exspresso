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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Model Class
#

class system.core.Model

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


# END Model class

module.exports = system.core.Model

# End of file Model.coffee
# Location: ./system/core/Model.coffee