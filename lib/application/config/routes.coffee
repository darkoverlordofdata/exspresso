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
#| -------------------------------------------------------------------------
#| RESERVED ROUTES
#| -------------------------------------------------------------------------
#|
#| There area two reserved routes:
#|
#|	exports['default_controller'] = 'welcome';
#|
#| This route indicates which controller class should be loaded if the
#| URI contains no data. In the above example, the "welcome" class
#| would be loaded.
#|
#|	exports['404_override'] = 'errors/page_missing';
#|
#| This route will tell the Router what URI segments to use if those provided
#| in the URL cannot be matched to a valid route.
#|
#

#----------------------------------------------------------------------
#          Route                                 Controller URI
#----------------------------------------------------------------------
exports['default_controller']                 = "home/index"
exports['404_override']                       = 'welcome/not_found'

exports['/home']                              = 'home/index'
exports['/welcome']                           = 'welcome/index'
exports['/test']                              = 'welcome/test'

exports['/admin']                             = 'admin/index'
exports['/admin/login']                       = 'admin/login'
exports['/admin/logout']                      = 'admin/logout'
exports['/admin/authenticate']                = 'admin/authenticate'

exports['/admin/blog']                        = 'blog/admin'
exports['/admin/config']                      = 'config/admin'
exports['/admin/db']                          = 'db/admin'
exports['/admin/migrate']                     = 'migrate/admin'
exports['/admin/routes']                      = 'routes/admin'
exports['/admin/travel']                      = 'travel/admin'
exports['/admin/user']                        = 'user/admin'

# End of file routes.coffee
# Location: ./application/config/routes.coffee