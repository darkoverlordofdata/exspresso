#+--------------------------------------------------------------------+
#| config.coffee
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
#	Config
#
require APPPATH+'core/AdminController.coffee'

class Config extends AdminController

## --------------------------------------------------------------------




  index: ->
    @template.view 'admin/config'


#
# Export the class:
#
module.exports = Config

# End of file Config.coffee
# Location: .modules/admin/controllers/Config.coffee
