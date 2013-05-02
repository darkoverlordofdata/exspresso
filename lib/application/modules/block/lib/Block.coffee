#+--------------------------------------------------------------------+
#| Block.coffee
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
#	Class Block
#
module.exports = class application.modules.block.lib.Block

  constructor: ($args...) ->
    super $args...

    log_message 'debug', "Block Class Initialized"


