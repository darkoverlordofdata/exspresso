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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
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

  #
  # Load driver
  #
  # Load's the requested driver
  #
  # @param  [String]    # @return [Object]  #
  loadDriver: ($driver) ->
    
    UNABLE_TO = "Unable to load the requested driver: %s"

    $lib_name = str_replace(config_item('subclass_prefix'), '', @constructor.name)
    #$class_name = ucfirst($lib_name + '_' + $driver)
    $class_name = ucfirst($driver) + ucfirst($lib_name)
    $subdir = $lib_name.toLocaleLowerCase()+'/drivers/'
    $class = null

    #  Is this a class extension request?
    if file_exists($file = APPPATH+'lib/'+$subdir+config_item('subclass_prefix')+$class_name+EXT)
      if not file_exists($baseclass = SYSPATH+'lib/'+$subdir+$class_name+EXT)
        log_message('error', UNABLE_TO, $class_name) if show_error(UNABLE_TO, $class_name)

      require $baseclass
      $class = require($file)

    else
      for $path in exspresso.load.getPackagePaths(true)
        if file_exists($file = $path+'lib/'+$subdir+$class_name+EXT)
          $class = require($file)
          break

    log_message('error', UNABLE_TO, $class_name) if show_error(UNABLE_TO, $class_name) if $class is null

    @[$driver] = if $class::decorate? then new $class().decorate(@) else new $class(@)

      
module.exports = system.lib.DriverLibrary
#  END ExspressoDriver_Library CLASS


#  End of file DriverLibrary.coffee
#  Location: .system/lib/DriverLibrary.coffee