#+--------------------------------------------------------------------+
#| Test.coffee
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
#	Unit test module
#

require APPPATH+'core/Module.coffee'

module.exports = class User extends application.core.Module

  name          : 'Test'
  description   : ''
  path          : __dirname
  active        : true


