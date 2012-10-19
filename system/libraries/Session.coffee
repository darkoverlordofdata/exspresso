#+--------------------------------------------------------------------+
#  Session.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# This file was ported from php to coffee-script using php2coffee v6.6.6
#
#

{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{file_exists, parse_url}  = require(FCPATH + 'lib')
{Exspresso, config_item, get_class, get_config, get_instance, is_loaded, load_class, load_new, load_object, log_message, show_error, register_class} = require(BASEPATH + 'core/Common')

express         = require('express')                    # Express 3.0 Framework

#  ------------------------------------------------------------------------
#
# Session Class
#
class Exspresso.CI_Session
  
  sess_encrypt_cookie: false
  sess_use_database: false
  sess_table_name: ''
  sess_expiration: 7200
  sess_expire_on_close: false
  sess_match_ip: false
  sess_match_useragent: true
  sess_cookie_name: 'ci_session'
  cookie_prefix: ''
  cookie_path: ''
  cookie_domain: ''
  cookie_secure: false
  sess_time_to_update: 300
  encryption_key: ''
  flashdata_key: 'flash'
  time_reference: 'time'
  gc_probability: 5
  userdata: {}
  CI: {}
  now: {}

  #
  # Session Constructor
  #
  # The constructor runs the session routines automatically
  # whenever the class is instantiated.
  #
  constructor: ($params = {}) ->
    log_message 'debug', "Session Class Initialized"

    #  Set the super object to a local variable for use throughout the class
    @CI = get_instance()

    #  Set all the session preferences, which can either be set
    #  manually via the $params array above or via the config file
    for $key in ['sess_encrypt_cookie', 'sess_use_database', 'sess_table_name', 'sess_expiration', 'sess_expire_on_close', 'sess_match_ip', 'sess_match_useragent', 'sess_cookie_name', 'cookie_path', 'cookie_domain', 'cookie_secure', 'sess_time_to_update', 'time_reference', 'cookie_prefix', 'encryption_key']
      @[$key] = if ($params[$key]?) then $params[$key] else @CI.config.item($key)

    if @encryption_key is ''
      show_error('In order to use the Session class you are required to set an encryption key in your config file.')

    @CI.app.use express.cookieParser(@encryption_key)


    #  Are we using a database?  If so, load it
    if @sess_use_database isnt false and @sess_table_name isnt ''

      if @sess_use_database is true
        @CI.load.database()
        $sess_driver = @CI.db.dbdriver
      else
        $sess_driver = parse_url(@sess_use_database).scheme

      console.log '-->  session driver = '+$sess_driver
      $found = false
      for $path in [BASEPATH, APPPATH]

        if file_exists($path+'libraries/Session/'+$sess_driver+EXT)

          $found = true

          $driver = require($path+'libraries/Session/'+$sess_driver+EXT)
          $store = new $driver(@)

          @CI.app.use express.session
            secret:   @encryption_key
            maxAge:   Date.now() + (@sess_expiration * 1000)
            store:    $store

      if not $found

        show_error "Session driver not found: "+$sess_driver

        @CI.app.use express.session()


    else

      @CI.app.use express.session()




#  END Session Class
module.exports = Exspresso.CI_Session
#  End of file Session.php 
#  Location: ./system/libraries/Session.php 