#+--------------------------------------------------------------------+
#| auth_model.coffee
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
#	auth_model
#
#
#
class global.Auth_model extends Exspresso_Model

  _db_exists    : false # do the auth tables exist?
  _use_data     : false # use migration data?
  _data         : null  # migration data

  #
  initialize: ($config = {}) ->
    log_message 'debug', 'Auth_model::initialize'
    console.log $config
    @['_'+$k] = $v for $k, $v of $config

  #
  # check if the user table exists
  #
  check_db: ($next) =>

    if not @CI.db? then return $next Error('Auth_model: Db not loaded')
    if @CI.db is null then return $next Error('Auth_model: Db object is null')

    @CI.db.table_exists 'users', ($err, $exists) =>

      if $err then return $next $err
      @_db_exists = $exists
      if $exists then return $next null
      if @_data is null then return $next null
      #
      # load the migration data in place of a live db
      #
      try
        for $key, $name of @_data
          $class = require(APPPATH+'modules/user/migrations/'+$name+EXT)
          @_data[$key] = (new $class()).data
        @_use_data = true
      catch $err
        @_use_data = false
      finally
        $next null




  #
  # activate
  #
  # @return void
  #
  activate: ($id, $code = false, $next = null) ->

  #
  # Deactivate
  #
  # @return void
  #
  deactivate: ($id = null, $next) ->

  #
  # reset password
  #
  # @return bool
  #
  reset_password: ($identity, $new, $next) ->


  #
  # change password
  #
  # @return bool
  #
  change_password: ($identity, $old, $new, $next) ->


  #
  # Checks username
  #
  # @return bool
  #
  username_check: ($username = '', $next) ->


  #
  # Checks email
  #
  # @return bool
  #
  email_check: ($email = '', $next) ->


  #
  # Identity check
  #
  # @return bool
  #
  identity_check: ($identity = '', $next) ->


  #
  # login
  #
  # @return bool
  #
  login: ($identity, $password, $remember = false, $next) ->

    if not @_db_exists then return @login2($identity, $password, $remember, $next)

  login2: ($identity, $password, $remember = false, $next) ->

    if not @_use_data then return $next Error('Auth_model: Unable to login')
    $next Error('Auth_model: Unable to login')

  #
  # users
  #
  # @return object Users
  #
  users: ($groups = null, $next = null) ->



  #
  # user
  #
  # @return object
  #
  user: ($id = null, $next) ->

  #
  # add_to_group
  #
  # @return bool
  #
  add_to_group: ($group_id, $user_id = false, $next) ->

  #
  # remove_from_group
  #
  # @return bool
  #
  remove_from_group: ($group_id = false, $user_id = false, $next) ->


  #
  # groups
  #
  # @return object
  #
  groups: ($next) ->


  #
  # group
  #
  # @return object
  #
  group: ($next) ->


  #
  # update
  #
  # @return bool
  #
  update: ($id, $data, $next) ->


  #
  # delete_user
  #
  # @return bool
  #
  delete_user: ($id, $next) ->

  #
  # update_last_login
  #
  # @return bool
  #
  update_last_login: ($id, $next) ->



module.exports = Auth_model

    # End of file auth_model.coffee
# Location: .application/modules/auth/models/auth_model.coffee