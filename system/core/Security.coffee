#+--------------------------------------------------------------------+
#| Output.coffee
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
#
#	Output - Main application
#
#
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{parse_url, rawurldecode, substr} = require(FCPATH + 'lib')
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

express         = require('express')                    # Express 3.0 Framework

#  ------------------------------------------------------------------------

#
# Exspresso Security Class
#
module.exports = class Exspresso.CI_Security

  constructor: ->

    @_initialize()

    log_message('debug', "Security Class Initialized")

  ## --------------------------------------------------------------------

  #
  # Initialize Security
  #
  #
  #   @access	private
  #   @return	void
  #
  _initialize: () ->

  _initializezz: () ->
    $app      = require(BASEPATH + 'core/Exspresso').app
    $config   = require(BASEPATH + 'core/Exspresso').config._config

    $app.use express.cookieParser($config.encryption_key)
    if $config.sess_use_database

      switch $config.session_db
        when 'redis'
        #
        #   set up Redis session store
        #
          redis           = require('redis')                      # Redis client library.


          $dns = parse_url($config.redis_url)
          $client = redis.createClient $dns.port, $dns.hostname
          $client.auth $dns.password

          connectRedis    = require('connect-redis')              # Redis session store for Connect.

          RedisStore = connectRedis(express)


          $app.use express.session
            secret:   $config.encryption_key
            maxAge:   new Date Date.now() + ($config.sess_expiration * 1000) # 2h Session lifetime
            store:    new RedisStore(client: $client)

        when 'mysql'
        #
        #   set up MySql session store
        #

          mysql           = require('mysql')                      # MySql client

          $dns = parse_url($config.mysql_url)

          $client = new mysql.createClient
            host:     if $dns['host']? then rawurldecode($dns['host']) else ''
            port:     if $dns['port']? then rawurldecode($dns['port']) else 3306
            user:     if $dns['user']? then rawurldecode($dns['user']) else ''
            password: if $dns['pass']? then rawurldecode($dns['pass']) else ''
            database: if $dns['path']? then rawurldecode(substr($dns['path'], 1)) else ''

          connectMysql    = require('connect-mysql')              # Mysql session store for Connect.

          MysqlStore = connectMysql(express)

          $app.use express.session
            secret:   $config.encryption_key
            maxAge:   new Date Date.now() + ($config.sess_expiration * 1000) # 2h Session lifetime
            store:    new MysqlStore(client: $client)

        when 'pg'
        #
        #   set up PostgreSql session store
        #
          pg              = require('pg')                         # PostgreSql client

          pgConnect = ($callback) ->
            pg.connect $config.pg_url, ($err, $client) ->
              if $err
                console.log JSON.stringify(err)
              else
              if $client
                $callback $client

          PgStore         = require('connect-pg')                 # PosgreSql session store for Connect.

          $app.use express.session
            secret:   $config.encryption_key
            maxAge:   new Date Date.now() + ($config.sess_expiration * 1000) # 2h Session lifetime
            store:    new PgStore(pgConnect)

        else
        #
        #   set up default session store
        #
          $app.use express.session()

    else
    #
    #   set up default session store
    #
      $app.use express.session()
    #
    # TODO: {BUG} 'express.csrf' fails
    # with Forbidden on route /travel/hotels
    #
    #$app.use express.csrf()

    return

# END CI_Security class

# End of file Security.coffee
# Location: ./system/core/Security.coffee