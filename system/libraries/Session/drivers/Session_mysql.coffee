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

    $CI = Exspresso
    @mysql = $CI.db.client

    @mysql.query 'CREATE TABLE IF NOT EXISTS `' + @table + '` (`sid` VARCHAR(255) NOT NULL, `session` TEXT NOT NULL, `expires` INT, PRIMARY KEY (`sid`) )', ($err) =>

      if $err then throw $err

      @mysql.query 'CREATE EVENT IF NOT EXISTS `sess_cleanup` ON SCHEDULE EVERY 15 MINUTE DO DELETE FROM `' + @table + '` WHERE `expires` < UNIX_TIMESTAMP()'


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

    @mysql.query 'DELETE FROM `' + @table + '` WHERE `sid` = ?', [$sid], ($err) ->
      $callback $err

module.exports = Exspresso_Session_mysql
# End of file postgres.coffee
# Location: ./system/libraries/Session/postgres.coffee