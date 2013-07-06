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
#   node exspresso [--option]
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
    # Allow the embedding componet to override all
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
    #  The coffee-script file extension
    #
    define 'EXT', '.coffee'

    #
    # Path to the this file
    #
    define 'FCPATH', realpath(__dirname) + '/'

    #
    # set the environment
    #
    define 'ENVIRONMENT', process.env.ENVIRONMENT ? process.env.NODE_ENV ? 'development'

    #
    # discover the system path
    #
    $system_folder = if realpath('system') then 'system' else FCPATH + 'system'
    unless is_dir($system_folder)
      exit "Your system folder path is not set correctly."

    #
    # discover the application path
    #
    $app_folder = if realpath($apppath) then $apppath else FCPATH + $apppath
    unless is_dir($app_folder)
      exit "Your application folder path not set correctly."

    #  Path to the system folder
    #
    define 'SYSPATH', realpath($system_folder) + '/'

    #
    # The path to the "application" folder
    #
    define 'APPPATH', realpath($app_folder) + '/'

    #
    # The path to the "assets" folder (optional)
    #
    define 'DOCPATH', if is_dir($docroot) then realpath($docroot) + '/' else false

    #
    # The path to the "modules" folder (optional)
    #
    define 'MODPATH', if is_dir($modpath) then realpath($modpath) + '/' else false

    #
    #   Initialize the API
    #
    core()

    #
    #   Create the top level system controller
    #
    define 'exspresso', new system.core.Exspresso

    #
    #   e x s p r e s s o
    #
    exspresso.setConfig $config
    exspresso.boot()


# End of file index.coffee
# Location: ./index.coffee
