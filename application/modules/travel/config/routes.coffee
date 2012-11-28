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
# travel database application demo
exports['/travel/:db']                        = 'travel/search'
exports['/travel/:db/search']                 = 'travel/search'
exports['/travel/:db/hotels']                 = 'travel/hotels'
exports['/travel/:db/hotel/:id']              = 'travel/hotel'
exports['/travel/:db/booking/:id']            = 'travel/booking'
exports['/travel/:db/confirm/:id']            = 'travel/confirm'
exports['/travel/:db/book/:id']               = 'travel/book'
exports['/travel/:db/login']                  = 'travel/login'
exports['/travel/:db/logout']                 = 'travel/logout'
exports['/travel/:db/authenticate']           = 'travel/authenticate'

# End of file routes.coffee
# Location: ./application/modules/travel/config/routes.coffee