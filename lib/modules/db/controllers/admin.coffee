#+--------------------------------------------------------------------+
#| admin.coffee
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
#	Database Admin
#
require APPPATH+'core/AdminController.coffee'

class Admin extends application.core.AdminController

  #
  # Index
  #
  index: ->

    $db = require(APPPATH+'config/database.coffee')

    @template.setAdminMenu 'Db'
    @db.listTables ($err, $tables) =>

      @template.view 'admin', $err || {
        info:   $db.db[$db.active_group]
        tables: $tables
      }


#
# Export the class:
#
module.exports = Admin

# End of file Admin.coffee
# Location: .modules/admin/controllers/Admin.coffee
