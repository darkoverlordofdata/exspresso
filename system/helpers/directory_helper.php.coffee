#+--------------------------------------------------------------------+
#  directory_helper.coffee
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
{closedir, defined, function_exists, is_dir, opendir, readdir, rtrim, trim}  = require(FCPATH + 'lib')


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
# CodeIgniter Directory Helpers
#
# @package		CodeIgniter
# @subpackage	Helpers
# @category	Helpers
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/helpers/directory_helper.html
#

#  ------------------------------------------------------------------------

#
# Create a Directory Map
#
# Reads the specified directory and builds an array
# representation of it.  Sub-folders contained with the
# directory will be mapped as well.
#
# @access	public
# @param	string	path to source
# @param	int		depth of directories to traverse (0 = fully recursive, 1 = current dir, etc)
# @return	array
#
if not function_exists('directory_map')
  exports.directory_map = directory_map = ($source_dir, $directory_depth = 0, $hidden = false) ->
    if $fp = opendir($source_dir)) then $filedata = {}$new_depth = $directory_depth - 1$source_dir = rtrim($source_dir, DIRECTORY_SEPARATOR) + DIRECTORY_SEPARATORwhile false isnt ($file = readdir($fp))
      #  Remove '.', '..', and hidden files [optional]
      if not trim($file, '.') or ($hidden is false and $file[0] is '.')
        continue
        
      
      if ($directory_depth < 1 or $new_depth > 0) and is_dir($source_dir + $file)
        $filedata[$file] = directory_map($source_dir + $file + DIRECTORY_SEPARATOR, $new_depth, $hidden)
        
      else 
        $filedata.push $file
        
      closedir($fp)
    return $filedata
    }
    
    return false
    
  


#  End of file directory_helper.php 
#  Location: ./system/helpers/directory_helper.php 