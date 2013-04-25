#+--------------------------------------------------------------------+
#  RamCache.coffee
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
# Ram Caching Class
#
#
module.exports = class system.lib.cache.RamCache #extends system.lib.Driver
  
  self = @
  self.cache = {}

  constructor: (@parent, @controller) ->


  #
  # Fetch from cache
  #
  # @param  [String]  id unique key id
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  get : ($id, $next) ->

    if not self.cache[$id]?
      return $next(null, false)

    $data = self.cache[$id]
    if Date.now() > ($data.time + $data.ttl)
      delete self.cache[$id]
      return $next(null, false)
    $next null, $data.data


  #
  # Save into cache
  #
  # @param 	[String]  id  unique key
  # @param  [Mixed] data  data to store
  # @param 	[Integer] ttl length of time (in seconds) the cache is valid
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  save : ($id, $data, $ttl = 60, $next) ->

    try
      self.cache[$id] =
        'time'    : Math.floor(Date.now()*1000)
        'ttl'     : $ttl
        'data'    : $data

      $next null, true

    catch $err
      $next null, false


  #
  # Delete from Cache
  #
  # @param  [Mixed]  unique identifier of item in cache
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  delete : ($id, $next) ->
    delete self.cache[$id] if self.cache[$id]?
    $next null, true



  #
  # Clean the Cache
  #
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  clean : ($next) ->
    self.cache = {}
    $next null, true

  #
  # Cache Info
  #
  # Not supported by file-based caching
  #
  # @param 	string	user/filehits
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  cacheInfo : ($type = null, $next) ->
    $next = $type unless $next?
    $next null, true


  #
  # Get Cache Metadata
  #
  # @param  [Mixed]  key to get cache metadata on
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  getMetadata : ($id, $next) ->

    if not self.cache[$id]?
      return $next(null, false)

    $data = self.cache[$id]
    if 'object' is typeof($data)
      $next null, {
        'expire'  :$data.time + $data.ttl
        'mtime'   :$data.time
      }

    else
      $next(null, false)

  #
  # Is Supported
  #
  # In the file driver, check to see that the cache directory is indeed writable
  #
  # @return boolean
  #
  isSupported :  ->
    true


