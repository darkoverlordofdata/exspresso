#+--------------------------------------------------------------------+
#  Cache.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+

#
# Database Cache Class
#
#
module.exports = class system.db.Cache

  fs = require('fs')

  self = @
  #self.cache = {}

  #
  # @property [system.db.ActiveRecord] database connection object
  #
  db : null
  #
  # @property [system.db.ActiveRecord] controller uri
  #
  uri : null
  #
  # @property [system.db.ActiveRecord] system lib Cache object
  #
  cache : null

  #
  # Constructor
  #
  constructor: ($db, $uri, $cache) ->

    Object.defineProperties @,
      db        : {enumerable: true, writeable: false, value: $db}
      uri       : {enumerable: true, writeable: false, value: $uri}
      cache     : {enumerable: true, writeable: false, value: $cache}

  #
  # Set Cache Directory Path
  #
  # @param  [String]  the path to the cache directory
  # @return	bool
  #
  checkPath: ($path = '') ->
    return true if self.cache?

    if $path is ''
      if @db.cachedir is ''
        return @db.cacheOff()
      $path = @db.cachedir

    #  Add a trailing slash to the path if needed
    $path = $path.replace(/(.+?)\/*$/, "$1/")

    if not is_dir($path) or not is_really_writable($path)
      #  If the path is wrong we'll turn off caching
      return @db.cacheOff()

    @db.cachedir = $path
    return true


  #
  # Retrieve a cached query
  #
  # The URI being requested will become the name of the cache sub-folder.
  # An MD5 hash of the SQL statement will become the cache file name
  #
  # @param  [String]  sql script to execute
  # @param  [Function]  next  async callback
  # @return	[Void]
  #
  read: ($sql, $next) ->
    return $next(null, false) unless @uri # skip system requests
    if not @checkPath()
      return $next(null, @db.cacheOff())

    $segment_one = @uri.segment(1, 'default')
    $segment_two = @uri.segment(2, 'index')
    $path = $segment_one + '+' + $segment_two

    if self.cache?
      $cache = self.cache?[$path]?[md5($sql)] ? false
      return $next(null, $cache)

    else
      $filepath = @db.cachedir+$path+'/'+md5($sql)
      fs.exists $filepath, ($exists) ->
        if $exists
          fs.readFile $filepath, encoding:'utf8', ($err, $cache) ->
            return $next(null, if $err then false else JSON.parse($cache))
        else
          return $next(null, false)


  
  #
  # Write a query to a cache file
  #
  # @param  [String]  sql script to execute
  # @param  [Object]  rs  result set
  # @param  [Function]  next  async callback
  # @return	[Void]
  #
  write: ($sql, $rs, $next) ->
    return $next(null, $rs) unless @uri # skip system requests
    if not @checkPath()
      @db.cacheOff()
      return $next(null, $rs)

    $segment_one = @uri.segment(1, 'default')
    $segment_two = @uri.segment(2, 'index')
    if $segment_one is '' then $segment_one = 'default'
    $path = $segment_one + '+' + $segment_two

    $cache =
      time: Math.floor(Date.now()/1000)
      ttl: -1
      sql: $sql
      data: $rs._rows
      meta: $rs._meta

    if self.cache?
      self.cache[$path] = {} unless self.cache[$path]
      self.cache[$path][md5($sql)] = $cache
      $next(null, $rs)

    else
      $dir_path = @db.cachedir + $path + '/'
      $filename = md5($sql)

      fs.exists $dir_path, ($exists) ->

        if $exists
          fs.writeFile $dir_path + $filename, JSON.stringify($cache), encoding:'utf8', ($err) ->
            return $next(null, $rs) if $err?

            fs.chmod $dir_path + $filename, FILE_WRITE_MODE, ($err) ->
              return $next(null, $rs) if $err?
              $next(null, $rs)

        else
          fs.mkdir $dir_path, DIR_WRITE_MODE, ($err) ->
            return $next(null, $rs) if $err?

            fs.chmod $dir_path, DIR_WRITE_MODE, ($err) ->
              return $next(null, $rs) if $err?

              fs.writeFile $dir_path + $filename, JSON.stringify($cache), encoding:'utf8', ($err) ->
                return $next(null, $rs) if $err?

                fs.chmod $dir_path + $filename, FILE_WRITE_MODE, ($err) ->
                  return $next(null, $rs) if $err?
                  $next(null, $rs)


  
  #
  # Delete cache files within a particular directory
  #
  # @return	bool
  #
  delete: ($segment_one = '', $segment_two = '', $next) ->
    return unless @uri
    if 'function' is typeof $segment_one
      $next = $segment_one
      $segment_one = ''
      $segment_two = ''
    else if 'function' is typeof $segment_two
      $next = $segment_two
      $segment_two = ''

    $segment_one = @uri.segment(1, 'default') if $segment_one is ''
    $segment_two = @uri.segment(2, 'index') if $segment_two is ''
    $path = $segment_one + '+' + $segment_two

    if self.cache?
      delete self.cache[$path] if self.cache[$path]?
    else
      delete_files(@db.cachedir+$path+'/', true)
    $next() if $next?

    
  
  #
  # Delete all existing cache files
  #
  # @return	bool
  #
  deleteAll: ($next) ->
    if self.cache?
      self.cache = {}
    else
      delete_files(@db.cachedir, true)
    $next() if $next?

