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
  # @param function $callback
  # @return 	nothing
  #
  get: ($sid, $callback) ->

    Exspresso.db.where 'sid', $sid
    Exspresso.db.get @_table, ($err, $result) ->

      return $callback($err) if show_error($err)
      $callback null, if $result.num_rows is 0 then null else JSON.parse($result.row().session)


  ## --------------------------------------------------------------------

  #
  # set
  #
  #   Sets the session data
  #
  # @param string session id
  # @param string session data
  # @param function $callback
  # @return 	nothing
  #
  set: ($sid, $session, $callback) ->

    $expires = new Date($session.cookie.expires).getTime() / 1000
    $session = JSON.stringify($session)
    Exspresso.db.where 'sid', $sid
    Exspresso.db.get @_table, ($err, $result) =>

      return $callback($err) if show_error($err)

      if $result.num_rows is 0
        $data =
          sid     : $sid
          session : $session
          expires : $expires
        Exspresso.db.insert @_table, $data, $callback

      else
        $data =
          session : $session
          expires : $expires

        Exspresso.db.update @_table, $data, $callback


  ## --------------------------------------------------------------------

  #
  # destroy
  #
  #   Delete the session data
  #
  # @param string session id
  # @param function $callback
  # @return 	nothing
  #
  destroy: ($sid, $callback) ->

    Exspresso.db.where 'sid', $sid
    Exspresso.db.delete @_table, $callback

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