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
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{array_merge, dirname, file_exists, is_dir, ltrim, realpath, rtrim, strrchr, trim, ucfirst} = require(FCPATH + 'helper')
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message} = require(BASEPATH + 'core/Common')
{load_object} = require(BASEPATH + 'core/Common')

app             = require(BASEPATH + 'core/Exspresso')  # Exspresso bootstrap module

module.exports = () ->

  ##
  # add messages to the flash message
  # queue for this session
  ##
  app.response.message = (msg) ->

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
  app.use (req, res, next) ->

    # make the message queue available the template engine
    res.locals.messages = req.session.messages ? []

    # clear session messages for next time through
    req.session.messages = []

    # do the next middleware in the queue
    next()
    return


