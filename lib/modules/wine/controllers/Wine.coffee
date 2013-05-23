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
#	Class Wine
#
module.exports = class Wine extends application.core.PublicController

  #
  # Display the Wines page
  #
  # @return [Void]
  #
  indexAction: () ->
    @theme.use 'coffeescript'
    #@theme.use 'js/wines.js'
    @theme.use 'js/wines.coffee'
    @theme.view 'index'