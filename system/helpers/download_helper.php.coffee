#+--------------------------------------------------------------------+
#  download_helper.coffee
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
{defined, end, explode, function_exists, header, is_array, is_file, strlen, strpos}  = require(FCPATH + 'lib')


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
# CodeIgniter Download Helpers
#
# @package		CodeIgniter
# @subpackage	Helpers
# @category	Helpers
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/helpers/download_helper.html
#

#  ------------------------------------------------------------------------

#
# Force Download
#
# Generates headers that force a download to happen
#
# @access	public
# @param	string	filename
# @param	mixed	the data to be downloaded
# @return	void
#
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
      require(APPPATH + 'config/' + ENVIRONMENT + '/mimes' + EXT)
      
    else if is_file(APPPATH + 'config/mimes' + EXT)
      require(APPPATH + 'config/mimes' + EXT)
      
    
    #  Set a default mime if we can't find it
    if not $mimes[$extension]? 
      $mime = 'application/octet-stream'
      
    else 
      $mime = if (is_array($mimes[$extension])) then $mimes[$extension][0] else $mimes[$extension]
      
    
    #  Generate the server headers
    if strpos($_SERVER['HTTP_USER_AGENT'], "MSIE") isnt false
      header('Content-Type: "' + $mime + '"')
      header('Content-Disposition: attachment; filename="' + $filename + '"')
      header('Expires: 0')
      header('Cache-Control: must-revalidate, post-check=0, pre-check=0')
      header("Content-Transfer-Encoding: binary")
      header('Pragma: public')
      header("Content-Length: " + strlen($data))
      
    else 
      header('Content-Type: "' + $mime + '"')
      header('Content-Disposition: attachment; filename="' + $filename + '"')
      header("Content-Transfer-Encoding: binary")
      header('Expires: 0')
      header('Pragma: no-cache')
      header("Content-Length: " + strlen($data))
      
    
    die $data
    
  


#  End of file download_helper.php 
#  Location: ./system/helpers/download_helper.php 