#+--------------------------------------------------------------------+
#| autoload.coffee
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
##
#| -------------------------------------------------------------------
#| AUTO-LOADER
#| -------------------------------------------------------------------
#| This file specifies which systems should be loaded by default.
#|
#| In order to keep the framework as light-weight as possible only the
#| absolute minimal resources are loaded by default. For example,
#| the database is not connected to automatically since no assumption
#| is made regarding whether you intend to use it.  This file lets
#| you globally define which systems you would like loaded with every
#| request.
#|
#| -------------------------------------------------------------------
#| Instructions
#| -------------------------------------------------------------------
#|
#| These are the things you can load automatically:
#|
#| 1. Middleware
#| 2. Libraries
#| 3. Helper files
#| 4. Models
#| 5. Controllers
#|
##

##
#|--------------------------------------------------------------------------
#|  Auto-load Middleware
#|--------------------------------------------------------------------------
#| Prototype:
#|
#|	exports['middleware'] = ['messages', ...]
##
exports['middleware'] = ['messages', 'profiler']

##
#|--------------------------------------------------------------------------
#|  Auto-load Helpers
#|--------------------------------------------------------------------------
#| Prototype:
#|
#|	exports['helper'] = ['url', 'file']
##
exports['helper'] = []

##
#|--------------------------------------------------------------------------
#|  Auto-load Models
#|--------------------------------------------------------------------------
#| Prototype:
#|
#|	exports['model'] = ['accounts']
##
exports['model'] = []

##
#|--------------------------------------------------------------------------
#|  Auto-load Controllers
#|--------------------------------------------------------------------------
#| Prototype:
#|
#|	exports['controllers'] = []
#|
##
exports['controllers'] = []

# End of file autoload.coffee
# Location: ./application/config/autoload.coffee