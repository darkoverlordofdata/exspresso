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

  mysql: null
  _table: ''
  _create_sql = ''


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

    @_sql_create = 'CREATE TABLE IF NOT EXISTS `' + @_table + '` (`sid` VARCHAR(255) NOT NULL, `session` TEXT NOT NULL, `expires` INT, PRIMARY KEY (`sid`) )'
    @_sql_get = 'SELECT `session` FROM `' + @_table + '` WHERE `sid` = ?'
    @_sql_set = 'INSERT INTO `' + @_table + '` (`sid`, `session`, `expires`) VALUES(?, ?, ?) ON DUPLICATE KEY UPDATE `session` = ?, `expires` = ?'
    @_sql_del = 'DELETE FROM `' + @_table + '` WHERE `sid` = ?'
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


    return $callback(null)
    @mysql.query 'SELECT `session` FROM `' + @table + '` WHERE `sid` = ?', [$sid], ($err, $result) =>

      if $err
        $callback $err
      else
        if $result? and $result[0]? and $result[0].session?
          $callback null, JSON.parse($result[0].session)
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

    log_message 'debug', 'Session::set: %s', $sid

    $CI = $session.get_instance()
    console.log $session

    return $callback(null)
    $expires = new Date($session.cookie.expires).getTime() / 1000
    $session = JSON.stringify($session)
    @mysql.query 'INSERT INTO `' + @table + '` (`sid`, `session`, `expires`) VALUES(?, ?, ?) ON DUPLICATE KEY UPDATE `session` = ?, `expires` = ?', [$sid, $session, $expires, $session, $expires], ($err) ->
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

    return $callback(null)
    @mysql.query 'DELETE FROM `' + @table + '` WHERE `sid` = ?', [$sid], ($err) ->
      $callback $err

module.exports = Exspresso_Session_mysql
# End of file postgres.coffee
# Location: ./system/libraries/Session/postgres.coffee