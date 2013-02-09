#+--------------------------------------------------------------------+
#  Driver.coffee
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
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
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
class global.Exspresso_Driver_Library

  #
  # Load driver
  #
  # Load's the requested driver
  #
  # @param	string
  # @return	object
  #
  load_driver: ($driver) ->

    $lib_name = str_replace(['Exspresso_', config_item('subclass_prefix')], '', @constructor.name)
    $class_name = ucfirst($lib_name + '_' + $driver)
    $subdir = $lib_name+'/drivers/'
    $class = null

    #  Is this a class extension request?
    $file = APPPATH+'libraries/'+$subdir+config_item('subclass_prefix')+$class_name+EXT
    if file_exists($file)
      $baseclass = BASEPATH+'libraries/'+$subdir+ucfirst($class_name)+EXT

      if not file_exists($baseclass)
        log_message('error', "Unable to load the requested driver: %s", $class_name)
        show_error("Unable to load the requested driver: %s", $class_name)

      require $baseclass
      $class = require($file)

    else
      for $path in Exspresso.load.get_package_paths(true)
        $file = $path+'libraries/'+$subdir+$class_name+EXT
        if file_exists($file)
          $class = require($file)
          break

    if $class is null
      log_message('error', "Unable to load the requested driver: %s", $class_name)
      show_error("Unable to load the requested driver: %s", $class_name)

    if $class::decorate?
      $child = new $class()
      $child.decorate @
    else
      $child = new $class(@)

    @[$driver] = $child
    return @[$driver]

module.exports = Exspresso_Driver_Library
#  END Exspresso_Driver_Library CLASS

#
# Exspresso Driver Class
#
# This class enables you to create drivers for a Library based on the Driver Library.
# It handles the drivers' access to the parent library
#
#
class global.Exspresso_Driver

  #
  # Decorate
  #
  # Decorates the child with the parent driver lib's methods and properties
  #
  # @param	object
  # @return	void
  #
  decorate : ($parent) ->

    # Decorate the driver with forwarders to the
    # parent driver lib's methods and properties
    for $name, $fn of $parent
      if $name[0] isnt '_' # skip - protected by convention
        do ($name, $fn) ->
          if typeof $fn is 'function'
            # forward the parent function call
            @[$name] = ($args...) ->
              $fn.apply($parent, $args)
          else
            # forward the parent accessor
            Object.defineProperties @,
            array($name,  get:  -> $parent[$name])
            array($name,  set: ($newval) -> $parent[$name] = $newval)

module.exports = Exspresso_Driver
#  END Exspresso_Driver CLASS

#  End of file Driver.php
#  Location: ./system/libraries/Driver.php