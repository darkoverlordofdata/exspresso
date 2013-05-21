#+--------------------------------------------------------------------+
#| Wine.coffee
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
#	Wine Module
#
require APPPATH+'core/Module.coffee'

module.exports = class Wine extends application.core.Module

  name          : 'Wine'
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
    @controller.load.model 'Wines'
    @controller.wines.install() if @controller.install


