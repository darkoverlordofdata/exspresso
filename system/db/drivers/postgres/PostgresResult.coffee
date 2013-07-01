#+--------------------------------------------------------------------+
#  PostgreResult.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+

#
# Postgres Result Class
#
# This class extends the parent result class: ExspressoDb_result
#
module.exports = class system.db.postgres.PostgresResult extends system.db.Result


#
# Initialize a Result object for PostgreSql
#
# @param  [Array] results the results from a PostgreSql query
# @return	[Void]
#
  constructor: ($results = []) ->

    $meta = []
    if $results.rows.length > 0
      for $name, $val of $results.rows[0]
        $meta.push {name: $name}

    super $results.rows, $meta

