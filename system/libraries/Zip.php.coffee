#+--------------------------------------------------------------------+
#  Zip.coffee
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
# This file was ported from php to coffee-script using php2coffee v6.6.6
#
#

{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{__construct, crc32, defined, dirname, fclose, file_exists, file_get_contents, filemtime, flock, fopen, force_download, fwrite, get_instance, getdate, gzcompress, helper, is_array, is_dir, load, opendir, pack, preg_match, preg_replace, readdir, str_replace, strlen, substr, time}  = require(FCPATH + 'lib')
{config_item, get_class, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

if not defined('BASEPATH') then die 'No direct script access allowed'
#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# Zip Compression Class
#
# This class is based on a library I found at Zend:
# http://www.zend.com/codex.php?id=696&single=1
#
# The original library is a little rough around the edges so I
# refactored it and added several additional methods -- Rick Ellis
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Encryption
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/libraries/zip.html
#
class CI_Zip
  
  zipdata: ''
  directory: ''
  entries: 0
  file_num: 0
  offset: 0
  now: {}
  
  #
  # Constructor
  #
  __construct()
  {
  log_message('debug', "Zip Compression Class Initialized")
  
  @now = time()
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Add Directory
  #
  # Lets you add a virtual directory into which you can place files.
  #
  # @access	public
  # @param	mixed	the directory name. Can be string or array
  # @return	void
  #
  add_dir : ($directory) ->
    for $dir in $directory
      if not preg_match("|.+/$|", $dir)
        $dir+='/'
        
      
      $dir_time = @_get_mod_time($dir)
      
      @_add_dir($dir, $dir_time['file_mtime'], $dir_time['file_mdate'])
      
    
  
  #  --------------------------------------------------------------------
  
  #
  #	Get file/directory modification time
  #
  #	If this is a newly created file/dir, we will set the time to 'now'
  #
  #	@param string	path to file
  #	@return array	filemtime/filemdate
  #
  _get_mod_time : ($dir) ->
    #  filemtime() will return false, but it does raise an error.
    $date = if (filemtime($dir)) then filemtime($dir) else getdate(@now)
    
    $time['file_mtime'] = ($date['hours']<<11) + ($date['minutes']<<5) + $date['seconds'] / 2
    $time['file_mdate'] = (($date['year'] - 1980)<<9) + ($date['mon']<<5) + $date['mday']
    
    return $time
    
  
  #  --------------------------------------------------------------------
  
  #
  # Add Directory
  #
  # @access	private
  # @param	string	the directory name
  # @return	void
  #
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
    
  
  #  --------------------------------------------------------------------
  
  #
  # Add Data to Zip
  #
  # Lets you add files to the archive. If the path is included
  # in the filename it will be placed within a directory.  Make
  # sure you use add_dir() first to create the folder.
  #
  # @access	public
  # @param	mixed
  # @param	string
  # @return	void
  #
  add_data : ($filepath, $data = null) ->
    if is_array($filepath)
      for $path, $data of $filepath
        $file_data = @_get_mod_time($path)
        
        @_add_data($path, $data, $file_data['file_mtime'], $file_data['file_mdate'])
        
      
    else 
      $file_data = @_get_mod_time($filepath)
      
      @_add_data($filepath, $data, $file_data['file_mtime'], $file_data['file_mdate'])
      
    
  
  #  --------------------------------------------------------------------
  
  #
  # Add Data to Zip
  #
  # @access	private
  # @param	string	the file name/path
  # @param	string	the data to be encoded
  # @return	void
  #
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
    
  
  #  --------------------------------------------------------------------
  
  #
  # Read the contents of a file and add it to the zip
  #
  # @access	public
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
  # @access	public
  # @param	string	path to source
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
        
      
      $CI = get_instance()
      $CI.load.helper('download')
      
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
    # @access	public
    # @return	binary string
    ##  --------------------------------------------------------------------#
    # Write File to the specified directory
    #
    # Lets you write a file
    #
    # @access	public
    # @param	string	the file name
    # @return	bool
    ##  --------------------------------------------------------------------#
    # Download
    #
    # @access	public
    # @param	string	the file name
    # @param	string	the data to be encoded
    # @return	bool
    ##  --------------------------------------------------------------------#
    # Initialize Data
    #
    # Lets you clear current zip data.  Useful if you need to create
    # multiple zips with different data.
    #
    # @access	public
    # @return	void
    ##  End of file Zip.php #  Location: ./system/libraries/Zip.php 

register_class 'CI_Zip', CI_Zip
module.exports = CI_Zip