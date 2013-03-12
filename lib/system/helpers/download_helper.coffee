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
# Exspresso Download Helpers
#
#

#  ------------------------------------------------------------------------

#
# Force Download
#
# Generates headers that force a download to happen
#
# @param  [String]  filename
# @param  [Mixed]  the data to be downloaded
# @return [Void]  #
if not function_exists('force_download')
  exports.force_download = force_download = ($filename = '', $data = '') ->
    if $filename is '' or $data is ''
      return false
    
    #  Try to determine if the filename includes a file extension.
    #  We need it in order to set the MIME type
    if false is strpos($filename, '.')
      return false
      
    #  Grab the file extension
    $x = explode('.', $filename)
    $extension = end($x)
    
    #  Load the mime types
    if defined('ENVIRONMENT') and is_file(APPPATH + 'config/' + ENVIRONMENT + '/mimes' + EXT)
      $mimes = require(APPPATH + 'config/' + ENVIRONMENT + '/mimes' + EXT)
      
    else if is_file(APPPATH + 'config/mimes' + EXT)
      $mimes = require(APPPATH + 'config/mimes' + EXT)
      
    
    #  Set a default mime if we can't find it
    if not $mimes[$extension]? 
      $mime = 'application/octet-stream'
      
    else 
      $mime = if (is_array($mimes[$extension])) then $mimes[$extension][0] else $mimes[$extension]
      
    
    #  Generate the server headers
    if strpos(@req,server['HTTP_USER_AGENT'], "MSIE") isnt false
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

  


#  End of file download_helper.php 
#  Location: ./system/helpers/download_helper.php 