#+--------------------------------------------------------------------+
#| user.coffee
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
#	user - Main application
#
#
#
bcrypt          = require('bcrypt')                     # A bcrypt library for NodeJS.

class User extends CI_Controller

  ## --------------------------------------------------------------------

  #
  # Load the configured database
  #
  #   @access	public
  #   @return	void
  #
  constructor: ->

    super()
    @load.database()

  #
  # Login
  #
  login: ->

    $url = @input.get_post("url") ? '/'

    log_message 'debug', '$url = %s', $url

    if @input.cookie('user') is '' or @input.cookie('code') is ''

      @load.view "user/login",
        url: $url

    else

      @db.from 'user'
      @db.where 'email', @input.cookie('user')
      @db.get ($err, $user) =>

        if $err
          @load.view "user/login",
            url: $url
          return

        if $user.num_rows is 0
          @load.view "user/login",
            url: $url
          return

        $user = $user.row()
        if $user.code is @input.cookie('code')
          @session.set_userdata 'user', $user
          @session.set_flashdata 'info', 'Hello '+$user.name

          $url = @input.get_post("url") ? $user.path ? '/'
          @redirect $url
        else
          @redirect "/logout"


  #
  # Logout
  #
  logout: ->

    @session.set_flashdata  'info', 'Goodbye!'
    @session.unset_userdata 'user'
    @input.set_cookie 'user', ''
    @input.set_cookie 'code', ''
    @redirect "/"

  #
  # Do the authenthication
  #
  authenticate: ->

    $email = @input.post("email")
    $password = @input.post("password")
    $remember_me = @input.post("remember_me")

    @db.from 'user'
    @db.where 'email', $email
    @db.get ($err, $user) =>

      if $user.num_rows is 0
        @session.set_flashdata 'error', 'Invalid credentials. Please try again.'
        @redirect "/login"
        return

      $user = $user.row()
      if bcrypt.compareSync($password, $user.code)

        if $remember_me
          @input.set_cookie 'user', $email, 900000
          @input.set_cookie 'code', $user.code, 900000

        delete $user.code
        @session.set_userdata 'user', $user

        @session.set_flashdata  'info', 'Hello '+$user.name
        if @input.post("url")?
          @redirect @input.post("url")
        else
          @redirect $user.path
      else
        @session.set_flashdata 'error', 'Invalid credentials. Please try again.'
        @redirect "/login"



  #
  # Reset password?
  #
  forgot_password: ->

    @load.view "user/forgot_password"


# END CLASS User
module.exports = User




# End of file user.coffee
# Location: ./user.coffee