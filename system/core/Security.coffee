#+--------------------------------------------------------------------+
#| Security.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
# Exspresso Application Security Class
#
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{array_merge, dirname, file_exists, is_dir, ltrim, realpath, rtrim, strrchr, trim, ucfirst} = require(FCPATH + 'helper')
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message} = require(BASEPATH + 'core/Common')

app             = require(BASEPATH + 'core/Exspresso')  # Exspresso application module
express         = require('express')                    # Express 3.0 Framework
url             = require('url')                        # node.url
redis           = require('redis')                      # Redis client library.
connectRedis    = require('connect-redis')              # Redis session store for Connect.


class CI_Security

  constructor: ->

    #|
    #|--------------------------------------------------------------------------
    #| Session Storage
    #|--------------------------------------------------------------------------
    #|
    config = get_config()
    if config.sessions

      app.use express.cookieParser(config.cookie_key)
      #
      # use redis to store session data?
      #
      if config.session_db is 'redis'

        r   = url.parse config.redis_url
        client = redis.createClient r.port, r.hostname
        if r.auth?
          client.auth r.auth.split(':')[1] # auth 1st part is username and 2nd is password separated by ":"


        RedisStore = connectRedis(express)
        app.use express.session
          secret:   config.cookie_key
          maxAge:   new Date Date.now() + 7200000 # 2h Session lifetime
          store:    new RedisStore(client: client)

      else

        app.use express.session()

    #app.use express.csrf()


# END CI_Security class

Exspresso.CI_Security = CI_Security
module.exports = CI_Security



# End of file Security.coffee
# Location: ./Security.coffee