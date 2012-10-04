#+--------------------------------------------------------------------+
#  Hooks.coffee
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
# This file was ported from php to coffee-script using php2coffee v6.6.6
#
#

{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{class_exists, defined, file_exists, function_exists, is_array, is_file, item}	= require(FCPATH + 'pal')
{config_item, get_class, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')


#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# CodeIgniter Hooks Class
#
# Provides a mechanism to extend the base system without hacking.
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Libraries
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/libraries/encryption.html
#
class CI_Hooks
	
	enabled: false
	hooks: {}
	in_progress: false
	
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
			require(APPPATH + 'config/' + ENVIRONMENT + '/hooks' + EXT)
			
		else if is_file(APPPATH + 'config/hooks' + EXT)
			require(APPPATH + 'config/hooks' + EXT)
			
		
		
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
			for $val in @hooks[$which]
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
				require($filepath)
				
			
			$HOOK = new $class
			$HOOK.$function($params)
			
		else 
			if not function_exists($function)
				require($filepath)
				
			
			$function($params)
			
		
		@in_progress = false
		return true
		
	
	

register_class 'CI_Hooks', CI_Hooks
module.exports = CI_Hooks

#  END CI_Hooks class

#  End of file Hooks.php 
#  Location: ./system/core/Hooks.php 