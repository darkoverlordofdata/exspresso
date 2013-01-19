#+--------------------------------------------------------------------+
#| MY_Loader.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#	EX_Loader - Main application
#
#
#
require APPPATH + 'libraries/MX/Loader.coffee'

class global.MY_Loader extends MX_Loader

  constructor: ->

    log_message 'debug', 'MY_Loader initialized'
    super()


module.exports = MY_Loader
# End of file MY_Loader.coffee
# Location: ./application/core/MY_Loader.coffee