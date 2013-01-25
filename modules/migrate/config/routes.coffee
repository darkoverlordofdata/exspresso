#+--------------------------------------------------------------------+
#| routes.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#
#
#| -------------------------------------------------------------------------
#| URI ROUTING
#| -------------------------------------------------------------------------
#| This file lets you re-map URI requests to specific controller functions.
#|
#| Typically there is a one-to-one relationship between a URL string
#| and its corresponding controller class/method. The segments in a
#| URL normally follow this pattern:
#|
#|	example.com/class/method/id/
#|
#| In some instances, however, you may want to remap this relationship
#| so that a different class/function is called than the one
#| corresponding to the URL.
#|
#| Please see the user guide for complete details:
#|
#|	http://darkoverlordofdata.com/user_guide/general/routing.html
#|
#

#----------------------------------------------------------------------
#          Route                                 Controller URI
#----------------------------------------------------------------------
# blog routeing
exports['/admin/migrate']                       = 'migrate/admin'
exports['/admin/migrate/list']                  = 'migrate/admin'
exports['/admin/migrate/list/:module']          = 'migrate/admin'
exports['/admin/migrate/preview/:module/:name'] = 'migrate/preview'

# End of file routes.coffee
# Location: .modules/blog/config/routes.coffee