
process.env.MEMCACHIER_SERVERS = '127.0.0.1:11211'

#process.env.MEMCACHIER_USERNAME = '58753b'

#process.env.MEMCACHIER_PASSWORD = 'e54ea13e8c1f58c9d12b'

memjs = require('memjs')

cache = memjs.Client.create()

cache.set 'fred', 'flintstone', ($err, $data) ->
  cache.get 'fred', ($err, $data, $extra) ->
    console.log $err
    console.log String($data)
    console.log $extra


