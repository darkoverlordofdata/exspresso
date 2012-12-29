#+--------------------------------------------------------------------+
#| welcome.coffee
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
#	Welcome
#
# This is the default controller
#

class Welcome extends MY_Controller

  ## --------------------------------------------------------------------

  #
  # Index
  #
  # Demo welcome page
  #
  #   @access	public
  #   @return	void
  #
  index: ->

    @output.enable_profiler true
    @load.view 'welcome_message'




#
# Export the class:
#
module.exports = Welcome

# End of file Welcome.coffee
# Location: .application/controllers/Welcome.coffee
