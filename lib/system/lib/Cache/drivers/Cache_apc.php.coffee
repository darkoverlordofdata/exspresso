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
# This file was ported from php to coffee-script using php2coffee
#
#

<% if not defined('BASEPATH') then die ('No direct script access allowed')
#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2006 - 2012 EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 2.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# CodeIgniter APC Caching Class
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Core
# @author		ExpressionEngine Dev Team
# @link
#

class CI_Cache_apc extends CI_Driver
  
  #
  # Get
  #
  # Look for a value in the cache.  If it exists, return the data
  # if not, return FALSE
  #
  # @param 	string
  # @return 	mixed		value that is stored/FALSE on failure
  #
  get : ($id) ->
    $data = apc_fetch($id)
    
    return if (is_array($data)) then $data[0] else false
    
  
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
  save : ($id, $data, $ttl = 60) ->
    return apc_store($id, [$data, time(], $ttl),$ttl)
    
  
  #  ------------------------------------------------------------------------
  
  #
  # Delete from Cache
  #
  # @param 	mixed		unique identifier of the item in the cache
  # @param 	boolean		true on success/false on failure
  #
  delete : ($id) ->
    return apc_delete($id)
    
  
  #  ------------------------------------------------------------------------
  
  #
  # Clean the cache
  #
  # @return 	boolean		false on failure/true on success
  #
  clean :  ->
    return apc_clear_cache('user')
    
  
  #  ------------------------------------------------------------------------
  
  #
  # Cache Info
  #
  # @param 	string		user/filehits
  # @return 	mixed		array on success, false on failure
  #
  cache_info : ($type = null) ->
    return apc_cache_info($type)
    
  
  #  ------------------------------------------------------------------------
  
  #
  # Get Cache Metadata
  #
  # @param 	mixed		key to get cache metadata on
  # @return 	mixed		array on success/false on failure
  #
  get_metadata : ($id) ->
    $stored = apc_fetch($id)
    
    if count($stored) isnt 3 then 
      return false
      
    
    [$data, $time, $ttl] = $stored
    
    return 
      'expire':$time + $ttl, 
      'mtime':$time, 
      'data':$data
      
    
  
  #  ------------------------------------------------------------------------
  
  #
  # is_supported()
  #
  # Check to see if APC is available on this system, bail if it isn't.
  #
  is_supported :  ->
    if not extension_loaded('apc') or ini_get('apc.enabled') isnt "1" then 
      log_message('error', 'The APC PHP extension must be loaded to use APC Cache.')
      return false
      
    
    return true
    
  
  #  ------------------------------------------------------------------------
  
  
  
module.exports = CI_Cache_apc
#  End Class

#  End of file Cache_apc.php 
#  Location: ./system/lib/Cache/drivers/Cache_apc.php