#+--------------------------------------------------------------------+
#| postgres.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	postgres driver for sessions
#
#  ------------------------------------------------------------------------

#
# PostgreSql Session store driver
#
#
class CI_Session_postgres extends require('express').session.Store

  postgres: null
  table: ''

  ## --------------------------------------------------------------------

  #
  # Constructor
  #
  #   If needed, create the table and cleanup jobs
  #
  # @return 	nothing
  #
  constructor: ($config) ->

    @table = $config.sess_table_name

    $CI = get_instance()
    $CI.db.db_connect ($err, $client) =>

      if $err then throw $err

      @postgres = $client

      @postgres.query 'CREATE TABLE IF NOT EXISTS "' + @table + '" ("sid" TEXT NOT NULL, "session" TEXT NOT NULL, "expires" INT, PRIMARY KEY ("sid") )', ($err) ->

        if $err then throw $err


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

    @postgres.query 'SELECT "session" FROM "' + @table + '" WHERE "sid" = $1', [$sid], ($err, $result) ->

      if $err
        $callback $err
      else
        if $result? and $result.rows? and $result.rows[0]? and $result.rows[0].session?
          $callback null, JSON.parse($result.rows[0].session)
        else
          $callback()


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
    @postgres.query 'UPDATE "'+ @table + '" SET  "session" = $2, "expires" = $3 WHERE "sid" = $1', [$sid, $session, $expires], ($err) =>

      @postgres.query 'INSERT INTO "' + @table + '" ("sid", "session", "expires") SELECT $1, $2, $3 WHERE NOT EXISTS (SELECT 1 FROM "' + @table + '" WHERE "sid"=$1)', [$sid, $session, $expires], ($err) ->

        $callback $err


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

    @postgres.query 'DELETE FROM "' + @table + '" WHERE "sid" = $1', [$sid], ($err) ->

      $callback $err

module.exports = CI_Session_postgres
# End of file postgres.coffee
# Location: ./system/libraries/Session/postgres.coffee