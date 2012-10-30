#+--------------------------------------------------------------------+
#  Cache_memcached.coffee
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


{Memcached, _default_options, _setup_memcached, add, addServer, array_key_exists, cache_info, clean, config, count, defined, delete, extension_loaded, flush, get, getStats, get_instance, get_metadata, is_array, is_supported, load, save, time}  = require(FCPATH + 'lib')


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

class CI_Cache_memcached extends CI_Driver
  
  _memcached: {}#  Holds the memcached object
  
  _memcache_conf: 
    'default':
      'default_host':'127.0.0.1', 
      'default_port':11211, 
      'default_weight':1
      
    
  
  #  ------------------------------------------------------------------------
  
  #
  # Fetch from cache
  #
  # @param 	mixed		unique key id
  # @return 	mixed		data on success/false on failure
  #
  get($id)
  {
  $data = @_memcached.get($id)
  
  return if (is_array($data)) then $data[0] else false
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Save
  #
  # @param 	string		unique identifier
  # @param 	mixed		data being cached
  # @param 	int			time to live
  # @return 	boolean 	true on success, false on failure
  #
  save($id, $data, $ttl = 60)
  {
  return @_memcached.add($id, [$data, time(], $ttl),$ttl)
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Delete from Cache
  #
  # @param 	mixed		key to be deleted.
  # @return 	boolean 	true on success, false on failure
  #
  delete($id)
  {
  return @_memcached.delete($id)
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Clean the Cache
  #
  # @return 	boolean		false on failure/true on success
  #
  clean()
  {
  return @_memcached.flush()
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Cache Info
  #
  # @param 	null		type not supported in memcached
  # @return 	mixed 		array on success, false on failure
  #
  cache_info($type = null)
  {
  return @_memcached.getStats()
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
  $stored = @_memcached.get($id)
  
  if count($stored) isnt 3
    return false
    
  
  [$data, $time, $ttl] = $stored
  
  return 
    'expire':$time + $ttl, 
    'mtime':$time, 
    'data':$data
    
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Setup memcached.
  #
  _setup_memcached()
  {
  #  Try to load memcached server info from the config file.
  $CI = get_instance()
  if $CI.config.load('memcached', true, true)
    if is_array($CI.config.config['memcached'])
      @_memcache_conf = null
      
      for $name, $conf of $CI.config.config['memcached']
        @_memcache_conf[$name] = $conf
        
      
    
  
  @_memcached = new Memcached()
  
  for $name, $cache_server of @_memcache_conf
    if not array_key_exists('hostname', $cache_server)
      $cache_server['hostname'] = @_default_options['default_host']
      
    
    if not array_key_exists('port', $cache_server)
      $cache_server['port'] = @_default_options['default_port']
      
    
    if not array_key_exists('weight', $cache_server)
      $cache_server['weight'] = @_default_options['default_weight']
      
    
    @_memcached.addServer(
    $cache_server['hostname'], $cache_server['port'], $cache_server['weight']
    )
    
  }
  
  #  ------------------------------------------------------------------------
  
  
  #
  # Is supported
  #
  # Returns FALSE if memcached is not supported on the system.
  # If it is, we setup the memcached object & return TRUE
  #
  is_supported()
  {
  if not extension_loaded('memcached')
    log_message('error', 'The Memcached Extension must be loaded to use Memcached Cache.')
    
    return false
    
  
  @_setup_memcached()
  return true
  }
  
  #  ------------------------------------------------------------------------
  
  

register_class 'CI_Cache_memcached', CI_Cache_memcached
module.exports = CI_Cache_memcached
#  End Class

#  End of file Cache_memcached.php 
#  Location: ./system/libraries/Cache/drivers/Cache_memcached.php 