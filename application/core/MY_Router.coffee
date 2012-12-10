#+--------------------------------------------------------------------+
#| MY_Router.coffee
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
#	MY_Router - Main application
#
#
#
require APPPATH + 'libraries/MX/Router.coffee'

class global.MY_Router extends MX_Router

  constructor: ->

    log_message 'debug', 'MY_Router initialized'
    super()


module.exports = MY_Router
# End of file MY_Router.coffee
# Location: ./application/core/MY_Router.coffee