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
# This file was ported from php to coffee-script using php2coffee
#
#
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

class global.CI_Model

  ## --------------------------------------------------------------------

  #
  # Model Constructor
  #
  #
  # @access	public
  # @param	object	$CI Controller Instance mixin
  # @return	void
  #
  constructor: ($CI) ->

    log_message 'debug', "Model Class Initialized"
    #
    # mixin CI objects to emulate php's magic __get
    #
    # this allows models to access CI's loaded classes
    # using the same syntax as controllers:
    #
    for $name, $var of $CI
      if typeof $var is 'object'
        if typeof $var isnt 'function' and not Array.isArray($var)
          @[$name] = $var



# END CI_Model class

module.exports = CI_Model

# End of file Model.coffee
# Location: ./system/core/Model.coffee