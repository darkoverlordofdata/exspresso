#+--------------------------------------------------------------------+
#| EX_Loader.coffee
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
#	EX_Loader - Main application
#
#
#
require APPPATH + 'libraries/MX/Loader.coffee'

class global.EX_Loader extends MX_Loader

  constructor: ->

    log_message 'debug', 'EX_Loader initialized'
    super()


module.exports = EX_Loader
# End of file EX_Loader.coffee
# Location: ./application/core/EX_Loader.coffee