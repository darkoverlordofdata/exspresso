#| -------------------------------------------------------------------
#| Database Connections
#| -------------------------------------------------------------------
#|
#|  active_group    the active connection group
#|
#|  active_record   true/false - load the active record class
#|
#|	url             Optional url. Overrides any of the following:
#|	hostname        Hostname of the database server.
#|	username        Username in the database.
#|	password        Password for the ysername.
#|	database        Name of the database.
#|	dbdriver        Database type. Currently supported options:
#|                    mysql, postgres, sqlite
#|	dbprefix        Optional prefix, added to the table name when
#|				            using the  Active Record class
#|	pconnect        true/false - Use a persistent connection
#|	db_debug        true/false - Database errors should be displayed.
#|	cache_on        true/false - Enables/disables query caching
#|	cachedir        Path to the folder where cache files should be stored
#|	char_set        Character set used by thee database.
#|	dbcollat        Collation sequence used by the database.
#|	swap_pre        Default table prefix that will be swapped with the dbprefix
#|	autoinit        true/false - Automatically initialize the database.
#|	stricton        true/false - Forces 'Strict Mode' connections if available
#|
#

module.exports =

  #
  # Use the ActiveRecord class?
  #
  active_record: true

  #
  # db group selected
  #
  active_group: 'default'

  #
  # db groups
  #
  db:
    default:
      hostname: ''
      username: ''
      password: ''
      database: './exspresso.sqlite'
      dbdriver: 'sqlite'
      dbprefix: ''
      db_debug: true
      cache_on: false
      cachedir: ''
      char_set: 'utf8'
      dbcollat: 'utf8_general_ci'
      swap_pre: ''
      autoinit: true
      stricton: false

    mysql:
      url     : process.env.CLEARDB_DATABASE_URL ? "mysql://demo:demo@localhost:3306/demo"
      hostname: ''
      username: ''
      password: ''
      database: ''
      dbdriver: 'mysql'
      dbprefix: ''
      db_debug: true
      cache_on: false
      cachedir: ''
      char_set: 'utf8'
      dbcollat: 'utf8_general_ci'
      swap_pre: ''
      autoinit: false
      stricton: false
      hostport: 3306

    postgres:
      url     : process.env.HEROKU_POSTGRESQL_ROSE_URL ? "postgres://tagsobe:tagsobe@localhost:5432/tagsobe"
      hostname: ''
      username: ''
      password: ''
      database: ''
      dbdriver: 'postgres'
      dbprefix: ''
      db_debug: true
      cache_on: false
      cachedir: ''
      char_set: 'utf8'
      dbcollat: 'utf8_general_ci'
      swap_pre: ''
      autoinit: false
      stricton: false
      hostport: 5432

    sqlite    :
      hostname: ''
      username: ''
      password: ''
      database: './exspresso.sqlite'
      dbdriver: 'sqlite'
      dbprefix: ''
      db_debug: true
      cache_on: true # false
      cachedir: APPPATH+'cache/'
      char_set: 'utf8'
      dbcollat: 'utf8_general_ci'
      swap_pre: ''
      autoinit: true
      stricton: false

