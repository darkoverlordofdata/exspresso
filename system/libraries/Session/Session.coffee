#+--------------------------------------------------------------------+
#  Session.coffee
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
# Session Class
#
class global.Exspresso_Session extends Exspresso_Driver_Library

  express     = require('express')      # Express 3.0 Framework
  cookie      = require('cookie')       # cookie parsing and serialization
  format      = require('util').format  # sprintf style formated string
  urldecode   = decodeURIComponent      # Decodes any %## encoding in the given string

  FLASH_KEY               = 'flash'     # flash data key prefix
  FLASH_NEW               = ':new:'     # flash data key new flag
  FLASH_OLD               = ':old:'     # flash data key old flag

  #
  # expose config as public properties
  #
  sess_driver             : 'sql'       # Session storage driver
  sess_encrypt_cookie     : false       # are cookies encrypted?
  sess_use_database       : false       # are sessions stored to database?
  sess_table_name         : ''          # storage table name in database
  sess_expiration         : 7200        # how long until the session expires
  sess_expire_on_close    : false       # expire session when browser is closed?
  sess_match_ip           : false       # match users ip to identify?
  sess_match_useragent    : true        # match the user agent to identify?
  sess_cookie_name        : 'sid'       # cookie name used for sessions
  cookie_prefix           : 'connect.'  # cookie name prefix used for sessions
  cookie_path             : ''          # path associated with cookies
  cookie_domain           : ''          # domain associated with cookies
  cookie_secure           : false       # using secure cookies?
  sess_time_to_update     : 300         # interval to update database
  encryption_key          : ''          # secure encryption key
  time_reference          : 'local'     # time specified as 'local' or 'gmt'

  _userdata               : null        # user data memory

  #
  # Session Constructor
  #
  # The constructor runs the session routines automatically
  # whenever the class is instantiated.
  #
  constructor: ($controller, $params = {}) ->

    log_message 'debug', "Session Class Initialized"

    #  Set all the session preferences, which can either be set
    #  manually via the $params array above or via the config file
    for $key in ['sess_driver', 'sess_encrypt_cookie', 'sess_use_database', 'sess_table_name', 'sess_expiration', 'sess_expire_on_close', 'sess_match_ip', 'sess_match_useragent', 'sess_cookie_name', 'cookie_path', 'cookie_domain', 'cookie_secure', 'sess_time_to_update', 'time_reference', 'cookie_prefix', 'encryption_key']
      @[$key] = if ($params[$key]?) then $params[$key] else config_item($key)

    if @_encryption_key is ''
      show_error('In order to use the Session class you are required to set an encryption key in your config file.')

    #  Set the session length. If the session expiration is
    #  set to zero we'll set the expiration two years from now.
    if @sess_expiration is 0
      @sess_expiration = (60 * 60 * 24 * 365 * 2)

    # Is there an http request?
    if @req?

      # initialize userdata for this session
      @_userdata = {}

      # expose flashdata method in views
      if @res.locals?
        if express.version[0] is '3'
          @res.locals.flashdata = @flashdata
        else
          @res.local('flashdata', @flashdata)
      else
        @res.flashdata = @flashdata

      #  Delete 'old' flashdata (from last request)
      @_flashdata_sweep()

      #  Mark all new flashdata as old (data will be deleted before next request)
      @_flashdata_mark()

      log_message('debug', "Session routines successfully run")

    else @server.session @ # we're booting, initialize the driver



  #
  # Parse the session properties
  #
  # Called prior to each controller constructor, ensures
  # that the expected session objects are available
  #
  # @access private
  # @param object
  # @param object
  # @param function
  # @return void
  #
  #
  parse_request: ($cookie_name) -> ($req, $res, $next) =>

    # parse the session id
    if $req.headers.cookie?
      if ($match = preg_match("/#{$cookie_name}=([^ ,;]*)/", $req.headers.cookie))?
        $sid = $match[1].split('.')[0]
        $req.session.session_id = urldecode($sid).split(':')[1]

    # set reasonable session defaults
    $req.session.uid            = $req.session.uid || User_model.UID_ANONYMOUS
    $req.session.ip_address     = ($req.headers['x-forwarded-for'] || '').split(',')[0] || $req.connection.remoteAddress
    $req.session.user_agent     = $req.headers['user-agent']
    $req.session.last_activity  = @_get_time()
    $req.session.userdata       = $req.session.userdata || {}

    $next()

  #
  # Add or change data in the "userdata" array
  #
  # @access public
  # @param mixed
  # @param string
  # @return void
  #
  setUserdata: ($newdata = {}, $newval = '') ->

    $data = @req.session.userdata = @req.session.userdata ? {}

    if typeof $newdata is 'string'
      $data[$newdata] = $newval

    else
      for $key, $val of $newdata
        $data[$key] = $val

    return

  #
  # Delete a session variable from the "userdata" array
  #
  # @access public
  # @param mixed
  # @return void
  #
  unsetUserdata: ($newdata = {}) ->

    $data = @req.session.userdata = @req.session.userdata ? {}

    if typeof $newdata is 'string'
      $data[$newdata] = ''

    else
      for $key, $val of $newdata
        delete $data[$key]

    return

  #
  # Fetch a specific item from the session array
  #
  # @access public
  # @param string
  # @return string
  #
  userdata: ($item) ->

    $data = @req.session.userdata = @req.session.userdata ? {}

    if not $data[$item]? then false else $data[$item]

  #
  # Fetch all session data
  #
  # @access public
  # @return mixed
  #
  allUserdata: () ->

    if not @req.session.userdata? then false else @req.session.userdata

  #
  # Add or change flashdata, only available
  # until the next request
  #
  # @access	public
  # @param	mixed
  # @param	string
  # @return	void
  #
  setFlashdata : ($newdata = {}, $args...) ->

    switch $args.length
      when 0 then $newval = ''
      when 1 then $newval = $args[0]
      else $newval = format.apply(undefined, $args)

    if typeof $newdata is 'string'
      $newdata = array($newdata, $newval)

    for $key, $val of $newdata
      $flashdata_key = FLASH_KEY + FLASH_NEW + $key
      @setUserdata($flashdata_key, $val)


  #
  # Keeps existing flashdata available to next request.
  #
  # @access	public
  # @param	string
  # @return	void
  #
  keepFlashdata : ($key) ->
    #  'old' flashdata gets removed.  Here we mark all
    #  flashdata as 'new' to preserve it from _flashdata_sweep()
    #  Note the function will return FALSE if the $key
    #  provided cannot be found
    $old_flashdata_key = FLASH_KEY + FLASH_OLD + $key
    $value = @userdata($old_flashdata_key)

    $new_flashdata_key = FLASH_KEY + FLASH_NEW + $key
    @setUserdata($new_flashdata_key, $value)

  #
  # Fetch a specific flashdata item from the session array
  #
  # @access	public
  # @param	string
  # @return	string
  #
  flashdata : ($key) =>

    $flashdata_key = FLASH_KEY + FLASH_OLD + $key
    return @userdata($flashdata_key)

  #
  # Identifies flashdata as 'old' for removal
  # when _flashdata_sweep() runs.
  #
  # @access	private
  # @return	void
  #
  _flashdata_mark :  ->
    $userdata = @allUserdata()
    for $name, $value of $userdata
      $parts = explode(FLASH_NEW, $name)
      if is_array($parts) and count($parts) is 2
        $new_name = FLASH_KEY + FLASH_OLD + $parts[1]
        @setUserdata($new_name, $value)
        @unsetUserdata($name)

  #
  # Removes all flashdata marked as 'old'
  #
  # @access	private
  # @return	void
  #
  _flashdata_sweep :  ->
    $userdata = @allUserdata()
    for $key, $value of $userdata
      if strpos($key, FLASH_OLD)
        @unsetUserdata($key)

  #
  # Get the "now" time
  #
  # @access	private
  # @return	string
  #
  _get_time :  ->
    $date = new Date()
    $time = $date.getTime()
    if strtolower(@time_reference) is 'gmt'
      $time = $time - $date.getTimezoneOffset()
    return $time


#  END Session Class
module.exports = Exspresso_Session

#  End of file Session.php
#  Location: ./system/libraries/Session.php