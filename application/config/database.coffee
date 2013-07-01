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
#

credential = ($name) ->

  #
  # AppFog?
  #
  if process.env.VCAP_SERVICES?

    $appfog =
      mysql: 'mysql'
      postgresql: 'postgres'

    $service = JSON.parse(process.env.VCAP_SERVICES)
    $driver = Object.keys($service)[0]
    $credentials = $service[$driver][0].credentials
    $driver = $appfog[$driver.split('-')[0]] # strip off the version and translate

    return switch $name
      when 'dbdriver' then $driver
      when 'username' then $credentials.username
      when 'password' then $credentials.password
      when 'hostname' then $credentials.hostname
      when 'port'     then parseInt($credentials.port, 10)
      when 'database' then $credentials.name

  #
  # Url?
  #
  $url = process.env.HEROKU_POSTGRESQL_CHARCOAL_URL ||
  process.env.CLEARDB_DATABASE_URL

  if $url?

    switch $name
      when 'dbdriver' then parse_url($url).scheme
      when 'username' then parse_url($url).user
      when 'password' then parse_url($url).pass
      when 'hostname' then parse_url($url).host
      when 'port'     then parseInt(parse_url($url).port, 10)
      when 'database' then parse_url($url).path

    #
    # Must be localhost
    #
  else
    switch $name
      when 'dbdriver' then 'mysql'
      when 'username' then 'demo'
      when 'password' then 'demo'
      when 'hostname' then 'localhost'
      when 'port'     then 3306
      when 'database' then 'demo'

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
      port:     credential('port')
      hostname: credential('hostname')
      username: credential('username')
      password: credential('password')
      database: credential('database')
      dbdriver: credential('dbdriver')
      dbprefix: 'ex5o_'
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
      url     : process.env.HEROKU_POSTGRESQL_CHARCOAL_URL ? "postgres://tagsobe:tagsobe@localhost:5432/tagsobe"
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
      cache_on: false
      cachedir: APPPATH+'cache/'
      char_set: 'utf8'
      dbcollat: 'utf8_general_ci'
      swap_pre: ''
      autoinit: true
      stricton: false

