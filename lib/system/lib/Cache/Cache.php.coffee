#+--------------------------------------------------------------------+
#  Cache.coffee
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

#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Caching Class
#
#
class ExspressoCache extends ExspressoDriver_Library

  self = @
  
  $valid_drivers = [
    'cache_apc', 'cache_file', 'cache_memcached', 'cache_dummy'
    ]
  
  $_cache_path = null#  Path of cache files (if file-based cache)
  $_adapter = 'dummy'
  $_backup_driver
  
  #
  # Constructor
  #
  # @param  [Array]  #
  constructor : ($controller, $config = {}) ->
    if not empty($config) then 
      @_initialize($config)
  
  #
  # Get
  #
  # Look for a value in the cache.  If it exists, return the data
  # if not, return FALSE
  #
  # @param 	string
  # @return [Mixed]  value that is stored/FALSE on failure
  #
  get : ($id) ->
    @[@_adapter].get($id)

  #
  # Cache Save
  #
  # @param 	string		Unique Key
  # @param  [Mixed]  Data to store
  # @param 	int			Length of time (in seconds) to cache the data
  #
  # @return 	boolean		true on success/false on failure
  #
  save : ($id, $data, $ttl = 60) ->
    @[@_adapter].save($id, $data, $ttl)
    
  
  #
  # Delete from Cache
  #
  # @param  [Mixed]  unique identifier of the item in the cache
  # @return 	boolean		true on success/false on failure
  #
  delete : ($id) ->
    @[@_adapter].delete($id)
    
  
  #
  # Clean the cache
  #
  # @return 	boolean		false on failure/true on success
  #
  clean :  ->
    @[@_adapter].clean()
    
  
  #
  # Cache Info
  #
  # @param 	string		user/filehits
  # @return [Mixed]  array on success, false on failure
  #
  cache_info : ($type = 'user') ->
    @[@_adapter].cache_info($type)
    
  
  #
  # Get Cache Metadata
  #
  # @param  [Mixed]  key to get cache metadata on
  # @return [Mixed]  return value from child method
  #
  get_metadata : ($id) ->
    @[@_adapter].get_metadata($id)
    
  
  #
  # Initialize
  #
  # Initialize class properties based on the configuration array.
  #
  # @param  [Array]  # @return [Void]  #
  _initialize : ($config) ->
    $default_config = [
      'adapter', 
      'memcached'
    ]
    
    for $key in $default_config
      if $config[$key]?  then 
        $param = '_' + $key
        @[$param] = $config[$key]

    if $config['backup']?  then 
      if in_array('cache_' + $config['backup'], @valid_drivers) then 
        @_backup_driver = $config['backup']
        
  #
  # Is the requested driver supported in this environment?
  #
  # @param 	string	The driver to test.
  # @return 	array
  #
  is_supported : ($driver) ->
    self.support = self.support ? {}
    
    if not self.support[$driver]?  then
      self[$driver] = @[$driver].is_supported()
      
    
    return self.support[$driver]
    
  
  #
  # __get()
  #
  # @param 	child
  # @return [Object]  #
  __get : ($child) ->
    $obj = parent::__get($child)
    
    if not @is_supported($child) then 
      @_adapter = @_backup_driver
      
    
    return $obj
    
  
  #  ------------------------------------------------------------------------
  
#  End Class
module.exports = ExspressoCache
#  End of file Cache.php 
#  Location: ./system/lib/Cache/Cache.php