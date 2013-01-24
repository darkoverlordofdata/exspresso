#+--------------------------------------------------------------------+
#| postgres.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#	postgres driver for sessions
#
#  ------------------------------------------------------------------------

#
# Mysql Session store driver
#
#
class Exspresso_Session_mysql extends require('express').session.Store

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

    log_message 'debug', 'Session::get: %s', $sid
    Exspresso.db.query 'SELECT `session` FROM `' + @_table + '` WHERE `session_id` = ?', [$sid], ($err, $result) ->


      log_message 'debug', 'Session::get result'
      console.log $err
      console.log $result

      if $err then return $callback $err
      $callback null, JSON.parse($result.row().session)


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

    log_message 'debug', 'Session::get: %s [%s]', $sid, $session
    $expires = new Date($session.cookie.expires).getTime() / 1000
    $session = JSON.stringify($session)
    Exspresso.db.query 'INSERT INTO `' + @_table + '` (`session_id`, `session`, `expires`) VALUES(?, ?, ?) ON DUPLICATE KEY UPDATE `session` = ?, `expires` = ?', [$sid, $session, $expires, $session, $expires], ($err) ->
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

    log_message 'debug', 'Session::destroy: %s', $sid

    Exspresso.db.query 'DELETE FROM `' + @_table + '` WHERE `session_id` = ?', [$sid], ($err) ->
      $callback $err

module.exports = Exspresso_Session_mysql
# End of file postgres.coffee
# Location: ./system/libraries/Session/postgres.coffee