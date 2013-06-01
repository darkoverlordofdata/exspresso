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
# Exspresso Cacheing Class
#
#
module.exports = class system.lib.Cache extends system.lib.DriverLibrary

  self = @
  self.support = {}

  valid_drivers: [

    'null'  # Dummy (noop) cache
    'ram'   # Hash table cache
    'mem'   # Memcached based cache
    'file'  # File system cache
  ]

  _cache_path       : ''
  _adapter          : 'mem'
  _fallback         : 'ram'
  
  #
  # Constructor
  #
  # @param  [Array]
  #
  constructor : ($controller, $config = {}) ->
    for $key in ['adapter', 'fallback']
      if $config[$key]?
        @['_'+$key] = $config[$key]

    @loadDriver @valid_drivers, $controller


  #
  # Get
  #
  # Look for a value in the cache.  If it exists, return the data
  # if not, return FALSE
  #
  # @param 	string
  # @return [Mixed]  value that is stored/FALSE on failure
  #
  get : ($id, $next) ->
    @_validate()
    @[@_adapter].get($id, $next)

  #
  # Cache Save
  #
  # @param 	string		Unique Key
  # @param  [Mixed]  Data to store
  # @param 	int			Length of time (in seconds) to cache the data
  # @return 	boolean		true on success/false on failure
  #
  save : ($id, $data, $ttl = 60, $next) ->
    @_validate()
    @[@_adapter].save($id, $data, $ttl, $next)
    
  
  #
  # Delete from Cache
  #
  # @param  [Mixed]  unique identifier of the item in the cache
  # @return 	boolean		true on success/false on failure
  #
  delete : ($id, $next) ->
    @_validate()
    @[@_adapter].delete($id, $next)
    
  
  #
  # Clean the cache
  #
  # @return 	boolean		false on failure/true on success
  #
  clean : ($next) ->
    @_validate()
    @[@_adapter].clean($next)
    
  
  #
  # Cache Info
  #
  # @param 	string		user/filehits
  # @return [Mixed]  array on success, false on failure
  #
  cacheInfo : ($type = 'user', $next) ->
    @_validate()
    @[@_adapter].cacheInfo($type, $next)
    
  
  #
  # Get Cache Metadata
  #
  # @param  [Mixed]  key to get cache metadata on
  # @return [Mixed]  return value from child method
  #
  getMetadata : ($id, $next) ->
    @[@_adapter].getMetadata($id, $next)
    

  #
  # Is the requested driver supported in this environment?
  #
  # @param 	string	The driver to test.
  # @return 	array
  #
  isSupported : ($driver) ->
    self.support[$driver] ? (self[$driver] = @[$driver].isSupported())

  #
  # Validate the current adapter
  # If not supported use the fallback adapter
  #
  # @private
  # @return [Void]
  #
  _validate: ->
    if not @isSupported(@_adapter)
      log_message 'debug', 'Cache adapter %s not found.', @_adapter
      log_message 'debug', 'Using fallback adapter %s.', @_fallback
      @_adapter = @_fallback
  
