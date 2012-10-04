#+--------------------------------------------------------------------+
#  Session.coffee
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
{__construct, addslashes, config, cookie, count, database, db, decode, defined, delete, encode, encrypt, explode, get, get_instance, gmdate, helper, input, insert_string, ip_address, is_array, is_null, is_string, item, library, load, md5, mktime, mt_getrandmax, mt_rand, num_rows, query, rand, row, serialize, setcookie, srand, str_replace, strip_slashes, strlen, strpos, strtolower, substr, time, trim, uniqid, unserialize, update, update_string, user_agent, user_data, where}  = require(FCPATH + 'pal')
{config_item, get_class, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

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
# Session Class
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Sessions
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/libraries/sessions.html
#
class CI_Session
  
  sess_encrypt_cookie: false
  sess_use_database: false
  sess_table_name: ''
  sess_expiration: 7200
  sess_expire_on_close: false
  sess_match_ip: false
  sess_match_useragent: true
  sess_cookie_name: 'ci_session'
  cookie_prefix: ''
  cookie_path: ''
  cookie_domain: ''
  cookie_secure: false
  sess_time_to_update: 300
  encryption_key: ''
  flashdata_key: 'flash'
  time_reference: 'time'
  gc_probability: 5
  userdata: {}
  CI: {}
  now: {}
  
  #
  # Session Constructor
  #
  # The constructor runs the session routines automatically
  # whenever the class is instantiated.
  #
  __construct($params = {})
  {
  log_message('debug', "Session Class Initialized")
  
  #  Set the super object to a local variable for use throughout the class
  @CI = get_instance()
  
  #  Set all the session preferences, which can either be set
  #  manually via the $params array above or via the config file
  for $key in ['sess_encrypt_cookie', 'sess_use_database', 'sess_table_name', 'sess_expiration', 'sess_expire_on_close', 'sess_match_ip', 'sess_match_useragent', 'sess_cookie_name', 'cookie_path', 'cookie_domain', 'cookie_secure', 'sess_time_to_update', 'time_reference', 'cookie_prefix', 'encryption_key']
    @$key = if ($params[$key]? ) then $params[$key] else @CI.config.item($key)
    
  
  if @encryption_key is ''
    show_error('In order to use the Session class you are required to set an encryption key in your config file.')
    
  
  #  Load the string helper so we can use the strip_slashes() function
  @CI.load.helper('string')
  
  #  Do we need encryption? If so, load the encryption class
  if @sess_encrypt_cookie is true
    @CI.load.library('encrypt')
    
  
  #  Are we using a database?  If so, load it
  if @sess_use_database is true and @sess_table_name isnt ''
    @CI.load.database()
    
  
  #  Set the "now" time.  Can either be GMT or server time, based on the
  #  config prefs.  We use this to set the "last activity" time
  @now = @_get_time()
  
  #  Set the session length. If the session expiration is
  #  set to zero we'll set the expiration two years from now.
  if @sess_expiration is 0
    @sess_expiration = (60 * 60 * 24 * 365 * 2)
    
  
  #  Set the cookie name
  @sess_cookie_name = @cookie_prefix + @sess_cookie_name
  
  #  Run the Session routine. If a session doesn't exist we'll
  #  create a new one.  If it does, we'll update it.
  if not @sess_read()
    @sess_create()
    
  else 
    @sess_update()
    
  
  #  Delete 'old' flashdata (from last request)
  @_flashdata_sweep()
  
  #  Mark all new flashdata as old (data will be deleted before next request)
  @_flashdata_mark()
  
  #  Delete expired sessions if necessary
  @_sess_gc()
  
  log_message('debug', "Session routines successfully run")
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Fetch the current session data if it exists
  #
  # @access	public
  # @return	bool
  #
  sess_read :  ->
    #  Fetch the cookie
    $session = @CI.input.cookie(@sess_cookie_name)
    
    #  No cookie?  Goodbye cruel world!...
    if $session is false
      log_message('debug', 'A session cookie was not found.')
      return false
      
    
    #  Decrypt the cookie data
    if @sess_encrypt_cookie is true
      $session = @CI.encrypt.decode($session)
      
    else 
      #  encryption was not used, so we need to check the md5 hash
      $hash = substr($session, strlen($session) - 32)#  get last 32 chars
      $session = substr($session, 0, strlen($session) - 32)
      
      #  Does the md5 hash match?  This is to prevent manipulation of session data in userspace
      if $hash isnt md5($session + @encryption_key)
        log_message('error', 'The session cookie data did not match what was expected. This could be a possible hacking attempt.')
        @sess_destroy()
        return false
        
      
    
    #  Unserialize the session array
    $session = @_unserialize($session)
    
    #  Is the session data we unserialized an array with the correct format?
    if not is_array($session) or  not $session['session_id']?  or  not $session['ip_address']?  or  not $session['user_agent']?  or  not $session['last_activity']? 
      @sess_destroy()
      return false
      
    
    #  Is the session current?
    if ($session['last_activity'] + @sess_expiration) < @now
      @sess_destroy()
      return false
      
    
    #  Does the IP Match?
    if @sess_match_ip is true and $session['ip_address'] isnt @CI.input.ip_address()
      @sess_destroy()
      return false
      
    
    #  Does the User Agent Match?
    if @sess_match_useragent is true and trim($session['user_agent']) isnt trim(substr(@CI.input.user_agent(), 0, 50))
      @sess_destroy()
      return false
      
    
    #  Is there a corresponding session in the DB?
    if @sess_use_database is true
      @CI.db.where('session_id', $session['session_id'])
      
      if @sess_match_ip is true
        @CI.db.where('ip_address', $session['ip_address'])
        
      
      if @sess_match_useragent is true
        @CI.db.where('user_agent', $session['user_agent'])
        
      
      $query = @CI.db.get(@sess_table_name)
      
      #  No result?  Kill it!
      if $query.num_rows() is 0
        @sess_destroy()
        return false
        
      
      #  Is there custom data?  If so, add it to the main session array
      $row = $query.row()
      if $row.user_data?  and $row.user_data isnt ''
        $custom_data = @_unserialize($row.user_data)
        
        if is_array($custom_data)
          for $key, $val of $custom_data
            $session[$key] = $val
            
          
        
      
    
    #  Session is valid!
    @userdata = $session
    delete $session
    
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Write the session data
  #
  # @access	public
  # @return	void
  #
  sess_write :  ->
    #  Are we saving custom data to the DB?  If not, all we do is update the cookie
    if @sess_use_database is false
      @_set_cookie()
      return 
      
    
    #  set the custom userdata, the session data we will set in a second
    $custom_userdata = @userdata
    $cookie_userdata = {}
    
    #  Before continuing, we need to determine if there is any custom data to deal with.
    #  Let's determine this by removing the default indexes to see if there's anything left in the array
    #  and set the session data while we're at it
    for $val in ['session_id', 'ip_address', 'user_agent', 'last_activity']
      delete $custom_userdata[$val]
      $cookie_userdata[$val] = @userdata[$val]
      
    
    #  Did we find any custom data?  If not, we turn the empty array into a string
    #  since there's no reason to serialize and store an empty array in the DB
    if count($custom_userdata) is 0
      $custom_userdata = ''
      
    else 
      #  Serialize the custom data array so we can store it
      $custom_userdata = @_serialize($custom_userdata)
      
    
    #  Run the update query
    @CI.db.where('session_id', @userdata['session_id'])
    @CI.db.update(@sess_table_name, 'last_activity':@userdata['last_activity'], 'user_data':$custom_userdata)
    
    #  Write the cookie.  Notice that we manually pass the cookie data array to the
    #  _set_cookie() function. Normally that function will store $this->userdata, but
    #  in this case that array contains custom data, which we do not want in the cookie.
    @_set_cookie($cookie_userdata)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Create a new session
  #
  # @access	public
  # @return	void
  #
  sess_create :  ->
    $sessid = ''
    while strlen($sessid) < 32
      $sessid+=mt_rand(0, mt_getrandmax())
      
    
    #  To make the session ID even more secure we'll combine it with the user's IP
    $sessid+=@CI.input.ip_address()
    
    @userdata = 
      'session_id':md5(uniqid($sessid, true), 
    'ip_address':@CI.input.ip_address(), 
    'user_agent':substr(@CI.input.user_agent(), 0, 50), 
    'last_activity':@now
    )
    
    
    #  Save the data to the DB if needed
    if @sess_use_database is true
      @CI.db.query(@CI.db.insert_string(@sess_table_name, @userdata))
      
    
    #  Write the cookie
    @_set_cookie()
    
  
  #  --------------------------------------------------------------------
  
  #
  # Update an existing session
  #
  # @access	public
  # @return	void
  #
  sess_update :  ->
    #  We only update the session every five minutes by default
    if (@userdata['last_activity'] + @sess_time_to_update)>=@now
      return 
      
    
    #  Save the old session id so we know which record to
    #  update in the database if we need it
    $old_sessid = @userdata['session_id']
    $new_sessid = ''
    while strlen($new_sessid) < 32
      $new_sessid+=mt_rand(0, mt_getrandmax())
      
    
    #  To make the session ID even more secure we'll combine it with the user's IP
    $new_sessid+=@CI.input.ip_address()
    
    #  Turn it into a hash
    $new_sessid = md5(uniqid($new_sessid, true))
    
    #  Update the session data in the session data array
    @userdata['session_id'] = $new_sessid
    @userdata['last_activity'] = @now
    
    #  _set_cookie() will handle this for us if we aren't using database sessions
    #  by pushing all userdata to the cookie.
    $cookie_data = null
    
    #  Update the session ID and last_activity field in the DB if needed
    if @sess_use_database is true
      #  set cookie explicitly to only have our session data
      $cookie_data = {}
      for $val in ['session_id', 'ip_address', 'user_agent', 'last_activity']
        $cookie_data[$val] = @userdata[$val]
        
      
      @CI.db.query(@CI.db.update_string(@sess_table_name, 'last_activity':@now, 'session_id':$new_sessid, 'session_id':$old_sessid))
      
    
    #  Write the cookie
    @_set_cookie($cookie_data)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Destroy the current session
  #
  # @access	public
  # @return	void
  #
  sess_destroy :  ->
    #  Kill the session DB row
    if @sess_use_database is true and @userdata['session_id']? 
      @CI.db.where('session_id', @userdata['session_id'])
      @CI.db.delete(@sess_table_name)
      
    
    #  Kill the cookie
    setcookie(
    @sess_cookie_name, 
    addslashes(serialize({})), 
    (@now - 31500000), 
    @cookie_path, 
    @cookie_domain, 
    0
    )
    
  
  #  --------------------------------------------------------------------
  
  #
  # Fetch a specific item from the session array
  #
  # @access	public
  # @param	string
  # @return	string
  #
  userdata : ($item) ->
    return if ( not @userdata[$item]? ) then false else @userdata[$item]
    
  
  #  --------------------------------------------------------------------
  
  #
  # Fetch all session data
  #
  # @access	public
  # @return	mixed
  #
  all_userdata :  ->
    return if ( not @userdata? ) then false else @userdata
    
  
  #  --------------------------------------------------------------------
  
  #
  # Add or change data in the "userdata" array
  #
  # @access	public
  # @param	mixed
  # @param	string
  # @return	void
  #
  set_userdata : ($newdata = {}, $newval = '') ->
    if is_string($newdata)
      $newdata = $newdata:$newval
      
    
    if count($newdata) > 0
      for $key, $val of $newdata
        @userdata[$key] = $val
        
      
    
    @sess_write()
    
  
  #  --------------------------------------------------------------------
  
  #
  # Delete a session variable from the "userdata" array
  #
  # @access	array
  # @return	void
  #
  unset_userdata : ($newdata = {}) ->
    if is_string($newdata)
      $newdata = $newdata:''
      
    
    if count($newdata) > 0
      for $key, $val of $newdata
        delete @userdata[$key]
        
      
    
    @sess_write()
    
  
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
  set_flashdata : ($newdata = {}, $newval = '') ->
    if is_string($newdata)
      $newdata = $newdata:$newval
      
    
    if count($newdata) > 0
      for $key, $val of $newdata
        $flashdata_key = @flashdata_key + ':new:' + $key
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
    $old_flashdata_key = @flashdata_key + ':old:' + $key
    $value = @userdata($old_flashdata_key)
    
    $new_flashdata_key = @flashdata_key + ':new:' + $key
    @set_userdata($new_flashdata_key, $value)
    
  
  #  ------------------------------------------------------------------------
  
  #
  # Fetch a specific flashdata item from the session array
  #
  # @access	public
  # @param	string
  # @return	string
  #
  flashdata : ($key) ->
    $flashdata_key = @flashdata_key + ':old:' + $key
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
        $new_name = @flashdata_key + ':old:' + $parts[1]
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
    if strtolower(@time_reference) is 'gmt'
      $now = time()
      $time = mktime(gmdate("H", $now), gmdate("i", $now), gmdate("s", $now), gmdate("m", $now), gmdate("d", $now), gmdate("Y", $now))
      
    else 
      $time = time()
      
    
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
      $cookie_data = @userdata
      
    
    #  Serialize the userdata for the cookie
    $cookie_data = @_serialize($cookie_data)
    
    if @sess_encrypt_cookie is true
      $cookie_data = @CI.encrypt.encode($cookie_data)
      
    else 
      #  if encryption is not used, we provide an md5 hash to prevent userside tampering
      $cookie_data = $cookie_data + md5($cookie_data + @encryption_key)
      
    
    $expire = if (@sess_expire_on_close is true) then 0 else @sess_expiration + time()
    
    #  Set the cookie
    setcookie(
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
  _serialize : ($data) ->
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
  _unserialize : ($data) ->
    $data = unserialize(strip_slashes($data))
    
    if is_array($data)
      for $key, $val of $data
        if is_string($val)
          $data[$key] = str_replace('{{slash}}', '\\', $val)
          
        
      
      return $data
      
    
    return if (is_string($data)) then str_replace('{{slash}}', '\\', $data) else $data
    
  
  #  --------------------------------------------------------------------
  
  #
  # Garbage collection
  #
  # This deletes expired session rows from database
  # if the probability percentage is met
  #
  # @access	public
  # @return	void
  #
  _sess_gc :  ->
    if @sess_use_database isnt true
      return 
      
    
    srand(time())
    if (rand()100) < @gc_probability
      $expire = @now - @sess_expiration
      
      @CI.db.where("last_activity < {$expire}")
      @CI.db.delete(@sess_table_name)
      
      log_message('debug', 'Session garbage collection performed.')
      
    
  
  
  

register_class 'CI_Session', CI_Session
module.exports = CI_Session
#  END Session Class

#  End of file Session.php 
#  Location: ./system/libraries/Session.php 