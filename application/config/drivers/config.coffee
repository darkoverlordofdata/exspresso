#+--------------------------------------------------------------------+
#| config.coffee.coffee
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
#| CONFIG SETTINGS
#| -------------------------------------------------------------------
#| This file will contain the settings needed to start the http server.
#|
exports['active_config'] = 'hmvc'
exports['config'] =
  mvc:
    'driver'            : 'mvc'   # simple mvc
  hmvc:
    'driver'            : 'hmvc'  # modular mvc


# End of file config.coffee.coffee
# Location: ./config.coffee.coffee