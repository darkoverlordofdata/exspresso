#+--------------------------------------------------------------------+
#| admin.coffee
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
#	  Admin Controller
#
require APPPATH+'core/AdminController.coffee'

module.exports = class Admin extends application.core.AdminController


  #
  # Admin overview - list/enable/disable modules
  #
  # @return [Void]
  #
  #
  indexAction: ->

    if @user.isLoggedIn
      if @user.authorizationCheck('admin')
        @theme.setAdminMenu 'Dashboard'
        @theme.view 'admin'
      else
        @theme.view new system.core.AuthorizationError('No Admin Permissions')
    else
      @theme.view 'signin'


  #
  # Authenticate user credentials
  #
  # @return [Void]
  #
  authenticateAction: ->

    if @input.post('login')
      if @validation.run('login')
        @user.login @input.post("username"), @input.post("password")
      else
        @session.setFlashdata 'error', @validation.errorString()
        @redirect '/admin'

  #
  # User Logout
  #
  # @return [Void]
  #
  logoutAction: ->

    @user.logout()

