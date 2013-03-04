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
UserModel = require(MODPATH+'user/models/UserModel'+EXT)

class modules.user.lib.User

  bcrypt            = require('bcrypt')     # A bcrypt library for NodeJS

  isAnonymous       : null  # returns true for anonymous user
  isLoggedIn        : null  # returns true for authenticated user
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
    @load.model('user/UserModel')
    @l10n.load('user/user')
    @queue ($next) =>
      #
      # Reload the current user
      @usermodel.loadById @req.session.uid, ($err, $user) =>

        $roles = []
        for $row in $user.roles
          $roles.push freeze(array_merge($row, {}))

        return $next($err) if $err
        defineProperties @,
          isAnonymous   : {enumerable: true,   get: -> $user.uid is UserModel.UID_ANONYMOUS}
          isLoggedIn    : {enumerable: true,   get: -> $user.uid isnt UserModel.UID_ANONYMOUS}
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
    @usermodel.loadByName $name, ($err, $user) =>
      return if log_error('error', 'load by name: %s', $err) if show_error($err)

      bcrypt.compare $password, String($user.password)+String($user.salt), ($err, $ok) =>
        return if log_error('error', 'bcrypt compare: %s', $err) if show_error($err)

        if $ok
          @req.session.uid = $user.uid
          @session.setFlashdata  'info', @l10n.line('user_hello'), $user.name
          @redirect $action

        else
          @req.session.uid = UserModel.UID_ANONYMOUS
          @session.setFlashdata 'error', @l10n.line('user_invalid_credentials')
          @redirect $action

  #
  # User logout
  #
  # @param    string
  # @return 	nothing
  #
  logout: ($action = '/admin') ->

    @session.setFlashdata  'info', @l10n.line('user_goodbye')
    @req.session.uid = UserModel.UID_ANONYMOUS
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

module.exports = modules.user.lib.User

# End of file User.coffee
# Location: .modules/user/lib/User.coffee