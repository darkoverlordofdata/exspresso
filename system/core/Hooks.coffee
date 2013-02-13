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
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Hooks Class
#
# Provides a mechanism to extend the base system without hacking.
#
#
class global.Exspresso_Hooks
  
  enabled       : false
  hooks         : null
  in_progress   : false
  
  #
  # Constructor
  #
  #
  constructor :  ->
    @_initialize()
    log_message('debug', "Hooks Class Initialized")
    
  
  #
  # Initialize the Hooks Preferences
  #
  # @access  private
  # @return  void
  #
  _initialize :  ->

    @hooks = {}

    #  If hooks are not enabled in the config file
    #  there is nothing else to do
    
    if config_item('enable_hooks') is false
      return 
      
    
    #  Grab the "hooks" definition file.
    #  If there are no hooks, we're done.
    
    if is_file(APPPATH + 'config/' + ENVIRONMENT + '/hooks' + EXT)
      $hook = require(APPPATH + 'config/' + ENVIRONMENT + '/hooks' + EXT)
      
    else if is_file(APPPATH + 'config/hooks' + EXT)
      $hook = require(APPPATH + 'config/hooks' + EXT)
      
    
    
    if not $hook?  or  not is_array($hook)
      return 
      
    
    @hooks = $hook
    @enabled = true
    
  
  #
  # Call Hook
  #
  # Calls a particular hook
  #
  # @access  private
  # @param  string  the hook name
  # @param  object  the controller instance instance
  # @return  mixed
  #
  _call_hook : ($which = '', $instance = null) ->

    log_message 'debug', '$HOOK %s', $which

    if not @enabled or  not @hooks[$which]? 
      return false

    if @hooks[$which][0]?  and is_array(@hooks[$which][0])
      for $val in @hooks[$which]
        @_run_hook($val, $instance)

    else
      @_run_hook(@hooks[$which], $instance)

    return true
    
  
  #
  # Run Hook
  #
  # Runs a particular hook
  #
  # @access  private
  # @param  array  the hook details
  # @return  bool
  #
  _run_hook : ($data, $instance) ->
    if not is_array($data)
      return false
      
    
    #  -----------------------------------
    #  Safety - Prevents run-away loops
    #  -----------------------------------
    
    #  If the script being called happens to have the same
    #  hook call within it a loop can happen
    
    if @in_progress is true
      return 
      
    
    #  -----------------------------------
    #  Set file path
    #  -----------------------------------
    
    if not $data['filepath']?  or  not $data['filename']? 
      return false
      
    
    $filepath = APPPATH + $data['filepath'] + '/' + $data['filename']
    
    if not file_exists($filepath)
      return false
      
    
    #  -----------------------------------
    #  Set class/function name
    #  -----------------------------------
    
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
      
    
    #  -----------------------------------
    #  Set the in_progress flag
    #  -----------------------------------
    
    @in_progress = true
    
    #  -----------------------------------
    #  Call the requested class and/or function
    #  -----------------------------------
    
    if $class isnt false
      $class = require($filepath)
      $hook = new $class()
      $hook[$function]($instance, $params)
      
    else
      $function = require($filepath)[$function]
      $function($instance, $params)
      
    
    @in_progress = false
    return true
    

#  END Exspresso_Hooks class
module.exports = Exspresso_Hooks

#  End of file Hooks.php 
#  Location: ./system/core/Hooks.php 