#+--------------------------------------------------------------------+
#| Session_sql.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
# Mysql Session store driver
#
#
class Exspresso_Session_sql extends require('express').session.Store

  fetch = ($obj, $key, $default='') ->
    if $obj[$key]?
      $val = $obj[$key]
      delete $obj[$key]
    else $val = $default
    return $val

  _sess_encrypt_cookie      : false
  _sess_use_database        : false
  _sess_table_name          : 'sessions'
  _sess_expiration          : 7200
  _sess_expire_on_close     : false
  _sess_match_ip            : false
  _sess_match_useragent     : true
  _sess_cookie_name         : 'sid'
  _cookie_prefix            : 'connect.'
  _cookie_path              : ''
  _cookie_domain            : ''
  _cookie_secure            : false
  _sess_time_to_update      : 300
  _encryption_key           : ''
  _time_reference           : 'local'


  ## --------------------------------------------------------------------

  #
  # Constructor
  #
  #   copy the config values
  #
  # @return 	nothing
  #
  constructor: ($config) ->

    for $key, $val of $config
      if @['_'+$key]?
        @['_'+$key] = $val

    Exspresso.load.model('user/user_model')
    return



  ## --------------------------------------------------------------------

  #
  # get
  #
  #   Gets the session data
  #
  # @param string session id
  # @param function next
  # @return 	nothing
  #
  get: ($sid, $next) ->

    Exspresso.db.reconnect ($err) =>

      return $next($err) if log_message('error', 'Session::get connect %s', $err) if $err

      Exspresso.db.where 'sid', $sid
      Exspresso.db.get @_sess_table_name, ($err, $result) ->

        return $next($err) if log_message('error', 'Session::get %s %s', $sid, $err) if $err

        return $next null, null if $result.num_rows is 0

        $data = $result.row()
        $session = JSON.parse($data.user_data)
        $session.uid = $data.uid || User_model.UID_ANONYMOUS
        $session.ip_address = $data.ip_address
        $session.user_agent = $data.user_agent
        $session.last_activity = $data.last_activity
        $next null, $session


  ## --------------------------------------------------------------------

  #
  # set
  #
  #   Sets the session data
  #
  # @param string session id
  # @param string session data
  # @param function next
  # @return 	nothing
  #
  set: ($sid, $session, $next) ->

    Exspresso.db.reconnect ($err) =>

      return $next($err) if log_message('error', 'Session::set connect %s', $err) if $err

      Exspresso.db.where 'sid', $sid
      Exspresso.db.get @_sess_table_name, ($err, $result) =>

        return $next($err) if log_message('error', 'Session::set %s %s', $sid, $err) if $err

        $user_data = array_merge({}, $session)

        if $result.num_rows is 0
          $data =
            sid             : $sid
            uid             : fetch($user_data, 'uid', User_model.UID_ANONYMOUS)
            ip_address      : fetch($user_data, 'ip_address')
            user_agent      : substr(fetch($user_data, 'user_agent'), 0, 120)
            last_activity   : fetch($user_data, 'last_activity')
            user_data       : JSON.stringify($user_data)

          Exspresso.db.insert @_sess_table_name, $data, ($err) =>
            return $next($err) if log_message('error', 'Session::set insert %s', $err) if $err
            $next()

        else
          delete $user_data['ip_address']
          delete $user_data['user_agent']
          $data =
            uid             : fetch($user_data, 'uid', User_model.UID_ANONYMOUS)
            last_activity   : fetch($user_data, 'last_activity')
            user_data       : JSON.stringify($user_data)

          Exspresso.db.where 'sid', $sid
          Exspresso.db.update @_sess_table_name, $data, ($err) =>
            return $next($err) if log_message('error', 'Session::set update %s', $err) if $err
            $next()


  ## --------------------------------------------------------------------

  #
  # destroy
  #
  #   Delete the session data
  #
  # @param string session id
  # @param function $next
  # @return 	nothing
  #
  destroy: ($sid, $next) ->

    Exspresso.db.reconnect ($err) =>

      return $next($err) if log_message('error', 'Session::destroy connect %s', $err) if $err

      Exspresso.db.where 'sid', $sid
      Exspresso.db.delete @_sess_table_name, =>
        return $next($err) if log_message('error', 'Session::destroy delete %s', $err) if $err
        $next()

  #
  # Session Database setup
  #
  #   create user & session tables if they doesn't exist
  #   called when Session library is auto loaded during boot
  #
  # @access	public
  # @return	void
  #
  setup: () ->

    Exspresso.user_model.setup()

module.exports = Exspresso_Session_sql
# End of file Session_sql.coffee
# Location: ./system/libraries/Session/drivers/Session_sql.coffee