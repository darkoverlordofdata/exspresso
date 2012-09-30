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
# Database Cache Class
#
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
class CI_DB_Cache
	
	$CI: {}
	$db: {}#  allows passing of db object so that multiple database connections and returned db objects can be supported
	
	#
	# Constructor
	#
	# Grabs the CI super object instance so we can access it.
	#
	#
	CI_DB_Cache : ( and $db) =>
		#  Assign the main CI object to $this->CI
		#  and load the file helper since we use it a lot
		@.CI = get_instance()
		@.db = $db
		@.CI.load.helper('file')
		
	
	#  --------------------------------------------------------------------
	
	#
	# Set Cache Directory Path
	#
	# @access	public
	# @param	string	the path to the cache directory
	# @return	bool
	#
	check_path : ($path = '') =>
		if $path is ''
			if @.db.cachedir is ''
				return @.db.cache_off()
				
			
			$path = @.db.cachedir
			
		
		#  Add a trailing slash to the path if needed
		$path = preg_replace("/(.+?)\/*$/", "\\1/", $path)
		
		if not is_dir($path) or  not is_really_writable($path)
			#  If the path is wrong we'll turn off caching
			return @.db.cache_off()
			
		
		@.db.cachedir = $path
		return TRUE
		
	
	#  --------------------------------------------------------------------
	
	#
	# Retrieve a cached query
	#
	# The URI being requested will become the name of the cache sub-folder.
	# An MD5 hash of the SQL statement will become the cache file name
	#
	# @access	public
	# @return	string
	#
	read : ($sql) =>
		if not @.check_path()
			return @.db.cache_off()
			
		
		$segment_one = if (@.CI.uri.segment(1) is FALSE) then 'default' else @.CI.uri.segment(1)
		
		$segment_two = if (@.CI.uri.segment(2) is FALSE) then 'index' else @.CI.uri.segment(2)
		
		$filepath = @.db.cachedir + $segment_one + '+' + $segment_two + '/' + md5($sql)
		
		if FALSE is ($cachedata = read_file($filepath))
			return FALSE
			
		
		return unserialize($cachedata)
		
	
	#  --------------------------------------------------------------------
	
	#
	# Write a query to a cache file
	#
	# @access	public
	# @return	bool
	#
	write : ($sql, $object) =>
		if not @.check_path()
			return @.db.cache_off()
			
		
		$segment_one = if (@.CI.uri.segment(1) is FALSE) then 'default' else @.CI.uri.segment(1)
		
		$segment_two = if (@.CI.uri.segment(2) is FALSE) then 'index' else @.CI.uri.segment(2)
		
		$dir_path = @.db.cachedir + $segment_one + '+' + $segment_two + '/'
		
		$filename = md5($sql)
		
		if not is_dir($dir_path)
			if not mkdir($dir_path, DIR_WRITE_MODE)
				return FALSE
				
			
			chmod($dir_path, DIR_WRITE_MODE)
			
		
		if write_file($dir_path + $filename, serialize($object)) is FALSE
			return FALSE
			
		
		chmod($dir_path + $filename, FILE_WRITE_MODE)
		return TRUE
		
	
	#  --------------------------------------------------------------------
	
	#
	# Delete cache files within a particular directory
	#
	# @access	public
	# @return	bool
	#
	delete : ($segment_one = '', $segment_two = '') =>
		if $segment_one is ''
			$segment_one = if (@.CI.uri.segment(1) is FALSE) then 'default' else @.CI.uri.segment(1)
			
		
		if $segment_two is ''
			$segment_two = if (@.CI.uri.segment(2) is FALSE) then 'index' else @.CI.uri.segment(2)
			
		
		$dir_path = @.db.cachedir + $segment_one + '+' + $segment_two + '/'
		
		delete_files($dir_path, TRUE)
		
	
	#  --------------------------------------------------------------------
	
	#
	# Delete all existing cache files
	#
	# @access	public
	# @return	bool
	#
	delete_all :  =>
		delete_files(@.db.cachedir, TRUE)
		
	
	


#  End of file DB_cache.php 
#  Location: ./system/database/DB_cache.php 