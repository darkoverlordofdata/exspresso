if not defined('BASEPATH') then die 'No direct script access allowed'
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
# User Agent Class
#
# Identifies the platform, browser, robot, or mobile devise of the browsing agent
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	User Agent
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/libraries/user_agent.html
#
class CI_User_agent
	
	$agent: NULL
	
	$is_browser: FALSE
	$is_robot: FALSE
	$is_mobile: FALSE
	
	$languages: {}
	$charsets: {}
	
	$platforms: {}
	$browsers: {}
	$mobiles: {}
	$robots: {}
	
	$platform: ''
	$browser: ''
	$version: ''
	$mobile: ''
	$robot: ''
	
	#
	# Constructor
	#
	# Sets the User Agent and runs the compilation routine
	#
	# @access	public
	# @return	void
	#
	__construct()
	{
	if $_SERVER['HTTP_USER_AGENT']? 
		@.agent = trim($_SERVER['HTTP_USER_AGENT'])
		
	
	if not is_null(@.agent)
		if @._load_agent_file()
			@._compile_data()
			
		
	
	log_message('debug', "User Agent Class Initialized")
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Compile the User Agent Data
	#
	# @access	private
	# @return	bool
	#
	_load_agent_file()
	{
	if defined('ENVIRONMENT') and is_file(APPPATH + 'config/' + ENVIRONMENT + '/user_agents' + EXT)
		eval include_all(APPPATH + 'config/' + ENVIRONMENT + '/user_agents' + EXT)
		
	else if is_file(APPPATH + 'config/user_agents' + EXT)
		eval include_all(APPPATH + 'config/user_agents' + EXT)
		
	else 
		return FALSE
		
	
	$return = FALSE
	
	if $platforms? 
		@.platforms = $platforms
		delete $platforms
		$return = TRUE
		
	
	if $browsers? 
		@.browsers = $browsers
		delete $browsers
		$return = TRUE
		
	
	if $mobiles? 
		@.mobiles = $mobiles
		delete $mobiles
		$return = TRUE
		
	
	if $robots? 
		@.robots = $robots
		delete $robots
		$return = TRUE
		
	
	return $return
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Compile the User Agent Data
	#
	# @access	private
	# @return	bool
	#
	_compile_data()
	{
	@._set_platform()
	
	for $function in as
		if @.$function() is TRUE
			break
			
		
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Set the Platform
	#
	# @access	private
	# @return	mixed
	#
	_set_platform()
	{
	if is_array(@.platforms) and count(@.platforms) > 0
		for $val, $key in as
			if preg_match("|" + preg_quote($key) + "|i", @.agent)
				@.platform = $val
				return TRUE
				
			
		
	@.platform = 'Unknown Platform'
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Set the Browser
	#
	# @access	private
	# @return	bool
	#
	_set_browser()
	{
	if is_array(@.browsers) and count(@.browsers) > 0
		for $val, $key in as
			if preg_match("|" + preg_quote($key) + ".*?([0-9\.]+)|i", @.agent, $match)
				@.is_browser = TRUE
				@.version = $match[1]
				@.browser = $val
				@._set_mobile()
				return TRUE
				
			
		
	return FALSE
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Set the Robot
	#
	# @access	private
	# @return	bool
	#
	_set_robot()
	{
	if is_array(@.robots) and count(@.robots) > 0
		for $val, $key in as
			if preg_match("|" + preg_quote($key) + "|i", @.agent)
				@.is_robot = TRUE
				@.robot = $val
				return TRUE
				
			
		
	return FALSE
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Set the Mobile Device
	#
	# @access	private
	# @return	bool
	#
	_set_mobile()
	{
	if is_array(@.mobiles) and count(@.mobiles) > 0
		for $val, $key in as
			if FALSE isnt (strpos(strtolower(@.agent), $key))
				@.is_mobile = TRUE
				@.mobile = $val
				return TRUE
				
			
		
	return FALSE
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Set the accepted languages
	#
	# @access	private
	# @return	void
	#
	_set_languages()
	{
	if (count(@.languages) is 0) and $_SERVER['HTTP_ACCEPT_LANGUAGE']?  and $_SERVER['HTTP_ACCEPT_LANGUAGE'] isnt ''
		$languages = preg_replace('/(;q=[0-9\.]+)/i', '', strtolower(trim($_SERVER['HTTP_ACCEPT_LANGUAGE'])))
		
		@.languages = explode(',', $languages)
		
	
	if count(@.languages) is 0
		@.languages = ['Undefined']
		
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Set the accepted character sets
	#
	# @access	private
	# @return	void
	#
	_set_charsets()
	{
	if (count(@.charsets) is 0) and $_SERVER['HTTP_ACCEPT_CHARSET']?  and $_SERVER['HTTP_ACCEPT_CHARSET'] isnt ''
		$charsets = preg_replace('/(;q=.+)/i', '', strtolower(trim($_SERVER['HTTP_ACCEPT_CHARSET'])))
		
		@.charsets = explode(',', $charsets)
		
	
	if count(@.charsets) is 0
		@.charsets = ['Undefined']
		
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Is Browser
	#
	# @access	public
	# @return	bool
	#
	is_browser($key = NULL)
	{
	if not @.is_browser
		return FALSE
		
	
	#  No need to be specific, it's a browser
	if $key is NULL
		return TRUE
		
	
	#  Check for a specific browser
	return array_key_exists($key, @.browsers) and @.browser is @.browsers[$key]
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Is Robot
	#
	# @access	public
	# @return	bool
	#
	is_robot($key = NULL)
	{
	if not @.is_robot
		return FALSE
		
	
	#  No need to be specific, it's a robot
	if $key is NULL
		return TRUE
		
	
	#  Check for a specific robot
	return array_key_exists($key, @.robots) and @.robot is @.robots[$key]
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Is Mobile
	#
	# @access	public
	# @return	bool
	#
	is_mobile($key = NULL)
	{
	if not @.is_mobile
		return FALSE
		
	
	#  No need to be specific, it's a mobile
	if $key is NULL
		return TRUE
		
	
	#  Check for a specific robot
	return array_key_exists($key, @.mobiles) and @.mobile is @.mobiles[$key]
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Is this a referral from another site?
	#
	# @access	public
	# @return	bool
	#
	is_referral()
	{
	if not $_SERVER['HTTP_REFERER']?  or $_SERVER['HTTP_REFERER'] is ''
		return FALSE
		
	return TRUE
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Agent String
	#
	# @access	public
	# @return	string
	#
	agent_string()
	{
	return @.agent
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Get Platform
	#
	# @access	public
	# @return	string
	#
	platform()
	{
	return @.platform
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Get Browser Name
	#
	# @access	public
	# @return	string
	#
	browser()
	{
	return @.browser
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Get the Browser Version
	#
	# @access	public
	# @return	string
	#
	version()
	{
	return @.version
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Get The Robot Name
	#
	# @access	public
	# @return	string
	#
	robot()
	{
	return @.robot
	}
	#  --------------------------------------------------------------------
	
	#
	# Get the Mobile Device
	#
	# @access	public
	# @return	string
	#
	mobile()
	{
	return @.mobile
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Get the referrer
	#
	# @access	public
	# @return	bool
	#
	referrer()
	{
	return if ( not $_SERVER['HTTP_REFERER']?  or $_SERVER['HTTP_REFERER'] is '') then '' else trim($_SERVER['HTTP_REFERER'])
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Get the accepted languages
	#
	# @access	public
	# @return	array
	#
	languages()
	{
	if count(@.languages) is 0
		@._set_languages()
		
	
	return @.languages
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Get the accepted Character Sets
	#
	# @access	public
	# @return	array
	#
	charsets()
	{
	if count(@.charsets) is 0
		@._set_charsets()
		
	
	return @.charsets
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Test for a particular language
	#
	# @access	public
	# @return	bool
	#
	accept_lang($lang = 'en')
	{
	return (in_array(strtolower($lang), @.languages(), TRUE))
	}
	
	#  --------------------------------------------------------------------
	
	#
	# Test for a particular character set
	#
	# @access	public
	# @return	bool
	#
	accept_charset($charset = 'utf-8')
	{
	return (in_array(strtolower($charset), @.charsets(), TRUE))
	}
	
	


#  End of file User_agent.php 
#  Location: ./system/libraries/User_agent.php 