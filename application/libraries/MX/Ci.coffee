#+--------------------------------------------------------------------+
#| Ci.coffee
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
#	Ci
#
#   Modifies the bootstrap sequance with modularized
#   versions of CI_Lang and CI_Config
#
# load MX core classes
require dirname(__filename)+'/Lang.coffee'
require dirname(__filename)+'/Config.coffee'

class global.CI

  constructor: ->

    log_message 'debug','Ci Initialized'

    # assign the application instance
    CI.$APP = CI_Controller.get_instance()

    # assign the core loader
    CI.$APP.load = new MX_Loader()

    # re-assign language and config for modules
    if not (CI.$APP.lang instanceof MX_Lang) then CI.$APP.lang = new MX_Lang()
    if not (CI.$APP.config instanceof MX_Config) then CI.$APP.config = new MX_Config()

    # autoload module items
    CI.$APP.load._autoloader([])

module.exports = CI
new CI

# End of file Ci.coffee
# Location: ./application/libraries/MX/Ci.coffee