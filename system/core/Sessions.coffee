#+--------------------------------------------------------------------+
#| Sessions.coffee
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
#	Sessions
#
#
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{parse_url, rawurldecode, substr} = require(FCPATH + 'lib')
{config_item, get_config, is_loaded, load_class, load_new, load_object, log_message} = require(BASEPATH + 'core/Common')

express         = require('express')                    # Express 3.0 Framework
url             = require('url')                        # node.url


## --------------------------------------------------------------------

#
# Initialize Sessions
#
#
#   @access	public
#   @param object express component
#   @return	void
#
exports.initialize = ($app) ->

  $config = load_class('Config', 'core')._config

  if $config.sessions
    $app.use express.cookieParser($config.cookie_key)

    switch $config.session_db
      when 'redis'
      #
      #   set up Redis session store
      #
        redis           = require('redis')                      # Redis client library.

        $r   = url.parse $config.redis_url
        $client = redis.createClient $r.port, $r.hostname
        if $r.auth?
          $client.auth $r.auth.split(':')[1] # auth 1st part is username and 2nd is password separated by ":"


        connectRedis    = require('connect-redis')              # Redis session store for Connect.

        RedisStore = connectRedis(express)


        $app.use express.session
          secret:   $config.cookie_key
          maxAge:   new Date Date.now() + 7200000 # 2h Session lifetime
          store:    new RedisStore(client: $client)

      when 'mysql'
      #
      #   set up MySql session store
      #

        mysql           = require('mysql')                      # MySql client

        $dns = parse_url($config.mysql_url)
        host =     if $dns['host']? then rawurldecode($dns['host']) else ''
        port =     if $dns['port']? then rawurldecode($dns['port']) else 3306
        user =     if $dns['user']? then rawurldecode($dns['user']) else ''
        password = if $dns['pass']? then rawurldecode($dns['pass']) else ''
        database = if $dns['path']? then rawurldecode(substr($dns['path'], 1)) else ''

        console.log "database "+database

        $client = new mysql.createClient
          host:     if $dns['host']? then rawurldecode($dns['host']) else ''
          port:     if $dns['port']? then rawurldecode($dns['port']) else 3306
          user:     if $dns['user']? then rawurldecode($dns['user']) else ''
          password: if $dns['pass']? then rawurldecode($dns['pass']) else ''
          database: if $dns['path']? then rawurldecode(substr($dns['path'], 1)) else ''
        ###
        host: 'localhost'
        port: 3306
        user: 'demo'
        password: 'demo'
        database: 'demo'

        ###

        connectMysql    = require('connect-mysql')              # Mysql session store for Connect.

        MysqlStore = connectMysql(express)

        $app.use express.session
          secret:   $config.cookie_key
          maxAge:   new Date Date.now() + 7200000 # 2h Session lifetime
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
          secret:   $config.cookie_key
          maxAge:   new Date Date.now() + 7200000 # 2h Session lifetime
          store:    new PgStore(pgConnect)

      else
      #
      #   set up default session store
      #
        $app.use express.session()

  return

# End of file Sessions.coffee
# Location: ./core/Sessions.coffee