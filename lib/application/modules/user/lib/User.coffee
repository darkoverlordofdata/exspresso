#+--------------------------------------------------------------------+
#| User.coffee
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
#	  User Library
#
module.exports = class application.modules.user.lib.User

  Users = load_class(APPPATH+'modules/user/models/Users.coffee')
  bcrypt            = require('bcrypt')     # A bcrypt library for NodeJS

  isAnonymous       : null  # returns true for anonymous user
  isLoggedIn        : null  # returns true for authenticated user
  isAdmin           : null  # returns true if authenticated user has admin role
  uid               : null  # returns current user database id
  name              : null  # returns current user name
  email             : null  # returns current user email
  createdOn         : null  # returns date the current user was created
  lastLogin         : null  # returns last login date for current user
  active            : null  # returns true if the current user is not blocked
  roles             : null  # returns an array of the current users roles

  #
  # Load the user model
  #
  # @return 	nothing
  #
  constructor: ($controller, $config = {}) ->

    log_message 'debug', "User Class Initialized"
    @i18n.load 'user', 'user'
    @load.model 'Users', 'users'
    #
    # Load the current user's attributes
    #
    @queue ($next) =>
      #
      # Reload the current user
      @users.getById @req.session.uid, ($err, $user) =>

        $roles = []
        $is_admin = false
        for $row in $user.roles
          $is_admin = true if $row.rid is Users.RID_ADMIN
          $roles.push freeze($row)

        return $next($err) if $err
        defineProperties @,
          isAnonymous   : {enumerable: true,   get: -> $user.uid is Users.UID_ANONYMOUS}
          isLoggedIn    : {enumerable: true,   get: -> $user.uid isnt Users.UID_ANONYMOUS}
          isAdmin       : {enumerable: true,   get: -> $is_admin}
          uid           : {enumerable: true,   get: -> $user.uid}
          name          : {enumerable: true,   get: -> $user.name}
          email         : {enumerable: true,   get: -> $user.email}
          createdOn     : {enumerable: true,   get: -> $user.created_on}
          lastLogin     : {enumerable: true,   get: -> $user.last_login}
          active        : {enumerable: true,   get: -> $user.active}
          roles         : {enumerable: true,   get: -> freeze($roles)}
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
    @users.getByName $name, ($err, $user) =>
      return if log_error('error', 'load by name: %s', $err) if show_error($err)

      bcrypt.compare $password, String($user.password)+String($user.salt), ($err, $ok) =>
        return if log_error('error', 'bcrypt compare: %s', $err) if show_error($err)

        if $ok
          @req.session.uid = $user.uid
          @session.setFlashdata 'info', @i18n.line('user_hello'), $user.name
          @redirect $action

        else
          @req.session.uid = Users.UID_ANONYMOUS
          @session.setFlashdata 'error', @i18n.line('user_invalid_credentials')
          @redirect $action

  #
  # User logout
  #
  # @param    string
  # @return 	nothing
  #
  logout: ($action = '/admin') ->

    @session.setFlashdata  'info', @i18n.line('user_goodbye')
    @req.session.uid = Users.UID_ANONYMOUS
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
  authorizationCheck: ($auth) ->

    for $role in @roles
      return true if $role.name is $auth

    return false

