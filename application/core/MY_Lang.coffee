#+--------------------------------------------------------------------+
#| MY_Lang.coffee
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
#	MY_Lang - Main application
#
#
#
require APPPATH + 'libraries/MX/Lang.coffee'

class global.MY_Lang extends MX_Lang

  constructor: ->

    log_message 'debug', 'MY_Lang initialized'
    super()


module.exports = MY_Lang

# End of file MY_Lang.coffee
# Location: ./MY_Lang.coffee