#+--------------------------------------------------------------------+
#| database.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	database - Main application
#
#
#
##
#| -------------------------------------------------------------------
#| DATABASE CONNECTIVITY SETTINGS
#| -------------------------------------------------------------------
#| This file will contain the settings needed to access your database.
#|
#| For complete instructions please consult the 'Database Connection'
#| page of the User Guide.
#|
#| -------------------------------------------------------------------
#| EXPLANATION OF VARIABLES
#| -------------------------------------------------------------------
#|
#|	['hostname'] The hostname of your database server.
#|	['username'] The username used to connect to the database
#|	['password'] The password used to connect to the database
#|	['database'] The name of the database you want to connect to
#|	['dbdriver'] The database type. ie: mysql.  Currently supported:
#                 mysql, sqlite, mongo
#|	['dbprefix'] You can add an optional prefix, which will be added
#|				 to the table name when using the  Active Record class
#|	['pconnect'] TRUE/FALSE - Whether to use a persistent connection
#|	['db_debug'] TRUE/FALSE - Whether database errors should be displayed.
#|	['cache_on'] TRUE/FALSE - Enables/disables query caching
#|	['cachedir'] The path to the folder where cache files should be stored
#|	['char_set'] The character set used in communicating with the database
#|	['dbcollat'] The character collation used in communicating with the database
#|	['swap_pre'] A default table prefix that should be swapped with the dbprefix
#|	['autoinit'] Whether or not to automatically initialize the database.
#|	['stricton'] TRUE/FALSE - forces 'Strict Mode' connections
#|							- good for ensuring strict SQL while developing
#|
##

#
# session db
#
exports['default'] =
  hostname: ''
  username: ''
  password: ''
  database: ''
  dbdriver: 'connect-sqlite3'
  dbprefix: ''
  pconnect: true
  db_debug: true
  cache_on: false
  cachedir: ''
  char_set: 'utf8'
  dbcollat: 'utf8_general_ci'
  swap_pre: ''
  autoinit: true
  stricton: false

#
# travel sample
#
exports['tagsobe'] =
  hostname: 'localhost'
  username: 'tagsobe'
  password: 'tagsobe'
  database: 'tagsobe'
  dbdriver: 'mysql'
  dbprefix: ''
  pconnect: true
  db_debug: true
  cache_on: false
  cachedir: ''
  char_set: 'utf8'
  dbcollat: 'utf8_general_ci'
  swap_pre: ''
  autoinit: true
  stricton: false


# End of file database.coffee
# Location: ./application/config/database.coffee