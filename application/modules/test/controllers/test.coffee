#+--------------------------------------------------------------------+
#| test.coffee
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
#	Test
#
# This is the test controller
#

class Test extends CI_Controller

  ## --------------------------------------------------------------------

  #
  # Index
  #
  # Demo Test page
  #
  #   @access	public
  #   @return	void
  #
  index: ->

    @load.view 'test_message'



#
# Export the class:
#
module.exports = Test

# End of file Test.coffee
# Location: .application/controllers/Test.coffee
