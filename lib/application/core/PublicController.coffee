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
#	PublicController
#
#   Base class for all publicly viewable pages
#
module.exports = class application.core.PublicController extends system.core.Controller

  constructor: ($args...) ->

    super($args...)

    @load.library 'Theme'
    @load.database()
    @output.enableProfiler exspresso.profile
    @output.cache 5

