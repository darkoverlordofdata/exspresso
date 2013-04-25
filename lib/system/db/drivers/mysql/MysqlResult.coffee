#+--------------------------------------------------------------------+
#  MysqlResult.coffee
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
# MySQL Result Class
#
# This class extends the parent result class: system.db.Result
#
module.exports = class system.db.mysql.MysqlResult extends system.db.Result

#
# Initialize a Result object for MySQL
#
# @param  [Array] rows  the results from a MySQL query
# @param  [Array] meta  field metadata
# @return	[Void]
#
  constructor: ($rows = [], $meta = []) ->

    super $rows, $meta