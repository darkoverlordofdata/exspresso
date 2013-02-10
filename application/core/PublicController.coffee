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
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#  ------------------------------------------------------------------------
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