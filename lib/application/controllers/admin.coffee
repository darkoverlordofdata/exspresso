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
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#  ------------------------------------------------------------------------
#
#	  Admin
#
require APPPATH+'core/AdminController.coffee'

class Admin extends application.core.AdminController


  #
  # Admin overview
  #
  #   @access	public
  # @return [Void]  #
  #
  index: ->

    if @user.isLoggedIn
      if @user.authorizationCheck('admin')
        @template.view 'admin'
      else
        @template.view new system.core.AuthorizationError('No Admin Permissions')
    else
      @template.view 'signin'


  #
  # Authenticate user credentials
  #
  #   @access	public
  # @return [Void]  #
  #
  authenticate: ->

    @user.login @input.post("username"), @input.post("password")


  #
  # User Logout
  #
  #   @access	public
  # @return [Void]  #
  #
  logout: ->

    @user.logout()


#
# Export the class:
#
module.exports = Admin

# End of file Admin.coffee
# Location: .application/controllers/Admin.coffee
