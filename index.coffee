#+--------------------------------------------------------------------+
#| exspresso.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Exspresso is free software you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#	Exspresso
#
#   node exspresso <docroot> [--option]
#
#     options:
#     --cache
#     --csrf
#     --preview
#     --profile
#     --nocache
#     --nocsrf
#     --noprofile
#     --db <mysql|postgres|sqlite>
#
#
#
# Set global path constants, load the api and boot exspresso
#

module.exports =

  run: ($config = {})->

    #
    # Allow the embedding component to override all
    # paths, except for the system path
    #
    $apppath = $config.APPPATH ? 'application'
    $modpath = $config.MODPATH ? 'modules'
    $docroot = $config.DOCROOT ? 'assets'

    #
    # Load the core api module
    #
    core = require('./system/core.coffee')

    #
    # Export the api methods
    #
    core.export global

    #
    # set the environment
    #
    define 'ENVIRONMENT', process.env.ENVIRONMENT ? process.env.NODE_ENV ? 'development'

    #
    #  The coffee-script file extension
    #
    define 'EXT', '.coffee'

    #
    # Path to the this file
    #
    define 'FCPATH', realpath(__dirname) + '/'

    #
    #  Path to the system folder
    #
    define 'SYSPATH', FCPATH + 'system/'

    #
    # The path to the "application" folder
    #
    define 'APPPATH', if is_dir($apppath) then realpath($apppath) + '/' else FCPATH + 'application/'

    #
    # The path to the "assets" folder (optional)
    #
    define 'DOCPATH', if is_dir($docroot) then realpath($docroot) + '/' else false

    #
    # The path to the "modules" folder (optional)
    #
    define 'MODPATH', if is_dir($modpath) then realpath($modpath) + '/' else false

    #
    # Verify the embedding application path
    #
    unless is_dir($apppath)
      console.log "WARN Your application folder path not set correctly"
      console.log "WARN --> #{$apppath} <--"
      console.log "WARN Booting default exspresso application"

    #
    # Initialize the API
    #
    core()

    #
    # Create the top level system controller
    #
    define 'exspresso', new system.core.Exspresso

    #
    #   e x s p r e s s o
    #
    exspresso.setConfig $config
    exspresso.boot()


# End of file index.coffee
# Location: ./index.coffee
