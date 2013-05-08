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

module.exports = class Admin extends application.core.AdminController

  #
  # Index
  #
  indexAction: ->

    $db = require(APPPATH+'config/database.coffee')

    @load.library 'Table'
    @theme.setAdminMenu 'Db'
    @db.listTables ($err, $tables) =>

      @theme.view 'admin', $err || {
        info:   $db.db[$db.active_group]
        tables: $tables
      }


