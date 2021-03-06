#+--------------------------------------------------------------------+
#  Zip.coffee
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
# Zip Compression Class
#
#
class system.lib.Zip

  zipstream = require('zipstream')

  zipdata: ''
  directory: ''
  entries: 0
  file_num: 0
  offset: 0
  now: {}
  
  #
  # Constructor
  #
  constructor: ($controller, $config = {}) ->
    log_message('debug', "Zip Compression Class Initialized")

    @now = time()

  #
  # Add Directory
  #
  # Lets you add a virtual directory into which you can place files.
  #
    # @param  [Mixed]  the directory name. Can be string or array
  # @return [Void]  #
  add_dir : ($directory) ->
    for $dir in $directory
      if not preg_match("|.+/$|", $dir)
        $dir+='/'
        
      
      $dir_time = @_get_mod_time($dir)
      
      @_add_dir($dir, $dir_time['file_mtime'], $dir_time['file_mdate'])
      
    
  
  #
  #	Get file/directory modification time
  #
  #	If this is a newly created file/dir, we will set the time to 'now'
  #
  # @param  [String]  path to file
  #	@return array	filemtime/filemdate
  #
  _get_mod_time : ($dir) ->
    #  filemtime() will return false, but it does raise an error.
    $date = if (filemtime($dir)) then filemtime($dir) else getdate(@now)
    
    $time['file_mtime'] = ($date['hours']<<11) + ($date['minutes']<<5) + $date['seconds'] / 2
    $time['file_mdate'] = (($date['year'] - 1980)<<9) + ($date['mon']<<5) + $date['mday']
    
    return $time
    
  
  #
  # Add Directory
  #
  # @private
  # @param  [String]  the directory name
  # @return [Void]  #
  _add_dir : ($dir, $file_mtime, $file_mdate) ->
    $dir = str_replace("\\", "/", $dir)
    
    @zipdata+=
    "\x50\x4b\x03\x04\x0a\x00\x00\x00\x00\x00"
     + pack('v', $file_mtime)
     + pack('v', $file_mdate)
     + pack('V', 0)#  crc32
     + pack('V', 0)#  compressed filesize
     + pack('V', 0)#  uncompressed filesize
     + pack('v', strlen($dir))#  length of pathname
     + pack('v', 0)#  extra field length
     + $dir
    #  below is "data descriptor" segment
     + pack('V', 0)#  crc32
     + pack('V', 0)#  compressed filesize
     + pack('V', 0)#  uncompressed filesize
    
    @directory+=
    "\x50\x4b\x01\x02\x00\x00\x0a\x00\x00\x00\x00\x00"
     + pack('v', $file_mtime)
     + pack('v', $file_mdate)
     + pack('V', 0)#  crc32
     + pack('V', 0)#  compressed filesize
     + pack('V', 0)#  uncompressed filesize
     + pack('v', strlen($dir))#  length of pathname
     + pack('v', 0)#  extra field length
     + pack('v', 0)#  file comment length
     + pack('v', 0)#  disk number start
     + pack('v', 0)#  internal file attributes
     + pack('V', 16)#  external file attributes - 'directory' bit set
     + pack('V', @offset)#  relative offset of local header
     + $dir
    
    @offset = strlen(@zipdata)
    @entries++
    
  
  #
  # Add Data to Zip
  #
  # Lets you add files to the archive. If the path is included
  # in the filename it will be placed within a directory.  Make
  # sure you use add_dir() first to create the folder.
  #
    # @param  [Mixed]  # @param  [String]    # @return [Void]  #
  add_data : ($filepath, $data = null) ->
    if is_array($filepath)
      for $path, $data of $filepath
        $file_data = @_get_mod_time($path)
        
        @_add_data($path, $data, $file_data['file_mtime'], $file_data['file_mdate'])
        
      
    else 
      $file_data = @_get_mod_time($filepath)
      
      @_add_data($filepath, $data, $file_data['file_mtime'], $file_data['file_mdate'])
      
    
  
  #
  # Add Data to Zip
  #
  # @private
  # @param  [String]  the file name/path
  # @param  [String]  the data to be encoded
  # @return [Void]  #
  _add_data : ($filepath, $data, $file_mtime, $file_mdate) ->
    $filepath = str_replace("\\", "/", $filepath)
    
    $uncompressed_size = strlen($data)
    $crc32 = crc32($data)
    
    $gzdata = gzcompress($data)
    $gzdata = substr($gzdata, 2,  - 4)
    $compressed_size = strlen($gzdata)
    
    @zipdata+=
    "\x50\x4b\x03\x04\x14\x00\x00\x00\x08\x00"
     + pack('v', $file_mtime)
     + pack('v', $file_mdate)
     + pack('V', $crc32)
     + pack('V', $compressed_size)
     + pack('V', $uncompressed_size)
     + pack('v', strlen($filepath))#  length of filename
     + pack('v', 0)#  extra field length
     + $filepath
     + $gzdata#  "file data" segment
    
    @directory+=
    "\x50\x4b\x01\x02\x00\x00\x14\x00\x00\x00\x08\x00"
     + pack('v', $file_mtime)
     + pack('v', $file_mdate)
     + pack('V', $crc32)
     + pack('V', $compressed_size)
     + pack('V', $uncompressed_size)
     + pack('v', strlen($filepath))#  length of filename
     + pack('v', 0)#  extra field length
     + pack('v', 0)#  file comment length
     + pack('v', 0)#  disk number start
     + pack('v', 0)#  internal file attributes
     + pack('V', 32)#  external file attributes - 'archive' bit set
     + pack('V', @offset)#  relative offset of local header
     + $filepath
    
    @offset = strlen(@zipdata)
    @entries++
    @file_num++
    
  
  #
  # Read the contents of a file and add it to the zip
  #
    # @return	bool
  #
  read_file : ($path, $preserve_filepath = false) ->
    if not file_exists($path)
      return false
      
    
    if false isnt ($data = file_get_contents($path))
      $name = str_replace("\\", "/", $path)
      
      if $preserve_filepath is false
        $name = preg_replace("|.*/(.+)|", "\\1", $name)
        
      
      @add_data($name, $data)
      return true
      
    return false
    
  
  #  ------------------------------------------------------------------------
  
  #
  # Read a directory and add it to the zip.
  #
  # This function recursively reads a folder and everything it contains (including
  # sub-folders) and creates a zip based on it.  Whatever directory structure
  # is in the original file path will be recreated in the zip file.
  #
    # @param  [String]  path to source
  # @return	bool
  #
  read_dir : ($path, $preserve_filepath = true, $root_path = null) ->
    if not $fp = opendir($path)) then return false}if $root_path is null
      $root_path = dirname($path) + '/'
      while false isnt ($file = readdir($fp))
      if substr($file, 0, 1) is '.'
        continue
        
      
      if is_dir($path + $file)
        @read_dir($path + $file + "/", $preserve_filepath, $root_path)
        
      else 
        if false isnt ($data = file_get_contents($path + $file))
          $name = str_replace("\\", "/", $path)
          
          if $preserve_filepath is false
            $name = str_replace($root_path, '', $name)
            
          
          @add_data($name + $file, $data)
          
        
      return true}get_zip :  ->
      #  Is there any data to return?
      if @entries is 0
        return false
        
      
      $zip_data = @zipdata
      $zip_data+=@directory + "\x50\x4b\x05\x06\x00\x00\x00\x00"
      $zip_data+=pack('v', @entries)#  total # of entries "on this disk"
      $zip_data+=pack('v', @entries)#  total # of entries overall
      $zip_data+=pack('V', strlen(@directory))#  size of central dir
      $zip_data+=pack('V', strlen(@zipdata))#  offset to start of central dir
      $zip_data+="\x00\x00"#  .zip file comment length
      
      return $zip_data
      archive : ($filepath) ->
      if not ($fp = fopen($filepath, FOPEN_WRITE_CREATE_DESTRUCTIVE))
        return false
        
      
      flock($fp, LOCK_EX)
      fwrite($fp, @get_zip())
      flock($fp, LOCK_UN)
      fclose($fp)
      
      return true
      download : ($filename = 'backup.zip') ->
      if not preg_match("|.+?\.zip$|", $filename)
        $filename+='.zip'
        
      
      $controller = Exspresso
      $controller.load.helper('download')
      
      $get_zip = @get_zip()
      
      $zip_content = $get_zip
      
      force_download($filename, $zip_content)
      clear_data :  ->
      @zipdata = ''
      @directory = ''
      @entries = 0
      @file_num = 0
      @offset = 0
      }#  Set the original directory root for child dir's to use as relative#  --------------------------------------------------------------------#
    # Get the Zip file
    #
        # @return	binary string
    ##  --------------------------------------------------------------------#
    # Write File to the specified directory
    #
    # Lets you write a file
    #
        # @param  [String]  the file name
    # @return	bool
    ##  --------------------------------------------------------------------#
    # Download
    #
        # @param  [String]  the file name
    # @param  [String]  the data to be encoded
    # @return	bool
    ##  --------------------------------------------------------------------#
    # Initialize Data
    #
    # Lets you clear current zip data.  Useful if you need to create
    # multiple zips with different data.
    #
        # @return [Void]  ##  End of file Zip.php #  Location: ./system/lib/Zip.php

register_class 'ExspressoZip', ExspressoZip
module.exports = ExspressoZip