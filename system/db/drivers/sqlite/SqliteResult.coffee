#+--------------------------------------------------------------------+
#  SqliteResult.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+

#
# SQLite Result Class
#
#
module.exports = class system.db.sqlite.SqliteResult extends system.db.Result

  #
  # Initialize a Result object for SQLite
  #
  # @param  [Array] rows  the results from a SQLite query
  # @return	[Void]
  #
  constructor: ($rows = []) ->

    $meta = []
    if $rows.length > 0
      for $name, $val of $rows[0]
        $meta.push {name: $name}
    super $rows, $meta


