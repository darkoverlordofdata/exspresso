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


    $apppath = $config.APPPATH ? 'lib/application'
    $modpath = $config.MODPATH ? 'lib/modules'
    $docroot = $config.DOCROOT ? 'lib/assets'

    #
    # Load the core api module
    #
    api = require('./lib/system/core.coffee')

    #
    # Export the api methods
    #
    api.export global

    #
    # set the environment
    #
    define 'ENVIRONMENT', process.env.ENVIRONMENT ? 'development'

    #
    # Set the default paths:
    #
    if realpath('lib/system') is false
      $system_folder  = __dirname + '/lib/system'       # expresso system libraries
    else
      $system_folder  = 'lib/system'

    if realpath($apppath) is false
      $app_folder  = __dirname + $apppath     # application libraries
    else
      $app_folder  = $apppath

    $asset_folder   = $docroot        # document root,
    $module_folder  = $modpath       # expresso modules

    #
    #  Resolve the path's
    #
    $system_path = realpath($system_folder) + '/'

    #   Is the system path correct?
    #
    if not is_dir($system_path)
      exit "Your system folder path is not set correctly. Please open the following file and correct this: "+__filename

    #  The coffee-script file extension
    #
    define 'EXT', '.coffee'

    #  Path to the system folder
    #
    define 'SYSPATH', $system_path

    #  Path to the front controller (this file)
    #
    define 'FCPATH', realpath(__dirname) + '/'

    #
    # The path to the "application" folder
    #
    if is_dir($app_folder)
      define 'APPPATH', realpath($app_folder) + '/'
    else
      if not is_dir(SYSPATH+$app_folder+'/')
        exit "Your application folder path does not appear to be set correctly. Please open the following file and correct this: "+__filename

      define 'APPPATH', SYSPATH+$app_folder+'/'

    #
    # The path to the "assets" folder
    #
    if is_dir($asset_folder)
      define 'DOCPATH', realpath($asset_folder) + '/'
    else
      if not is_dir(SYSPATH+$asset_folder+'/')
        #exit "Your asset folder path does not appear to be set correctly. Please open the following file and correct this: "+__filename
        define 'DOCPATH', false
      else
        define 'DOCPATH', SYSPATH+$asset_folder+'/'


    #
    # The path to the "modules" folder
    #
    if is_dir($module_folder)
      define 'MODPATH', realpath($module_folder) + '/'
    else
      if not is_dir(SYSPATH+$module_folder+'/')
        exit "Your module folder path does not appear to be set correctly. Please open the following file and correct this: "+__filename

      define 'MODPATH', SYSPATH+$module_folder+'/'

    #
    #   Initialize the API
    #
    api()

    #
    #   Create the top level system controller
    #
    define 'exspresso', new system.core.Exspresso

    #
    #   e x s p r e s s o
    #
    exspresso.boot()


# End of file index.coffee
# Location: ./index.coffee
