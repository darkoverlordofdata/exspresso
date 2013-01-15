#+--------------------------------------------------------------------+
#| demo.coffee
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
#	Demo
#
require APPPATH+'core/AdminController.coffee'

class Demo extends AdminController

## --------------------------------------------------------------------




  index: ->
    @template.view 'admin/demo'


#
# Export the class:
#
module.exports = Demo

# End of file Demo.coffee
# Location: .modules/admin/controllers/Demo.coffee
