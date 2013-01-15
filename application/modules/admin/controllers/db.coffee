#+--------------------------------------------------------------------+
#| db.coffee
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
#	Db
#
require APPPATH+'core/AdminController.coffee'

class Db extends AdminController

  ## --------------------------------------------------------------------
  index: ->

    $db = require(APPPATH+'config/database.coffee')

    @db.list_tables ($err, $tables) =>

      @template.view 'admin/db', $err || {
        info:   $db.db[$db.active_group]
        tables: $tables
      }


#
# Export the class:
#
module.exports = Db

# End of file Db.coffee
# Location: .modules/admin/controllers/Db.coffee
