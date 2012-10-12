#+--------------------------------------------------------------------+
#  Log.coffee
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
{__construct, chmod, date, defined, fclose, file_exists, flock, fopen, fwrite, is_dir, is_numeric, strtoupper, write_log}  = require(FCPATH + 'lib')
{config_item, get_class, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

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
# Logging Class
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Logging
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/general/errors.html
#
class CI_Log
  
  _log_path: {}
  _threshold: 1
  _date_fmt: 'Y-m-d H:i:s'
  _enabled: true
  _levels: 'ERROR':'1', 'DEBUG':'2', 'INFO':'3', 'ALL':'4'
  
  #
  # Constructor
  #
  __construct()
  {
  $config = get_config()
  
  @_log_path = if ($config['log_path'] isnt '') then $config['log_path'] else APPPATH + 'logs/'
  
  if not is_dir(@_log_path) or  not is_really_writable(@_log_path)
    @_enabled = false
    
  
  if is_numeric($config['log_threshold'])
    @_threshold = $config['log_threshold']
    
  
  if $config['log_date_format'] isnt ''
    @_date_fmt = $config['log_date_format']
    
  }
  
  #  --------------------------------------------------------------------
  
  #
  # Write Log File
  #
  # Generally this function will be called using the global log_message() function
  #
  # @param	string	the error level
  # @param	string	the error message
  # @param	bool	whether the error is a native PHP error
  # @return	bool
  #
  write_log($level = 'error',$msg, $php_error = false)
  {
  if @_enabled is false
    return false
    
  
  $level = strtoupper($level)
  
  if not @_levels[$level]?  or (@_levels[$level] > @_threshold)
    return false
    
  
  $filepath = @_log_path + 'log-' + date('Y-m-d') + EXT
  $message = ''
  
  if not file_exists($filepath)
    $message+="<" + "?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed'); ?" + ">\n\n"
    
  
  if not $fp = fopen($filepath, FOPEN_WRITE_CREATE)) then return false}$message+=$level + ' ' + (($level is 'INFO') then ' -' else '-') + ' ' + date(@_date_fmt) + ' --> ' + $msg + "\n"
  
  flock($fp, LOCK_EX)
  fwrite($fp, $message)
  flock($fp, LOCK_UN)
  fclose($fp)
  
  chmod($filepath, FILE_WRITE_MODE)
  return true
  }
  
  

register_class 'CI_Log', CI_Log
module.exports = CI_Log
#  END Log Class

#  End of file Log.php 
#  Location: ./system/libraries/Log.php 