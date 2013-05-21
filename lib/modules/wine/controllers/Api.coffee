#+--------------------------------------------------------------------+
#| Api.coffee
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
#	Class RESTful Api
#
module.exports = class Api extends system.core.Controller

  #
  # Initialize the controller
  #
  constructor: ($args...) ->

    super $args...
    @load.model 'Wines'

  #
  # Get list of wines
  #
  # @return [Void]
  #
  indexAction: () ->
    @wines.getList ($err, $data) =>
      @res.json $err || $data

  #
  # Search wines
  #
  # @param  [String] like  pattern to search for
  # @return [Void]
  #
  searchAction: ($like) ->
    @wines.getByName $like, ($err, $data) =>
      @res.json $err || $data

  #
  # Create wine entry
  #
  # @return [Void]
  #
  createAction: () ->
    @wines.create @req.body, ($err, $id) =>
      @res.json $err || $id

  #
  # Get a wine entry
  #
  # @param  [String] id record id
  # @return [Void]
  #
  readAction: ($id) ->
    @wines.getById $id, ($err, $data) =>
      @res.json $err || $data

  #
  # Update a wine entry
  #
  # @param  [String] id record id
  # @return [Void]
  #
  updateAction: ($id) ->
    @wines.create @req.body, ($err) =>
      @res.json $err || {}

  #
  # Delete a wine entry
  #
  # @param  [String] id record id
  # @return [Void]
  #
  deleteAction: ($id) ->
    @wines.delete @req.body, ($err) =>
      @res.json $err || {}
