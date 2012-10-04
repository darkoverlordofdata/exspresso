#+--------------------------------------------------------------------+
#  Sha1.coffee
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
{__construct, bindec, count, decbin, dechex, defined, ord, strlen, substr}  = require(FCPATH + 'pal')
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
# SHA1 Encoding Class
#
# Purpose: Provides 160 bit hashing using The Secure Hash Algorithm
# developed at the National Institute of Standards and Technology. The 40
# character SHA1 message hash is computationally infeasible to crack.
#
# This class is a fallback for servers that are not running PHP greater than
# 4.3, or do not have the MHASH library.
#
# This class is based on two scripts:
#
# Marcus Campbell's PHP implementation (GNU license)
# http://www.tecknik.net/sha-1/
#
# ...which is based on Paul Johnston's JavaScript version
# (BSD license). http://pajhome.org.uk/
#
# I encapsulated the functions and wrote one additional method to fix
# a hex conversion bug. - Rick Ellis
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Encryption
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/general/encryption.html
#
class CI_SHA1
  
  __construct()
  {
  log_message('debug', "SHA1 Class Initialized")
  }
  
  #
  # Generate the Hash
  #
  # @access	public
  # @param	string
  # @return	string
  #
  generate : ($str) ->
    $n = ((strlen($str) + 8)>>6) + 1
    
    for ($i = 0$i < $n * 16$i++)
    {
    $x[$i] = 0
    }
    
    for ($i = 0$i < strlen($str)$i++)
    {
    $x[$i>>2]|=ord(substr($str, $i, 1))<<(24 - ($i4) * 8)
    }
    
    $x[$i>>2]|=0o0x80<<(24 - ($i4) * 8)
    
    $x[$n * 16 - 1] = strlen($str) * 8
    
    $a = 1732584193
    $b =  - 271733879
    $c =  - 1732584194
    $d = 271733878
    $e =  - 1009589776
    
    for ($i = 0$i < count($x)$i+=16)
    {
    $olda = $a
    $oldb = $b
    $oldc = $c
    $oldd = $d
    $olde = $e
    
    for ($j = 0$j < 80$j++)
    {
    if $j < 16
      $w[$j] = $x[$i + $j]
      
    else 
      $w[$j] = @_rol($w[$j - 3]$w[$j - 8]$w[$j - 14]$w[$j - 16], 1)
      
    
    $t = @_safe_add(@_safe_add(@_rol($a, 5), @_ft($j, $b, $c, $d)), @_safe_add(@_safe_add($e, $w[$j]), @_kt($j)))
    
    $e = $d
    $d = $c
    $c = @_rol($b, 30)
    $b = $a
    $a = $t
    }
    
    $a = @_safe_add($a, $olda)
    $b = @_safe_add($b, $oldb)
    $c = @_safe_add($c, $oldc)
    $d = @_safe_add($d, $oldd)
    $e = @_safe_add($e, $olde)
    }
    
    return @_hex($a) + @_hex($b) + @_hex($c) + @_hex($d) + @_hex($e)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Convert a decimal to hex
  #
  # @access	private
  # @param	string
  # @return	string
  #
  _hex : ($str) ->
    $str = dechex($str)
    
    if strlen($str) is 7
      $str = '0' + $str
      
    
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  #  Return result based on iteration
  #
  # @access	private
  # @return	string
  #
  _ft : ($t, $b, $c, $d) ->
    if $t < 20 then return ($b and $c) or (($b) and $d)if $t < 40 then return $b$c$dif $t < 60 then return ($b and $c) or ($b and $d) or ($c and $d)return $b$c$d}_kt : ($t) ->
      if $t < 20
        return 1518500249
        
      else if $t < 40
        return 1859775393
        
      else if $t < 60
        return  - 1894007588
        
      else 
        return  - 899497514
        
      _safe_add : ($x, $y) ->
      $lsw = ($x and 0o0xFFFF) + ($y and 0o0xFFFF)
      $msw = ($x>>16) + ($y>>16) + ($lsw>>16)
      
      return ($msw<<16) or ($lsw and 0o0xFFFF)
      _rol : ($num, $cnt) ->
      return ($num<<$cnt) or @_zero_fill($num, 32 - $cnt)
      _zero_fill : ($a, $b) ->
      $bin = decbin($a)
      
      if strlen($bin) < $b
        $bin = 0
        
      else 
        $bin = substr($bin, 0, strlen($bin) - $b)
        
      
      for ($i = 0$i < $b$i++)
      {
      $bin = "0" + $bin
      }
      
      return bindec($bin)
      }#  --------------------------------------------------------------------#
    # Determine the additive constant
    #
    # @access	private
    # @return	string
    ##  --------------------------------------------------------------------#
    # Add integers, wrapping at 2^32
    #
    # @access	private
    # @return	string
    ##  --------------------------------------------------------------------#
    # Bitwise rotate a 32-bit number
    #
    # @access	private
    # @return	integer
    ##  --------------------------------------------------------------------#
    # Pad string with zero
    #
    # @access	private
    # @return	string
    ##  END CI_SHA#  End of file Sha1.php #  Location: ./system/libraries/Sha1.php 

register_class 'CI_SHA1', CI_SHA1
module.exports = CI_SHA1