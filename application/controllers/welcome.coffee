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
#	welcome - the default controller
#

#
# register the controller with the server
#
#   @param {Object} express connect server
#   @param {Object} Exspresso configuration
#
module.exports = (server, config) ->

  #
  # index
  #
  #   @param {Object} server request object
  #   @param {Object} server response object
  #
  server.get "/", (req, res) ->

    res.render 'welcome_message'
    return
