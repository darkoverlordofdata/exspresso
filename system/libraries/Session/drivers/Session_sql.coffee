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
# Sql Session store driver
#
#
class Exspresso_Session_sql extends require('express').session.Store

  serialize         = JSON.stringify
  unserialize       = JSON.parse

  ## --------------------------------------------------------------------

  #
  # Constructor
  #
  #   Load the user data model
  #
  # @param  object
  # @return 	nothing
  #
  constructor: (@parent) ->

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

    # Ensure that we have a live database connection
    Exspresso.db.reconnect ($err) =>

      return $next($err) if log_message('error', 'Session::get connect %s', $err) if $err

      # Get the record for this session
      Exspresso.db.where 'sid', $sid
      Exspresso.db.get @parent.sess_table_name, ($err, $result) ->

        return $next($err) if log_message('error', 'Session::get %s %s', $sid, $err) if $err

        return $next(null, null) if $result.num_rows is 0

        # unpack the data
        $data                   = $result.row()
        $session                = unserialize($data.user_data)
        $session.uid            = $data.uid || User_model.UID_ANONYMOUS
        $session.ip_address     = $data.ip_address
        $session.user_agent     = $data.user_agent
        $session.last_activity  = $data.last_activity

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

    # Ensure that we have a live database connection
    Exspresso.db.reconnect ($err) =>

      return $next($err) if log_message('error', 'Session::set connect %s', $err) if $err

      # Get the record for this session
      Exspresso.db.where 'sid', $sid
      Exspresso.db.get @parent.sess_table_name, ($err, $result) =>

        return $next($err) if log_message('error', 'Session::set %s %s', $sid, $err) if $err

        # pack up the data
        $user_data = array_merge({}, $session)
        $data =
          uid             : fetch($user_data, 'uid', User_model.UID_ANONYMOUS)
          ip_address      : fetch($user_data, 'ip_address')
          user_agent      : substr(fetch($user_data, 'user_agent'), 0, 120)
          last_activity   : fetch($user_data, 'last_activity')
          user_data       : serialize($user_data)

        if $result.num_rows is 0

          # Add primary key data so we can insert a new record
          $data['sid'] = $sid
          Exspresso.db.insert @parent.sess_table_name, $data, ($err) =>
            return $next($err) if log_message('error', 'Session::set insert %s', $err) if $err
            $next()

        else

          # Just update the data
          Exspresso.db.where 'sid', $sid
          Exspresso.db.update @parent.sess_table_name, $data, ($err) =>
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

    # Ensure that we have a live database connection
    Exspresso.db.reconnect ($err) =>

      return $next($err) if log_message('error', 'Session::destroy connect %s', $err) if $err

      # Nuke the record for this session
      Exspresso.db.where 'sid', $sid
      Exspresso.db.delete @parent.sess_table_name, =>
        return $next($err) if log_message('error', 'Session::destroy delete %s', $err) if $err
        $next()

  ## --------------------------------------------------------------------

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
    @

  ## --------------------------------------------------------------------

  #
  # Fetch
  #
  #   Retrieve an item from a table and remove it
  #   If not found, return the default value
  #
  # @param object
  # @param string
  # @param string
  # @return string
  #
  fetch = ($table, $key, $default='') ->
    if $table[$key]?
      $val = $table[$key]
      delete $table[$key]
    else $val = $default
    return $val


module.exports = Exspresso_Session_sql
# End of file Session_sql.coffee
# Location: ./system/libraries/Session/drivers/Session_sql.coffee