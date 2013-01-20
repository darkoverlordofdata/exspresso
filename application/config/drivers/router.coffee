#+--------------------------------------------------------------------+
#| router.coffee
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
#| -------------------------------------------------------------------
#| ROUTER SETTINGS
#| -------------------------------------------------------------------
#| This file will contain the settings needed to start the http server.
#|
exports['active_router'] = 'hmvc'
exports['router'] =
  mvc:
    'driver'            : 'mvc'
  hmvc:
    'driver'            : 'hmvc'

# End of file router.coffee
# Location: ./router.coffee