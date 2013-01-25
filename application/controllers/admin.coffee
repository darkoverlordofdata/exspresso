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

    if not @session.user()
      return @redirect "/admin/login"

    @template.view 'admin'

  ## --------------------------------------------------------------------

  #
  # Customer Login
  #
  #   @access	public
  #   @return	void
  #
  #
  login: ->

    if not @session.user()
      @template.view 'admin/signin'
    else
      @db.from 'customer'
      @db.where 'username', @input.cookie('username')
      @db.get ($err, $customer) =>

        if $err or $customer.num_rows is 0
          @template.view "admin/signin"
          return

        $customer = $customer.row()
        if $customer.password is @input.cookie('usercode')
          @session.set_userdata 'usercode', $customer

          @session.set_flashdata 'info', 'Hello '+$customer.name
          return @redirect "/admin"
        else
          return @redirect "/admin/logout"

  ## --------------------------------------------------------------------

  #
  # Authenticate Customer credentials
  #
  #   @access	public
  #   @return	void
  #
  #
  authenticate: ->

    $username = @input.post("username")
    $password = @input.post("password")
    $remember = @input.post("remember")

    @db.from 'customer'
    @db.where 'username', $username
    @db.get ($err, $customer) =>

      if $err then return @template.view $err

      if $customer.num_rows is 0
        @session.set_flashdata 'error', 'Invalid credentials. Please try again.'
        return @redirect "/admin/login"
        return

      $customer = $customer.row()
      if $password is $customer.password

        if $remember
          @input.set_cookie 'username', $customer.username, new Date(Date.now()+900000)
          @input.set_cookie 'usercode', $customer.password, new Date(Date.now()+900000)

        delete $customer.password
        @session.set_userdata 'customer', $customer

        @session.set_flashdata  'info', 'Hello '+$customer.name
        return @redirect '/admin'
      else
        @session.set_flashdata 'error', 'Invalid credentials. Please try again.'
        return @redirect "/admin/login"


  ## --------------------------------------------------------------------

  #
  # Customer Logout
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
