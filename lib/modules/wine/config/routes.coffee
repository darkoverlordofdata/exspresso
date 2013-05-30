#----------------------------------------------------------------------
#          Route                                 Controller URI
#----------------------------------------------------------------------
module.exports =
  '/wines'                                  : 'wine/Wine/index'
  '/dashboard'                              : 'wine/Wine/dashboard'
  'GET /api/wines'                          : 'wine/Api/index'
  'POST /api/wines'                         : 'wine/Api/create'
  'GET /api/wines/:id'                      : 'wine/Api/read'
  'PUT /api/wines/:id'                      : 'wine/Api/update'
  'DELETE /api/wines/:id'                   : 'wine/Api/delete'


