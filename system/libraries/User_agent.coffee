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
# @copyright  Copyright (c) 2012, Dark Overlord of Data
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

  Exspresso: null
  agent: null
  
  is_browser: false
  is_robot: false
  is_mobile: false
  
  languages: null
  charsets: null
  
  platforms: null
  browsers: null
  mobiles: null
  robots: null
  
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
  constructor: ($config = {}, @Exspresso) ->

    @languages = {}
    @charsets = {}

    @platforms = {}
    @browsers = {}
    @mobiles = {}
    @robots = {}

    if @Exspresso.$_SERVER['HTTP_USER_AGENT']?
      @agent = trim(@Exspresso.$_SERVER['HTTP_USER_AGENT'])

    if not is_null(@agent)
      if @_load_agent_file()
        @_compile_data()

    log_message('debug', "User Agent Class Initialized")

  #  --------------------------------------------------------------------
  
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
      @platforms = $config.platforms
      $return = true


    if $config.browsers?
      @browsers = $config.browsers
      $return = true


    if $config.mobiles?
      @mobiles = $config.mobiles
      $return = true


    if $config.robots?
      @robots = $config.robots
      $return = true

    return $return

  #  --------------------------------------------------------------------
  
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

  #  --------------------------------------------------------------------
  
  #
  # Set the Platform
  #
  # @access	private
  # @return	mixed
  #
  _set_platform: () ->

    if is_array(@platforms) and count(@platforms) > 0
      for $key, $val of @platforms
        if preg_match("|" + preg_quote($key) + "|i", @agent)
          @platform = $val
          return true

    @platform = 'Unknown Platform'


  #  --------------------------------------------------------------------
  
  #
  # Set the Browser
  #
  # @access	private
  # @return	bool
  #
  _set_browser: () ->

    if is_array(@browsers) and count(@browsers) > 0
      for $key, $val of @browsers
        $match = preg_match("|" + preg_quote($key) + ".*?([0-9\\.]+)|i", @agent)
        if $match.length
          @is_browser = true
          @version = $match[1]
          @browser = $val
          @_set_mobile()
          return true

    return false

  #  --------------------------------------------------------------------
  
  #
  # Set the Robot
  #
  # @access	private
  # @return	bool
  #
  _set_robot: () ->

    if is_array(@robots) and count(@robots) > 0
      for $key, $val of @robots
        if preg_match("|" + preg_quote($key) + "|i", @agent).length
          @is_robot = true
          @robot = $val
          return true

    return false

  #  --------------------------------------------------------------------
  
  #
  # Set the Mobile Device
  #
  # @access	private
  # @return	bool
  #
  _set_mobile: () ->

    if is_array(@mobiles) and count(@mobiles) > 0
      for $key, $val of @mobiles
        if false isnt (strpos(strtolower(@agent), $key))
          @is_mobile = true
          @mobile = $val
          return true

    return false


  #  --------------------------------------------------------------------
  
  #
  # Set the accepted languages
  #
  # @access	private
  # @return	void
  #
  _set_languages: () ->

    # req.acceptedLanguages
    if (count(@languages) is 0) and @Exspresso.$_SERVER['HTTP_ACCEPT_LANGUAGE']?  and @Exspresso.$_SERVER['HTTP_ACCEPT_LANGUAGE'] isnt ''
      $languages = preg_replace('/(;q=[0-9\\.]+)/i', '', strtolower(trim(@Exspresso.$_SERVER['HTTP_ACCEPT_LANGUAGE'])))

      @languages = explode(',', $languages)


    if count(@languages) is 0
      @languages = ['Undefined']


  #  --------------------------------------------------------------------
  
  #
  # Set the accepted character sets
  #
  # @access	private
  # @return	void
  #
  _set_charsets: () ->

    # req.acceptedCharsets
    if (count(@charsets) is 0) and @Exspresso.$_SERVER['HTTP_ACCEPT_CHARSET']?  and @Exspresso.$_SERVER['HTTP_ACCEPT_CHARSET'] isnt ''
      $charsets = preg_replace('/(;q=.+)/i', '', strtolower(trim(@Exspresso.$_SERVER['HTTP_ACCEPT_CHARSET'])))

      @charsets = explode(',', $charsets)


    if count(@charsets) is 0
      @charsets = ['Undefined']


  #  --------------------------------------------------------------------
  
  #
  # Is Browser
  #
  # @access	public
  # @return	bool
  #
  is_browser: ($key = null) ->

    if not @is_browser
      return false

    #  No need to be specific, it's a browser
    if $key is null
      return true

    #  Check for a specific browser
    return array_key_exists($key, @browsers) and @browser is @browsers[$key]

  #  --------------------------------------------------------------------
  
  #
  # Is Robot
  #
  # @access	public
  # @return	bool
  #
  is_robot: ($key = null) ->

    if not @is_robot
      return false

    #  No need to be specific, it's a robot
    if $key is null
      return true

    #  Check for a specific robot
    return array_key_exists($key, @robots) and @robot is @robots[$key]

  #  --------------------------------------------------------------------
  
  #
  # Is Mobile
  #
  # @access	public
  # @return	bool
  #
  is_mobile: ($key = null) ->

    if not @is_mobile
      return false

    #  No need to be specific, it's a mobile
    if $key is null
      return true

    #  Check for a specific robot
    return array_key_exists($key, @mobiles) and @mobile is @mobiles[$key]


  #  --------------------------------------------------------------------
  
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


  #  --------------------------------------------------------------------
  
  #
  # Agent String
  #
  # @access	public
  # @return	string
  #
  agent_string: () ->
    return @agent

  #  --------------------------------------------------------------------
  
  #
  # Get Platform
  #
  # @access	public
  # @return	string
  #
  platform: () ->
    return @platform

  #  --------------------------------------------------------------------
  
  #
  # Get Browser Name
  #
  # @access	public
  # @return	string
  #
  browser: () ->
    return @browser

  #  --------------------------------------------------------------------
  
  #
  # Get the Browser Version
  #
  # @access	public
  # @return	string
  #
  version: () ->
    return @version

  #  --------------------------------------------------------------------
  
  #
  # Get The Robot Name
  #
  # @access	public
  # @return	string
  #
  robot: () ->
    return @robot

  #  --------------------------------------------------------------------
  
  #
  # Get the Mobile Device
  #
  # @access	public
  # @return	string
  #
  mobile: () ->
    return @mobile

  
  #  --------------------------------------------------------------------
  
  #
  # Get the referrer
  #
  # @access	public
  # @return	bool
  #
  #req.headers['referer']
  referrer: () ->
    return if ( not @Exspresso.$_SERVER['HTTP_REFERER']?  or @Exspresso.$_SERVER['HTTP_REFERER'] is '') then '' else trim(@Exspresso.$_SERVER['HTTP_REFERER'])

  
  #  --------------------------------------------------------------------
  
  #
  # Get the accepted languages
  #
  # @access	public
  # @return	array
  #
  languages: () ->
    if count(@languages) is 0
      @_set_languages()

    return @languages

  
  #  --------------------------------------------------------------------
  
  #
  # Get the accepted Character Sets
  #
  # @access	public
  # @return	array
  #
  charsets: () ->
    if count(@charsets) is 0
      @_set_charsets()

    return @charsets

  
  #  --------------------------------------------------------------------
  
  #
  # Test for a particular language
  #
  # @access	public
  # @return	bool
  #
  accept_lang: ($lang = 'en') ->
    return (in_array(strtolower($lang), @languages(), true))

  
  #  --------------------------------------------------------------------
  
  #
  # Test for a particular character set
  #
  # @access	public
  # @return	bool
  #
  accept_charset: ($charset = 'utf-8') ->
    return (in_array(strtolower($charset), @charsets(), true))


module.exports = Exspresso_User_agent


#  End of file User_agent.php 
#  Location: ./system/libraries/User_agent.php 