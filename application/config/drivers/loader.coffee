#+--------------------------------------------------------------------+
#| loader.coffee.coffee
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
#| LOADER SETTINGS
#| -------------------------------------------------------------------
#| This file will contain the settings needed to start the http server.
#|
exports['active_loader'] = 'hmvc'
exports['loader'] =
  mvc:
    'driver'            : 'mvc'
  hmvc:
    'driver'            : 'hmvc'

# End of file loader.coffee.coffee
# Location: ./loader.coffee.coffee