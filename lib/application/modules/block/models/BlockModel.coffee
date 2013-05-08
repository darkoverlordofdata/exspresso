#+--------------------------------------------------------------------+
#| BlockModel.coffee
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
#	Class Blocks
#
# Define User Blocks
#
module.exports = class application.modules.block.models.BlockModel extends system.core.Model

  table: 'block'

  constructor: ($args...) ->
    super $args...

  getById: ($id, $next) ->
    @db.where 'id', $id
    @db.get @table, ($err, $block) =>
      return $next($err, {}) if $err
      return $next(null, $block.row())

  getByName: ($name, $next) ->
    @db.where 'name', $name
    @db.get @table, ($err, $block) =>
      return $next($err, {}) if $err
      return $next(null, $block.row())

  getByTheme: ($theme, $next) ->
    @db.where 'theme', $theme
    @db.get @table, ($err, $block) =>
      return $next($err, []) if $err
      return $next(null, $block.result())

  #
  # Install the Block Module data
  #
  # @return [Void]
  #
  install: () ->

    @load.dbforge() unless @dbforge?
    @queue @install_blocks


  #
  # Install Check
  # Create the blocks table
  #
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  install_blocks: ($next) =>

    #
    # if block doesn't exist, create and load initial data
    #
    @dbforge.createTable @table, $next, ($table) ->
      $table.addKey 'id', true
      $table.addField
        id:
          type: 'INT', constraint: 5, unsigned: true, auto_increment: true
        name:
          type: 'VARCHAR', constraint: 255
        theme:
          type: 'VARCHAR', constraint: 255
        module:
          type: 'VARCHAR', constraint: 255
        region:
          type: 'VARCHAR', constraint: 255
        active:
          type:'TINYINT', constraint:'1', unsigned:true, null:true
        order:
          type:'TINYINT', constraint:'1', unsigned:true, null:true
        view:
          type: 'VARCHAR', constraint: 255
        cache:
          type:'TINYINT', constraint:'1', unsigned:true, null:true
        content:
          type: 'TEXT'

      $table.addData [
        {
          id: 1
          name: "copyright"
          theme: "default"
          module: "system"
          region: "$footer"
          active: 1
          order: 1
          view: ""
          cache: 0
          content: '''
                   <span class="pull-left muted">
                   &copy; Copyright 2012 - 2013 by Dark Overlord of Data
                   </span>
                   '''
        }
        {

          id: 2
          name: "poweredby"
          theme: "default"
          module: "system"
          region: "$footer"
          active: 1
          order: 2
          view: ""
          cache: 0
          content: '''
                   <span class="pull-right">
                   powered by &nbsp; <a href="https://npmjs.org/package/exspresso">e x s p r e s s o</a> {$profile}
                   </span>
                   '''
        }
      ]