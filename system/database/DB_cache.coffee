#+--------------------------------------------------------------------+
#  DB_cache.coffee
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
# @copyright  Copyright (c) 2012, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Database Cache Class
#
# @category	Database
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/database/
#
class global.Exspresso_DB_Cache
  
  Exspresso: {}
  db: {}#  allows passing of db object so that multiple database connections and returned db objects can be supported
  
  #
  # Constructor
  #
  # Grabs the CI super object instance so we can access it.
  #
  #
  constructor: (@db, @Exspresso) ->
    #  Assign the main CI object to $this->CI
    #  and load the file helper since we use it a lot
    @Exspresso.load.helper('file')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Set Cache Directory Path
  #
  # @access	public
  # @param	string	the path to the cache directory
  # @return	bool
  #
  check_path: ($path = '') ->
    if $path is ''
      if @db.cachedir is ''
        return @db.cache_off()
        
      
      $path = @db.cachedir
      
    
    #  Add a trailing slash to the path if needed
    $path = preg_replace("/(.+?)\\/*$/", "$1/", $path)

    
    if not is_dir($path) or not is_really_writable($path)
      #  If the path is wrong we'll turn off caching
      return @db.cache_off()
      
    
    @db.cachedir = $path
    return true
    
  
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
  read: ($sql) ->
    if not @check_path()
      return @db.cache_off()
      
    
    $segment_one = if (@Exspresso.uri.segment(1) is false) then 'default' else @Exspresso.uri.segment(1)
    
    $segment_two = if (@Exspresso.uri.segment(2) is false) then 'index' else @Exspresso.uri.segment(2)
    
    $filepath = @db.cachedir + $segment_one + '+' + $segment_two + '/' + md5($sql)
    
    if false is ($cachedata = read_file($filepath))
      return false
      
    
    return unserialize($cachedata)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Write a query to a cache file
  #
  # @access	public
  # @return	bool
  #
  write: ($sql, $object) ->
    if not @check_path()
      return @db.cache_off()
      
    
    $segment_one = if (@Exspresso.uri.segment(1) is false) then 'default' else @Exspresso.uri.segment(1)
    
    $segment_two = if (@Exspresso.uri.segment(2) is false) then 'index' else @Exspresso.uri.segment(2)
    
    $dir_path = @db.cachedir + $segment_one + '+' + $segment_two + '/'
    
    $filename = md5($sql)
    
    if not is_dir($dir_path)
      if not mkdir($dir_path, DIR_WRITE_MODE)
        return false
        
      
      chmod($dir_path, DIR_WRITE_MODE)
      
    
    if write_file($dir_path + $filename, serialize($object)) is false
      return false
      
    
    chmod($dir_path + $filename, FILE_WRITE_MODE)
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Delete cache files within a particular directory
  #
  # @access	public
  # @return	bool
  #
  delete: ($segment_one = '', $segment_two = '') ->
    if $segment_one is ''
      $segment_one = if (@Exspresso.uri.segment(1) is false) then 'default' else @Exspresso.uri.segment(1)
      
    
    if $segment_two is ''
      $segment_two = if (@Exspresso.uri.segment(2) is false) then 'index' else @Exspresso.uri.segment(2)
      
    
    $dir_path = @db.cachedir + $segment_one + '+' + $segment_two + '/'
    
    delete_files($dir_path, true)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Delete all existing cache files
  #
  # @access	public
  # @return	bool
  #
  delete_all :  ->
    delete_files(@db.cachedir, true)

module.exports = Exspresso_DB_Cache


#  End of file DB_cache.php 
#  Location: ./system/database/DB_cache.php 