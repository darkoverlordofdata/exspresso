#+--------------------------------------------------------------------+
#| User.coffee
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
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#  ------------------------------------------------------------------------
#
#	  User Library
#

class global.User extends Exspresso_Class

  bcrypt          = require('bcrypt')     # A bcrypt library for NodeJS

  Exspresso       : null  # the local exspresso object
  model           : null  # the user data model

  _field_list     : ['uid', 'name', 'email', 'created_on', 'last_login', 'active']
  _user           : null

  #
  # Load the user model
  #
  # @return 	nothing
  #
  constructor: ($args...) ->

    super $args...
    log_message 'debug', "User Class Initialized"

    @user_model = @load.model('user/user_model')

    # add to the controller queue
    @queue ($next) =>
      @initialize $next


  #
  # Initialize the User object
  #
  #
  initialize: ($next) ->

    @user_model.load_by_id @req.session.uid, ($err, $user) =>

      return $next($err) if $err

      @_user = {}
      for $field in @_field_list
        @_user[$field] = $user[$field]

      @user_model.load_roles $user.uid, ($err, $roles) =>
        @_user.roles = if $err then [] else $roles
        $next()


  #
  # User read-only properties
  #
  #
  @get is_anonymous : -> @_user.uid is User_model.UID_ANONYMOUS

  @get is_logged_in : -> @_user.uid isnt User_model.UID_ANONYMOUS

  @get uid          : -> @_user.uid

  @get name         : -> @_user.name

  @get email        : -> @_user.email

  @get created_on   : -> @_user.created_on

  @get last_login   : -> @_user.last_login

  @get active       : -> @_user.active


  #
  # Authenticate the user
  #
  # @param    string
  # @param    string
  # @param    function
  # @return 	nothing
  #
  authenticate: ($name, $password, $next) ->

    @user_model.load_by_name $name, ($err, $user) =>

      $next($err) if $err

      if @check_password($password, $user)
        for $field in @_field_list
          @_user[$field] = $user[$field]
        @req.session.uid = $user.uid
        @user_model.load_roles $user.uid, ($err, $roles) =>

          @_user.roles = if $err then [] else $roles
          $next null, $user.uid

      else
        $user = @user_model.anonymous_user()
        for $field in @_field_list
          @_user[$field] = $user[$field]
        @req.session.uid = $user.uid
        $next null, false

  #
  # Authorization Check
  #
  #   Check if the current user has authorization
  #   to perform an action
  #
  # @param    string
  # @return 	boolean
  #
  authorization_check: ($auth) ->

    for $role in @_user.roles
      return true if $role.name is $auth

    return false

  #
  # Check password
  #
  #   Check if the password is valid for the user
  #
  # @param    string
  # @param    string
  # @return 	boolean
  #
  check_password: ($password, $user) ->

    bcrypt.compareSync($password, String($user.password)+String($user.salt))

module.exports = User

# End of file User.coffee
# Location: .modules/user/libraries/User.coffee