#+--------------------------------------------------------------------+
#| blog.coffee
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
#	Blog
#
require APPPATH+'core/AdminController.coffee'

class Blog extends AdminController

## --------------------------------------------------------------------




  index: ->
    @template.view 'admin/blog'


#
# Export the class:
#
module.exports = Blog

# End of file Blog.coffee
# Location: .modules/admin/controllers/Blog.coffee
