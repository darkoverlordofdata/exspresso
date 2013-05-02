#+--------------------------------------------------------------------+
#| MyModel.coffee
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
#	Class MyModel
#
module.exports = class application.core.MyModel extends system.core.Model

  source: null

  constructor: ($args...) ->
    super $args...

    @source = plural(@constructor.name.replace(/Model$/, '').toLowerCase())


    log_message 'debug', 'MyModel Initialized %s', @source
