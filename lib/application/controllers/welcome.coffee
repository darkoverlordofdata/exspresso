#+--------------------------------------------------------------------+
#| welcome.coffee
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
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#  ------------------------------------------------------------------------
#
#	Welcome
#
# This is the default controller
#

class Welcome extends system.core.Controller

  #
  # Index
  #
  # Demo welcome page
  #
  # @access	public
  # @return [Void]
  #
  index: ->

    @load.view 'welcome_message'




#
# Export the class:
#
module.exports = Welcome

# End of file Welcome.coffee
# Location: .application/controllers/Welcome.coffee
