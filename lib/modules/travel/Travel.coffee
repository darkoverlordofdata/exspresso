#+--------------------------------------------------------------------+
#| Travel.coffee
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
#	Travel Module
#
require APPPATH+'core/Module.coffee'

module.exports = class Travel extends application.core.Module

  name          : 'Travel'
  description   : ''
  path          : __dirname
  active        : true



  #
  # Initialize the module
  #
  #   Install if needed
  #   Load the categories
  #
  # @return [Void]
  #
  initialize: () ->
    @controller.load.model 'TravelModel'
    @controller.travelmodel.install() if @controller.install


