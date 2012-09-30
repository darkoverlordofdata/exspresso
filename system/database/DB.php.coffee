if not defined('BASEPATH') then die 'No direct script access allowed'
#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# Initialize the database
#
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
global.DB = ($params = '', $active_record_override = NULL) ->
	#  Load the DB config file if a DSN string wasn't passed
	if is_string($params) and strpos($params, '://') is FALSE
		#  Is the config file in the environment folder?
		if not defined('ENVIRONMENT') or  not file_exists($file_path = APPPATH + 'config/' + ENVIRONMENT + '/database' + EXT)
			if not file_exists($file_path = APPPATH + 'config/database' + EXT)
				show_error('The configuration file database' + EXT + ' does not exist.')
				
			
		
		eval include_all($file_path)
		
		if not $db?  or count($db) is 0
			show_error('No database connection settings were found in the database config file.')
			
		
		if $params isnt ''
			$active_group = $params
			
		
		if not $active_group?  or  not $db[$active_group]? 
			show_error('You have specified an invalid database connection group.')
			
		
		$params = $db[$active_group]
		
	else if is_string($params)
		
		#/* parse the URL from the DSN string
		#  Database settings can be passed as discreet
		#  parameters or as a data source name in the first
		#  parameter. DSNs must have this prototype:
		#  $dsn = 'driver://username:password@hostname/database';
		#
		
		if ($dns = parse_url($params)) is FALSE
			show_error('Invalid DB Connection String')
			
		
		$params = if 
			'dbdriver':$dns['scheme']
			'hostname':($dns['host']?  then rawurldecode($dns['host']) else '',
		'username':($dns['user']? ) then rawurldecode($dns['user']) else '', 
		'password':($dns['pass']? ) then rawurldecode($dns['pass']) else '', 
		'database':($dns['path']? ) then rawurldecode(substr($dns['path'], 1)) else ''
		)
		
		#  were additional config items set?
		if $dns['query']? 
			parse_str($dns['query'], $extra)
			
			for $val, $key in as
				#  booleans please
				if strtoupper($val) is "TRUE"
					$val = TRUE
					
				else if strtoupper($val) is "FALSE"
					$val = FALSE
					
				
				$params[$key] = $val
				
			
		
	
	#  No DB specified yet?  Beat them senseless...
	if not $params['dbdriver']?  or $params['dbdriver'] is ''
		show_error('You have not selected a database type to connect to.')
		
	
	#  Load the DB classes.  Note: Since the active record class is optional
	#  we need to dynamically create a class that extends proper parent class
	#  based on whether we're using the active record class or not.
	#  Kudos to Paul for discovering this clever use of eval()
	
	if $active_record_override isnt NULL
		$active_record = $active_record_override
		
	
	eval require_once(BASEPATH + 'database/DB_driver' + EXT)
	
	if not $active_record?  or $active_record is TRUE
		eval require_once(BASEPATH + 'database/DB_active_rec' + EXT)
		
		if not class_exists('CI_DB')
			eval'class CI_DB extends CI_DB_active_record { }'
			
		
	else 
		if not class_exists('CI_DB')
			eval'class CI_DB extends CI_DB_driver { }'
			
		
	
	eval require_once(BASEPATH + 'database/drivers/' + $params['dbdriver'] + '/' + $params['dbdriver'] + '_driver' + EXT)
	
	#  Instantiate the DB adapter
	$driver = 'CI_DB_' + $params['dbdriver'] + '_driver'
	$DB = new $driver($params)
	
	if $DB.autoinit is TRUE
		$DB.initialize()
		
	
	if $params['stricton']?  and $params['stricton'] is TRUE
		$DB.query('SET SESSION sql_mode="STRICT_ALL_TABLES"')
		
	
	return $DB
	



#  End of file DB.php 
#  Location: ./system/database/DB.php 