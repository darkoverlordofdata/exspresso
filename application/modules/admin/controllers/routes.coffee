#+--------------------------------------------------------------------+
#| routes.coffee
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
#	Routes
#
require APPPATH+'core/AdminController.coffee'

class Routes extends AdminController

## --------------------------------------------------------------------




  index: ->
    @template.view 'admin/routes'


#
# Export the class:
#
module.exports = Routes

# End of file Routes.coffee
# Location: .modules/admin/controllers/Routes.coffee
