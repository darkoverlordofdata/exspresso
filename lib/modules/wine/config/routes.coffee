#----------------------------------------------------------------------
#          Route                                 Controller URI
#----------------------------------------------------------------------
module.exports =
  '/wines'                                  : 'wine/Wine/index'
  '/api/wines'                              : 'wine/Api/index'
  '/api/wines/search/:query'                : 'wine/Api/search'
  'POST /api/wines'                         : 'wine/Api/create'
  'GET /api/wines/:id'                      : 'wine/Api/read'
  'PUT /api/wines/:id'                      : 'wine/Api/update'
  'DELETE /api/wines/:id'                   : 'wine/Api/delete'


