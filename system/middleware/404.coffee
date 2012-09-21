#+--------------------------------------------------------------------+
#| _5xx.coffee
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
#	internal error 5xx
#

module.exports = (server) ->

  #
  # handle 404 not found error
  #
  server.use (req, res, next) ->

    res.status(404).render 'errors/404', url: req.originalUrl
    return

