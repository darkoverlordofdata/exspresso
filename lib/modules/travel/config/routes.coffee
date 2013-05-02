#----------------------------------------------------------------------
#          Route                                 Controller URI
#----------------------------------------------------------------------
module.exports =
  '/admin/travel'                     : 'travel/Admin'
  '/travel'                           : 'travel/Travel/search'
  '/travel/search'                    : 'travel/Travel/search'
  '/travel/hotels'                    : 'travel/Travel/hotels'
  '/travel/hotels/:start'             : 'travel/Travel/hotels'
  '/travel/hotel/:id'                 : 'travel/Travel/hotel'
  '/travel/booking/:id'               : 'travel/Travel/booking'
  '/travel/confirm/:id'               : 'travel/Travel/confirm'
  '/travel/book/:id'                  : 'travel/Travel/book'
  '/travel/login'                     : 'travel/Travel/login'
  '/travel/logout'                    : 'travel/Travel/logout'
  '/travel/authenticate'              : 'travel/Travel/authenticate'

