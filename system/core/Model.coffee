#+--------------------------------------------------------------------+
#  Model.coffee
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
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Model Class
#

class global.Exspresso_Model extends Exspresso_Object

  #
  # Model Constructor
  #
  # Copies the Exspresso_Controllers public base class properties
  #
  # @access	public
  # @param	object	$Exspresso Controller Instance mixin
  # @return	void
  #
  constructor: ($Exspresso) ->

    super $Exspresso
    log_message 'debug', "Model Class Initialized"


# END Exspresso_Model class

module.exports = Exspresso_Model

# End of file Model.coffee
# Location: ./system/core/Model.coffee