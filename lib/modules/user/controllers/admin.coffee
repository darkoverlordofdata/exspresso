#+--------------------------------------------------------------------+
#| admin.coffee
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
#	Admin
#
require APPPATH+'core/AdminController.coffee'

class Admin extends application.core.AdminController

## --------------------------------------------------------------------




  indexAction: ->
    @template.setAdminMenu 'User'
    @template.view 'admin'


#
# Export the class:
#
module.exports = Admin

# End of file Admin.coffee
# Location: .modules/admin/controllers/Admin.coffee
