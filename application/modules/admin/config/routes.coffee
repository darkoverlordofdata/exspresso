#+--------------------------------------------------------------------+
#| routes.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
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
#|	http://codeigniter.com/user_guide/general/routing.html
#|
#

#----------------------------------------------------------------------
#          Route                                 Controller URI
#----------------------------------------------------------------------
# blog routeing
exports['/admin']                               = 'admin/index'
exports['/admin/login']                         = 'admin/login'
exports['/admin/authenticate']                  = 'admin/authenticate'
exports['/admin/index']                         = 'admin/index'
exports['/admin/config']                        = 'admin/config'
exports['/admin/routes']                        = 'admin/routes'
exports['/admin/users']                         = 'admin/users'
exports['/admin/db']                            = 'admin/db'
exports['/admin/migrate']                       = 'admin/migrate'
exports['/admin/migrate/list']                  = 'admin/migrate'
exports['/admin/migrate/list/:module']          = 'admin/migrate'
exports['/admin/migrate/preview/:module/:name'] = 'admin/migrate_info'
exports['/admin/blog']                          = 'admin/blog'
exports['/admin/demo']                          = 'admin/demo'

# End of file routes.coffee
# Location: .modules/blog/config/routes.coffee