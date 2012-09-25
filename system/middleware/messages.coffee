#+--------------------------------------------------------------------+
#| messages.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of DarkRoast
#|
#| DarkRoast is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	cache a flash message queue
#
module.exports = (server) ->

  ##
  # add messages to the flash message
  # queue for this session
  ##
  server.response.message = (msg) ->

    sess = @req.session

    # ensure the seesion has a messages queue
    sess.messages = sess.messages ? []

    # add to the message queue
    sess.messages.push msg
    return @

  ##
  # expose messages to template engine
  # while the views are rendering
  ##
  server.use (req, res, next) ->

    # make the message queue available the template engine
    res.locals.messages = req.session.messages ? []

    # clear session messages for next time through
    req.session.messages = []

    # do the next middleware in the queue
    next()
    return


