#+--------------------------------------------------------------------+
#| EX_Router.coffee
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
#	EX_Router - Main application
#
#
#
require APPPATH + 'libraries/MX/Router.coffee'

class global.EX_Router extends MX_Router

  constructor: ->

    log_message 'debug', 'EX_Router initialized'
    super()


module.exports = EX_Router
# End of file EX_Router.coffee
# Location: ./application/core/EX_Router.coffee