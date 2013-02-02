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

    #  Set the cookie name
    @sess_cookie_name = @cookie_prefix + @sess_cookie_name

    if $Exspresso.req?

      $req = @req = $Exspresso.req
      $res = @res = $Exspresso.res


      $m = preg_match("/#{@sess_cookie_name}=([^ ,;]*)/", $req.headers.cookie)
      if $m?
        $m = $m[1].split('.')[0]
        $m = urldecode($m).split(':')[1]

        log_message 'debug', 'sid = %s', $m

      $req.session.ip_address     = ($req.headers['x-forwarded-for'] || '').split(',')[0] || $req.connection.remoteAddress
      $req.session.user_agent     = $req.headers['user-agent']
      $req.session.last_activity  = (new Date()).getTime()
      $req.session.userdata       = $req.session.userdata || {}

      if $res.locals?
        if express.version[0] is '3'
          $res.locals.flashdata = @flashdata
        else
          $res.local('flashdata', @flashdata)
      else
        $res.flashdata = @flashdata


      @_flashdata_sweep()

      #  Mark all new flashdata as old (data will be deleted before next request)
      @_flashdata_mark()

      #  Delete expired sessions if necessary
      #@_sess_gc()

      log_message('debug', "Session routines successfully run")

    else

      # then we're booting.
      # Initialize the server:
      Exspresso.server.session @


  # --------------------------------------------------------------------

  #
  # Get logged in user
  #
  user: () ->
    @req.session.user ? false
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


  #  --------------------------------------------------------------------

  #
  # Write the session cookie
  #
  # @access	public
  # @return	void
  #
  _set_cookie : ($cookie_data = null) ->
    if is_null($cookie_data)
      $cookie_data = @_userdata

    #  Serialize the userdata for the cookie
    $cookie_data = @_serialize($cookie_data)

    if @sess_encrypt_cookie is true
      $cookie_data = @Exspresso.encrypt.encode($cookie_data)

    else
      #  if encryption is not used, we provide an md5 hash to prevent userside tampering
      $cookie_data = $cookie_data + md5($cookie_data + @encryption_key)

    $expire = if (@sess_expire_on_close is true) then 0 else @sess_expiration + time()

    #  Set the cookie
    @_setcookie(
      @sess_cookie_name,
      $cookie_data,
      $expire,
      @cookie_path,
      @cookie_domain,
      @cookie_secure
    )

  #  --------------------------------------------------------------------

  #
  # Serialize an array
  #
  # This function first converts any slashes found in the array to a temporary
  # marker, so when it gets unserialized the slashes will be preserved
  #
  # @access	private
  # @param	array
  # @return	string
  #
  _serialize: ($data) ->
    if is_array($data)
      for $key, $val of $data
        if is_string($val)
          $data[$key] = str_replace('\\', '{{slash}}', $val)
    else
      if is_string($data)
        $data = str_replace('\\', '{{slash}}', $data)

    return serialize($data)

  #  --------------------------------------------------------------------

  #
  # Unserialize
  #
  # This function unserializes a data string, then converts any
  # temporary slash markers back to actual slashes
  #
  # @access	private
  # @param	array
  # @return	string
  #
  _unserialize: ($data) ->
    $data = unserialize(strip_slashes($data))

    if is_array($data)
      for $key, $val of $data
        if is_string($val)
          $data[$key] = str_replace('{{slash}}', '\\', $val)

      return $data

    return if (is_string($data)) then str_replace('{{slash}}', '\\', $data) else $data

  #  --------------------------------------------------------------------

  #
  # php setcookie
  #
  # @access	private
  # @return	string
  #
  _setcookie: ($name, $value, $expire = 0, $path = '/', $domain, $secure = false, $httponly = false) ->

    if $secure and not @req.secure
      throw new Error('secure protocole required for signed cookies')
    if $secure and not @req.secret
      throw new Error('connect.cookieParser("secret") required for signed cookies')

    $options =
      path      : $path
      expires   : $expire
      domain    : $domain
      secure    : $secure
      httpOnly  : $httponly

    @res.set 'Set-Cookie', cookie.serialize($name, $value, $options)


#  END Session Class
module.exports = Exspresso_Session
#  End of file Session.php 
#  Location: ./system/libraries/Session.php 