#+--------------------------------------------------------------------+
#| Travel.coffee
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
#	Class application.lib.Travel
#

require APPPATH+'core/Module.coffee'

class Travel extends application.core.Module

  name: 'Travel'
  description: ''
  path: __dirname

  constructor: ->
    @name = 'Travel'
    @path = __dirname


# END CLASS Travel
module.exports = Travel
# End of file Travel.coffee
# Location: .application/lib/Travel.coffee