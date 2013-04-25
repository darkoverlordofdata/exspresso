#+--------------------------------------------------------------------+
#  Cache_file.coffee
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
# Exspresso File Caching Class
#
module.exports = class system.lib.cache.FileCache # extends system.lib.Driver

  fs = require('fs')

  _cache_path   : ''
  _encoding     : 'utf8'

  
  #
  # Constructor
  #
  constructor: (@parent, @controller) ->

    @controller.load.helper('file')
    $cache_path = config_item('cache_path')
    $encoding = config_item('encoding')

    @_cache_path = if ($cache_path is '') then APPPATH+'cache/' else $cache_path
    @_encoding = $encoding
    
  
  #
  # Fetch from cache
  #
  # @param  [String]  id unique key id
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  get : ($id, $next) ->

    fs.exists @_cache_path+$id, ($exists) =>
      return $next(null, false) unless $exists

      fs.readFile @_cache_path+$id, encoding:@_encoding, ($err, $data) =>
        return $next(null, false) if $err?

        $data = JSON.parse($data)
        if Date.now() > ($data.time + $data.ttl)
          fs.unlink @_cache_path+$id, ($err) =>
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

    if not $next?
      [$ttl, $next] = [60, $ttl]

    $contents = 
      'time'    : Math.floor(Date.now()*1000)
      'ttl'     : $ttl
      'data'    : $data

    fs.writeFile @_cache_path+$id, JSON.stringify($contents), ($err) =>

      return $next(null, false) if $err?
      fs.chmod @_cache_path+$id, DIR_WRITE_MODE, ($err) =>
        $next null, not($err?)

  
  #
  # Delete from Cache
  #
  # @param  [Mixed]  unique identifier of item in cache
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  delete : ($id, $next) ->
    fs.unlink @_cache_path+$id, ($err) ->
      $next null, not($err?)

    
  
  #
  # Clean the Cache
  #
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  clean : ($next) ->
    delete_files(@_cache_path, $next)
    
  
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
    get_dir_file_info(@_cache_path, $next)
    
  
  #
  # Get Cache Metadata
  #
  # @param  [Mixed]  key to get cache metadata on
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  getMetadata : ($id, $next) ->
    fs.exists @_cache_path+$id, ($exists) =>
      return $next(null, false) unless $exists

      fs.readFile @_cache_path+$id, encoding:@_encoding, ($err, $data) =>
        return $next(null, false) if $err?

        $data = JSON.parse($data)
        if 'object' is typeof($data)
          fs.Stats @_cache_path+$id, ($err, $stats) =>
            return $next(null, false) if $err?

            $next null, {
              'expire'  :$mtime + $data.ttl
              'mtime'   :$mtime
            }

        else
          $next(null, false)

  #
  # Is supported
  #
  # In the file driver, check to see that the cache directory is indeed writable
  #
  # @return boolean
  #
  isSupported :  ->
    is_really_writable(@_cache_path)
    
  
