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
# This file was ported from php to coffee-script using php2coffee
#
#

express         = require('express')                    # Express 3.0 Framework

array = ($field, $match) ->
  $array = {}
  $array[$field] = $match
  return $array

#  ------------------------------------------------------------------------
#
# Session Class
#
class global.CI_Session
  
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

    #  Set all the session preferences, which can either be set
    #  manually via the $params array above or via the config file
    for $key in ['sess_encrypt_cookie', 'sess_use_database', 'sess_table_name', 'sess_expiration', 'sess_expire_on_close', 'sess_match_ip', 'sess_match_useragent', 'sess_cookie_name', 'cookie_path', 'cookie_domain', 'cookie_secure', 'sess_time_to_update', 'time_reference', 'cookie_prefix', 'encryption_key']
      @[$key] = if ($params[$key]?) then $params[$key] else config_item($key)

    if @encryption_key is ''
      show_error('In order to use the Session class you are required to set an encryption key in your config file.')

    $SRV.session @

  # --------------------------------------------------------------------
  # Method Stubs
  #
  #   These methods will be overriden by the middleware
  # --------------------------------------------------------------------

  #
  # Get logged in user
  #
  user: () -> false;
  # --------------------------------------------------------------------

  #
  # Add or change data in the "userdata" array
  #
  # @access public
  # @param mixed
  # @param string
  # @return void
  #
  set_userdata: ($newdata = {}, $newval = '') ->
  # --------------------------------------------------------------------

  #
  # Delete a session variable from the "userdata" array
  #
  # @access public
  # @param mixed
  # @return void
  #
  unset_userdata: ($newdata = {}) ->
  # --------------------------------------------------------------------

  #
  # Fetch a specific item from the session array
  #
  # @access public
  # @param string
  # @return string
  #
  userdata: ($item) -> false
  # --------------------------------------------------------------------

  #
  # Fetch all session data
  #
  # @access public
  # @return mixed
  #
  all_userdata: () -> false
  # --------------------------------------------------------------------

  #
  # set_flashdata
  #
  #   @param string item name
  #   @param string value
  #   @return void
  #
  set_flashdata: ($item, $value) ->
  # --------------------------------------------------------------------

  #
  # flashdata
  #
  #   @param string item name
  #   @return string item value
  #
  flashdata: ($item) -> ''
  # --------------------------------------------------------------------

  #
  # Override session instance methods
  #
  #   @returns function middlware callback
  #
  middleware: ()->

    log_message 'debug',"Session middleware initialized"

    ($req, $res, $next) =>

      # --------------------------------------------------------------------
      @user = () -> @req.session.user ? false

      # --------------------------------------------------------------------
      @set_userdata = ($newdata = {}, $newval = '') ->

        $data = $req.session.userdata = $req.session.userdata ? {}

        if typeof $newdata is 'string'
          $newdata = array($newdata, $newval)

        if count($newdata) > 0
          for $key, $val of $newdata
            $data[$key] = $val

        return

      # --------------------------------------------------------------------
      @unset_userdata = ($newdata = {}) ->

        $data = $req.session.userdata = $req.session.userdata ? {}

        if typeof $newdata is 'string'
          $newdata = array($newdata, '')

        if count($newdata) > 0
          for $key, $val of $newdata
            delete $data[$key]

        return

      # --------------------------------------------------------------------
      @userdata = ($item) ->

        $data = $req.session.userdata = $req.session.userdata ? {}

        if not $data[$item]? then false else $data[$item]

      # --------------------------------------------------------------------
      @all_userdata = () ->

        if not $req.session.userdata? then false else $req.session.userdata

      # --------------------------------------------------------------------
      @set_flashdata = ($item, $value) ->

        if not $req.session?
          throw Error('set_flashdata() requires sessions')

        $data = $req.session.flashdata = $req.session.flashdata ? {}

        if arguments.length > 2
          $args = Array::slice.call(arguments, 1)
          $value = format.apply(undefined, $args)

        $data[$item] = $value
        return

      # --------------------------------------------------------------------

      $res.locals.flashdata = @flashdata = ($item) ->

        $data = $req.session.flashdata = $req.session.flashdata ? {}

        $value = ''
        if $data[$item]?
          $value = $data[$item]
          delete $data[$item]

        return $value ? ''

      $next()




#  END Session Class
module.exports = CI_Session
#  End of file Session.php 
#  Location: ./system/libraries/Session.php 