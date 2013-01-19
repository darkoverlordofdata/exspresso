#+--------------------------------------------------------------------+
#  Driver.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
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
# @package		Exspresso
# @author		EllisLab Dev Team
# @copyright	Copyright (c) 2006 - 2011, EllisLab, Inc.
# @license		MIT License
# @link		http://darkoverlordofdata.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# Exspresso Driver Library Class
#
# This class enables you to create "Driver" libraries that add runtime ability
# to extend the capabilities of a class via additional driver objects
#
# @package		Exspresso
# @subpackage	Libraries
# @category	Libraries
# @author		EllisLab Dev Team
# @link
#
class global.Exspresso_Driver_Library

  valid_drivers: null
  _adapter: ''

  constructor: () ->
    @valid_drivers = {}

  #  The first time a child is used it won't exist, so we instantiate it
  #  subsequents calls will go straight to the proper child.
  __get : ($child, $libloc = 'libraries') ->
    if not @lib_name?
      @lib_name = @constructor.name # get_class(@)
      
    
    #  The class will be prefixed with the parent lib
    $child_class = @lib_name + '_' + $child
    
    #  Remove the Exspresso_ prefix and lowercase
    $lib_name = strtolower(preg_replace('/^Exspresso_/', '', @lib_name))
    $driver_name = strtolower(preg_replace('/^Exspresso_/', '', $child_class))

    #if in_array($driver_name, array_map('strtolower', @valid_drivers))
    if in_array($driver_name, @valid_drivers)
      #  check and see if the driver is in a separate file
      if not class_exists($child_class)
        #  check application path first
        for $path in [APPPATH, BASEPATH]
          #  loves me some nesting!
          for $class in [ucfirst($driver_name), $driver_name]
            $filepath = $path + $libloc + '/' + ucfirst($lib_name) + '/drivers/' + $class + EXT
            log_message 'debug', '$filepath = %s',$filepath
            if file_exists($filepath)
              $klass = require($filepath)
              break

        #  it's a valid driver, but the file simply can't be found
        if not class_exists($child_class)
          log_message('error', "Unable to load the requested driver: " + $child_class)
          show_error("Unable to load the requested driver: " + $child_class)

      log_message 'debug', '$child_class = %s', $child_class
      $obj = new $klass()
      console.log $obj
      if $obj.decorate? then $obj.decorate(@)
      #@[$key] = $val for $key, $var in $obj
      @[$child] = $obj
      return @[$child]
      
    
    #  The requested driver isn't valid!
    log_message('error', "Invalid driver requested: " + $child_class)
    show_error("Invalid driver requested: " + $child_class)
    
  
  #  --------------------------------------------------------------------
  
  
module.exports = Exspresso_Driver_Library
#  END Exspresso_Driver_Library CLASS


#
# Exspresso Driver Class
#
# This class enables you to create drivers for a Library based on the Driver Library.
# It handles the drivers' access to the parent library
#
# @package		Exspresso
# @subpackage	Libraries
# @category	Libraries
# @author		EllisLab Dev Team
# @link
#
class global.Exspresso_Driver

  parent: null
  
  methods: null
  properties: null
  reflections: null

  constructor: ->
    @methods = {}
    @properties = {}
    @reflections = @reflections ? {}
  #
  # Decorate
  #
  # Decorates the child with the parent driver lib's methods and properties
  #
  # @param	object
  # @return	void
  #
  decorate : ($parent) ->
    @parent = $parent
    
    #  Lock down attributes to what is defined in the class
    #  and speed up references in magic methods
    
    $class_name = $parent.constructor.name # get_class($parent)
    
    if not self::$reflections[$class_name]?
      $r = new ReflectionObject($parent)
      
      for $method in $r.getMethods()
        if $method.isPublic()
          @methods.push $method.getName()

      for $prop in $r.getProperties()
        if $prop.isPublic()
          @properties.push $prop.getName()

      self::$reflections[$class_name] = [@methods, @properties]
      
    else 
      [@methods, @properties] = self::$reflections[$class_name]
      
    
  
  #  --------------------------------------------------------------------
  
  #
  # __call magic method
  #
  # Handles access to the parent driver library's methods
  #
  # @access	public
  # @param	string
  # @param	array
  # @return	mixed
  #
  __call : ($method, $args = {}) ->
    if in_array($method, @methods)
      return call_user_func_array([@parent, $method], $args)
      
    
    $trace = debug_backtrace()
    _exception_handler(E_ERROR, "No such method '{$method}'", $trace[1]['file'], $trace[1]['line'])
    die 
    
  
  #  --------------------------------------------------------------------
  
  #
  # __get magic method
  #
  # Handles reading of the parent driver library's properties
  #
  # @param	string
  # @return	mixed
  #
  __get : ($var) ->
    if in_array($var, @properties)
      return @parent.$var
      
    
  
  #  --------------------------------------------------------------------
  
  #
  # __set magic method
  #
  # Handles writing to the parent driver library's properties
  #
  # @param	string
  # @param	array
  # @return	mixed
  #
  __set : ($var, $val) ->
    if in_array($var, @properties)
      @parent.$var = $val
      
    
  
  #  --------------------------------------------------------------------
  
  
module.exports = Exspresso_Driver
#  END Exspresso_Driver CLASS

#  End of file Driver.php 
#  Location: ./system/libraries/Driver.php 