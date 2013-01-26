#+--------------------------------------------------------------------+
#| autoload.coffee
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
#| -------------------------------------------------------------------
#| AUTO-LOADER
#| -------------------------------------------------------------------
#| This file specifies which systems should be loaded by default.
#|
#| In order to keep the framework as light-weight as possible only the
#| absolute minimal resources are loaded by default. For example,
#| the database is not connected to automatically since no assumption
#| is made regarding whether you intend to use it.  This file lets
#| you globally define which systems you would like loaded when the
#| Exspresso server boots.
#|
#| -------------------------------------------------------------------
#| Instructions
#| -------------------------------------------------------------------
#|
#| These are the things you can load automatically:
#|
#| 1. Packages
#| 2. Libraries
#| 3. Helper files
#| 4. Custom config files
#| 5. Language files
#| 6. Models
#|
#

#
#| -------------------------------------------------------------------
#|  Auto-load Packges
#| -------------------------------------------------------------------
#| Prototype:
#|
#|  $autoload['packages'] = [APPPATH+'third_party', '/usr/local/shared']
#|
#
exports['packages'] = [APPPATH+'third_party/ckeditor/', APPPATH+'third_party/gravatar/']

#
#| -------------------------------------------------------------------
#|  Auto-load Libraries
#| -------------------------------------------------------------------
#| These are the classes located in the system/libraries folder
#| or in your application/libraries folder.
#|
#| Prototype:
#|
#|	$autoload['libraries'] = ['database', 'session']
#
exports['libraries'] = ['Session/session']

#
#|--------------------------------------------------------------------------
#|  Auto-load Helpers
#|--------------------------------------------------------------------------
#| Prototype:
#|
#|	exports['helper'] = ['url', 'file']
#
exports['helper'] = ['form', 'url', 'html', 'ckeditor']

#
#| -------------------------------------------------------------------
#|  Auto-load Config files
#| -------------------------------------------------------------------
#| Prototype:
#|
#|	$autoload['config'] = ['config1', 'config2']
#|
#| NOTE: This item is intended for use ONLY if you have created custom
#| config files.  Otherwise, leave it blank.
#|
#
exports['config'] = []

#
#| -------------------------------------------------------------------
#|  Auto-load Language files
#| -------------------------------------------------------------------
#| Prototype:
#|
#|	$autoload['language'] = ['lang1', 'lang2']
#|
#| NOTE: Do not include the "_lang" part of your file.  For example
#| "codeigniter_lang.php" would be referenced as array('codeigniter');
#|
#
exports['language'] = []

#
#|--------------------------------------------------------------------------
#|  Auto-load Models
#|--------------------------------------------------------------------------
#| Prototype:
#|
#|	exports['model'] = ['accounts']
#
exports['model'] = []


# End of file autoload.coffee
# Location: ./application/config/autoload.coffee