#+--------------------------------------------------------------------+
#  Model.coffee
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
{Exspresso, config_item, get_class, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')


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
# CodeIgniter Model Class
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Libraries
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/libraries/config.html
#

module.exports = class Exspresso.CI_Model

  ## --------------------------------------------------------------------

  #
  # Model Constructor
  #
  #
  # @access	public
  # @param	object	$CI Controller Instance mixin
  # @return	void
  #
  constructor: () ->

    # Allows models to access CI's loaded classes using the same
    # syntax as controllers:
    # for $key, $member of $CI
    #   @[$key] = $member

    log_message 'debug', "Model Class Initialized"



# END CI_Model class

# End of file Model.coffee
# Location: ./system/core/Model.coffee