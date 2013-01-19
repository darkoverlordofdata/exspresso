#+--------------------------------------------------------------------+
#  Cache_dummy.coffee
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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#


{cache_info, clean, defined, delete, get, get_metadata, is_supported, save}  = require(FCPATH + 'lib')


if not defined('BASEPATH') then die 'No direct script access allowed'
#
# Exspresso
#
# An open source application development framework for PHP 4.3.2 or newer
#
# @package		Exspresso
# @author		darkoverlordofdata
# @copyright	Copyright (c) 2006 - 2011 EllisLab, Inc.
# @license		MIT License
# @link		http://darkoverlordofdata.com
# @since		Version 2.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# Exspresso Dummy Caching Class
#
# @package		Exspresso
# @subpackage	Libraries
# @category	Core
# @author		darkoverlordofdata
# @link
#

class Exspresso_Cache_dummy extends Exspresso_Driver
  
  #
  # Get
  #
  # Since this is the dummy class, it's always going to return FALSE.
  #
  # @param 	string
  # @return 	Boolean		FALSE
  #
  get($id)
  {
  return false
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Cache Save
  #
  # @param 	string		Unique Key
  # @param 	mixed		Data to store
  # @param 	int			Length of time (in seconds) to cache the data
  #
  # @return 	boolean		TRUE, Simulating success
  #
  save($id, $data, $ttl = 60)
  {
  return true
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Delete from Cache
  #
  # @param 	mixed		unique identifier of the item in the cache
  # @param 	boolean		TRUE, simulating success
  #
  delete($id)
  {
  return true
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Clean the cache
  #
  # @return 	boolean		TRUE, simulating success
  #
  clean()
  {
  return true
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Cache Info
  #
  # @param 	string		user/filehits
  # @return 	boolean		FALSE
  #
  cache_info($type = null)
  {
  return false
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Get Cache Metadata
  #
  # @param 	mixed		key to get cache metadata on
  # @return 	boolean		FALSE
  #
  get_metadata($id)
  {
  return false
  }
  
  #  ------------------------------------------------------------------------
  
  #
  # Is this caching driver supported on the system?
  # Of course this one is.
  #
  # @return TRUE;
  #
  is_supported()
  {
  return true
  }
  
  #  ------------------------------------------------------------------------
  
  

register_class 'Exspresso_Cache_dummy', Exspresso_Cache_dummy
module.exports = Exspresso_Cache_dummy
#  End Class

#  End of file Cache_apc.php 
#  Location: ./system/libraries/Cache/drivers/Cache_apc.php 