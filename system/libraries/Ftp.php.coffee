#+--------------------------------------------------------------------+
#  Ftp.coffee
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
# This file was ported from php to coffee-script using php2coffee
#
#


{__construct, count, defined, end, explode, file_exists, ftp_chdir, ftp_chmod, ftp_close, ftp_connect, ftp_delete, ftp_get, ftp_login, ftp_mkdir, ftp_nlist, ftp_pasv, ftp_put, ftp_rename, ftp_rmdir, function_exists, get_instance, in_array, is_dir, is_null, is_resource, lang, line, load, opendir, preg_replace, readdir, strpos, substr}  = require(FCPATH + 'lib')


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
# FTP Class
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Libraries
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/libraries/ftp.html
#
class CI_FTP
  
  hostname: ''
  username: ''
  password: ''
  port: 21
  passive: true
  debug: false
  conn_id: false
  
  
  #
  # Constructor - Sets Preferences
  #
  # The constructor can be passed an array of config values
  #
  __construct($config = {})
  {
  if count($config) > 0
    @initialize($config)
    
  
  log_message('debug', "FTP Class Initialized")
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Initialize preferences
  #
  # @access	public
  # @param	array
  # @return	void
  #
  initialize : ($config = {}) ->
    for $key, $val of $config
      if @$key? 
        @$key = $val
        
      
    
    #  Prep the hostname
    @hostname = preg_replace('|.+?://|', '', @hostname)
    
  
  #  --------------------------------------------------------------------
  
  #
  # FTP Connect
  #
  # @access	public
  # @param	array	 the connection values
  # @return	bool
  #
  connect : ($config = {}) ->
    if count($config) > 0
      @initialize($config)
      
    
    if false is (@conn_id = ftp_connect(@hostname, @port))
      if @debug is true
        @_error('ftp_unable_to_connect')
        
      return false
      
    
    if not @_login()
      if @debug is true
        @_error('ftp_unable_to_login')
        
      return false
      
    
    #  Set passive mode if needed
    if @passive is true
      ftp_pasv(@conn_id, true)
      
    
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # FTP Login
  #
  # @access	private
  # @return	bool
  #
  _login :  ->
    return ftp_login(@conn_id, @username, @password)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Validates the connection ID
  #
  # @access	private
  # @return	bool
  #
  _is_conn :  ->
    if not is_resource(@conn_id)
      if @debug is true
        @_error('ftp_no_connection')
        
      return false
      
    return true
    
  
  #  --------------------------------------------------------------------
  
  
  #
  # Change directory
  #
  # The second parameter lets us momentarily turn off debugging so that
  # this function can be used to test for the existence of a folder
  # without throwing an error.  There's no FTP equivalent to is_dir()
  # so we do it by trying to change to a particular directory.
  # Internally, this parameter is only used by the "mirror" function below.
  #
  # @access	public
  # @param	string
  # @param	bool
  # @return	bool
  #
  changedir : ($path = '', $supress_debug = false) ->
    if $path is '' or  not @_is_conn()
      return false
      
    
    $result = ftp_chdir(@conn_id, $path)
    
    if $result is false
      if @debug is true and $supress_debug is false
        @_error('ftp_unable_to_changedir')
        
      return false
      
    
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Create a directory
  #
  # @access	public
  # @param	string
  # @return	bool
  #
  mkdir : ($path = '', $permissions = null) ->
    if $path is '' or  not @_is_conn()
      return false
      
    
    $result = ftp_mkdir(@conn_id, $path)
    
    if $result is false
      if @debug is true
        @_error('ftp_unable_to_makdir')
        
      return false
      
    
    #  Set file permissions if needed
    if not is_null($permissions)
      @chmod($path, $permissions)
      
    
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Upload a file to the server
  #
  # @access	public
  # @param	string
  # @param	string
  # @param	string
  # @return	bool
  #
  upload : ($locpath, $rempath, $mode = 'auto', $permissions = null) ->
    if not @_is_conn()
      return false
      
    
    if not file_exists($locpath)
      @_error('ftp_no_source_file')
      return false
      
    
    #  Set the mode if not specified
    if $mode is 'auto'
      #  Get the file extension so we can set the upload type
      $ext = @_getext($locpath)
      $mode = @_settype($ext)
      
    
    $mode = if ($mode is 'ascii') then FTP_ASCII else FTP_BINARY
    
    $result = ftp_put(@conn_id, $rempath, $locpath, $mode)
    
    if $result is false
      if @debug is true
        @_error('ftp_unable_to_upload')
        
      return false
      
    
    #  Set file permissions if needed
    if not is_null($permissions)
      @chmod($rempath, $permissions)
      
    
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Download a file from a remote server to the local server
  #
  # @access	public
  # @param	string
  # @param	string
  # @param	string
  # @return	bool
  #
  download : ($rempath, $locpath, $mode = 'auto') ->
    if not @_is_conn()
      return false
      
    
    #  Set the mode if not specified
    if $mode is 'auto'
      #  Get the file extension so we can set the upload type
      $ext = @_getext($rempath)
      $mode = @_settype($ext)
      
    
    $mode = if ($mode is 'ascii') then FTP_ASCII else FTP_BINARY
    
    $result = ftp_get(@conn_id, $locpath, $rempath, $mode)
    
    if $result is false
      if @debug is true
        @_error('ftp_unable_to_download')
        
      return false
      
    
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Rename (or move) a file
  #
  # @access	public
  # @param	string
  # @param	string
  # @param	bool
  # @return	bool
  #
  rename : ($old_file, $new_file, $move = false) ->
    if not @_is_conn()
      return false
      
    
    $result = ftp_rename(@conn_id, $old_file, $new_file)
    
    if $result is false
      if @debug is true
        $msg = if ($move is false) then 'ftp_unable_to_rename' else 'ftp_unable_to_move'
        
        @_error($msg)
        
      return false
      
    
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Move a file
  #
  # @access	public
  # @param	string
  # @param	string
  # @return	bool
  #
  move : ($old_file, $new_file) ->
    return @rename($old_file, $new_file, true)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Rename (or move) a file
  #
  # @access	public
  # @param	string
  # @return	bool
  #
  delete_file : ($filepath) ->
    if not @_is_conn()
      return false
      
    
    $result = ftp_delete(@conn_id, $filepath)
    
    if $result is false
      if @debug is true
        @_error('ftp_unable_to_delete')
        
      return false
      
    
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Delete a folder and recursively delete everything (including sub-folders)
  # containted within it.
  #
  # @access	public
  # @param	string
  # @return	bool
  #
  delete_dir : ($filepath) ->
    if not @_is_conn()
      return false
      
    
    #  Add a trailing slash to the file path if needed
    $filepath = preg_replace("/(.+?)\/*$/", "\\1/", $filepath)
    
    $list = @list_files($filepath)
    
    if $list isnt false and count($list) > 0
      for $item in $list
        #  If we can't delete the item it's probaly a folder so
        #  we'll recursively call delete_dir()
        if not ftp_delete(@conn_id, $item)
          @delete_dir($item)
          
        
      
    
    $result = ftp_rmdir(@conn_id, $filepath)
    
    if $result is false
      if @debug is true
        @_error('ftp_unable_to_delete')
        
      return false
      
    
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Set file permissions
  #
  # @access	public
  # @param	string	the file path
  # @param	string	the permissions
  # @return	bool
  #
  chmod : ($path, $perm) ->
    if not @_is_conn()
      return false
      
    
    #  Permissions can only be set when running PHP 5
    if not function_exists('ftp_chmod')
      if @debug is true
        @_error('ftp_unable_to_chmod')
        
      return false
      
    
    $result = ftp_chmod(@conn_id, $perm, $path)
    
    if $result is false
      if @debug is true
        @_error('ftp_unable_to_chmod')
        
      return false
      
    
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # FTP List files in the specified directory
  #
  # @access	public
  # @return	array
  #
  list_files : ($path = '.') ->
    if not @_is_conn()
      return false
      
    
    return ftp_nlist(@conn_id, $path)
    
  
  #  ------------------------------------------------------------------------
  
  #
  # Read a directory and recreate it remotely
  #
  # This function recursively reads a folder and everything it contains (including
  # sub-folders) and creates a mirror via FTP based on it.  Whatever the directory structure
  # of the original file path will be recreated on the server.
  #
  # @access	public
  # @param	string	path to source with trailing slash
  # @param	string	path to destination - include the base folder with trailing slash
  # @return	bool
  #
  mirror : ($locpath, $rempath) ->
    if not @_is_conn()
      return false
      
    
    #  Open the local file path
    if $fp = opendir($locpath)) then if not @changedir($rempath, true)
      #  If it doesn't exist we'll attempt to create the direcotory
      if not @mkdir($rempath) or  not @changedir($rempath)
        return false
        
      while false isnt ($file = readdir($fp))
      if is_dir($locpath + $file) and substr($file, 0, 1) isnt '.'
        @mirror($locpath + $file + "/", $rempath + $file + "/")
        
      else if substr($file, 0, 1) isnt "."
        #  Get the file extension so we can se the upload type
        $ext = @_getext($file)
        $mode = @_settype($ext)
        
        @upload($locpath + $file, $rempath + $file, $mode)
        
      return true}return false}_getext : ($filename) ->
      if false is strpos($filename, '.')
        return 'txt'
        
      
      $x = explode('.', $filename)
      return end($x)
      _settype : ($ext) ->
      $text_types = [
        'txt', 
        'text', 
        'php', 
        'phps', 
        'php4', 
        'js', 
        'css', 
        'htm', 
        'html', 
        'phtml', 
        'shtml', 
        'log', 
        'xml'
        ]
      
      
      return if (in_array($ext, $text_types)) then 'ascii' else 'binary'
      close :  ->
      if not @_is_conn()
        return false
        
      
      ftp_close(@conn_id)
      _error : ($line) ->
      $CI = Exspresso
      $CI.lang.load('ftp')
      show_error($CI.lang.line($line))
      }#  Attempt to open the remote file path.#  Recursively read the local directory#  --------------------------------------------------------------------#
    # Extract the file extension
    #
    # @access	private
    # @param	string
    # @return	string
    ##  --------------------------------------------------------------------#
    # Set the upload type
    #
    # @access	private
    # @param	string
    # @return	string
    ##  ------------------------------------------------------------------------#
    # Close the connection
    #
    # @access	public
    # @param	string	path to source
    # @param	string	path to destination
    # @return	bool
    ##  ------------------------------------------------------------------------#
    # Display error message
    #
    # @access	private
    # @param	string
    # @return	bool
    ##  END FTP Class#  End of file Ftp.php #  Location: ./system/libraries/Ftp.php 

register_class 'CI_FTP', CI_FTP
module.exports = CI_FTP