#+--------------------------------------------------------------------+
#  DB.coffee
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
#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package    CodeIgniter
# @author    ExpressionEngine Dev Team
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    http://codeigniter.com/user_guide/license.html
# @link    http://codeigniter.com
# @since    Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# Initialize the database
#
# @category  Database
# @author    ExpressionEngine Dev Team
# @link    http://codeigniter.com/user_guide/database/
#
module.exports = ($params = '', active_record_override = null) ->
  #  Load the DB config file if a DSN string wasn't passed
  if is_string($params) and strpos($params, '://') is false
    #  Is the config file in the environment folder?
    if not file_exists($file_path = APPPATH + 'config/' + ENVIRONMENT + '/database' + EXT)
      if not file_exists($file_path = APPPATH + 'config/database' + EXT)
        show_error('The configuration file database' + EXT + ' does not exist.')

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


  CI_DB_driver = require(BASEPATH + 'database/DB_driver' + EXT)


  if not active_record?  or active_record is true
    CI_DB_active_record = require(BASEPATH + 'database/DB_active_rec' + EXT)

    if not class_exists('CI_DB')
      class CI_DB extends CI_DB_active_record


  else if not class_exists('CI_DB')
    class CI_DB extends CI_DB_driver


  if not file_exists(BASEPATH + 'database/drivers/' + $params['dbdriver'] + '/' + $params['dbdriver'] + '_driver' + EXT)
    throw new Error("Unsuported DB driver: " + $params['dbdriver'])

  $driver = require(BASEPATH + 'database/drivers/' + $params['dbdriver'] + '/' + $params['dbdriver'] + '_driver' + EXT)(CI_DB)

  #  Instantiate the DB adapter
  # $driver = 'CI_DB_' + $params['dbdriver'] + '_driver'

  $DB = new $driver($params)

  if $DB.autoinit is true
    $DB.initialize()
    
  
  if $params['stricton']?  and $params['stricton'] is true
    $DB.query('SET SESSION sql_mode="STRICT_ALL_TABLES"')
    
  
  return $DB
  



#  End of file DB.php 
#  Location: ./system/database/DB.php 