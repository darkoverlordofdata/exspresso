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
  sess_cookie_name        : 'sessions'
  cookie_prefix           : ''
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

      $req.session.session_id     = $req.sessionID
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


      ###
      $Exspresso.queue ($next) =>
        #  Run the Session routine. If a session doesn't exist we'll
        #  create a new one.  If it does, we'll update it.
        @sess_read ($err, $exists) =>
          return $next($err) if log_message('error', 'Session::ctor %s', $err) if $err
          if not $exists
            @sess_create ($err) =>
              return $next($err) if log_message('error', 'Session::ctor %s', $err) if $err
              $next()
          else
            @sess_update ($err) =>
              return $next($err) if log_message('error', 'Session::ctor %s', $err) if $err
              $next()

      ###

      $Exspresso.queue ($next) =>
        #  Delete 'old' flashdata (from last request)
        @_flashdata_sweep()

        #  Mark all new flashdata as old (data will be deleted before next request)
        @_flashdata_mark()

        #  Delete expired sessions if necessary
        #@_sess_gc()

        log_message('debug', "Session routines successfully run")
        $next()

    else

      # then we're booting.
      # Initialize the server:
      Exspresso.server.session @

  #  --------------------------------------------------------------------

  #
  # Fetch the current session data if it exists
  #
  # @access	public
  # @return	bool
  #
  sess_read: ($next) ->
    #  Fetch the cookie
    $session = @Exspresso.input.cookie(@sess_cookie_name)

    #  No cookie?  Goodbye cruel world!...
    if $session is false
      log_message('debug', 'A session cookie was not found.')
      return $next(null, false)

    #  Decrypt the cookie data
    if @sess_encrypt_cookie is true
      $session = @Exspresso.encrypt.decode($session)

    else
      #  encryption was not used, so we need to check the md5 hash
      $hash = substr($session, strlen($session) - 32)#  get last 32 chars
      $session = substr($session, 0, strlen($session) - 32)

      #  Does the md5 hash match?  This is to prevent manipulation of session data in userspace
      if $hash isnt md5($session + @encryption_key)
        log_message('error', 'The session cookie data did not match what was expected. This could be a possible hacking attempt.')
        @sess_destroy ($err) =>
          return $next($err, false)

    #  Unserialize the session array
    $session = @_unserialize($session)

    #  Is the session data we unserialized an array with the correct format?
    if not is_array($session) or  not $session['session_id']?  or  not $session['ip_address']?  or  not $session['user_agent']?  or  not $session['last_activity']?
      @sess_destroy ($err) =>
        return $next($err, false)

    #  Is the session current?
    if ($session['last_activity'] + @sess_expiration) < @_now
      @sess_destroy ($err) =>
        return $next($err, false)

    #  Does the IP Match?
    if @sess_match_ip is true and $session['ip_address'] isnt @Exspresso.input.ip_address()
      @sess_destroy ($err) =>
        return $next($err, false)

    #  Does the User Agent Match?
    if @sess_match_useragent is true and trim($session['user_agent']) isnt trim(substr(@Exspresso.input.user_agent(), 0, 120))
      @sess_destroy ($err) =>
        return $next($err, false)

    #  Is there a corresponding session in the DB?
    if @sess_use_database is true
      Exspresso.db.where('session_id', $session['session_id'])

      if @sess_match_ip is true
        Exspresso.db.where('ip_address', $session['ip_address'])

      if @sess_match_useragent is true
        Exspresso.db.where('user_agent', $session['user_agent'])

      Exspresso.db.get @sess_table_name, ($err, $query) =>

        #  No result?  Kill it!
        if $query.num_rows() is 0
          @sess_destroy ($err) =>
            return $next($err, false)

        #  Is there custom data?  If so, add it to the main session array
        $row = $query.row()
        if $row.user_data?  and $row.user_data isnt ''
          $custom_data = @_unserialize($row.user_data)

          if is_array($custom_data)
            for $key, $val of $custom_data
              $session[$key] = $val
        #  Session is valid!
        @_userdata = $session
        return $next(null, true)

    #  Session is valid!
    @_userdata = $session
    $session = null

    return $next(null, true)

  #  --------------------------------------------------------------------

  #
  # Write the session data
  #
  # @access	public
  # @return	void
  #
  sess_write: ($next) ->
    #  Are we saving custom data to the DB?  If not, all we do is update the cookie
    if @sess_use_database is false
      @_set_cookie()
      return $next()


    #  set the custom userdata, the session data we will set in a second
    $custom_userdata = @_userdata
    $cookie_userdata = {}

    #  Before continuing, we need to determine if there is any custom data to deal with.
    #  Let's determine this by removing the default indexes to see if there's anything left in the array
    #  and set the session data while we're at it
    for $val in ['session_id', 'ip_address', 'user_agent', 'last_activity']
      delete $custom_userdata[$val]
      $cookie_userdata[$val] = @_userdata[$val]


    #  Did we find any custom data?  If not, we turn the empty array into a string
    #  since there's no reason to serialize and store an empty array in the DB
    if count($custom_userdata) is 0
      $custom_userdata = ''

    else
      #  Serialize the custom data array so we can store it
      $custom_userdata = @_serialize($custom_userdata)


    #  Run the update query
    Exspresso.db.where 'session_id', @_userdata['session_id']
    $data =
      last_activity   : @_userdata['last_activity']
      user_data       : $custom_userdata

    Exspresso.db.update @sess_table_name, $data, ($err) =>

      return $next($err) if log_message('error', 'Session::sess_write %s', $err) if $err
      @_set_cookie($cookie_userdata)
      $next()

    #  Write the cookie.  Notice that we manually pass the cookie data array to the
    #  _set_cookie() function. Normally that function will store $this->userdata, but
    #  in this case that array contains custom data, which we do not want in the cookie.
    @_set_cookie($cookie_userdata)
    $next()


  #  --------------------------------------------------------------------

  #
  # Create a new session
  #
  # @access	public
  # @return	void
  #
  sess_create: ($next) ->
    $sessid = ''
    while strlen($sessid) < 32
      $sessid+=mt_rand(0, mt_getrandmax())

    #  To make the session ID even more secure we'll combine it with the user's IP
    $sessid+=@Exspresso.input.ip_address()

    @_userdata =
      session_id      : md5(uniqid($sessid, true)),
      ip_address      : @Exspresso.input.ip_address(),
      user_agent      : substr(@Exspresso.input.user_agent(), 0, 120),
      last_activity   : @_now,
      user_data       : ''

    #  Save the data to the DB if needed
    if @sess_use_database is true
      $sql = Exspresso.db.insert_string(@sess_table_name, @_userdata)
      Exspresso.db.query $sql, ($err) =>

        return if log_message('error', 'Session::sess_create %s', $err) if $err
        @_set_cookie()
        $next()


    #  Write the cookie
    @_set_cookie()
    $next()

  #  --------------------------------------------------------------------

  #
  # Update an existing session
  #
  # @access	public
  # @return	void
  #
  sess_update: ($next) ->
    #  We only update the session every five minutes by default
    if (@_userdata['last_activity'] + @sess_time_to_update)>=@_now
      return $next()


    #  Save the old session id so we know which record to
    #  update in the database if we need it
    $old_sessid = @_userdata['session_id']
    $new_sessid = ''
    while strlen($new_sessid) < 32
      $new_sessid+=mt_rand(0, mt_getrandmax())


    #  To make the session ID even more secure we'll combine it with the user's IP
    $new_sessid+=@Exspresso.input.ip_address()

    #  Turn it into a hash
    $new_sessid = md5(uniqid($new_sessid, true))

    #  Update the session data in the session data array
    @_userdata['session_id'] = $new_sessid
    @_userdata['last_activity'] = @_now

    #  _set_cookie() will handle this for us if we aren't using database sessions
    #  by pushing all userdata to the cookie.
    $cookie_data = null

    #  Update the session ID and last_activity field in the DB if needed
    if @sess_use_database is true
      #  set cookie explicitly to only have our session data
      $cookie_data = {}
      for $val in ['session_id', 'ip_address', 'user_agent', 'last_activity']
        $cookie_data[$val] = @_userdata[$val]


      $sql = Exspresso.db.update_string(@sess_table_name, last_activity:@_now, session_id:$new_sessid, session_id:$old_sessid)
      Exspresso.db.query $sql, ($err) =>
        return $next($err) if log_message('error', 'Session::sess_update %s', $err) if $err
        @_set_cookie($cookie_data)
        return $next()

    #  Write the cookie
    @_set_cookie($cookie_data)
    return $next()

  #  --------------------------------------------------------------------

  #
  # Destroy the current session
  #
  # @access	public
  # @return	void
  #
  sess_destroy: ($next) ->
    #  Kill the session DB row
    if @sess_use_database is true and @_userdata['session_id']?
      Exspresso.db.where 'session_id', @_userdata['session_id']
      Exspresso.db.delete @sess_table_name, ($err) =>

        return $next($err) log_message('error', 'Session::sess_destroy %s', $err) if $err
        @_sess_destroy2($next)

    else
      @_sess_destroy2($next)

  _sess_destroy2: ($next) ->
    #  Kill the cookie
    @_setcookie(
      @sess_cookie_name,
      addslashes(serialize({})),
      (@_now - 31500000),
      @cookie_path,
      @cookie_domain,
      0
    )

    #  Kill session data
    @_userdata = {}
    $next()


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