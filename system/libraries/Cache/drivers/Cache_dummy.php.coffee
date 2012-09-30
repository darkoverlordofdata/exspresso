if not defined('BASEPATH') then die 'No direct script access allowed'
#
# CodeIgniter
#
# An open source application development framework for PHP 4.3.2 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2006 - 2011 EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 2.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# CodeIgniter Dummy Caching Class
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Core
# @author		ExpressionEngine Dev Team
# @link
#

class CI_Cache_dummyextends CI_Driver
	
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
	return FALSE
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
	return TRUE
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
	return TRUE
	}
	
	#  ------------------------------------------------------------------------
	
	#
	# Clean the cache
	#
	# @return 	boolean		TRUE, simulating success
	#
	clean()
	{
	return TRUE
	}
	
	#  ------------------------------------------------------------------------
	
	#
	# Cache Info
	#
	# @param 	string		user/filehits
	# @return 	boolean		FALSE
	#
	cache_info($type = NULL)
	{
	return FALSE
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
	return FALSE
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
	return TRUE
	}
	
	#  ------------------------------------------------------------------------
	
	
#  End Class

#  End of file Cache_apc.php 
#  Location: ./system/libraries/Cache/drivers/Cache_apc.php 