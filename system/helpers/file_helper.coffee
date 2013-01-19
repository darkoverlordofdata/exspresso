#+--------------------------------------------------------------------+
#  file_helper.coffee
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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package		Exspresso
# @author		darkoverlordofdata
# @copyright	Copyright (c) 2012, Dark Overlord of Data
# @license		MIT License
# @link		http://darkoverlordofdata.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# Exspresso File Helpers
#
# @package		Exspresso
# @subpackage	Helpers
# @category	Helpers
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/helpers/file_helpers.html
#

#  ------------------------------------------------------------------------

#
# Read File
#
# Opens the file specfied in the path and returns it as a string.
#
# @access	public
# @param	string	path to file
# @return	string
#
if not function_exists('read_file')
  exports.read_file = read_file = ($file) ->
    if not file_exists($file)
      return false
      
    
    if function_exists('file_get_contents')
      return file_get_contents($file)
      
    
    if not ($fp = fopen($file, FOPEN_READ)) then return false
    flock($fp, LOCK_SH)
    
    $data = ''
    if filesize($file) > 0
      $data = fread($fp, filesize($file))
      
    
    flock($fp, LOCK_UN)
    fclose($fp)
    
    return $data
    
  

#  ------------------------------------------------------------------------

#
# Write File
#
# Writes data to the file specified in the path.
# Creates a new file if non-existent.
#
# @access	public
# @param	string	path to file
# @param	string	file data
# @return	bool
#
if not function_exists('write_file')
  exports.write_file = write_file = ($path, $data, $mode = FOPEN_WRITE_CREATE_DESTRUCTIVE) ->
    if not $fp = fopen($path, $mode)) then return false}flock($fp, LOCK_EX)
    fwrite($fp, $data)
    flock($fp, LOCK_UN)
    fclose($fp)
    
    return true
    
  

#  ------------------------------------------------------------------------

#
# Delete Files
#
# Deletes all files contained in the supplied directory path.
# Files must be writable or owned by the system in order to be deleted.
# If the second parameter is set to TRUE, any directories contained
# within the supplied base directory will be nuked as well.
#
# @access	public
# @param	string	path to file
# @param	bool	whether to delete any directories found in the path
# @return	bool
#
if not function_exists('delete_files')
  exports.delete_files = delete_files = ($path, $del_dir = false, $level = 0) ->
    #  Trim the trailing slash
    $path = rtrim($path, DIRECTORY_SEPARATOR)
    
    if not $current_dir = opendir($path)) then return false}while false isnt ($filename = readdir($current_dir))
      if $filename isnt "." and $filename isnt ".."
        if is_dir($path + DIRECTORY_SEPARATOR + $filename)
          #  Ignore empty folders
          if substr($filename, 0, 1) isnt '.'
            delete_files($path + DIRECTORY_SEPARATOR + $filename, $del_dir, $level + 1)
            
          
        else 
          unlink($path + DIRECTORY_SEPARATOR + $filename)
          
        
      closedir($current_dir)
    
    if $del_dir is true and $level > 0
      return rmdir($path)
      
    
    return true
    
  

#  ------------------------------------------------------------------------

#
# Get Filenames
#
# Reads the specified directory and builds an array containing the filenames.
# Any sub-folders contained within the specified path are read as well.
#
# @access	public
# @param	string	path to source
# @param	bool	whether to include the path as part of the filename
# @param	bool	internal variable to determine recursion status - do not use in calls
# @return	array
#
$_filedata = {}
if not function_exists('get_filenames')
  exports.get_filenames = get_filenames = ($source_dir, $include_path = false, $_recursion = false) ->

    if $fp = opendir($source_dir)) then if $_recursion is false
      $_filedata = {}
      $source_dir = rtrim(realpath($source_dir), DIRECTORY_SEPARATOR) + DIRECTORY_SEPARATOR
      while false isnt ($file = readdir($fp))
      if is_dir($source_dir + $file) and strncmp($file, '.', 1) isnt 0
        get_filenames($source_dir + $file + DIRECTORY_SEPARATOR, $include_path, true)
        
      else if strncmp($file, '.', 1) isnt 0
        $_filedata.push ($include_path is true) then $source_dir + $file else $file
        
      return $_filedata}else 
      return false
      }}if not function_exists('get_dir_file_info')
      exports.get_dir_file_info = get_dir_file_info = ($source_dir, $top_level_only = true, $_recursion = false) ->
        $relative_path = $source_dir
        
        if $fp = opendir($source_dir)) then if $_recursion is false
          $_filedata = {}
          $source_dir = rtrim(realpath($source_dir), DIRECTORY_SEPARATOR) + DIRECTORY_SEPARATOR
          while false isnt ($file = readdir($fp))
          if is_dir($source_dir + $file) and strncmp($file, '.', 1) isnt 0 and $top_level_only is false
            get_dir_file_info($source_dir + $file + DIRECTORY_SEPARATOR, $top_level_only, true)
            
          else if strncmp($file, '.', 1) isnt 0
            $_filedata[$file] = get_file_info($source_dir + $file)
            $_filedata[$file]['relative_path'] = $relative_path
            
          return $_filedata}else 
          return false
          }}if not function_exists('get_file_info')
          exports.get_file_info = get_file_info = ($file, $returned_values = ['name', 'server_path', 'size', 'date']) ->
            
            if not file_exists($file)
              return false
              
            
            if is_string($returned_values)
              $returned_values = explode(',', $returned_values)
              
            
            for $key in $returned_values
              switch $key
                when 'name'
                  $fileinfo['name'] = substr(strrchr($file, DIRECTORY_SEPARATOR), 1)
                  
                when 'server_path'
                  $fileinfo['server_path'] = $file
                  
                when 'size'
                  $fileinfo['size'] = filesize($file)
                  
                when 'date'
                  $fileinfo['date'] = filemtime($file)
                  
                when 'readable'
                  $fileinfo['readable'] = is_readable($file)
                  
                when 'writable'#  There are known problems using is_weritable on IIS.  It may not be reliable - consider fileperms()
                  #  There are known problems using is_weritable on IIS.  It may not be reliable - consider fileperms()
                  $fileinfo['writable'] = is_writable($file)
                  
                when 'executable'
                  $fileinfo['executable'] = is_executable($file)
                  
                when 'fileperms'
                  $fileinfo['fileperms'] = fileperms($file)
                  
                  
              
            
            return $fileinfo
            
          if not function_exists('get_mime_by_extension')
          exports.get_mime_by_extension = get_mime_by_extension = ($file) ->
            $extension = strtolower(substr(strrchr($file, '.'), 1))
            
            exports.$mimes
            
            if not is_array($mimes)
              if defined('ENVIRONMENT') and is_file(APPPATH + 'config/' + ENVIRONMENT + '/mimes' + EXT)
                require(APPPATH + 'config/' + ENVIRONMENT + '/mimes' + EXT)
                
              else if is_file(APPPATH + 'config/mimes' + EXT)
                require(APPPATH + 'config/mimes' + EXT)
                
              
              if not is_array($mimes)
                return false
                
              
            
            if array_key_exists($extension, $mimes)
              if is_array($mimes[$extension])
                #  Multiple mime types, just give the first one
                return current($mimes[$extension])
                
              else 
                return $mimes[$extension]
                
              
            else 
              return false
              
            
          if not function_exists('symbolic_permissions')
          exports.symbolic_permissions = symbolic_permissions = ($perms) ->
            if ($perms and 0o0xC000) is 0o0xC000
              $symbolic = 's'#  Socket
              
            else if ($perms and 0o0xA000) is 0o0xA000
              $symbolic = 'l'#  Symbolic Link
              
            else if ($perms and 0o0x8000) is 0o0x8000
              $symbolic = '-'#  Regular
              
            else if ($perms and 0o0x6000) is 0o0x6000
              $symbolic = 'b'#  Block special
              
            else if ($perms and 0o0x4000) is 0o0x4000
              $symbolic = 'd'#  Directory
              
            else if ($perms and 0o0x2000) is 0o0x2000
              $symbolic = 'c'#  Character special
              
            else if ($perms and 0o0x1000) is 0o0x1000
              $symbolic = 'p'#  FIFO pipe
              
            else 
              $symbolic = 'u'#  Unknown
              
            
            #  Owner
            $symbolic+=(($perms and 0o0x0100) then 'r' else '-')
            $symbolic+=(($perms and 0o0x0080) then 'w' else '-')
            $symbolic+=(($perms and 0o0x0040) then (($perms and 0o0x0800) then 's' else 'x') else (($perms and 0o0x0800) then 'S' else '-'))
            
            #  Group
            $symbolic+=(($perms and 0o0x0020) then 'r' else '-')
            $symbolic+=(($perms and 0o0x0010) then 'w' else '-')
            $symbolic+=(($perms and 0o0x0008) then (($perms and 0o0x0400) then 's' else 'x') else (($perms and 0o0x0400) then 'S' else '-'))
            
            #  World
            $symbolic+=(($perms and 0o0x0004) then 'r' else '-')
            $symbolic+=(($perms and 0o0x0002) then 'w' else '-')
            $symbolic+=(($perms and 0o0x0001) then (($perms and 0o0x0200) then 't' else 'x') else (($perms and 0o0x0200) then 'T' else '-'))
            
            return $symbolic
            
          if not function_exists('octal_permissions')
          exports.octal_permissions = octal_permissions = ($perms) ->
            return substr(sprintf('%o', $perms),  - 3)
            
          #  reset the array and make sure $source_dir has a trailing slash on the initial call#  foreach (scandir($source_dir, 1) as $file) // In addition to being PHP5+, scandir() is simply not as fast#  --------------------------------------------------------------------#
        # Get File Info
        #
        # Given a file and path, returns the name, path, size, date modified
        # Second parameter allows you to explicitly declare what information you want returned
        # Options are: name, server_path, size, date, readable, writable, executable, fileperms
        # Returns FALSE if the file cannot be found.
        #
        # @access	public
        # @param	string	path to file
        # @param	mixed	array or comma separated string of information returned
        # @return	array
        ##  --------------------------------------------------------------------#
        # Get Mime by Extension
        #
        # Translates a file extension into a mime type based on config/mimes.php.
        # Returns FALSE if it can't determine the type, or open the mime config file
        #
        # Note: this is NOT an accurate way of determining file mime types, and is here strictly as a convenience
        # It should NOT be trusted, and should certainly NOT be used for security
        #
        # @access	public
        # @param	string	path to file
        # @return	mixed
        ##  --------------------------------------------------------------------#
        # Symbolic Permissions
        #
        # Takes a numeric value representing a file's permissions and returns
        # standard symbolic notation representing that value
        #
        # @access	public
        # @param	int
        # @return	string
        ##  --------------------------------------------------------------------#
        # Octal Permissions
        #
        # Takes a numeric value representing a file's permissions and returns
        # a three character string representing the file's octal permissions
        #
        # @access	public
        # @param	int
        # @return	string
        ##  End of file file_helper.php #  Location: ./system/helpers/file_helper.php #  reset the array and make sure $source_dir has a trailing slash on the initial call#  --------------------------------------------------------------------#
    # Get Directory File Information
    #
    # Reads the specified directory and builds an array containing the filenames,
    # filesize, dates, and permissions
    #
    # Any sub-folders contained within the specified path are read as well.
    #
    # @access	public
    # @param	string	path to source
    # @param	bool	Look only at the top level directory specified?
    # @param	bool	internal variable to determine recursion status - do not use in calls
    # @return	array
    #