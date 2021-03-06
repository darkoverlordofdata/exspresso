#+--------------------------------------------------------------------+
#  Ftp.coffee
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
# FTP Class
#
module exports = class system.lib.Ftp

  ftp = require('ftp')

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
  constructor: ($controller, $config = {}) ->
    if count($config) > 0
      @initialize($config)


    log_message('debug', "FTP Class Initialized")

  #
  # Initialize preferences
  #
    # @param  [Array]  # @return [Void]  #
  initialize : ($config = {}) ->
    for $key, $val of $config
      if @$key? 
        @$key = $val
        
      
    
    #  Prep the hostname
    @hostname = preg_replace('|.+?://|', '', @hostname)
    
  
  #
  # FTP Connect
  #
    # @param  [Array]  the connection values
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
    
  
  #
  # FTP Login
  #
  # @private
  # @return	bool
  #
  _login :  ->
    return ftp_login(@conn_id, @username, @password)
    
  
  #
  # Validates the connection ID
  #
  # @private
  # @return	bool
  #
  _is_conn :  ->
    if not is_resource(@conn_id)
      if @debug is true
        @_error('ftp_no_connection')
        
      return false
      
    return true
    
  

  #
  # Change directory
  #
  # The second parameter lets us momentarily turn off debugging so that
  # this function can be used to test for the existence of a folder
  # without throwing an error.  There's no FTP equivalent to is_dir()
  # so we do it by trying to change to a particular directory.
  # Internally, this parameter is only used by the "mirror" function below.
  #
    # @param  [String]    # @return	[Boolean]
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
    
  
  #
  # Create a directory
  #
    # @param  [String]    # @return	bool
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
    
  
  #
  # Upload a file to the server
  #
    # @param  [String]    # @param  [String]    # @param  [String]    # @return	bool
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
    
  
  #
  # Download a file from a remote server to the local server
  #
    # @param  [String]    # @param  [String]    # @param  [String]    # @return	bool
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
    
  
  #
  # Rename (or move) a file
  #
    # @param  [String]    # @param  [String]    # @return	[Boolean]
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
    
  
  #
  # Move a file
  #
    # @param  [String]    # @param  [String]    # @return	bool
  #
  move : ($old_file, $new_file) ->
    return @rename($old_file, $new_file, true)
    
  
  #
  # Rename (or move) a file
  #
    # @param  [String]    # @return	bool
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
    
  
  #
  # Delete a folder and recursively delete everything (including sub-folders)
  # containted within it.
  #
    # @param  [String]    # @return	bool
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
    
  
  #
  # Set file permissions
  #
    # @param  [String]  the file path
  # @param  [String]  the permissions
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
    
  
  #
  # FTP List files in the specified directory
  #
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
    # @param  [String]  path to source with trailing slash
  # @param  [String]  path to destination - include the base folder with trailing slash
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
      $controller = Exspresso
      $controller.lang.load('ftp')
      show_error($controller.lang.line($line))
      }#  Attempt to open the remote file path.#  Recursively read the local directory#  --------------------------------------------------------------------#
    # Extract the file extension
    #
    # @private
    # @param  [String]      # @return	[String]
    ##  --------------------------------------------------------------------#
    # Set the upload type
    #
    # @private
    # @param  [String]      # @return	[String]
    ##  ------------------------------------------------------------------------#
    # Close the connection
    #
        # @param  [String]  path to source
    # @param  [String]  path to destination
    # @return	bool
    ##  ------------------------------------------------------------------------#
    # Display error message
    #
    # @private
    # @param  [String]      # @return	bool
    ##  END FTP Class#  End of file Ftp.php #  Location: ./system/lib/Ftp.php

