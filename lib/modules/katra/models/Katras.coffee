#+--------------------------------------------------------------------+
#| Katras.coffee
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
#	Katra Data Model
#
module.exports = class modules.katra.models.Katras extends system.core.Model

  #
  # Get all
  #
  # @param  [Function] $next  async function
  # @return [Void]
  #
  getAll: ($next) ->
    @db.select 'katras.id, users.name AS author, katras.status'
    @db.select 'katras.created_on, katras.updated_on, katras.title'
    @db.from 'katras'
    @db.join 'users', 'users.uid = katras.author_id', 'inner'
    @db.get ($err, $katras) ->
      return $next($err) if $err?
      $next null, $katras.result()

  #
  # Get katras by id
  #
  # @param  [Integer] $id katras id
  # @param  [Function] $next  async function
  # @return [Void]
  #
  getById: ($id, $next) ->
    @db.from 'katras'
    @db.where 'id', $id
    @db.get ($err, $katras) ->
      return $next($err) if $err?
      $next null, $katras.row()

  #
  # Get the most recently updated article
  #
  # @return [Void]
  #
  getLatest: ($next) ->
    @db.from 'katras'
    @db.orderBy 'updated_on', 'desc'
    @db.limit 1
    @db.get ($err, $katras) ->
      return $next($err) if $err?
      $next null, $katras.row()

  #
  # Delete katras by id
  #
  # @param  [Integer] $id katras id
  # @param  [Function] $next  async function
  # @return [Void]
  #
  deleteById: ($id, $next) ->
    @db.where 'id', $id
    @db.delete 'katras', $next

  #
  # Create new katras doc
  #
  # @param  [Integer] $doc katras document
  # @param  [Function] $next  async function
  # @return [Void]
  #
  create: ($doc, $next) ->

    @db.insert 'katras', $doc, ($err) =>
      return $next($err) if $err?

      @db.insertId ($err, $id) ->
        return $next($err) if $err?
        $next null, $id

  #
  # Save katras doc by id
  #
  # @param  [Integer] $id katras id
  # @param  [Integer] $doc katras document
  # @param  [Function] $next  async function
  # @return [Void]
  #
  save: ($id, $doc, $next) ->
    @db.where 'id', $id
    @db.update 'katras', $doc, $next


  #
  # Install the Katra Module data
  #
  # @return [Void]
  #
  install: () ->

    @load.dbforge() unless @dbforge?
    @queue @install_katras

  #
  # Install Check
  # Create the katras table
  #
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  install_katras: ($next) =>

    fs = require('fs')

    #
    # if katras table doesn't exist, create and load initial data
    #
    @dbforge.createTable 'katras', $next, ($table) ->
      $table.addKey 'id', true
      $table.addField
        id:
          type: 'INT', constraint: 5, unsigned: true, auto_increment: true
        author_id:
          type: 'INT'
        status:
          type: 'INT'
        created_on:
          type: 'DATETIME'
        updated_on:
          type: 'DATETIME'
        updated_by:
          type: 'INT'
        title:
          type: 'VARCHAR', constraint: 255
        notes:
          type: 'TEXT'
        code:
          type: 'TEXT'

      $table.addData
        id: 1
        author_id: 2
        status: 1
        created_on: "2013-03-13 04:20:00"
        updated_on: "2013-03-13 04:20:00"
        updated_by: 2
        title: "TEST"
        notes: htmlspecialchars("This is my test case")
        code: htmlspecialchars(fs.readFileSync("#{__dirname}/src/TEST.BAS"))

      $table.addData
        id: 2,
        author_id: 2,
        status: 1,
        created_on: "2012-03-13 04:20:00",
        updated_on: "2012-03-13 04:20:00",
        updated_by: 2,
        title: "STTR1: STAR TREK",
        notes: htmlspecialchars("The original HP program by Mike Mayfield. This is the one that inspired Katra.")
        code: htmlspecialchars(fs.readFileSync("#{__dirname}/src/STTR1.bas"))

      $table.addData
        id: 3,
        author_id: 2,
        status: 1,
        created_on: "2012-03-13 04:20:00",
        updated_on: "2012-03-13 04:20:00",
        updated_by: 2,
        title: "R O M U L A N",
        notes: htmlspecialchars("I'm sure I remember seeing this in Byte. Remember Byte?")
        code: htmlspecialchars(fs.readFileSync("#{__dirname}/src/romulan.bas"))

      $table.addData
        id: 4,
        author_id: 2,
        status: 1,
        created_on: "2012-03-13 04:20:00",
        updated_on: "2012-03-13 04:20:00",
        updated_by: 2,
        title: "strtr1",
        notes: htmlspecialchars("???")
        code: htmlspecialchars(fs.readFileSync("#{__dirname}/src/strtr1.bas"))

      $table.addData
        id: 5,
        author_id: 2,
        status: 1,
        created_on: "2012-03-13 04:20:00",
        updated_on: "2012-03-13 04:20:00",
        updated_by: 2,
        title: "strtrk",
        notes: htmlspecialchars("???")
        code: htmlspecialchars(fs.readFileSync("#{__dirname}/src/strtrk.bas"))

