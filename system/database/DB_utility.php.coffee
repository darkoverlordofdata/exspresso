if not defined('BASEPATH') then die 'No direct script access allowed'
#
# Code Igniter
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
# Database Utility Class
#
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
class CI_DB_utilityextends CI_DB_forge
	
	$db: {}
	$data_cache: {}
	
	#
	# Constructor
	#
	# Grabs the CI super object instance so we can access it.
	#
	#
	CI_DB_utility :  =>
		#  Assign the main database object to $this->db
		$CI = get_instance()
		@.db = $CI.db
		
		log_message('debug', "Database Utility Class Initialized")
		
	
	#  --------------------------------------------------------------------
	
	#
	# List databases
	#
	# @access	public
	# @return	bool
	#
	list_databases :  =>
		#  Is there a cached result?
		if @.data_cache['db_names']? 
			return @.data_cache['db_names']
			
		
		$query = @.db.query(@._list_databases())
		$dbs = {}
		if $query.num_rows() > 0
			for $row in as
				$dbs.push current($row)
				
			
		
		@.data_cache['db_names'] = $dbs
		return @.data_cache['db_names']
		
	
	#  --------------------------------------------------------------------
	
	#
	# Determine if a particular database exists
	#
	# @access	public
	# @param	string
	# @return	boolean
	#
	database_exists : ($database_name) =>
		#  Some databases won't have access to the list_databases() function, so
		#  this is intended to allow them to override with their own functions as
		#  defined in $driver_utility.php
		if method_exists(@, '_database_exists')
			return @._database_exists($database_name)
			
		else 
			return if ( not in_array($database_name, @.list_databases())) then FALSE else TRUE
			
		
	
	
	#  --------------------------------------------------------------------
	
	#
	# Optimize Table
	#
	# @access	public
	# @param	string	the table name
	# @return	bool
	#
	optimize_table : ($table_name) =>
		$sql = @._optimize_table($table_name)
		
		if is_bool($sql)
			show_error('db_must_use_set')
			
		
		$query = @.db.query($sql)
		$res = $query.result_array()
		
		#  Note: Due to a bug in current() that affects some versions
		#  of PHP we can not pass function call directly into it
		return current($res)
		
	
	#  --------------------------------------------------------------------
	
	#
	# Optimize Database
	#
	# @access	public
	# @return	array
	#
	optimize_database :  =>
		$result = {}
		for $table_name in as
			$sql = @._optimize_table($table_name)
			
			if is_bool($sql)
				return $sql
				
			
			$query = @.db.query($sql)
			
			#  Build the result array...
			#  Note: Due to a bug in current() that affects some versions
			#  of PHP we can not pass function call directly into it
			$res = $query.result_array()
			$res = current($res)
			$key = str_replace(@.db.database + '.', '', current($res))
			$keys = array_keys($res)
			delete $res[$keys[0]]
			
			$result[$key] = $res
			
		
		return $result
		
	
	#  --------------------------------------------------------------------
	
	#
	# Repair Table
	#
	# @access	public
	# @param	string	the table name
	# @return	bool
	#
	repair_table : ($table_name) =>
		$sql = @._repair_table($table_name)
		
		if is_bool($sql)
			return $sql
			
		
		$query = @.db.query($sql)
		
		#  Note: Due to a bug in current() that affects some versions
		#  of PHP we can not pass function call directly into it
		$res = $query.result_array()
		return current($res)
		
	
	#  --------------------------------------------------------------------
	
	#
	# Generate CSV from a query result object
	#
	# @access	public
	# @param	object	The query result object
	# @param	string	The delimiter - comma by default
	# @param	string	The newline character - \n by default
	# @param	string	The enclosure - double quote by default
	# @return	string
	#
	csv_from_result : ($query, $delim = ",", $newline = "\n", $enclosure = '"') =>
		if not is_object($query) or  not method_exists($query, 'list_fields')
			show_error('You must submit a valid result object')
			
		
		$out = ''
		
		#  First generate the headings from the table column names
		for $name in as
			$out+=$enclosure + str_replace($enclosure, $enclosure + $enclosure, $name) + $enclosure + $delim
			
		
		$out = rtrim($out)
		$out+=$newline
		
		#  Next blast through the result array and build out the rows
		for $row in as
			for $item in as
				$out+=$enclosure + str_replace($enclosure, $enclosure + $enclosure, $item) + $enclosure + $delim
				
			$out = rtrim($out)
			$out+=$newline
			
		
		return $out
		
	
	#  --------------------------------------------------------------------
	
	#
	# Generate XML data from a query result object
	#
	# @access	public
	# @param	object	The query result object
	# @param	array	Any preferences
	# @return	string
	#
	xml_from_result : ($query, $params = {}) =>
		if not is_object($query) or  not method_exists($query, 'list_fields')
			show_error('You must submit a valid result object')
			
		
		#  Set our default values
		for $val, $key in as
			if not $params[$key]? 
				$params[$key] = $val
				
			
		
		#  Create variables for convenience
		extract($params)
		
		#  Load the xml helper
		$CI = get_instance()
		$CI.load.helper('xml')
		
		#  Generate the result
		$xml = <{$$root}> + $newlinefor $row in as
		$xml+=$tab + <{$$element> + $newline
	
	for $val, $key in as
		$xml+=$tab + $tab + <{$$key> + xml_convert($val) + </{$$key> + $newline
}
$xml+=$tab + </{$$element}> + $newline
}
$xml+=</$root> + $newline

return $xml
}

#  --------------------------------------------------------------------

#
# Database Backup
#
# @access	public
# @return	void
#
global.backup = ($params = {}) ->
	#  If the parameters have not been submitted as an
	#  array then we know that it is simply the table
	#  name, which is a valid short cut.
	if is_string($params)
		$params = 'tables':$params
		
	
	#  ------------------------------------------------------
	
	#  Set up our default preferences
	$prefs = 
		'tables':{}
		'ignore':{}
		'filename':''
		'format':'gzip', #  gzip, zip, txt
		'add_drop':TRUE
		'add_insert':TRUE
		'newline':"\n"
		
	
	#  Did the user submit any preferences? If so set them....
	if count($params) > 0
		for $val, $key in as
			if $params[$key]? 
				$prefs[$key] = $params[$key]
				
			
		
	
	#  ------------------------------------------------------
	
	#  Are we backing up a complete database or individual tables?
	#  If no table names were submitted we'll fetch the entire table list
	if count($prefs['tables']) is 0
		$prefs['tables'] = @.db.list_tables()
		
	
	#  ------------------------------------------------------
	
	#  Validate the format
	if not in_array($prefs['format'], ['gzip', 'zip', 'txt'], TRUE)
		$prefs['format'] = 'txt'
		
	
	#  ------------------------------------------------------
	
	#  Is the encoder supported?  If not, we'll either issue an
	#  error or use plain text depending on the debug settings
	if ($prefs['format'] is 'gzip' and  not function_exists('gzencode')) or ($prefs['format'] is 'zip' and  not function_exists('gzcompress'))
		if @.db.db_debug
			return @.db.display_error('db_unsuported_compression')
			
		
		$prefs['format'] = 'txt'
		
	
	#  ------------------------------------------------------
	
	#  Set the filename if not provided - Only needed with Zip files
	if $prefs['filename'] is '' and $prefs['format'] is 'zip'
		$prefs['filename'] = if (count($prefs['tables']) is 1) then $prefs['tables'] else @.db.database
		$prefs['filename']+='_' + date('Y-m-d_H-i', time())
		
	
	#  ------------------------------------------------------
	
	#  Was a Gzip file requested?
	if $prefs['format'] is 'gzip'
		return gzencode(@._backup($prefs))
		
	
	#  ------------------------------------------------------
	
	#  Was a text file requested?
	if $prefs['format'] is 'txt'
		return @._backup($prefs)
		
	
	#  ------------------------------------------------------
	
	#  Was a Zip file requested?
	if $prefs['format'] is 'zip'
		#  If they included the .zip file extension we'll remove it
		if preg_match("|.+?\.zip$|", $prefs['filename'])
			$prefs['filename'] = str_replace('.zip', '', $prefs['filename'])
			
		
		#  Tack on the ".sql" file extension if needed
		if not preg_match("|.+?\.sql$|", $prefs['filename'])
			$prefs['filename']+='.sql'
			
		
		#  Load the Zip class and output it
		
		$CI = get_instance()
		$CI.load.library('zip')
		$CI.zip.add_data($prefs['filename'], @._backup($prefs))
		return $CI.zip.get_zip()
		
	
	

}


#  End of file DB_utility.php 
#  Location: ./system/database/DB_utility.php 