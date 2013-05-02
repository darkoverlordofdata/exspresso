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
# Exspresso Directory Helpers
#
#

fs = require('fs')
path = require('path')
DIRECTORY_SEPARATOR = path.sep

#
# Create a Directory Map
#
# Reads the specified directory and builds an array
# representation of it.  Sub-folders contained with the
# directory are mapped by treating the array as a hash
#
# @param  [String]  path to source
# @param	int		depth of directories to traverse (0 = fully recursive, 1 = current dir, etc)
# @return	array
#
exports.directory_map = directory_map = ($source_dir, $directory_depth = 0, $hidden = false) ->

  if is_dir($source_dir)

    $filedata = []
    $new_depth = $directory_depth - 1
    $source_dir = rtrim($source_dir, DIRECTORY_SEPARATOR) + DIRECTORY_SEPARATOR

    for $file in fs.readdirSync($source_dir)
      #  Remove '.', '..', and hidden files [optional]
      if not trim($file, '.') or ($hidden is false and $file[0] is '.')
        continue

      if ($directory_depth < 1 or $new_depth > 0) and is_dir($source_dir + $file)
        $filedata[$file] = directory_map($source_dir + $file + DIRECTORY_SEPARATOR, $new_depth, $hidden)

      else
        $filedata.push $file

    return $filedata
  else
    return false

for $name, $body of module.exports
  define $name, $body
