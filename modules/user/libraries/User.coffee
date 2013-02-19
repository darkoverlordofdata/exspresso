#+--------------------------------------------------------------------+
#| User.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
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

class global.User extends Exspresso_Object

  bcrypt              = require('bcrypt')     # A bcrypt library for NodeJS
  __defineProperties  = Object.defineProperties
  __freeze            = Object.freeze

  #
  # Load the user model
  #
  # @return 	nothing
  #
  constructor: ($controller, $config = {}) ->

    super $controller, $config

    log_message 'debug', "User Class Initialized"
    @load.model('user/user_model')
    @lang.load('user/user')
    @queue ($next) => @initialize $next
    @


  #
  # Initialize the User object
  #
  #
  initialize: ($next) ->

    #
    # Reload the current user
    @user_model.load_by_id @req.session.uid, ($err, $user) =>

      $roles = []
      for $row in $user.roles
        $roles.push __freeze(array_merge($row, {}))

      return $next($err) if $err
      __defineProperties @,
        is_anonymous  : {enumerable: true,   get: -> $user.uid is User_model.UID_ANONYMOUS}
        is_logged_in  : {enumerable: true,   get: -> $user.uid isnt User_model.UID_ANONYMOUS}
        uid           : {enumerable: true,   get: -> $user.uid}
        name          : {enumerable: true,   get: -> $user.name}
        email         : {enumerable: true,   get: -> $user.email}
        created_on    : {enumerable: true,   get: -> $user.created_on}
        last_login    : {enumerable: true,   get: -> $user.last_login}
        active        : {enumerable: true,   get: -> $user.active}
        roles         : {enumerable: true,   get: -> __freeze($roles)}
      $next()

  #
  # Authenticate the user
  #
  # @param    string
  # @param    string
  # @param    string
  # @return 	nothing
  #
  login: ($name, $password, $action = '/admin') ->
    #
    #
    @user_model.load_by_name $name, ($err, $user) =>
      return if log_error('error', 'load by name: %s', $err) if show_error($err)

      bcrypt.compare $password, String($user.password)+String($user.salt), ($err, $ok) =>
        return if log_error('error', 'bcrypt compare: %s', $err) if show_error($err)

        if $ok
          @req.session.uid = $user.uid
          @session.set_flashdata  'info', @lang.line('user_hello'), $user.name
          @redirect $action

        else
          @req.session.uid = User_model.UID_ANONYMOUS
          @session.set_flashdata 'error', @lang.line('user_invalid_credentials')
          @redirect $action

  #
  # User logout
  #
  # @param    string
  # @return 	nothing
  #
  logout: ($action = '/admin') ->

    @session.set_flashdata  'info', @lang.line('user_goodbye')
    @req.session.uid = User_model.UID_ANONYMOUS
    @redirect $action


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

    for $role in @roles
      return true if $role.name is $auth

    return false

module.exports = User

# End of file User.coffee
# Location: .modules/user/libraries/User.coffee