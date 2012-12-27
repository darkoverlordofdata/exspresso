#+--------------------------------------------------------------------+
#| home.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	Home page
#
#
#
require APPPATH+'core/PublicController.coffee'

class Home extends PublicController

  ## --------------------------------------------------------------------

  #
  # Index
  #
  # Display the home page
  #
  #   @access	public
  #   @return	void
  #
  index: ->

    @template.set_title config_item('site_name')

    @db.from 'blog'
    @db.where 'id', '1'
    @db.get ($err, $blog) =>

      if $err then show_error
      else @template.view 'home_page', blog: $blog.row()

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
module.exports = Home

# End of file home.coffee
# Location: .application/controllers/home.coffee