#+--------------------------------------------------------------------+
#| constants.coffee
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
#|--------------------------------------------------------------------------
#| File and Directory Modes
#|--------------------------------------------------------------------------
#|
#| These prefs are used when checking and setting modes when working
#| with the file system.  The defaults are fine on servers with proper
#| security, but you may wish (or even need) to change the values in
#| certain environments (Apache running a separate process for each
#| user, PHP under CGI with Apache suEXEC, etc.).  Octal values should
#| always be used to set the mode correctly.
#|
#
define('FILE_READ_MODE', 0o0644)
define('FILE_WRITE_MODE', 0o0666)
define('DIR_READ_MODE', 0o0755)
define('DIR_WRITE_MODE', 0o0777)

#
#|--------------------------------------------------------------------------
#| File Stream Modes
#|--------------------------------------------------------------------------
#|
#| These modes are used when working with fopen()/popen()
#|
#

define('FOPEN_READ', 'rb')
define('FOPEN_READ_WRITE', 'r+b')
define('FOPEN_WRITE_CREATE_DESTRUCTIVE', 'wb')#  truncates existing file data, use with care
define('FOPEN_READ_WRITE_CREATE_DESTRUCTIVE', 'w+b')#  truncates existing file data, use with care
define('FOPEN_WRITE_CREATE', 'ab')
define('FOPEN_READ_WRITE_CREATE', 'a+b')
define('FOPEN_WRITE_CREATE_STRICT', 'xb')
define('FOPEN_READ_WRITE_CREATE_STRICT', 'x+b')


#  End of file constants.php 
#  Location: ./application/config/constants.php 