#+--------------------------------------------------------------------+
#  download_helper.coffee
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
# Exspresso Download Helpers
#
#
fs = require('fs')
#
# Force Download
#
# Generates headers that force a download to happen
#
# @param  [String]  filename
# @param  [Mixed]  the data to be downloaded
# @return [Void]
#
exports.force_download = force_download = ($filename = '', $data = '') ->
  if $filename is '' or $data is ''
    return false

  #  Try to determine if the filename includes a file extension.
  #  We need it in order to set the MIME type
  if $filename.indexOf('.') is -1
    return false

  #  Grab the file extension
  $extension = $filename.split('.').pop()

  #  Load the mime types
  if fs.existsSync(APPPATH + 'config/' + ENVIRONMENT + '/mimes.coffee')
    $mimes = require(APPPATH + 'config/' + ENVIRONMENT + '/mimes.coffee')

  else if fs.existsSync(APPPATH + 'config/mimes.coffee')
    $mimes = require(APPPATH + 'config/mimes.coffee')


  #  Set a default mime if we can't find it
  if not $mimes[$extension]?
    $mime = 'application/octet-stream'

  else
    $mime = if (Array.isArray($mimes[$extension])) then $mimes[$extension][0] else $mimes[$extension]


  #  Generate the server headers
  if @req.server['HTTP_USER_AGENT'].indexOf("MSIE") isnt -1
    @res.header('Content-Type: "' + $mime + '"')
    @res.header('Content-Disposition: attachment; filename="' + $filename + '"')
    @res.header('Expires: 0')
    @res.header('Cache-Control: must-revalidate, post-check=0, pre-check=0')
    @res.header("Content-Transfer-Encoding: binary")
    @res.header('Pragma: public')
    @res.header("Content-Length: " + strlen($data))

  else
    @res.header('Content-Type: "' + $mime + '"')
    @res.header('Content-Disposition: attachment; filename="' + $filename + '"')
    @res.header("Content-Transfer-Encoding: binary")
    @res.header('Expires: 0')
    @res.header('Pragma: no-cache')
    @res.header("Content-Length: " + strlen($data))


  @res.writeHead 200,
                 'Content-Length'  : $data.length
                 'Content-Type'    : 'text/html; charset=utf-8'
  @res.end $data

