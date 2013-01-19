#+--------------------------------------------------------------------+
#  Cache_apc.coffee
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


{apc_cache_info, apc_clear_cache, apc_delete, apc_fetch, apc_store, cache_info, clean, count, defined, delete, extension_loaded, function_exists, get, get_metadata, is_array, is_supported, save, time}  = require(FCPATH + 'lib')


if not defined('BASEPATH') then die 'No direct script access allowed'
#
# Exspresso
#
# An open source application development framework for coffee-script
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
# Exspresso APC Caching Class
#
# @package		Exspresso
# @subpackage	Libraries
# @category	Core
# @author		darkoverlordofdata
# @link
#

class Exspresso_Cache_apc extends Exspresso_Driver
  
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
  $data = apc_fetch($id)
  
  return if (is_array($data)) then $data[0] else false
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
  return apc_store($id, [$data, time(], $ttl),$ttl)
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Delete from Cache
  #
  # @param 	mixed		unique identifier of the item in the cache
  # @param 	boolean		true on success/false on failure
  #
  delete($id)
  {
  return apc_delete($id)
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Clean the cache
  #
  # @return 	boolean		false on failure/true on success
  #
  clean()
  {
  return apc_clear_cache('user')
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Cache Info
  #
  # @param 	string		user/filehits
  # @return 	mixed		array on success, false on failure
  #
  cache_info($type = null)
  {
  return apc_cache_info($type)
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Get Cache Metadata
  #
  # @param 	mixed		key to get cache metadata on
  # @return 	mixed		array on success/false on failure
  #
  get_metadata($id)
  {
  $stored = apc_fetch($id)
  
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
  # is_supported()
  #
  # Check to see if APC is available on this system, bail if it isn't.
  #
  is_supported()
  {
  if not extension_loaded('apc') or  not function_exists('apc_store')
    log_message('error', 'The APC PHP extension must be loaded to use APC Cache.')
    return false
    
  
  return true
  }
  
  #  ------------------------------------------------------------------------
  
  
  

register_class 'Exspresso_Cache_apc', Exspresso_Cache_apc
module.exports = Exspresso_Cache_apc
#  End Class

#  End of file Cache_apc.php 
#  Location: ./system/libraries/Cache/drivers/Cache_apc.php 