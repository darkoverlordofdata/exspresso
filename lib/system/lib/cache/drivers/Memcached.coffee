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
module.exports = class system.lib.cache.Memcached #extends system.lib.Driver


  _memcached  : null #  Holds the memcached object

  _default_options  :
    default_host    : '127.0.0.1'
    default_port    : 11211
    default_weight  : 1

  _memcache_conf  :
    default       :
      hostname    : '127.0.0.1'
      port        : 11211
      weight      : 1

  constructor: (@parent, @controller) ->

  
  #  ------------------------------------------------------------------------
  
  #
  # Fetch from cache
  #
  # @param  [Mixed]  unique key id
  # @return [Mixed]  data on success/false on failure
  #
  get : ($id, $next) ->
    @_memcached.get($id, $next)

  
  #  ------------------------------------------------------------------------
  
  #
  # Save
  #
  # @param 	string		unique identifier
  # @param  [Mixed]  data being cached
  # @param 	int			time to live
  # @return 	boolean 	true on success, false on failure
  #
  save : ($id, $data, $ttl = 60, $next) ->
    @_memcached.set($id, $data, $ttl, $next)

  
  #  ------------------------------------------------------------------------
  
  #
  # Delete from Cache
  #
  # @param  [Mixed]  key to be deleted.
  # @return 	boolean 	true on success, false on failure
  #
  delete : ($id, $next) ->
    @_memcached.del($id, $next)
    
  
  #  ------------------------------------------------------------------------
  
  #
  # Clean the Cache
  #
  # @return 	boolean		false on failure/true on success
  #
  clean :  ($next)->
    @_memcached.flush($next)
    
  
  #  ------------------------------------------------------------------------
  
  #
  # Cache Info
  #
  # @param 	null		type not supported in memcached
  # @return [Mixed]  array on success, false on failure
  #
  cacheInfo : ($type = null, $next) ->
    $next = $type unless $next?
    return @_memcached.stats($next)
    
  
  #  ------------------------------------------------------------------------
  
  #
  # Get Cache Metadata
  #
  # @param  [Mixed]  key to get cache metadata on
  # @return [Mixed]  FALSE on failure, array on success.
  #
  getMetadata : ($id, $next) ->
    $stored = @_memcached.get $id, ($err, $result) ->

      return $next($err) if $err?
      return $next(null, @)

  
  #  ------------------------------------------------------------------------
  
  #
  # Setup memcached.
  #
  _setup_memcached :  ->
    Memcached = require('memcached')
    #  Try to load memcached server info from the config file.
    if @controller.config.load('memcached', true, true)
      if Object.keys(@controller.config.item('memcached')).length>0
        @_memcache_conf = {}
        
        for $name, $conf of @controller.config.item('memcached')
          @_memcache_conf[$name] = $conf


      $servers = {}
      $options = {}
      for $name, $cache_server of @_memcache_conf
        if not $cache_server.hostname?
          $cache_server.hostname = @_default_options['default_host']

        if not $cache_server.port?
          $cache_server.port = @_default_options['default_port']

        if not $cache_server.weight?
          $cache_server.weight = @_default_options['default_weight']

        $servers[$cache_server.hostname+':'+$cache_server.port] = $cache_server.weight

      @_memcached = new Memcached($servers, $options)

    

  #
  # Is Supported
  #
  # Returns false if memcached is not supported on the system.
  # If it is, we setup the memcached object & return true
  #
  isSupported :  ->

    try
      require 'memcached'

    catch $err
      log_message 'error', $err
      return false

    @_setup_memcached()
    return true
    
  
