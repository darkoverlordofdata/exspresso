#+--------------------------------------------------------------------+
#| welcome.coffee
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
#	Welcome
#
# This is the default controller
#
{FCPATH}        = require(process.cwd() + '/index')     # '/var/www/Exspresso/'
{BASEPATH}      = require(FCPATH + 'index')             # '/var/www/Exspresso/system/'
{log_message}   = require(BASEPATH + 'core/Common')     # Error Logging Interface.
CI_Controller   = require(BASEPATH + 'core/Controller') # Exspresso Controller Base Class


class Welcome extends CI_Controller

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

    @render 'welcome_message'


  ## --------------------------------------------------------------------

  #
  # About
  #
  # About this site:
  #
  #   http://0.0.0.0:5000/about/42
  #
  #   @access	public
  #   @param string test id to echo back
  #   @return	void
  #
  about: ($id) ->

    $id = parseInt($id,10)

    @render 'about',
      id: $id

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

    @render 'errors/404',
      url: 'invalid uri'

#
# Export the class:
#
module.exports = Welcome

# End of file Travel.coffee
# Location: .application/controllers/Welcome.coffee
