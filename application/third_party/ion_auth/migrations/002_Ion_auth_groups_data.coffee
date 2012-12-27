#+--------------------------------------------------------------------+
#| 002_Ion_auth_groups_data.coffee
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
#	002_Ion_auth_groups_data
#
#
#
class global.Migration_Ion_auth_groups_data extends CI_Migration

  seq: '002'
  description: 'Initial Ion_auth groups data'
  table: 'groups'
  data:
    [
      {'name':'admin', 'description':'Administrator'}
      {'name':'members', 'description':'General User'}
    ]

  up: ($next) ->

    @db.insert_batch @table, @data, $next

  down: ($next) ->

    @db.truncate @table, $next

module.exports = Migration_Ion_auth_groups_data

# End of file 002_Ion_auth_groups_data.coffee
# Location: ./ion_auth/migrations/002_Ion_auth_groups_data.coffee