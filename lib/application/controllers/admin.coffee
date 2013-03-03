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
#	  Admin
#
require APPPATH+'core/AdminController.coffee'

class Admin extends AdminController


  #
  # Admin overview
  #
  #   @access	public
  #   @return	void
  #
  #
  index: ->

    if @user.isLoggedIn
      if @user.authorizationCheck('admin')
        @template.view 'admin'
      else
        @template.view new Authorization_Error('No Admin Permissions')
    else
      @template.view 'signin'


  #
  # Authenticate user credentials
  #
  #   @access	public
  #   @return	void
  #
  #
  authenticate: ->

    @user.login @input.post("username"), @input.post("password")


  #
  # User Logout
  #
  #   @access	public
  #   @return	void
  #
  #
  logout: ->

    @user.logout()


#
# Export the class:
#
module.exports = Admin

# End of file Admin.coffee
# Location: .application/controllers/Admin.coffee
