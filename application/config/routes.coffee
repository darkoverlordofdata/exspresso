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
exports['default_controller']                 = "welcome/index"
exports['404_override']                       = 'welcome/not_found'

exports['/readme']                            = 'welcome/readme'
exports['/about']                             = 'welcome/about'
exports['/about/:id']                         = "welcome/about"

# database application demo I - Postgres + Sequelize ORM
exports['/pgorm']                             = 'pgorm/search'
exports['/pgorm/search']                      = 'pgorm/search'
exports['/pgorm/hotels']                      = 'pgorm/hotels'
exports['/pgorm/hotel/:id']                   = 'pgorm/hotel'
exports['/pgorm/booking']                     = 'pgorm/booking'
exports['/pgorm/confirm']                     = 'pgorm/confirm'
exports['/pgorm/book']                        = 'pgorm/book'

# database application demo II - Postgres + CI_DB_active_rec
exports['/pgtravel']                          = 'pgtravel/search'
exports['/pgtravel/search']                   = 'pgtravel/search'
exports['/pgtravel/hotels']                   = 'pgtravel/hotels'
exports['/pgtravel/hotel/:id']                = 'pgtravel/hotel'
exports['/pgtravel/booking']                  = 'pgtravel/booking'
exports['/pgtravel/confirm']                  = 'pgtravel/confirm'
exports['/pgtravel/book']                     = 'pgtravel/book'

# database application demo III - MySql + CI_DB_active_rec
exports['/mytravel']                          = 'mytravel/search'
exports['/mytravel/search']                   = 'mytravel/search'
exports['/mytravel/hotels']                   = 'mytravel/hotels'
exports['/mytravel/hotel/:id']                = 'mytravel/hotel'
exports['/mytravel/booking']                  = 'mytravel/booking'
exports['/mytravel/confirm']                  = 'mytravel/confirm'
exports['/mytravel/book']                     = 'mytravel/book'
#exports['/login']                             = 'mytravel/login'
#exports['/logout']                            = 'mytravel/logout'
#exports['/authenticate']                      = 'mytravel/authenticate'

# database tests
exports['/mysql']                             = 'query/mysql'
exports['/pg']                                = 'query/pg'


# End of file routes.coffee
# Location: ./routes.coffee