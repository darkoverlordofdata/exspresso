#+--------------------------------------------------------------------+
#| MY_Controller.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	PublicController
#
#   Base class for all publicly viewable pages
#

class global.AdminController extends MY_Controller

  constructor: ($args...) ->

    super($args...)

    @load.library 'template'
    @template.set_theme 'default', 'prettify'
    @load.database 'mysql'

module.exports = AdminController
# End of file AdminController.coffee
# Location: ./application/core/AdminController.coffee