#+--------------------------------------------------------------------+
#| MY_Controller.coffee
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

class global.PublicController extends Exspresso_Controller

  constructor: ($args...) ->

    super($args...)

    @load.library 'template'
    @template.set_theme 'default', 'prettify'
    @load.database()
    @output.enable_profiler Exspresso.server._profile

module.exports = PublicController
# End of file PublicController.coffee
# Location: ./application/core/PublicController.coffee