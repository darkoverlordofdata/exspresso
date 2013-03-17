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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# User Agent Class
#
# Identifies the platform, browser, robot, or mobile devise of the browsing agent
#
#
class system.lib.UserAgent

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
  # @return [Void]  #
  constructor: ($controller, $config = {}) ->

    super $controller, $config

    @_languages = {}
    @_charsets = {}

    @_platforms = {}
    @_browsers = {}
    @_mobiles = {}
    @_robots = {}

    if @req.headers['user-agent']
      @_agent = trim(@req.headers['user-agent'])

    if @_agent?
      if @_load_agent_file()
        @_compile_data()

    log_message('debug', "User Agent Class Initialized")

  #
  # Compile the User Agent Data
  #
  # @private
  # @return	bool
  #
  _load_agent_file: () ->
    if is_file(APPPATH + 'config/' + ENVIRONMENT + '/user_agents.coffee')
      $config = require(APPPATH + 'config/' + ENVIRONMENT + '/user_agents.coffee')

    else if is_file(APPPATH + 'config/user_agents.coffee')
      $config = require(APPPATH + 'config/user_agents.coffee')

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
  # @private
  # @return	bool
  #
  _compile_data: () ->
    @_set_platform()

    for $function in ['_set_browser', '_set_robot', '_set_mobile']
      if @[$function()] is true
        break
    return

  #
  # Set the Platform
  #
  # @private
  # @return [Mixed]  #
  _set_platform: () ->

    if is_array(@_platforms) and count(@_platforms) > 0
      for $key, $val of @_platforms
        if preg_match("|" + reg_quote($key) + "|i", @_agent)?
          @_platform = $val
          return true

    @_platform = 'Unknown Platform'
    return


  #
  # Set the Browser
  #
  # @private
  # @return	bool
  #
  _set_browser: () ->

    if is_array(@_browsers) and count(@_browsers) > 0
      for $key, $val of @_browsers
        if ($match = preg_match("|" + reg_quote($key) + ".*?([0-9\\.]+)|i", @_agent))?
          @_is_browser = true
          @_version = $match[1]
          @_browser = $val
          @_set_mobile()
          return true

    false

  #
  # Set the Robot
  #
  # @private
  # @return	bool
  #
  _set_robot: () ->

    if is_array(@_robots) and count(@_robots) > 0
      for $key, $val of @_robots
        if preg_match("|" + reg_quote($key) + "|i", @_agent).length
          @_is_robot = true
          @_robot = $val
          return true

    false

  #
  # Set the Mobile Device
  #
  # @private
  # @return	bool
  #
  _set_mobile: () ->

    if is_array(@_mobiles) and count(@_mobiles) > 0
      for $key, $val of @_mobiles
        if -1 isnt (@_agent.toLowerCase().indexOf($key))
          @_is_mobile = true
          @_mobile = $val
          return true

    false


  #
  # Set the accepted languages
  #
  # @private
  # @return [Void]  #
  _set_languages: () ->

  # req.acceptedLanguages
    if (count(@_languages) is 0) and @req.headers['accept-language']?  and @req.headers['accept-language'] isnt ''
      $languages = preg_replace('/(;q=[0-9\\.]+)/i', '', trim(@req.headers['accept-language'].toLowerCase()))

      @_languages = $languages.split(',')


    if count(@_languages) is 0
      @_languages = ['Undefined']
    return


  #
  # Set the accepted character sets
  #
  # @private
  # @return [Void]  #
  _set_charsets: () ->

  # req.acceptedCharsets
    if (count(@_charsets) is 0) and @req.headers['accept-charset']?  and @req.headers['accept-charset'] isnt ''
      $charsets = preg_replace('/(;q=.+)/i', '', trim(@req.headers['accept-charset'].toLowerCase()))

      @_charsets = $charsets.split(',')


    if count(@_charsets) is 0
      @_charsets = ['Undefined']
    return


  #
  # Is Browser
  #
  # @return	bool
  #
  isBrowser: ($key = null) ->

    if not @_is_browser
      return false

  #  No need to be specific, it's a browser
    if $key is null
      return true

  #  Check for a specific browser
    @_browsers[$key]? and @_browser is @_browsers[$key]

  #
  # Is Robot
  #
  # @return	bool
  #
  isRobot: ($key = null) ->

    if not @_is_robot
      return false

  #  No need to be specific, it's a robot
    if $key is null
      return true

  #  Check for a specific robot
    @_robots[$key]? and @_robot is @_robots[$key]

  #
  # Is Mobile
  #
  # @return	bool
  #
  isMobile: ($key = null) ->

    if not @_is_mobile
      return false

  #  No need to be specific, it's a mobile
    if $key is null
      return true

  #  Check for a specific robot
    @_mobiles[$key]? and @_mobile is @_mobiles[$key]


  #
  # Is this a referral from another site?
  #
  # @return	bool
  #
  isReferral: () ->

    if not @req.headers['referer']?  or @req.headers['referer'] is '' then false else true


  #
  # Agent String
  #
  # @return	[String]
  #
  agentString: () ->
    @_agent

  #
  # Get Platform
  #
  # @return	[String]
  #
  platform: () ->
    @_platform

  #
  # Get Browser Name
  #
  # @return	[String]
  #
  browser: () ->
    @_browser

  #
  # Get the Browser Version
  #
  # @return	[String]
  #
  version: () ->
    @_version

  #
  # Get The Robot Name
  #
  # @return	[String]
  #
  robot: () ->
    @_robot

  #
  # Get the Mobile Device
  #
  # @return	[String]
  #
  mobile: () ->
    @_mobile

  
  #
  # Get the referrer
  #
  # @return	bool
  #
  #req.headers['referer']
  referrer: () ->
    if ( not @req.headers['referer']?  or @req.headers['referer'] is '') then '' else trim(@req.headers['referer'])

  
  #
  # Get the accepted languages
  #
  # @return	array
  #
  languages: () ->
    if count(@_languages) is 0
      @_set_languages()

    @_languages

  
  #
  # Get the accepted Character Sets
  #
  # @return	array
  #
  charsets: () ->
    if count(@_charsets) is 0
      @_set_charsets()

    @_charsets

  
  #
  # Test for a particular language
  #
  # @return	bool
  #
  acceptLang: ($lang = 'en') ->
    in_array($lang.toLowerCase(), @_languages(), true)

  
  #
  # Test for a particular character set
  #
  # @return	bool
  #
  acceptCharset: ($charset = 'utf-8') ->
    in_array($charset.toLowerCase(), @_charsets(), true)


module.exports = system.lib.UserAgent


#  End of file UserAgent.coffee
#  Location: ./system/lib/Useragent.coffee