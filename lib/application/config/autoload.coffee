#| -------------------------------------------------------------------
#| AUTO-LOADER
#| -------------------------------------------------------------------
#| This file specifies which systems should be loaded by default.
#|
#| -------------------------------------------------------------------
#| Instructions
#| -------------------------------------------------------------------
#|
#| These are the things you can load automatically:
#|
#| 1. Packages
#| 2. Libraries
#| 3. Drivers
#| 4. Helper files
#| 5. Custom config files
#| 6. Language files
#| 7. Models
#|
#

module.exports =

  #
  #| -------------------------------------------------------------------
  #|  Auto-load Packges
  #| -------------------------------------------------------------------
  #| Prototype:
  #|
  #|  $autoload['packages: [APPPATH+'vendor', '/usr/local/shared']
  #|
  #
  packages: [
    APPPATH+'vendor/ckeditor/'
    APPPATH+'vendor/gravatar/'
  ]
  #
  #| -------------------------------------------------------------------
  #|  Auto-load Libraries
  #| -------------------------------------------------------------------
  #| These are the classes located in the system/libraries folder
  #| or in your application/libraries folder.
  #|
  #| Prototype:
  #|
  #|	$autoload['libraries: ['database']
  #
  libraries: ['database'] #, 'Session/session']
  
  #
  #| -------------------------------------------------------------------
  #|  Auto-load Drivers
  #| -------------------------------------------------------------------
  #| These are the classes located in the system/libraries folder
  #| or in your application/libraries folder.
  #|
  #| Prototype:
  #|
  #|	$autoload['drivers: ['session']
  #
  drivers: ['session', 'cache']
  
  #
  #|--------------------------------------------------------------------------
  #|  Auto-load Helpers
  #|--------------------------------------------------------------------------
  #| Prototype:
  #|
  #|	helper: ['url', 'file']
  #
  helper: ['form', 'url', 'html', 'ckeditor', 'date', 'inflector', 'file', 'directory']
  
  #
  #| -------------------------------------------------------------------
  #|  Auto-load Config files
  #| -------------------------------------------------------------------
  #| Prototype:
  #|
  #|	$autoload['config: ['config1', 'config2']
  #|
  #| NOTE: This item is intended for use ONLY if you have created custom
  #| config files.  Otherwise, leave it blank.
  #|
  #
  config: []
  
  #
  #| -------------------------------------------------------------------
  #|  Auto-load Language files
  #| -------------------------------------------------------------------
  #| Prototype:
  #|
  #|	$autoload['language: ['lang1', 'lang2']
  #|
  #|
  #
  language: []
  
  #
  #|--------------------------------------------------------------------------
  #|  Auto-load Models
  #|--------------------------------------------------------------------------
  #| Prototype:
  #|
  #|	model: ['accounts']
  #
  model: []
  

