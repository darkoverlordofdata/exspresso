#+--------------------------------------------------------------------+
#  NullCache.coffee
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
# Null Caching Class
#
#
module.exports = class system.lib.cache.NullCache #extends system.lib.Driver

  constructor: (@parent, @controller) ->

  #
  # Get
  #
  # Since this is the dummy class, it's always going to return FALSE.
  #
  # @param 	string
  # @return 	Boolean		FALSE
  #
  get : ($id, $next) ->
    $next null, false
    
  
  #  ------------------------------------------------------------------------
  
  #
  # Cache Save
  #
  # @param 	string		Unique Key
  # @param  [Mixed]  Data to store
  # @param 	int			Length of time (in seconds) to cache the data
  #
  # @return 	boolean		TRUE, Simulating success
  #
  save : ($id, $data, $ttl = 60, $next) ->
    $next null, true
    
  
  #  ------------------------------------------------------------------------
  
  #
  # Delete from Cache
  #
  # @param  [Mixed]  unique identifier of the item in the cache
  # @param 	boolean		TRUE, simulating success
  #
  delete : ($id, $next) ->
    $next null, true
    
  
  #  ------------------------------------------------------------------------
  
  #
  # Clean the cache
  #
  # @return 	boolean		TRUE, simulating success
  #
  clean : ($next) ->
    $next null, true
    
  
  #  ------------------------------------------------------------------------
  
  #
  # Cache Info
  #
  # @param 	string		user/filehits
  # @return 	boolean		FALSE
  #
  cacheInfo : ($type = null, $next) ->
    $next = $type unless $next?
    $next null, true
    
  
  #  ------------------------------------------------------------------------
  
  #
  # Get Cache Metadata
  #
  # @param  [Mixed]  key to get cache metadata on
  # @return 	boolean		FALSE
  #
  getMetadata : ($id, $next) ->
    $next null, false
    
  
  #  ------------------------------------------------------------------------
  
  #
  # Is this caching driver supported on the system?
  # Of course this one is.
  #
  # @return TRUE;
  #
  isSupported :  ->
    true
    
