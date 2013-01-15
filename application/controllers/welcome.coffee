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

class Welcome extends PublicController

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

    @template.view 'welcome_message'


  ## --------------------------------------------------------------------

  #
  # Not Found
  #
  # Custom 404 error page
  #
  #   @access	public
  #   @return	void
  #
  not_found: ->

    #@template.set_title config_item('site_name'), '404 Not Found'
    @load.view 'errors/404',
      url: 'invalid uri'



#
# Export the class:
#
module.exports = Welcome

# End of file Welcome.coffee
# Location: .application/controllers/Welcome.coffee
