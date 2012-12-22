#+--------------------------------------------------------------------+
#  Ion_auth.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# This file was ported from php to coffee-script using php2coffee
#
# modifed by bruce davidson 12/18/12 to use node async i/o
#
#
#
#
# Name:  Ion Auth
#
# Author: Ben Edmunds
#		  ben.edmunds@gmail.com
#         @benedmunds
#
# Added Awesomeness: Phil Sturgeon
#
# Location: http://github.com/benedmunds/CodeIgniter-Ion-Auth
#
# Created:  10.01.2009
#
# Description:  Modified auth system based on redux_auth with extensive customization.  This is basically what Redux Auth 2 should be.
# Original Author name has been kept but that does not mean that the method has not been modified.
#
#
#

class global.Ion_auth

  #
  # constructor
  #
  # @return void
  # @author Ben
  #
  constructor: ($config = {}, @CI) ->

    @CI.load.config('ion_auth', true)
    @CI.load.library('email')
    @CI.load.library('session')
    @CI.lang.load('ion_auth')
    @CI.load.model('ion_auth_model')
    @CI.load.helper('cookie')

    # auto-login the user if they are remembered
    if not @logged_in() and @CI.input.get_cookie('identity') and @CI.input.get_cookie('remember_code')
      @ion_auth_model.login_remembered_user ($err) =>
        if $err then log_message 'error', 'login_remembered_user %j', $err

    $email_config = @config.item('email_config', 'ion_auth')

    if $email_config?  and is_array($email_config)
      @email.initialize($email_config)

    @ion_auth_model.trigger_events('library_constructor')

  #
  #
  # We don't have php magic __call
  # So, delegate these methods to ion_auth_model:
  #
  login: ($args...) ->
    @ion_auth_model.login.apply(@ion_auth_model, $args...)

  clear_forgotten_password_code: ($args...) ->
    @ion_auth_model.clear_forgotten_password_code.apply(@ion_auth_model, $args...)

  reset_password: ($args...) ->
    @ion_auth_model.reset_password.apply(@ion_auth_model, $args...)

  activate: ($args...) ->
    @ion_auth_model.activate.apply(@ion_auth_model, $args...)

  deactivate: ($args...) ->
    @ion_auth_model.deactivate.apply(@ion_auth_model, $args...)


  #
  # forgotten password feature
  #
  # @return mixed  boolian / array
  # @author Mathew
  #
  forgotten_password: ($identity, $next) -> # changed $email to $identity

    @ion_auth_model.forgotten_password $identity, ($err, $forgotten) =>  # changed

      if $forgotten
        #  Get user information
        # changed to get_user_by_identity from email

        @where(@config.item('identity', 'ion_auth'), $identity).users ($err, $query) =>

          if $err then return $next $err

          $user = $query.row()
          if $user
            $data =
              identity:                 $user[@config.item('identity', 'ion_auth')]
              forgotten_password_code:  $user.forgotten_password_code

            if not @config.item('use_ci_email', 'ion_auth')
              @set_message('forgot_password_successful')
              return $data

            else
              $view = @config.item('email_templates', 'ion_auth') + @config.item('email_forgot_password', 'ion_auth')
              @load.view $view, $data, ($err, $message) =>

                @email.clear()
                @email.set_newline("\r\n")
                @email.from(@config.item('admin_email', 'ion_auth'), @config.item('site_title', 'ion_auth'))
                @email.to($user.email)
                @email.subject(@config.item('site_title', 'ion_auth') + ' - Forgotten Password Verification')
                @email.message($message)

                @email.send ($err, $details) =>

                  if $err
                    @set_error('forgot_password_unsuccessful')
                    return $next null, false

                  else
                    @set_message('forgot_password_successful')
                    return $next null, true

          else
            @set_error('forgot_password_unsuccessful')
            return $next null, false

      else
        @set_error('forgot_password_unsuccessful')
        return $next $err, false


  #
  # forgotten_password_complete
  #
  # @return void
  # @author Mathew
  #
  forgotten_password_complete: ($code, $next) ->

    @ion_auth_model.trigger_events('pre_password_change')

    $identity = @config.item('identity', 'ion_auth')
    @where('forgotten_password_code', $code).users ($err, $users) =>

      $profile = $users.row()
      if not $profile
        @ion_auth_model.trigger_events(['post_password_change', 'password_change_unsuccessful'])
        @set_error('password_change_unsuccessful')
        return $next null, false


      @ion_auth_model.forgotten_password_complete $code, $profile.salt ($err, $new_password) =>

        if $new_password
          $data =
            identity:     $profile[$identity],
            new_password: $new_password

          if not @config.item('use_ci_email', 'ion_auth')
            @set_message('password_change_successful')
            @ion_auth_model.trigger_events(['post_password_change', 'password_change_successful'])
            return $next null, $data

          else
            $view = @config.item('email_templates', 'ion_auth') + @config.item('email_forgot_password_complete', 'ion_auth')
            @load.view $view, $data, ($err, $message) =>

              @email.clear()
              @email.set_newline("\r\n")
              @email.from(@config.item('admin_email', 'ion_auth'), @config.item('site_title', 'ion_auth'))
              @email.to($profile.email)
              @email.subject(@config.item('site_title', 'ion_auth') + ' - New Password')
              @email.message($message)

              @email.send ($err, $details) =>

                if $err
                  @set_message('password_change_successful')
                  @ion_auth_model.trigger_events(['post_password_change', 'password_change_successful'])
                  return $next null, true

                else
                  @set_error('password_change_unsuccessful')
                  @ion_auth_model.trigger_events(['post_password_change', 'password_change_unsuccessful'])
                  return $next null, false

        else
          @ion_auth_model.trigger_events(['post_password_change', 'password_change_unsuccessful'])
          return $next null, false

  #
  # forgotten_password_check
  #
  # @return void
  # @author Michael
  #
  forgotten_password_check: ($code, $next) ->

    @where('forgotten_password_code', $code).users ($err, $users) =>

      if $err then return $next $err
      $profile = $users.row()# pass the code to profile

      if not is_object($profile)
        @set_error('password_change_unsuccessful')
        return $next null, false

      else
        if @config.item('forgot_password_expiration', 'ion_auth') > 0
          # Make sure it isn't expired
          $expiration = @config.item('forgot_password_expiration', 'ion_auth')
          if time() - $profile.forgotten_password_time > $expiration
            # it has expired
            @clear_forgotten_password_code($code)
            @set_error('password_change_unsuccessful')
            return $next null, false

        return $next null, $profile


  #
  # register
  #
  # @return void
  # @author Mathew
  #
  register: ($username, $password, $email, $additional_data = {}, $group_name = {}, $next = null) ->

    if $next is null
      $next = $group_name
      $group_name = {}

  # need to test email activation

    @ion_auth_model.trigger_events('pre_account_creation')

    $email_activation = @config.item('email_activation', 'ion_auth')

    if not $email_activation
      @ion_auth_model.register $username, $password, $email, $additional_data, $group_name, ($err, $id) =>

        if $id isnt false
          @set_message('account_creation_successful')
          @ion_auth_model.trigger_events(['post_account_creation', 'post_account_creation_successful'])
          return $next null, $id

        else
          @set_error('account_creation_unsuccessful')
          @ion_auth_model.trigger_events(['post_account_creation', 'post_account_creation_unsuccessful'])
          return $next null, false

    else
      @ion_auth_model.register $username, $password, $email, $additional_data, $group_name, ($err, $id) =>

        if not $id
          @set_error('account_creation_unsuccessful')
          return $next null, false

        $deactivate = @ion_auth_model.deactivate($id)

        if not $deactivate
          @set_error('deactivate_unsuccessful')
          @ion_auth_model.trigger_events(['post_account_creation', 'post_account_creation_unsuccessful'])
          return $next null, false

        $activation_code = @ion_auth_model.activation_code
        $identity = @config.item('identity', 'ion_auth')
        @ion_auth_model.user $id, ($err, $users) =>

          $users = $user.row()
          $data =
            identity:   $user[$identity]
            id:         $user.id,
            email:      $email,
            activation: $activation_code,

          if not @config.item('use_ci_email', 'ion_auth')
            @ion_auth_model.trigger_events(['post_account_creation', 'post_account_creation_successful', 'activation_email_successful'])
            @set_message('activation_email_successful')
            return $next null, $data

          else
            $view = @config.item('email_templates', 'ion_auth') + @config.item('email_activate', 'ion_auth')
            @load.view $view, $data, ($err, $message) =>

              @email.clear()
              @email.set_newline("\r\n")
              @email.from(@config.item('admin_email', 'ion_auth'), @config.item('site_title', 'ion_auth'))
              @email.to($email)
              @email.subject(@config.item('site_title', 'ion_auth') + ' - Account Activation')
              @email.message($message)

              @email.send ($err, $details) =>

                if $err
                  @ion_auth_model.trigger_events(['post_account_creation', 'post_account_creation_unsuccessful', 'activation_email_unsuccessful'])
                  @set_error('activation_email_unsuccessful')
                  return $next null, false
                else
                  @ion_auth_model.trigger_events(['post_account_creation', 'post_account_creation_successful', 'activation_email_successful'])
                  @set_message('activation_email_successful')
                  return $next null, $id
  #
  # logout
  #
  # @return void
  # @author Mathew
  #
  logout: () ->

    @ion_auth_model.trigger_events('logout')

    $identity = @config.item('identity', 'ion_auth')
    @session.unset_userdata($identity)
    @session.unset_userdata('id')
    @session.unset_userdata('user_id')

    # delete the remember me cookies if they exist
    if get_cookie('identity')
      delete_cookie('identity')

    if get_cookie('remember_code')
      delete_cookie('remember_code')

    # Recreate the session
    @session.sess_destroy()
    @session.sess_create()

    @set_message('logout_successful')
    return true


  #
  # logged_in
  #
  # @return bool
  # @author Mathew
  #
  logged_in: () ->

    @ion_auth_model.trigger_events('logged_in')
    $identity = @config.item('identity', 'ion_auth')
    return @session.userdata($identity)

  #
  # is_admin
  #
  # @return bool
  # @author Ben Edmunds
  #
  is_admin: ($next) ->

    @ion_auth_model.trigger_events('is_admin')
    $admin_group = @config.item('admin_group', 'ion_auth')
    @in_group $admin_group, ($err, $is_admin) =>
      if $err then return $next $err
      return $next null, $is_admin

  #
  # in_group
  #
  # @return bool
  # @author Phil Sturgeon
  #
  in_group: ($check_group, $id = false, $next = null) ->

    if $next is null
      $next = $id
      $id = false

    @ion_auth_model.trigger_events('in_group')

    $users_groups = @ion_auth_model.get_users_groups($id).result()

    @ion_auth_model.get_users_groups $id, ($err, $query) =>

      $users_groups = $query.result()
      $groups = []
      for $group in $users_groups
        $groups.push $group.name

      if is_array($check_group)
        for $key, $value of $check_group
          if in_array($value, $groups)
            return $next null, true

      else
        if in_array($check_group, $groups)
          return $next null, true

      return $next null, false


#  END Ion_auth class

module.exports = Ion_auth

#  End of file Ion_auth.coffee
#  Location: .ion_auth/libraries/Ion_auth.coffee