#+--------------------------------------------------------------------+
#| Config.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#
#	Class application.lib.Config
#

require APPPATH+'core/Module.coffee'

class Config extends application.core.Module

  name          : 'Config'
  description   : ''
  path          : __dirname
  active        : true


# END CLASS Config
module.exports = Config
# End of file Config.coffee
# Location: .application/lib/Config.coffee