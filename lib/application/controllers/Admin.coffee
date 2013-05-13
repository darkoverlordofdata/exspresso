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
        return @theme.view 'admin'
      else
        return @theme.view new system.core.AuthorizationError('No Admin Permissions')

    if @input.post('login')
      if @validation.run('login')
        return @user.login @input.post("username"), @input.post("password")

    @theme.view 'signin'

  #
  # User Logout
  #
  # @return [Void]
  #
  logoutAction: ->

    @user.logout()

