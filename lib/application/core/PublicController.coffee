#+--------------------------------------------------------------------+
#| PublicController.coffee
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
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#  ------------------------------------------------------------------------
#
#	PublicController
#
#   Base class for all publicly viewable pages
#

class application.core.PublicController extends system.core.Controller

  constructor: ($args...) ->

    super($args...)

    @load.library 'template'
    @template.setTheme 'default', 'prettify'
    @load.database()
    @output.enableProfiler exspresso.profile
    @output.cache 5

module.exports = application.core.PublicController
# End of file PublicController.coffee
# Location: ./application/core/PublicController.coffee