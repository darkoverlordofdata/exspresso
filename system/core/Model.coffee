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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Model Class
#
# @package		Exspresso
# @subpackage	Libraries
# @category	Libraries
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/libraries/config.html
#

class global.Exspresso_Model

  ## --------------------------------------------------------------------

  #
  # Model Constructor
  #
  #
  # @access	public
  # @param	object	$CI Controller Instance mixin
  # @return	void
  #
  constructor: (@Exspresso) ->

    log_message 'debug', "Model Class Initialized"
    #
    # mixin CI objects to emulate php's magic __get
    #
    # this allows models to access CI's loaded classes
    # using the same syntax as controllers:
    #
    #for $name, $var of $CI
    #  if typeof $var is 'object'
    #    if typeof $var isnt 'function' and not Array.isArray($var)
    #      @[$name] = $var



# END Exspresso_Model class

module.exports = Exspresso_Model

# End of file Model.coffee
# Location: ./system/core/Model.coffee