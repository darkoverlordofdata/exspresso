#+--------------------------------------------------------------------+
#| Security.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
# Exspresso Application Security Class
#
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{array_merge, dirname, file_exists, is_dir, ltrim, realpath, rtrim, strrchr, trim, ucfirst} = require(FCPATH + 'helper')
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message} = require(BASEPATH + 'core/Common')

class CI_Hooks
	
	$enabled: false
	$hooks: {}
	$in_progress: false
	
	#
	# Constructor
	#
	#
	constructor :  ->
		@_initialize()
		log_message('debug', "Hooks Class Initialized")
		
	
	#  --------------------------------------------------------------------
	
	#
	# Initialize the Hooks Preferences
	#
	# @access	private
	# @return	void
	#
	_initialize :  ->
		$CFG = load_class('Config', 'core')
		
		#  If hooks are not enabled in the config file
		#  there is nothing else to do
		
		if $CFG.item('enable_hooks') is false
			return 
			
		
		#  Grab the "hooks" definition file.
		#  If there are no hooks, we're done.
		
		if defined('ENVIRONMENT') and is_file(APPPATH + 'config/' + ENVIRONMENT + '/hooks' + EXT)
			$hook = require(APPPATH + 'config/' + ENVIRONMENT + '/hooks' + EXT)
			
		else if is_file(APPPATH + 'config/hooks' + EXT)
			$hook = require(APPPATH + 'config/hooks' + EXT)
			
		
		
		if not $hook?  or  not is_array($hook)
			return 
			
		
		@hooks = $hook
		@enabled = true
		
	
	#  --------------------------------------------------------------------
	
	#
	# Call Hook
	#
	# Calls a particular hook
	#
	# @access	private
	# @param	string	the hook name
	# @return	mixed
	#
	_call_hook : ($which = '') ->
		if not @enabled or  not @hooks[$which]? 
			return false
			
		
		if @hooks[$which][0]?  and is_array(@hooks[$which][0])
			for $val in as
				@_run_hook($val)
				
			
		else 
			@_run_hook(@hooks[$which])
			
		
		return true
		
	
	#  --------------------------------------------------------------------
	
	#
	# Run Hook
	#
	# Runs a particular hook
	#
	# @access	private
	# @param	array	the hook details
	# @return	bool
	#
	_run_hook : ($data) ->
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
			if not class_exists($class)
				eval require_all($filepath)
				
			
			$HOOK = new $class
			$HOOK.$function($params)
			
		else 
			if not function_exists($function)
				eval require_all($filepath)
				
			
			$function($params)
			
		
		@in_progress = false
		return true
		
	
	

#  END CI_Hooks class

Exspresso.CI_Hooks = CI_Hooks
module.exports = CI_Hooks

#  End of file Hooks.php 
#  Location: ./system/core/Hooks.php 