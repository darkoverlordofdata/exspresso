#+--------------------------------------------------------------------+
#  DB.coffee
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
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#
# Database Driver Factory
#
#
module.exports = ($params = '', active_record_override = null) ->
  #  Load the DB config file if a DSN string wasn't passed
  if is_string($params) and strpos($params, '://') is false
    #  Is the config file in the environment folder?
    if not file_exists($file_path = APPPATH + 'config/' + ENVIRONMENT + '/database' + EXT)
      if not file_exists($file_path = APPPATH + 'config/database' + EXT)
        show_error('The configuration file database%s does not exist.', EXT)

    {db, active_group, active_record} = require($file_path)

    if not db?  or count(db) is 0
      show_error 'No database connection settings were found in the database config file.'

    if $params isnt ''
      active_group = $params

    if not active_group?  or  not db[active_group]? 
      show_error 'You have specified an invalid database connection group.'

    $params = db[active_group]

    if db[active_group]['url']?

      if ($dns = parse_url(db[active_group]['url'])) is false
        show_error 'Invalid DB Connection String'

      $params.dbdriver = $dns['scheme']
      $params.hostname = if $dns['host']? then rawurldecode($dns['host']) else ''
      $params.username = if $dns['user']? then rawurldecode($dns['user']) else ''
      $params.password = if $dns['pass']? then rawurldecode($dns['pass']) else ''
      $params.database = if $dns['path']? then rawurldecode(substr($dns['path'], 1)) else ''

    
  else if is_string($params)
    
    # parse the URL from the DSN string
    #  Database settings can be passed as discreet
    #  parameters or as a data source name in the first
    #  parameter. DSNs must have this prototype:
    #  $dsn = 'driver://username:password@hostname/database';
    #
    
    if ($dns = parse_url($params)) is false
      show_error 'Invalid DB Connection String'

    $params =
      'dbdriver': $dns['scheme']
      'hostname': if $dns['host']? then rawurldecode($dns['host']) else ''
      'username': if $dns['user']? then rawurldecode($dns['user']) else ''
      'password': if $dns['pass']? then rawurldecode($dns['pass']) else ''
      'database': if $dns['path']? then rawurldecode(substr($dns['path'], 1)) else ''

    #  were additional config items set?
    if $dns['query']?
      $extra = {}
      parse_str($dns['query'], $extra)
      
      for $key, $val of $extra
        #  booleans please
        if strtoupper($val) is "TRUE"
          $val = true
          
        else if strtoupper($val) is "FALSE"
          $val = false

        $params[$key] = $val

  #  No DB specified yet?  Beat them senseless...
  if not $params['dbdriver']?  or $params['dbdriver'] is ''
    show_error('You have not selected a database type to connect to.')

  #  Load the DB classes.  Note: Since the active record class is optional
  #  we need to dynamically create a class that extends proper parent class
  #  based on whether we're using the active record class or not.

  if active_record_override isnt null
    active_record = active_record_override


  ExspressoDbDriver = require(BASEPATH + 'db/Driver' + EXT)


  if not active_record?  or active_record is true
    ExspressoDbActiveRecord = require(BASEPATH + 'db/ActiveRecord' + EXT)

    if not class_exists('ExspressoDb')
      class global.ExspressoDb extends ExspressoDbActiveRecord

  else if not class_exists('ExspressoDb')
    class global.ExspressoDb extends ExspressoDbDriver


  if not file_exists(BASEPATH + 'db/drivers/' + $params['dbdriver'] + '/' + ucfirst($params['dbdriver']) + 'Driver' + EXT)
    throw new Error("Unsuported DB driver: " + $params['dbdriver'])

  $driver = require(BASEPATH + 'db/drivers/' + $params['dbdriver'] + '/' + ucfirst($params['dbdriver']) + 'Driver' + EXT)

  #  Instantiate the DB adapter
  $db = new $driver($params)

  if $db.autoinit is true
    $db.initialize()

  if $params['stricton']?  and $params['stricton'] is true
    $db.query('SET SESSION sql_mode="STRICT_ALL_TABLES"')
    
  
  return $db
  



#  End of file DB.php 
#  Location: ./system/db/DB.php 