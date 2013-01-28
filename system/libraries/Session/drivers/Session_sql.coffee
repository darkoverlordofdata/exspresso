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

  _table: ''


  ## --------------------------------------------------------------------

  #
  # Constructor
  #
  #   If needed, create the table and cleanup jobs
  #
  # @return 	nothing
  #
  constructor: ($config) ->

    @_table = $config.sess_table_name
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

      return $next($err) if log_message('debug', 'Session::get connect %s', $err) if $err

      Exspresso.db.where 'sid', $sid
      Exspresso.db.get @_table, ($err, $result) ->

        return $next($err) if log_message('debug', 'Session::get %s %s', $sid, $err) if $err

        $next null, if $result.num_rows is 0 then null else JSON.parse($result.row().session)


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

      return $next($err) if log_message('debug', 'Session::set connect %s', $err) if $err

      Exspresso.db.where 'sid', $sid
      Exspresso.db.get @_table, ($err, $result) =>

        return $next($err) if log_message('debug', 'Session::set %s %s', $sid, $err) if $err

        if $result.num_rows is 0
          $data =
            sid     : $sid
            session : JSON.stringify($session)
            expires : new Date($session.cookie.expires).getTime() / 1000
            
          Exspresso.db.insert @_table, $data, $next

        else
          $data =
            session : JSON.stringify($session)
            expires : new Date($session.cookie.expires).getTime() / 1000

          Exspresso.db.update @_table, $data, $next


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

      return $next($err) if log_message('debug', 'Session::set connect %s', $err) if $err

      Exspresso.db.where 'sid', $sid
      Exspresso.db.delete @_table, $next

  #  --------------------------------------------------------------------

  #
  # Session Database setup
  #
  #   create session table
  #
  # @access	public
  # @return	void
  #
  create: () ->

    Exspresso.queue ($next) ->
      Exspresso.db.table_exists 'ex_sessions', ($err, $table_exists) ->

        if $err then return $next $err
        if $table_exists then return $next null

        Exspresso.load.dbforge()
        Exspresso.dbforge.add_field
          sid:
            type        : 'VARCHAR'
            constraint  : 24
            default     : '0'
            null        : false
          expires:
            type        : 'INT'
            constraint  : 10
            unsigned    : true
            default     : 0
            null        : false
          session:
            type        : 'TEXT'
            null        : true

        Exspresso.dbforge.add_key 'sid', true
        Exspresso.dbforge.create_table 'ex_sessions', $next




module.exports = Exspresso_Session_sql
# End of file Session_sql.coffee
# Location: ./system/libraries/Session/drivers/Session_sql.coffee