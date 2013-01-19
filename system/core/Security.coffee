#+--------------------------------------------------------------------+
#| Output.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#	Output - Main application
#
#
#
express         = require('express')                    # Express 3.0 Framework

#  ------------------------------------------------------------------------

#
# Exspresso Security Class
#
module.exports = class global.Exspresso_Security

  constructor: ->

    @_initialize()

    log_message('debug', "Security Class Initialized")

  ## --------------------------------------------------------------------

  #
  # Initialize Security
  #
  #
  #   @access	private
  #   @return	void
  #
  _initialize: () ->


    return

# END Exspresso_Security class

# End of file Security.coffee
# Location: ./system/core/Security.coffee