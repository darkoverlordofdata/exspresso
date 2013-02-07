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
#	Admin
#
require APPPATH+'core/AdminController.coffee'

class Admin extends AdminController


  ## --------------------------------------------------------------------

  #
  # Admin overview
  #
  #   @access	public
  #   @return	void
  #
  #
  index: ->

    if @user.is_logged_in
      if @user.authorization_check('adminz')
        @template.view 'admin'
      else
        @template.view new Authorization_Error('No Admin Permissions')
    else
      @template.view 'signin'


  ## --------------------------------------------------------------------

  #
  # Authenticate user credentials
  #
  #   @access	public
  #   @return	void
  #
  #
  authenticate: ->

    $username = @input.post("username")
    $password = @input.post("password")
    @user.authenticate $username, $password, ($err, $uid) =>

      return @template.view($err) if $err

      if $uid
        @session.set_flashdata  'info', 'Hello %s', @user.name
        @redirect '/admin'
      else
        @session.set_flashdata 'error', 'Invalid credentialz. Please try again.'
        @redirect "/admin"



  ## --------------------------------------------------------------------

  #
  # User Logout
  #
  #   @access	public
  #   @return	void
  #
  #
  logout: ->

    @session.set_flashdata  'info', 'Goodbye!'
    @session.unset_userdata 'customer'
    @input.set_cookie 'username', ''
    @input.set_cookie 'usercode', ''
    return @redirect "/admin"



#
# Export the class:
#
module.exports = Admin

# End of file Admin.coffee
# Location: .modules/admin/controllers/Admin.coffee
