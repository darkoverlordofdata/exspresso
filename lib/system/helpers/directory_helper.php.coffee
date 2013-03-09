#+--------------------------------------------------------------------+
#  directory_helper.coffee
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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
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
# Exspresso Directory Helpers
#
#

fs = require('fs')
#  ------------------------------------------------------------------------

#
# Create a Directory Map
#
# Reads the specified directory and builds an array
# representation of it.  Sub-folders contained with the
# directory will be mapped as well.
#
# @param  [String]  path to source
# @param	int		depth of directories to traverse (0 = fully recursive, 1 = current dir, etc)
# @return	array
#
if not function_exists('directory_map')
  exports.directory_map = directory_map = ($source_dir, $directory_depth = 0, $hidden = false, $filedata = {}) ->
    if is_dir($source_dir)
      $new_depth = $directory_depth - 1
      $source_dir = rtrim($source_dir, DIRECTORY_SEPARATOR) + DIRECTORY_SEPARATOR
      for $file in fs.readdirSync($source_dir)
        #  Remove '.', '..', and hidden files [optional]
        if not trim($file, '.') or ($hidden is false and $file[0] is '.')
          continue

        if ($directory_depth < 1 or $new_depth > 0) and is_dir($source_dir + $file)
          $filedata[$file] = directory_map($source_dir + $file + DIRECTORY_SEPARATOR, $new_depth, $hidden, $filedata)

        else
          $filedata.push $file

      return $filedata
    else
      return false


#  ------------------------------------------------------------------------
#
# Export helpers to the global namespace
#
#
for $name, $body of module.exports
  define $name, $body


#  End of file directory_helper.php 
#  Location: ./system/helpers/directory_helper.php 