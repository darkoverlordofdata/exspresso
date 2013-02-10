#+--------------------------------------------------------------------+
#  User_agent.coffee
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
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# User Agent Class
#
# Identifies the platform, browser, robot, or mobile devise of the browsing agent
#
# @package		Exspresso
# @subpackage	Libraries
# @category	User Agent
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/libraries/user_agent.html
#
class global.Exspresso_User_agent

  Exspresso       : null
  _agent          : null
  
  _is_browser     : false
  _is_robot       : false
  _is_mobile      : false
  
  _languages      : null
  _charsets       : null

  _platforms      : null
  _browsers       : null
  _mobiles        : null
  _robots         : null

  _platform       : ''
  _browser        : ''
  _version        : ''
  _mobile         : ''
  _robot          : ''
  
  #
  # Constructor
  #
  # Sets the User Agent and runs the compilation routine
  #
  # @access	public
  # @return	void
  #
  constructor: ($config = {}, @Exspresso) ->

    @_languages = {}
    @_charsets = {}

    @_platforms = {}
    @_browsers = {}
    @_mobiles = {}
    @_robots = {}

    if @Exspresso.$_SERVER['HTTP_USER_AGENT']?
      @_agent = trim(@Exspresso.$_SERVER['HTTP_USER_AGENT'])

    if not is_null(@_agent)
      if @_load_agent_file()
        @_compile_data()

    log_message('debug', "User Agent Class Initialized")

  #
  # Compile the User Agent Data
  #
  # @access	private
  # @return	bool
  #
  _load_agent_file: () ->
    if defined('ENVIRONMENT') and is_file(APPPATH + 'config/' + ENVIRONMENT + '/user_agents' + EXT)
      $config = require(APPPATH + 'config/' + ENVIRONMENT + '/user_agents' + EXT)

    else if is_file(APPPATH + 'config/user_agents' + EXT)
      $config = require(APPPATH + 'config/user_agents' + EXT)

    else
      return false

    $return = false

    if $config.platforms?
      @_platforms = $config.platforms
      $return = true


    if $config.browsers?
      @_browsers = $config.browsers
      $return = true


    if $config.mobiles?
      @_mobiles = $config.mobiles
      $return = true


    if $config.robots?
      @_robots = $config.robots
      $return = true

    return $return

  #
  # Compile the User Agent Data
  #
  # @access	private
  # @return	bool
  #
  _compile_data: () ->
    @_set_platform()

    for $function in ['_set_browser', '_set_robot', '_set_mobile']
      if @[$function()] is true
        break

  #
  # Set the Platform
  #
  # @access	private
  # @return	mixed
  #
  _set_platform: () ->

    if is_array(@_platforms) and count(@_platforms) > 0
      for $key, $val of @_platforms
        if preg_match("|" + preg_quote($key) + "|i", @_agent)
          @_platform = $val
          return true

    @_platform = 'Unknown Platform'


  #
  # Set the Browser
  #
  # @access	private
  # @return	bool
  #
  _set_browser: () ->

    if is_array(@_browsers) and count(@_browsers) > 0
      for $key, $val of @_browsers
        $match = preg_match("|" + preg_quote($key) + ".*?([0-9\\.]+)|i", @_agent)
        if $match.length
          @_is_browser = true
          @_version = $match[1]
          @_browser = $val
          @_set_mobile()
          return true

    return false

  #
  # Set the Robot
  #
  # @access	private
  # @return	bool
  #
  _set_robot: () ->

    if is_array(@_robots) and count(@_robots) > 0
      for $key, $val of @_robots
        if preg_match("|" + preg_quote($key) + "|i", @_agent).length
          @_is_robot = true
          @_robot = $val
          return true

    return false

  #
  # Set the Mobile Device
  #
  # @access	private
  # @return	bool
  #
  _set_mobile: () ->

    if is_array(@_mobiles) and count(@_mobiles) > 0
      for $key, $val of @_mobiles
        if false isnt (strpos(strtolower(@_agent), $key))
          @_is_mobile = true
          @_mobile = $val
          return true

    return false


  #
  # Set the accepted languages
  #
  # @access	private
  # @return	void
  #
  _set_languages: () ->

    # req.acceptedLanguages
    if (count(@_languages) is 0) and @Exspresso.$_SERVER['HTTP_ACCEPT_LANGUAGE']?  and @Exspresso.$_SERVER['HTTP_ACCEPT_LANGUAGE'] isnt ''
      $languages = preg_replace('/(;q=[0-9\\.]+)/i', '', strtolower(trim(@Exspresso.$_SERVER['HTTP_ACCEPT_LANGUAGE'])))

      @_languages = explode(',', $languages)


    if count(@_languages) is 0
      @_languages = ['Undefined']


  #
  # Set the accepted character sets
  #
  # @access	private
  # @return	void
  #
  _set_charsets: () ->

    # req.acceptedCharsets
    if (count(@_charsets) is 0) and @Exspresso.$_SERVER['HTTP_ACCEPT_CHARSET']?  and @Exspresso.$_SERVER['HTTP_ACCEPT_CHARSET'] isnt ''
      $charsets = preg_replace('/(;q=.+)/i', '', strtolower(trim(@Exspresso.$_SERVER['HTTP_ACCEPT_CHARSET'])))

      @_charsets = explode(',', $charsets)


    if count(@_charsets) is 0
      @_charsets = ['Undefined']


  #
  # Is Browser
  #
  # @access	public
  # @return	bool
  #
  is_browser: ($key = null) ->

    if not @_is_browser
      return false

    #  No need to be specific, it's a browser
    if $key is null
      return true

    #  Check for a specific browser
    return array_key_exists($key, @_browsers) and @_browser is @_browsers[$key]

  #
  # Is Robot
  #
  # @access	public
  # @return	bool
  #
  is_robot: ($key = null) ->

    if not @_is_robot
      return false

    #  No need to be specific, it's a robot
    if $key is null
      return true

    #  Check for a specific robot
    return array_key_exists($key, @_robots) and @_robot is @_robots[$key]

  #
  # Is Mobile
  #
  # @access	public
  # @return	bool
  #
  is_mobile: ($key = null) ->

    if not @_is_mobile
      return false

    #  No need to be specific, it's a mobile
    if $key is null
      return true

    #  Check for a specific robot
    return array_key_exists($key, @_mobiles) and @_mobile is @_mobiles[$key]


  #
  # Is this a referral from another site?
  #
  # @access	public
  # @return	bool
  #
  is_referral: () ->

    if not @Exspresso.$_SERVER['HTTP_REFERER']?  or @Exspresso.$_SERVER['HTTP_REFERER'] is ''
      return false

    return true


  #
  # Agent String
  #
  # @access	public
  # @return	string
  #
  agent_string: () ->
    return @_agent

  #
  # Get Platform
  #
  # @access	public
  # @return	string
  #
  platform: () ->
    return @_platform

  #
  # Get Browser Name
  #
  # @access	public
  # @return	string
  #
  browser: () ->
    return @_browser

  #
  # Get the Browser Version
  #
  # @access	public
  # @return	string
  #
  version: () ->
    return @_version

  #
  # Get The Robot Name
  #
  # @access	public
  # @return	string
  #
  robot: () ->
    return @_robot

  #
  # Get the Mobile Device
  #
  # @access	public
  # @return	string
  #
  mobile: () ->
    return @_mobile

  
  #
  # Get the referrer
  #
  # @access	public
  # @return	bool
  #
  #req.headers['referer']
  referrer: () ->
    return if ( not @Exspresso.$_SERVER['HTTP_REFERER']?  or @Exspresso.$_SERVER['HTTP_REFERER'] is '') then '' else trim(@Exspresso.$_SERVER['HTTP_REFERER'])

  
  #
  # Get the accepted languages
  #
  # @access	public
  # @return	array
  #
  languages: () ->
    if count(@_languages) is 0
      @_set_languages()

    return @_languages

  
  #
  # Get the accepted Character Sets
  #
  # @access	public
  # @return	array
  #
  charsets: () ->
    if count(@_charsets) is 0
      @_set_charsets()

    return @_charsets

  
  #
  # Test for a particular language
  #
  # @access	public
  # @return	bool
  #
  accept_lang: ($lang = 'en') ->
    return (in_array(strtolower($lang), @_languages(), true))

  
  #
  # Test for a particular character set
  #
  # @access	public
  # @return	bool
  #
  accept_charset: ($charset = 'utf-8') ->
    return (in_array(strtolower($charset), @_charsets(), true))


module.exports = Exspresso_User_agent


#  End of file User_agent.php 
#  Location: ./system/libraries/User_agent.php 