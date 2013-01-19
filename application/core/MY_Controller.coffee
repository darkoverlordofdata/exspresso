#+--------------------------------------------------------------------+
#| MY_Controller.coffee
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
#	MY_Controller
#
#
#

class global.MY_Controller extends Exspresso_Controller

  _module: ''

  constructor: ($res, @_module) ->
    super($res)


module.exports = MY_Controller
# End of file MY_Controller.coffee
# Location: ./application/core/MY_Controller.coffee