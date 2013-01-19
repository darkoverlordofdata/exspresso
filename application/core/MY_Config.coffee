#+--------------------------------------------------------------------+
#| MY_Config.coffee
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
#	MY_Config - Main application
#
#
#
require APPPATH + 'libraries/MX/Config.coffee'

class global.MY_Config extends MX_Config

  constructor: ->

    log_message 'debug', 'MY_Config initialized'
    super()


module.exports = MY_Config


# End of file MY_Config.coffee
# Location: ./MY_Config.coffee