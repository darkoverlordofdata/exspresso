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
# CodeIgniter Memcached Caching Class
#
#
module.exports = class system.lib.cache.MemCache #extends system.lib.Driver

  #
  # memjs uses the following environment variables:
  #
  # process.env.MEMCACHIER_SERVERS = '127.0.0.1:11211'
  # process.env.MEMCACHIER_USERNAME = '<name>'
  # process.env.MEMCACHIER_PASSWORD = '<password'
  #

  _memcached  : null #  Holds the memcached object


  constructor: (@parent, @controller) ->

  #
  # Fetch from cache
  #
  # @param  [Mixed]  unique key id
  # @return [Mixed]  data on success/false on failure
  #
  get : ($id, $next) ->
    @_memcached.get($id, $next)

  
  #
  # Save
  #
  # @param 	string		unique identifier
  # @param  [Mixed]  data being cached
  # @param 	int			time to live
  # @return 	boolean 	true on success, false on failure
  #
  save : ($id, $data, $ttl = 60, $next) ->
    @_memcached.set($id, $data, $next, $ttl)

  
  #
  # Delete from Cache
  #
  # @param  [Mixed]  key to be deleted.
  # @return 	boolean 	true on success, false on failure
  #
  delete : ($id, $next) ->
    @_memcached.delete($id, $next)
    
  
  #
  # Clean the Cache
  #
  # @return 	boolean		false on failure/true on success
  #
  clean :  ($next)->
    @_memcached.flush($next)
    
  
  #
  # Cache Info
  #
  # @param 	null		type not supported in memcached
  # @return [Mixed]  array on success, false on failure
  #
  cacheInfo : ($type = null, $next) ->
    $next = $type unless $next?
    @_memcached.stats ($err, $server, $stats) ->
      return $next($err) if $err?
      $next null, array($server, $stats)
    
  
  #
  # Get Cache Metadata
  #
  # @param  [Mixed]  key to get cache metadata on
  # @return [Mixed]  FALSE on failure, array on success.
  #
  getMetadata : ($id, $next) ->
    $stored = @_memcached.get $id, ($err, $data, $extra) ->

      return $next($err) if $err?
      $extra['data'] = $data
      return $next(null, $extra)

  
  #
  # Is Supported
  #
  # Returns false if memcached is not supported on the system.
  # If it is, we setup the memcached object & return true
  #
  isSupported :  ->

    try
      memjs = require('memjs')
      @_memcached = memjs.Client.create()
      return true

    catch $err
      return false


  
