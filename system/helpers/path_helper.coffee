#+--------------------------------------------------------------------+
#  path_helper.coffee
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
# Exspresso Path Helpers
#
#

#
# Set Realpath
#
# @param  [String]  # @return	[Boolean]	checks to see if the path exists
# @return	[String]
#
exports.set_realpath = set_realpath = ($path, $check_existance = false) ->
  #  Security check to make sure the path is NOT a URL.  No remote file inclusion!
  #if preg_match("#^(http:\/\/|https:\/\/|www\.|ftp|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})#i", $path)
  if /^(http:\/\/|https:\/\/|www\.|ftp|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})/i.test($path)
    show_error('The path you submitted must be a local server path, not a URL')


  #  Resolve the path
  if realpath($path) isnt false
    $path = realpath($path) + '/'


  #  Add a trailing slash
  $path = $path.replace(/([^\/])\/*$/, "$1/")

  #  Make sure the path exists
  if $check_existance is true
    if not is_dir($path)
      show_error('Not a valid path: %s', $path)



  return $path


#  ------------------------------------------------------------------------
#
# Export helpers to the global namespace
#
#
for $name, $body of module.exports
  define $name, $body

