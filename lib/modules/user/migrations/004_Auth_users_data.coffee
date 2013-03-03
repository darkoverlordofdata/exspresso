#+--------------------------------------------------------------------+
#| 004_Auth_users_data.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#	004_Auth_users_data
#
#
#
class global.Migration_Auth_users_data extends ExspressoMigration

  seq: '004'
  description: 'Initial Auth users data'
  table: 'users'
  data:
    [
      {
        'ip_address':inet_pton('127.0.0.1'),
        'username':'administrator',
        'password':'59beecdf7fc966e2f17fd8f65a4a9aeb09d4a3d4',
        'salt':'9462e8eee0',
        'email':'admin@admin.com',
        'activation_code':'',
        'forgotten_password_code':null,
        'forgotten_password_time':null,
        'created_on':'1268889823',
        'last_login':'1268889823',
        'active':'1',
        'first_name':'Admin',
        'last_name':'',
        'company':'',
        'phone':'0'
      }
    ]

  up: ($next) ->

    @db.insert_batch @table, @data, $next

  down: ($next) ->

    @db.truncate @table, $next

module.exports = Migration_Auth_users_data

# End of file 004_Auth_users_data.coffee
# Location: ./ion_auth/migrations/004_Auth_users_data.coffee