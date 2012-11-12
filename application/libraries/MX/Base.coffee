#+--------------------------------------------------------------------+
#| Base.coffee
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
#	Base
#
#
#
# load MX core classes

MX_Lang = require(dirname(__filename)+'/Lang.coffee')
MX_Config = require(dirname(__filename)+'/Config.coffee')

class CI

  constructor: ->

    # assign the application instance
    CI.$APP = get_instance()

    # assign the core loader
    CI.$APP.load = new MX_Loader()

    # re-assign language and config for modules
    if not CI.$APP.lang instanceof MX_Lang then CI.$APP.lang = new MX_Lang()
    if not CI.$APP.config instanceof MX_Config then CI.$APP.config = new MX_Config()


module.exports = CI

new CI

# End of file Base.coffee
# Location: ./application/libraries/MX/Base.coffee