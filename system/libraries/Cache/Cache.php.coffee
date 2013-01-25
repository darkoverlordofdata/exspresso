#+--------------------------------------------------------------------+
#  Cache.coffee
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


{__construct, __get, _initialize, cache_info, clean, defined, delete, get, get_metadata, in_array, is_supported, parent, save}  = require(FCPATH + 'lib')


if not defined('BASEPATH') then die 'No direct script access allowed'
#
# Exspresso
#
# An open source application development framework for PHP 4.3.2 or newer
#
# @package		Exspresso
# @author		darkoverlordofdata
# @copyright	Copyright (c) 2006 - 2011 EllisLab, Inc.
# @license		MIT License
# @link		http://darkoverlordofdata.com
# @since		Version 2.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# Exspresso Caching Class
#
# @package		Exspresso
# @subpackage	Libraries
# @category	Core
# @author		darkoverlordofdata
# @link
#
class Exspresso_Cache extends Exspresso_Driver_Library
  
  valid_drivers: [
    'cache_apc', 'cache_file', 'cache_memcached', 'cache_dummy'
    ]
  
  _cache_path: null#  Path of cache files (if file-based cache)
  _adapter: 'dummy'
  _backup_driver: {}
  
  #  ------------------------------------------------------------------------
  
  #
  # Constructor
  #
  # @param array
  #
  __construct($config = {})
  {
  if not empty($config)
    @_initialize($config)
    
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Get
  #
  # Look for a value in the cache.  If it exists, return the data
  # if not, return FALSE
  #
  # @param 	string
  # @return 	mixed		value that is stored/FALSE on failure
  #
  get($id)
  {
  return @{@_adapter}.get($id)
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Cache Save
  #
  # @param 	string		Unique Key
  # @param 	mixed		Data to store
  # @param 	int			Length of time (in seconds) to cache the data
  #
  # @return 	boolean		true on success/false on failure
  #
  save($id, $data, $ttl = 60)
  {
  return @{@_adapter}.save($id, $data, $ttl)
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Delete from Cache
  #
  # @param 	mixed		unique identifier of the item in the cache
  # @return 	boolean		true on success/false on failure
  #
  delete($id)
  {
  return @{@_adapter}.delete($id)
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Clean the cache
  #
  # @return 	boolean		false on failure/true on success
  #
  clean()
  {
  return @{@_adapter}.clean()
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Cache Info
  #
  # @param 	string		user/filehits
  # @return 	mixed		array on success, false on failure
  #
  cache_info($type = 'user')
  {
  return @{@_adapter}.cache_info($type)
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Get Cache Metadata
  #
  # @param 	mixed		key to get cache metadata on
  # @return 	mixed		return value from child method
  #
  get_metadata($id)
  {
  return @{@_adapter}.get_metadata($id)
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Initialize
  #
  # Initialize class properties based on the configuration array.
  #
  # @param	array
  # @return 	void
  #
  _initialize($config)
  {
  $default_config = [
    'adapter', 
    'memcached'
    ]
  
  for $key in $default_config
    if $config[$key]? 
      $param = '_' + $key
      
      @{$param} = $config[$key]
      
    
  
  if $config['backup']? 
    if in_array('cache_' + $config['backup'], @valid_drivers)
      @_backup_driver = $config['backup']
      
    
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Is the requested driver supported in this environment?
  #
  # @param 	string	The driver to test.
  # @return 	array
  #
  is_supported($driver)
  {
  @$support = @$support ? {} = {}
  
  if not $support[$driver]? 
    $support[$driver] = @{$driver}.is_supported()
    
  
  return $support[$driver]
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # __get()
  #
  # @param 	child
  # @return 	object
  #
  __get($child)
  {
  $obj = parent::__get($child)
  
  if not @is_supported($child)
    @_adapter = @_backup_driver
    
  
  return $obj
  }
  
  #  ------------------------------------------------------------------------
  

register_class 'Exspresso_Cache', Exspresso_Cache
module.exports = Exspresso_Cache
#  End Class

#  End of file Cache.php 
#  Location: ./system/libraries/Cache/Cache.php 