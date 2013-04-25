#+--------------------------------------------------------------------+
#| module.coffee
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
#	Admin module
#
#
#
exports['active'] = true
exports['name'] = 'Migrate'
exports['desc'] = 'Database migrations'
exports['version'] = '1.0'
exports['base'] = APPPATH+'modules/migrate/'

exports['menu'] =
  Dashboard    : '/migrate/index'


# End of file module.coffee
# Location: .application/modules/admin/module.coffee