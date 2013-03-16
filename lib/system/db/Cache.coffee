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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Database Cache Class
#
#
class system.db.Cache

  is_dir            = require(SYSPATH+'util.coffee').is_dir
  md5               = require(SYSPATH+'util.coffee').md5
  fs = require('fs')
  unserialize = JSON.parse
  serialize   = JSON.stringify

  
  db: null #  allows passing of db object so that multiple database connections and returned db objects can be supported
  
  #
  # Constructor
  #
  # Grabs the Exspresso super object instance so we can access it.
  #
  #
  constructor: ($controller, @db) ->
    #  and load the file helper since we use it a lot
    @load.helper('file')
    
  
  #
  # Set Cache Directory Path
  #
  # @param  [String]  the path to the cache directory
  # @return	bool
  #
  checkPath: ($path = '') ->
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
  # @return	[String]
  #
  read: ($sql) ->
    if not @checkPath()
      return @db.cacheOff()

    $segment_one = if (@uri.segment(1) is false) then 'default' else @uri.segment(1)
    $segment_two = if (@uri.segment(2) is false) then 'index' else @uri.segment(2)
    $filepath = @db.cachedir + $segment_one + '+' + $segment_two + '/' + md5($sql)
    
    if false is ($cachedata = fs.readFileSync($filepath))
      return false

    return unserialize($cachedata)
    
  
  #
  # Write a query to a cache file
  #
  # @return	bool
  #
  write: ($sql, $object) ->
    if not @check_path()
      return @db.cache_off()
      
    
    $segment_one = if (@uri.segment(1) is false) then 'default' else @uri.segment(1)
    $segment_two = if (@uri.segment(2) is false) then 'index' else @uri.segment(2)
    $dir_path = @db.cachedir + $segment_one + '+' + $segment_two + '/'
    
    $filename = md5($sql)
    if not is_dir($dir_path)
      if not fs.mkdirSync($dir_path, DIR_WRITE_MODE)
        return false

      fs.chmodSync($dir_path, DIR_WRITE_MODE)

    if fs.writeFileSync($dir_path + $filename, serialize($object)) is false
      return false

    fs.chmodSync($dir_path + $filename, FILE_WRITE_MODE)
    return true
    
  
  #
  # Delete cache files within a particular directory
  #
  # @return	bool
  #
  delete: ($segment_one = '', $segment_two = '') ->
    if $segment_one is ''
      $segment_one = if (@uri.segment(1) is false) then 'default' else @uri.segment(1)
    if $segment_two is ''
      $segment_two = if (@uri.segment(2) is false) then 'index' else @uri.segment(2)
    $dir_path = @db.cachedir + $segment_one + '+' + $segment_two + '/'
    
    delete_files($dir_path, true)
    
  
  #
  # Delete all existing cache files
  #
  # @return	bool
  #
  deleteAll :  ->
    delete_files(@db.cachedir, true)

module.exports = system.db.Cache


#  End of file Cache.coffee
#  Location: ./system/database/Cache.coffee