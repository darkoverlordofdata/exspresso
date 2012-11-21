#+--------------------------------------------------------------------+
#| 002_add_users_data.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	002_add_users_data - Migration
#
#
#
class Migration_add_users_data extends CI_Migration

  seq: '002'
  description: 'Initialize the users data'

  up: ($callback) ->

    @db.insert_batch 'user', @data, $callback

  down: ($callback) ->

    @db.delete 'user', @keys, $callback

  keys:
    [
      {id: 1}
      {id: 2}
    ]


  data:
    [
      {
        id: 1,
        email: "darkoverlordofdata@gmail.com"
        name: "bruce"
        code: "$2a$10$Kx9nhYIRPNiUN1jvVIOsp..vEyapyRlc0AV/zqU9DVsedfydm68Rq"
        last_logon: "2012-03-13 04:20:00"
        created_on: "2012-03-13 04:20:00"
        created_by: "darkoverlordofdata@gmail.com"
        active: 1
        timezone: "America/Los Angeles"
        language: "EN"
        theme: "default"
        path: "/"
      }
      {
        id: 2
        email: "demo@email.com"
        name: "shaggy"
        code: "$2a$10$tJRAO0iJGM0s.m3uCJ3UceRMDV.yhRxaXB7TTl7BqbnlWLn6kYpI."
        last_logon: "2012-03-13 04:20:00"
        created_on: "2012-03-13 04:20:00"
        created_by: "darkoverlordofdata@gmail.com"
        active: 1
        timezone: "America/Los Angeles"
        language: "EN"
        theme: "default"
        path: "/"
      }
    ]


# End of file 002_add_users_data.coffee
# Location: ./002_add_users_data.coffee