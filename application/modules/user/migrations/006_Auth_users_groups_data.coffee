#+--------------------------------------------------------------------+
#| 006_Auth_users_groups_data.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#	006_Auth_users_groups_data
#
#
#
class global.Migration_Auth_users_groups_data extends Exspresso_Migration

  seq: '006'
  description: 'Initial Auth users_groups data'
  table: 'users_groups'
  data:
    [
      {user_id: 1, group_id: 1}
      {user_id: 1, group_id: 2}
    ]

  up: ($next) ->

    @db.insert_batch @table, @data, $next

  down: ($next) ->

    @db.truncate @table, $next

module.exports = Migration_Auth_users_groups_data

# End of file 006_Auth_users_groups_data.coffee
# Location: ./ion_auth/migrations/006_Auth_users_groups_data.coffee