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
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{Exspresso, config_item, get_config, is_loaded, load_class, load_new, load_object, log_message} = require(BASEPATH + 'core/Common')

CI_Controller   = require(BASEPATH + 'core/Controller') # Exspresso Controller Base Class
bcrypt          = require('bcrypt')

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

    console.log "LOGIN"
    console.log "user = "+@input.cookie('user')
    console.log "code = "+@input.cookie('code')
    if @input.cookie('user') is '' or @input.cookie('code') is ''

      console.log "render login"

      @load.view "user/login",
        url: @input.post("url")

    else

      console.log "read db"
      @db.from 'user'
      @db.where 'email', @input.cookie('user')
      @db.get ($err, $user) =>

        if $err
          @load.view "user/login",
            url: @input.post("url")
          return

        if not $user?
          @load.view "user/login",
            url: @input.post("url")
          return

        if $user.code is @input.cookie('code')
          @session.set_userdata 'user', $user

          @session.set_flashdata 'info', 'Hello '+$user.name
          if @input.post("url")?
            @redirect @input.post("url")
          else
            @redirect $user.path
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

      if $user.length? and $user.length is 0
        @session.set_flashdata 'error', 'Invalid credentials. Please try again.'
        @redirect "/login"
        return

      if bcrypt.compareSync($password, $user.code)
        @session.set_userdata 'user', $user

        if $remember_me
          @input.set_cookie 'user', $email, 900000
          @input.set_cookie 'code', $user.code, 900000

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