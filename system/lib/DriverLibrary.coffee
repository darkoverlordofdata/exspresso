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
# Exspresso Driver Library Class
#
# This class enables you to create "Driver" libraries that add runtime ability
# to extend the capabilities of a class via additional driver objects
#
#
module.exports = class system.lib.DriverLibrary

  fs = require('fs')
  UNABLE_TO = "Unable to load the requested driver: %s"

  #
  # Load driver
  #
  # Load's the requested driver
  #
  # @param  [String]  driver  the driver prefix
  # @param  [system.core.Exspresso] controller  the system controller
  # @return [Object]
  #
  loadDriver: ($drivers, $controller) ->

    load_driver = ($driver, $prefix = '') =>

      $lib_name = @constructor.name.replace(config_item('subclass_prefix'), '')
      $class_name = ucfirst($driver) + ucfirst($lib_name)
      $subdir = $lib_name.toLowerCase()+'/drivers/'
      $class = null

      #  Is this a class extension request?
      if fs.existsSync($file = APPPATH+'lib/'+$subdir+config_item('subclass_prefix')+$class_name+EXT)
        if not fs.existsSync($baseclass = SYSPATH+'lib/'+$subdir+$class_name+EXT)
          log_message('error', UNABLE_TO, $class_name) if show_error(UNABLE_TO, $class_name)

        require $baseclass
        $class = require($file)

      else
        for $path in exspresso.load.getClassPaths(true)
          if fs.existsSync($file = $path+'lib/'+$subdir+$class_name+EXT)
            $class = require($file)
            break

      log_message('error', UNABLE_TO, $class_name) if show_error(UNABLE_TO, $class_name) if $class is null

      Object.defineProperty @, $prefix+$driver,
        writeable : false
        enumerable: if $prefix is '_' then false else true
        value     : if $class::decorate? then new $class($controller).decorate(@) else new $class(@, $controller)

      @[$prefix+$driver]


    if 'string' is typeof $drivers
      load_driver($drivers)

    else
      for $driver in $drivers
        do ($driver) =>
          Object.defineProperty @, $driver,
            get: -> @['_'+$driver] ? load_driver($driver, '_')

      return