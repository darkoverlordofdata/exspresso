#+--------------------------------------------------------------------+
#  DriverLibrary.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Driver Library Class
#
# This class enables you to create "Driver" libraries that add runtime ability
# to extend the capabilities of a class via additional driver objects
#
#
class system.lib.DriverLibrary

  {ucfirst} = require(SYSPATH+'core.coffee')
  fs = require('fs')

  #
  # Load driver
  #
  # Load's the requested driver
  #
  # @param  [String]  driver  the driver prefix
  # @param  [system.core.Exspresso] controller  the system controller
  # @return [Object]
  #
  loadDriver: ($driver, $controller) ->
    
    UNABLE_TO = "Unable to load the requested driver: %s"

    $lib_name = @constructor.name.replace(config_item('subclass_prefix'), '')
    $class_name = ucfirst($driver) + ucfirst($lib_name)
    $subdir = $lib_name.toLocaleLowerCase()+'/drivers/'
    $class = null

    #  Is this a class extension request?
    if fs.existsSync($file = APPPATH+'lib/'+$subdir+config_item('subclass_prefix')+$class_name+EXT)
      if not fs.existsSync($baseclass = SYSPATH+'lib/'+$subdir+$class_name+EXT)
        log_message('error', UNABLE_TO, $class_name) if show_error(UNABLE_TO, $class_name)

      require $baseclass
      $class = require($file)

    else
      for $path in exspresso.load.getPackagePaths(true)
        if fs.existsSync($file = $path+'lib/'+$subdir+$class_name+EXT)
          $class = require($file)
          break

    log_message('error', UNABLE_TO, $class_name) if show_error(UNABLE_TO, $class_name) if $class is null

    @[$driver] = if $class::decorate? then new $class($controller).decorate(@) else new $class(@, $controller)

      
module.exports = system.lib.DriverLibrary
#  END ExspressoDriver_Library CLASS


#  End of file DriverLibrary.coffee
#  Location: .system/lib/DriverLibrary.coffee