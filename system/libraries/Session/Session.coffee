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
# @copyright  Copyright (c) 2012, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

express         = require('express')                    # Express 3.0 Framework
cookie          = require('cookie')                     # cookie parsing and serialization
#  ------------------------------------------------------------------------
#
# Session Class
#
class global.Exspresso_Session

  {format}    = require('util')
  unserialize = JSON.parse
  serialize   = JSON.stringify
  urldecode   = decodeURIComponent
  urlencode   = encodeURIComponent

  Exspresso               : null
  req                     : null
  res                     : null

  # expose config as public properties
  sess_encrypt_cookie     : false
  sess_use_database       : false
  sess_table_name         : ''
  sess_expiration         : 7200
  sess_expire_on_close    : false
  sess_match_ip           : false
  sess_match_useragent    : true
  sess_cookie_name        : 'sid'
  cookie_prefix           : 'connect.'
  cookie_path             : ''
  cookie_domain           : ''
  cookie_secure           : false
  sess_time_to_update     : 300
  encryption_key          : ''
  time_reference          : 'local'

  _flashdata_key          : 'flash'
  _gc_probability         : 5
  _userdata               : null
  _now                    : 0

  #
  # Session Constructor
  #
  # The constructor runs the session routines automatically
  # whenever the class is instantiated.
  #
  constructor: ($params = {}, $Exspresso) ->

    log_message 'debug', "Session Class Initialized"

    @_userdata = {}
    @_now = 0

    #  Set all the session preferences, which can either be set
    #  manually via the $params array above or via the config file
    for $key in ['sess_encrypt_cookie', 'sess_use_database', 'sess_table_name', 'sess_expiration', 'sess_expire_on_close', 'sess_match_ip', 'sess_match_useragent', 'sess_cookie_name', 'cookie_path', 'cookie_domain', 'cookie_secure', 'sess_time_to_update', 'time_reference', 'cookie_prefix', 'encryption_key']
      @[$key] = if ($params[$key]?) then $params[$key] else config_item($key)

    if @_encryption_key is ''
      show_error('In order to use the Session class you are required to set an encryption key in your config file.')

    #  Set the "now" time.  Can either be GMT or server time, based on the
    #  config prefs.  We use this to set the "last activity" time
    @_now = @_get_time()

    #  Set the session length. If the session expiration is
    #  set to zero we'll set the expiration two years from now.
    if @sess_expiration is 0
      @sess_expiration = (60 * 60 * 24 * 365 * 2)

    if $Exspresso.req?

      $req = @req = $Exspresso.req
      $res = @res = $Exspresso.res

      # expose flashdata method in views
      if $res.locals?
        if express.version[0] is '3'
          $res.locals.flashdata = @flashdata
        else
          $res.local('flashdata', @flashdata)
      else
        $res.flashdata = @flashdata

      #  Delete 'old' flashdata (from last request)
      @_flashdata_sweep()

      #  Mark all new flashdata as old (data will be deleted before next request)
      @_flashdata_mark()

      log_message('debug', "Session routines successfully run")

    else

      # then we're booting.
      # Initialize the server:
      Exspresso.server.session @


  # --------------------------------------------------------------------

  #
  # Get logged in user
  #
  user: () -> @req.user()
  # --------------------------------------------------------------------

  #
  # Add or change data in the "userdata" array
  #
  # @access public
  # @param mixed
  # @param string
  # @return void
  #
  set_userdata: ($newdata = {}, $newval = '') ->

    $data = @req.session.userdata = @req.session.userdata ? {}

    if typeof $newdata is 'string'
      $newdata = array($newdata, $newval)

    if count($newdata) > 0
      for $key, $val of $newdata
        $data[$key] = $val

    return
  # --------------------------------------------------------------------

  #
  # Delete a session variable from the "userdata" array
  #
  # @access public
  # @param mixed
  # @return void
  #
  unset_userdata: ($newdata = {}) ->

    $data = @req.session.userdata = @req.session.userdata ? {}

    if typeof $newdata is 'string'
      $newdata = array($newdata, '')

    if count($newdata) > 0
      for $key, $val of $newdata
        delete $data[$key]

    return
  # --------------------------------------------------------------------

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

  # --------------------------------------------------------------------

  #
  # Fetch all session data
  #
  # @access public
  # @return mixed
  #
  all_userdata: () ->

    if not @req.session.userdata? then false else @req.session.userdata

  #  ------------------------------------------------------------------------

  #
  # Add or change flashdata, only available
  # until the next request
  #
  # @access	public
  # @param	mixed
  # @param	string
  # @return	void
  #
  set_flashdata : ($newdata = {}, $args...) ->

    switch $args.length
      when 0 then $newval = ''
      when 1 then $newval = $args[0]
      else $newval = format.apply(undefined, $args)

    if is_string($newdata)
      $newdata = array($newdata, $newval)

    if count($newdata) > 0
      for $key, $val of $newdata
        $flashdata_key = @_flashdata_key + ':new:' + $key
        @set_userdata($flashdata_key, $val)


  #  ------------------------------------------------------------------------

  #
  # Keeps existing flashdata available to next request.
  #
  # @access	public
  # @param	string
  # @return	void
  #
  keep_flashdata : ($key) ->
    #  'old' flashdata gets removed.  Here we mark all
    #  flashdata as 'new' to preserve it from _flashdata_sweep()
    #  Note the function will return FALSE if the $key
    #  provided cannot be found
    $old_flashdata_key = @_flashdata_key + ':old:' + $key
    $value = @userdata($old_flashdata_key)

    $new_flashdata_key = @_flashdata_key + ':new:' + $key
    @set_userdata($new_flashdata_key, $value)

  #  ------------------------------------------------------------------------

  #
  # Fetch a specific flashdata item from the session array
  #
  # @access	public
  # @param	string
  # @return	string
  #
  flashdata : ($key) =>

    $flashdata_key = @_flashdata_key + ':old:' + $key
    return @userdata($flashdata_key)

  #  ------------------------------------------------------------------------

  #
  # Identifies flashdata as 'old' for removal
  # when _flashdata_sweep() runs.
  #
  # @access	private
  # @return	void
  #
  _flashdata_mark :  ->
    $userdata = @all_userdata()
    for $name, $value of $userdata
      $parts = explode(':new:', $name)
      if is_array($parts) and count($parts) is 2
        $new_name = @_flashdata_key + ':old:' + $parts[1]
        @set_userdata($new_name, $value)
        @unset_userdata($name)

  #  ------------------------------------------------------------------------

  #
  # Removes all flashdata marked as 'old'
  #
  # @access	private
  # @return	void
  #
  _flashdata_sweep :  ->
    $userdata = @all_userdata()
    for $key, $value of $userdata
      if strpos($key, ':old:')
        @unset_userdata($key)

  #  --------------------------------------------------------------------

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