#+--------------------------------------------------------------------+
#| Output.coffee
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
#	Output - Main application
#
#
#

#  ------------------------------------------------------------------------

#
# Exspresso Security Class
#
class global.Exspresso_Security

  express         = require('express')                    # Express 3.0 Framework
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
module.exports = Exspresso_Security

# End of file Security.coffee
# Location: ./system/core/Security.coffee