#+--------------------------------------------------------------------+
#| database.coffee
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
#|	['url']      Optional url. Overrides any of the following:
#|	['hostname'] The hostname of your database server.
#|	['username'] The username used to connect to the database
#|	['password'] The password used to connect to the database
#|	['database'] The name of the database you want to connect to
#|	['dbdriver'] The database type. ie: mysql.  Currently supported:
#                 mysql, postgres, sqlite
#|	['dbprefix'] You can add an optional prefix, which will be added
#|				 to the table name when using the  Active Record class
#|	['pconnect'] true/false - Whether to use a persistent connection
#|	['db_debug'] true/false - Whether database errors should be displayed.
#|	['cache_on'] true/false - Enables/disables query caching
#|	['cachedir'] The path to the folder where cache files should be stored
#|	['char_set'] The character set used in communicating with the database
#|	['dbcollat'] The character collation used in communicating with the database
#|	['swap_pre'] A default table prefix that should be swapped with the dbprefix
#|	['autoinit'] Whether or not to automatically initialize the database.
#|	['stricton'] true/false - forces 'Strict Mode' connections
#|							- good for ensuring strict SQL while developing
#|
#| The $active_group variable lets you choose which connection group to
#| make active.  By default there is only one group (the 'default' group).
#|
#| The $active_record variables lets you determine whether or not to load
#| the active record class
#

exports['active_group'] = 'mysql'
exports['active_record'] = true
exports['db'] =

  default:
    'hostname': 'localhost'
    'username': ''
    'password': ''
    'database': ''
    'dbdriver': 'mysql'
    'dbprefix': ''
    'pconnect': true
    'db_debug': true
    'cache_on': false
    'cachedir': ''
    'char_set': 'utf8'
    'dbcollat': 'utf8_general_ci'
    'swap_pre': ''
    'autoinit': true
    'stricton': false

  mysql:
    'url': process.env.CLEARDB_DATABASE_URL ? "mysql://demo:demo@localhost:3306/demo"
    'hostname': ''
    'username': ''
    'password': ''
    'database': ''
    'dbdriver': 'mysql'
    'dbprefix': ''
    'pconnect': true
    'db_debug': true
    'cache_on': false
    'cachedir': ''
    'char_set': 'utf8'
    'dbcollat': 'utf8_general_ci'
    'swap_pre': ''
    'autoinit': false
    'stricton': false

  postgres:
    'url': process.env.HEROKU_POSTGRESQL_ROSE_URL ? "postgres://tagsobe:tagsobe@localhost:5432/tagsobe"
    'hostname': ''
    'username': ''
    'password': ''
    'database': ''
    'dbdriver': 'postgres'
    'dbprefix': ''
    'pconnect': true
    'db_debug': true
    'cache_on': false
    'cachedir': ''
    'char_set': 'utf8'
    'dbcollat': 'utf8_general_ci'
    'swap_pre': ''
    'autoinit': false
    'stricton': false

  redis:
    'url': process.env.REDISTOGO_URL ? 'redis://localhost:6379'
    'hostname': ''
    'username': ''
    'password': ''
    'database': ''
    'dbdriver': 'redis'
    'dbprefix': ''
    'pconnect': true
    'db_debug': true
    'cache_on': false
    'cachedir': ''
    'char_set': 'utf8'
    'dbcollat': 'utf8_general_ci'
    'swap_pre': ''
    'autoinit': false
    'stricton': false

#  End of file database.php
#  Location: ./application/config/database.php 