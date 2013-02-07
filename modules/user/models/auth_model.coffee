#+--------------------------------------------------------------------+
#| auth_model.coffee
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
#	auth_model
#
#
#
class global.Auth_model extends Exspresso_Model

  #
  initialize: ($config = {}) ->
    log_message 'debug', 'Auth_model::initialize'
    console.log $config
    @['_'+$key] = $val for $key, $val of $config



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
# Location: .modules/user/models/auth_model.coffee