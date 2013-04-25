#+--------------------------------------------------------------------+
#| 002_Auth_groups_data.coffee
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
#	002_Auth_groups_data
#
#
#
class global.Migration_Auth_groups_data extends ExspressoMigration

  seq: '002'
  description: 'Initial Auth groups data'
  table: 'groups'
  data:
    [
      {'name':'admin', 'description':'Administrator'}
      {'name':'member', 'description':'Member'}
    ]

  up: ($next) ->

    @db.insert_batch @table, @data, $next

  down: ($next) ->

    @db.truncate @table, $next

module.exports = Migration_Auth_groups_data

# End of file 002_Auth_groups_data.coffee
# Location: ./ion_auth/migrations/002_Auth_groups_data.coffee