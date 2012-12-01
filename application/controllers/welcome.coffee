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

    @load.view 'welcome_message'



  varz: ($name) ->

    console.log $_SERVER

    @load.view 'server_vars', server_vars: $_SERVER

  ## --------------------------------------------------------------------

  #
  # Edit
  #
  # ckedit demo
  #
  #   @access	public
  #   @return	void
  #
  edit: ->

    @db = @load.database('mysql', true)
    @db.initialize =>

      @db.from 'blog'
      @db.where 'id', '1'
      @db.get ($err, $blog) =>

        @load.view 'ckeditor', blog: $blog.row()


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

    @load.view 'errors/404',
      url: 'invalid uri'

#
# Export the class:
#
module.exports = Welcome

# End of file Welcome.coffee
# Location: .application/controllers/Welcome.coffee
