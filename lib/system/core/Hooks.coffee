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
# Exspresso Hooks Class
#
#
module.exports = class system.core.Hooks

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
    
    log_message 'debug', "Hooks Class Initialized"

    @hooks = {}
    #
    #  If hooks are not enabled in the config file
    #  there is nothing else to do
    #
    return unless config_item('enable_hooks')

      
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
  # @param  [String]  which the hook name
  # @param  [Object]  instance  the controller instance
  # @return [Boolean] returns true if the hook was run, false if it was not
  #
  callHook : ($which = '', $instance = null) ->

    return false if not @enabled or not @hooks[$which]?

    if @hooks[$which][0]?  and typeof @hooks[$which][0] is 'object'
      @runHook($val, $instance) for $val in @hooks[$which]
    else
      @runHook(@hooks[$which], $instance)

    true
    
  
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
    return false if typeof $data isnt 'object'

    #
    #  Safety - Prevents run-away loops
    #
    #  If the script being called happens to have the same
    #  hook call within it a loop can happen
    #
    return false if @in_progress is true

    #
    #  Set file path
    #
    return false if not $data['filepath']? or not $data['filename']?

    $filepath = APPPATH + $data['filepath'] + '/' + $data['filename']

    return false if not file_exists($filepath)
    #
    #  Set class/function name
    #
    $class = false
    $function = false
    $params = ''

    $class    = $data['class']    if $data['class']?  and $data['class'] isnt ''
    $function = $data['function'] if $data['function']?
    $params   = $data['params']   if $data['params']?

    return false if $class is false and $function is false


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
    true
