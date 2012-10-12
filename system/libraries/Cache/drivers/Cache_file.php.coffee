#+--------------------------------------------------------------------+
#  Cache_file.coffee
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

{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{__construct, cache_info, chmod, clean, config, defined, delete, delete_files, file_exists, filemtime, get, get_dir_file_info, get_instance, get_metadata, helper, is_array, is_supported, item, load, read_file, save, serialize, time, unlink, unserialize, write_file}  = require(FCPATH + 'lib')
{config_item, get_class, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

if not defined('BASEPATH') then die 'No direct script access allowed'
#
# CodeIgniter
#
# An open source application development framework for PHP 4.3.2 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2006 - 2011 EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 2.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# CodeIgniter Memcached Caching Class
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Core
# @author		ExpressionEngine Dev Team
# @link
#

class CI_Cache_file extends CI_Driver
  
  _cache_path: {}
  
  #
  # Constructor
  #
  __construct()
  {
  $CI = get_instance()
  $CI.load.helper('file')
  
  $path = $CI.config.item('cache_path')
  
  @_cache_path = if ($path is '') then APPPATH + 'cache/' else $path
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Fetch from cache
  #
  # @param 	mixed		unique key id
  # @return 	mixed		data on success/false on failure
  #
  get($id)
  {
  if not file_exists(@_cache_path + $id)
    return false
    
  
  $data = read_file(@_cache_path + $id)
  $data = unserialize($data)
  
  if time() > $data['time'] + $data['ttl']
    unlink(@_cache_path + $id)
    return false
    
  
  return $data['data']
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Save into cache
  #
  # @param 	string		unique key
  # @param 	mixed		data to store
  # @param 	int			length of time (in seconds) the cache is valid
  #						- Default is 60 seconds
  # @return 	boolean		true on success/false on failure
  #
  save($id, $data, $ttl = 60)
  {
  $contents = 
    'time':time(,
  'ttl':$ttl, 
  'data':$data
  )
  
  if write_file(@_cache_path + $id, serialize($contents))
    chmod(@_cache_path + $id, 0o0777)
    return true
    
  
  return false
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Delete from Cache
  #
  # @param 	mixed		unique identifier of item in cache
  # @return 	boolean		true on success/false on failure
  #
  delete($id)
  {
  return unlink(@_cache_path + $id)
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Clean the Cache
  #
  # @return 	boolean		false on failure/true on success
  #
  clean()
  {
  return delete_files(@_cache_path)
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Cache Info
  #
  # Not supported by file-based caching
  #
  # @param 	string	user/filehits
  # @return 	mixed 	FALSE
  #
  cache_info($type = null)
  {
  return get_dir_file_info(@_cache_path)
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Get Cache Metadata
  #
  # @param 	mixed		key to get cache metadata on
  # @return 	mixed		FALSE on failure, array on success.
  #
  get_metadata($id)
  {
  if not file_exists(@_cache_path + $id)
    return false
    
  
  $data = read_file(@_cache_path + $id)
  $data = unserialize($data)
  
  if is_array($data)
    $data = $data['data']
    $mtime = filemtime(@_cache_path + $id)
    
    if not $data['ttl']? 
      return false
      
    
    return 
      'expire':$mtime + $data['ttl'], 
      'mtime':$mtime
      
    
  
  return false
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Is supported
  #
  # In the file driver, check to see that the cache directory is indeed writable
  #
  # @return boolean
  #
  is_supported()
  {
  return is_really_writable(@_cache_path)
  }
  
  #  ------------------------------------------------------------------------
  

register_class 'CI_Cache_file', CI_Cache_file
module.exports = CI_Cache_file
#  End Class

#  End of file Cache_file.php 
#  Location: ./system/libraries/Cache/drivers/Cache_file.php 