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
    $source_dir = rtrim($source_dir, DIRECTORY_SEPARATOR) + DIRECTORY_SEPARATOR

    for $file in fs.readdirSync($source_dir)
      #  Remove '.', '..', and hidden files [optional]
      if trim($file, '.').length is 0 or ($hidden is false and $file[0] is '.')
        continue

      if is_dir($source_dir + $file)
        if $directory_depth < 1
          $filedata[$file] = directory_map($source_dir + $file + DIRECTORY_SEPARATOR, $directory_depth - 1, $hidden)

      else
        #$filedata.push $file
        $filedata[$file] = $file

    return $filedata
  else
    return false

for $name, $body of module.exports
  define $name, $body
