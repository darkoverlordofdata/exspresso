#+--------------------------------------------------------------------+
#| Auth.coffee
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
#	Auth
#
#
#
class global.Auth

  constructor: ($config = {}, @CI) ->

    @auth_model = @CI.load.model('user/auth_model')
    @CI.load.config('user/auth', true)
    @auth_model.initialize $config
    @CI._ctor.push ($next) => @auth_model.check_db $next

    
  login: ($args...) ->
    @auth_model.login.apply(@auth_model, $args...)

  reset_password: ($args...) ->
    @auth_model.reset_password.apply(@auth_model, $args...)

  activate: ($args...) ->
    @auth_model.activate.apply(@auth_model, $args...)

  deactivate: ($args...) ->
    @auth_model.deactivate.apply(@auth_model, $args...)

  #
  # logout
  #
  # @return void
  #
  logout: () ->

  #
  # logged_in
  #
  # @return bool
  #
  logged_in: () ->


  #
  # is_admin
  #
  # @return bool
  #
  is_admin: ($next) ->


  #
  # in_group
  #
  # @return bool
  #
  in_group: ($check_group, $id = false, $next = null) ->


module.exports = Auth

# End of file Auth.coffee
# Location: .application/modules/auth/libraries/Auth.coffee