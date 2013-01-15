#+--------------------------------------------------------------------+
#| users.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#	Users
#
require APPPATH+'core/AdminController.coffee'

class Users extends AdminController

## --------------------------------------------------------------------




  index: ->
    @template.view 'admin/users'


#
# Export the class:
#
module.exports = Users

# End of file Users.coffee
# Location: .modules/admin/controllers/Users.coffee
