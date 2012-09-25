#+--------------------------------------------------------------------+
#| Controller.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#
#	Controller base class
#

class exspresso.Controller

  load: null

  constructor: ->

    @load = new Load(@)



class Load

  constructor: (@parent) ->

  model: (name, name_as) ->

    member = name_as ? name
    @parent[member] = require(APPPATH + 'models/' + name)

