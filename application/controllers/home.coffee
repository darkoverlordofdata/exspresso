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

    console.log '----------------------'
    console.log @res
    console.log '----------------------'

    @res.send "hello"

  index1: ->
    @template.set_title config_item('site_name')

    @db.from 'blog'
    @db.where 'id', '1'
    @db.get ($err, $blog) =>

      if $err then return show_error

      $data = array_merge({blog: $blog.row()}, @load.helper('html'))

      @template.view 'home_page', $data

#
# Export the class:
#
module.exports = Home

# End of file home.coffee
# Location: .application/controllers/home.coffee