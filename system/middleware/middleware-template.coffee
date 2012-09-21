#+--------------------------------------------------------------------+
#| ${NAME}.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	${NAME}
#
#

#
# register the middleware with the server
#
#   @param {Object} express connect server
#   @param {Object} Exspresso configuration
#
module.exports = (server, config) ->

  #
  # ${NAME} middleware
  #
  #   @param {Object} server request object
  #   @param {Object} server response object
  #   @param {Object} next middleware
  #
  server.use (req, res, next) ->

    next()


# End of file ${NAME}.coffee
# Location: ./system/middleware/${NAME}.coffee