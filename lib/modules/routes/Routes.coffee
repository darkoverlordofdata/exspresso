#+--------------------------------------------------------------------+
#| Routes.coffee
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
#	Class application.lib.Routes
#

require APPPATH+'core/Module.coffee'

class Routes extends application.core.Module

  name: 'Routes'
  description: ''
  path: __dirname

  constructor: ->
    @name = 'Routes'
    @path = __dirname


# END CLASS Routes
module.exports = Routes
# End of file Routes.coffee
# Location: .application/lib/Routes.coffee