#+--------------------------------------------------------------------+
#  User_agent.coffee
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


{__construct, _compile_data, _load_agent_file, _set_browser, _set_charsets, _set_languages, _set_mobile, _set_platform, _set_robot, accept_charset, accept_lang, agent_string, array_key_exists, count, defined, explode, in_array, is_array, is_file, is_null, is_referral, preg_match, preg_quote, preg_replace, referrer, strpos, strtolower, trim}  = require(FCPATH + 'lib')


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
  
  agent: null
  
  is_browser: false
  is_robot: false
  is_mobile: false
  
  languages: {}
  charsets: {}
  
  platforms: {}
  browsers: {}
  mobiles: {}
  robots: {}
  
  platform: ''
  browser: ''
  version: ''
  mobile: ''
  robot: ''
  
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
    @agent = trim($_SERVER['HTTP_USER_AGENT'])
    
  
  if not is_null(@agent)
    if @_load_agent_file()
      @_compile_data()
      
    
  
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
    require(APPPATH + 'config/' + ENVIRONMENT + '/user_agents' + EXT)
    
  else if is_file(APPPATH + 'config/user_agents' + EXT)
    require(APPPATH + 'config/user_agents' + EXT)
    
  else 
    return false
    
  
  $return = false
  
  if $platforms? 
    @platforms = $platforms
    delete $platforms
    $return = true
    
  
  if $browsers? 
    @browsers = $browsers
    delete $browsers
    $return = true
    
  
  if $mobiles? 
    @mobiles = $mobiles
    delete $mobiles
    $return = true
    
  
  if $robots? 
    @robots = $robots
    delete $robots
    $return = true
    
  
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
  @_set_platform()
  
  for $function in ['_set_browser', '_set_robot', '_set_mobile']
    if @$function() is true
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
  if is_array(@platforms) and count(@platforms) > 0
    for $key, $val of @platforms
      if preg_match("|" + preg_quote($key) + "|i", @agent)
        @platform = $val
        return true
        
      
    
  @platform = 'Unknown Platform'
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
  if is_array(@browsers) and count(@browsers) > 0
    for $key, $val of @browsers
      if preg_match("|" + preg_quote($key) + ".*?([0-9\.]+)|i", @agent, $match)
        @is_browser = true
        @version = $match[1]
        @browser = $val
        @_set_mobile()
        return true
        
      
    
  return false
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
  if is_array(@robots) and count(@robots) > 0
    for $key, $val of @robots
      if preg_match("|" + preg_quote($key) + "|i", @agent)
        @is_robot = true
        @robot = $val
        return true
        
      
    
  return false
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
  if is_array(@mobiles) and count(@mobiles) > 0
    for $key, $val of @mobiles
      if false isnt (strpos(strtolower(@agent), $key))
        @is_mobile = true
        @mobile = $val
        return true
        
      
    
  return false
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
  if (count(@languages) is 0) and $_SERVER['HTTP_ACCEPT_LANGUAGE']?  and $_SERVER['HTTP_ACCEPT_LANGUAGE'] isnt ''
    $languages = preg_replace('/(;q=[0-9\.]+)/i', '', strtolower(trim($_SERVER['HTTP_ACCEPT_LANGUAGE'])))
    
    @languages = explode(',', $languages)
    
  
  if count(@languages) is 0
    @languages = ['Undefined']
    
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
  if (count(@charsets) is 0) and $_SERVER['HTTP_ACCEPT_CHARSET']?  and $_SERVER['HTTP_ACCEPT_CHARSET'] isnt ''
    $charsets = preg_replace('/(;q=.+)/i', '', strtolower(trim($_SERVER['HTTP_ACCEPT_CHARSET'])))
    
    @charsets = explode(',', $charsets)
    
  
  if count(@charsets) is 0
    @charsets = ['Undefined']
    
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Is Browser
  #
  # @access	public
  # @return	bool
  #
  is_browser($key = null)
  {
  if not @is_browser
    return false
    
  
  #  No need to be specific, it's a browser
  if $key is null
    return true
    
  
  #  Check for a specific browser
  return array_key_exists($key, @browsers) and @browser is @browsers[$key]
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Is Robot
  #
  # @access	public
  # @return	bool
  #
  is_robot($key = null)
  {
  if not @is_robot
    return false
    
  
  #  No need to be specific, it's a robot
  if $key is null
    return true
    
  
  #  Check for a specific robot
  return array_key_exists($key, @robots) and @robot is @robots[$key]
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Is Mobile
  #
  # @access	public
  # @return	bool
  #
  is_mobile($key = null)
  {
  if not @is_mobile
    return false
    
  
  #  No need to be specific, it's a mobile
  if $key is null
    return true
    
  
  #  Check for a specific robot
  return array_key_exists($key, @mobiles) and @mobile is @mobiles[$key]
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
    return false
    
  return true
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
  return @agent
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
  return @platform
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
  return @browser
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
  return @version
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
  return @robot
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
  return @mobile
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
  if count(@languages) is 0
    @_set_languages()
    
  
  return @languages
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
  if count(@charsets) is 0
    @_set_charsets()
    
  
  return @charsets
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
  return (in_array(strtolower($lang), @languages(), true))
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
  return (in_array(strtolower($charset), @charsets(), true))
  }
  
  

register_class 'CI_User_agent', CI_User_agent
module.exports = CI_User_agent


#  End of file User_agent.php 
#  Location: ./system/libraries/User_agent.php 