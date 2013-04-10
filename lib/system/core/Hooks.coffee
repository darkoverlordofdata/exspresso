#+--------------------------------------------------------------------+
#  Hooks.coffee
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
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#
# Exspresso Hooks Class
#
# Provides a mechanism to extend the base system without hacking.
#
#
class system.core.Hooks

  fs = require('fs')
  #
  # @property [Boolean] Are hooks enabled? True/False 
  #
  enabled: false
  #
  # @property [Object] Hash list of hooks to call
  #
  hooks: null
  #
  # @property [Boolean] Are hooks currently running? True/False
  #
  in_progress: false
  
  #
  # Constructor
  #
  #
  constructor :  ->
    
    log_message('debug', "Hooks Class Initialized")

    @hooks = {}
    #
    #  If hooks are not enabled in the config file
    #  there is nothing else to do
    #
    if config_item('enable_hooks') is false
      return 
      
    #
    #  Grab the "hooks" definition file.
    #  If there are no hooks, we're done.
    #
    if fs.existsSync(APPPATH + 'config/' + ENVIRONMENT + '/hooks.coffee')
      $hook = require(APPPATH + 'config/' + ENVIRONMENT + '/hooks.coffee')
      
    else if fs.existsSync(APPPATH + 'config/hooks.coffee')
      $hook = require(APPPATH + 'config/hooks.coffee')
    
    if not $hook?  or  typeof $hook isnt 'object'
      return 
    
    @hooks = $hook
    @enabled = true
    
  
  #
  # Call Hook
  #
  # Calls a particular hook
  #
  # @param  [String]  which the hook name
  # @param  [Object]  instance  the controller instance
  # @return [Boolean] returns true if the hook was run, false if it was not
  #
  callHook : ($which = '', $instance = null) ->

    if not @enabled or not @hooks[$which]?
      return false

    if @hooks[$which][0]?  and typeof @hooks[$which][0] is 'object'
      for $val in @hooks[$which]
        @runHook($val, $instance)

    else
      @runHook(@hooks[$which], $instance)

    return true
    
  
  #
  # Run Hook
  #
  # Runs a particular hook
  #
  # @param  [Array]  data the configuration data for the hook
  # @param  [Object]  instance  the controller instance
  # @return [Boolean] returns true if the hook was run, false if it was not
  #
  runHook : ($data, $instance) ->
    if typeof $data isnt 'object'
      return false
      
    
    #
    #  Safety - Prevents run-away loops
    #
    #  If the script being called happens to have the same
    #  hook call within it a loop can happen
    #
    if @in_progress is true
      return false

    #
    #  Set file path
    #
    if not $data['filepath']?  or  not $data['filename']?
      return false

    $filepath = APPPATH + $data['filepath'] + '/' + $data['filename']
    
    if not file_exists($filepath)
      return false

    #
    #  Set class/function name
    #
    $class = false
    $function = false
    $params = ''
    
    if $data['class']?  and $data['class'] isnt ''
      $class = $data['class']

    if $data['function']? 
      $function = $data['function']

    if $data['params']? 
      $params = $data['params']

    if $class is false and $function is false
      return false

    #
    #  Set the in_progress flag
    #
    @in_progress = true
    
    #
    #  Call the requested class and/or function
    #
    if $class isnt false
      $class = require($filepath)
      $hook = new $class()
      $hook[$function]($instance, $params)
      
    else
      $function = require($filepath)[$function]
      $function($instance, $params)

    @in_progress = false
    return true
    

#  END ExspressoHooks class
module.exports = system.core.Hooks

#  End of file Hooks.php 
#  Location: ./system/core/Hooks.php 