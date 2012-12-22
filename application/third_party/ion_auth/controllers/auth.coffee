#+--------------------------------------------------------------------+
#  auth.coffee
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
class Auth extends CI_Controller

  data: null
  
  constructor : ($args...) ->

    super($args...)
    @load.library('ion_auth')
    @load.library('session')
    @load.library('form_validation')
    @load.database()
    @load.helper('url')
    @data = {}
    
  
  # @redirect if needed, otherwise display the user list
  index :  ->
    
    if not @ion_auth.logged_in()
      # @redirect them to the login page
      return @redirect('auth/login', 'refresh')

    @ion_auth.is_admin ($err, $is_admin) =>

      if not $is_admin
        # @redirect them to the home page because they must be an administrator to view this
        return @redirect(@config.item('base_url'), 'refresh')

      else
        # set the flash data error message if there is one
        @data['message'] = if (validation_errors()) then validation_errors() else @session.flashdata('message')

        # list the users
        @ion_auth.users ($err, $users) =>

          @data['users'] = $users.result()
          for $k, $user of @data['users']
            @data['users'][$k] = @data['users'][$k] ? {}
            @data['users'][$k].groups = @ion_auth.get_users_groups($user.id).result()
          @load.view 'auth/index', @data
      
    
  
  # log the user in
  login :  ->
    @data['title'] = "Login"
    
    # validate form input
    @form_validation.set_rules('identity', 'Identity', 'required')
    @form_validation.set_rules('password', 'Password', 'required')
    
    if @form_validation.run() is true # check to see if the user is logging in
      # check for "remember me"
      $remember = @input.post('remember')
      
      @ion_auth.login @input.post('identity'), @input.post('password'), $remember, ($err, $sucess) => # if the login is successful

        if $sucess
          # @redirect them back to the home page
          @session.set_flashdata('message', @ion_auth.messages())
          return @redirect(@config.item('base_url'), 'refresh')

        else  # if the login was un-successful
          # @redirect them back to the login page
          @session.set_flashdata('message', @ion_auth.errors())
          return @redirect('auth/login', 'refresh')# use @redirects instead of loading views for compatibility with MY_Controller libraries

      
    else  # the user is not logging in so display the login page
      # set the flash data error message if there is one
      @data['message'] = if (validation_errors()) then validation_errors() else @session.flashdata('message')
      
      @data['identity'] =
        name:   'identity'
        id:     'identity'
        type:   'text'
        value:  @form_validation.set_value('identity')

      @data['password'] =
        name:   'password'
        id:     'password'
        type:   'password'
        
      
      @load.view('auth/login', @data)
      
    
  
  # log the user out
  logout :  ->
    @data['title'] = "Logout"

    # log the user out
    $logout = @ion_auth.logout()
    # @redirect them back to the page they came from
    @redirect('auth', 'refresh')
    
  
  # change password
  change_password :  ->

    @form_validation.set_rules('old', 'Old password', 'required')
    @form_validation.set_rules('new', 'New Password', 'required|min_length[' + @config.item('min_password_length', 'ion_auth') + ']|max_length[' + @config.item('max_password_length', 'ion_auth') + ']|matches[new_confirm]')
    @form_validation.set_rules('new_confirm', 'Confirm New Password', 'required')
    
    if not @ion_auth.logged_in()
      return @redirect('auth/login', 'refresh')

    @ion_auth.user ($err, $query) =>

      $user = $query.row()

      if @form_validation.run() is false # display the form
        # set the flash data error message if there is one
        @data['message'] = if (validation_errors()) then validation_errors() else @session.flashdata('message')

        @data['min_password_length'] = @config.item('min_password_length', 'ion_auth')
        @data['old_password'] =
          name:     'old',
          id:       'old',
          type:     'password',

        @data['new_password'] =
          name:     'new',
          id:       'new',
          type:     'password',
          pattern:  '^.{' + @data['min_password_length'] + '}.*$',

        @data['new_password_confirm'] =
          name:     'new_confirm',
          id:       'new_confirm',
          type:     'password',
          pattern:  '^.{' + @data['min_password_length'] + '}.*$',

        @data['user_id'] =
          name:     'user_id',
          id:       'user_id',
          type:     'hidden',
          value:    $user.id,


        # render
        @load.view('auth/change_password', @data)

      else
        $identity = @session.userdata(@config.item('identity', 'ion_auth'))

        @ion_auth.change_password $identity, @input.post('old'), @input.post('new'), ($err, $change) =>

          if $change # if the password was successfully changed
            @session.set_flashdata('message', @ion_auth.messages())
            @logout()

          else
            @session.set_flashdata('message', @ion_auth.errors())
            @redirect('auth/change_password', 'refresh')

      
    
  
  # forgot password
  forgot_password :  ->
    @form_validation.set_rules('email', 'Email Address', 'required')
    if @form_validation.run() is false
      # setup the input
      @data['email'] =
        name:   'email'
        id:     'email'
        
      # set any errors and display the form
      @data['message'] = if (validation_errors()) then validation_errors() else @session.flashdata('message')
      @load.view('auth/forgot_password', @data)
      
    else 
      # run the forgotten password method to email an activation code to the user
      @ion_auth.forgotten_password @input.post('email'), ($err, $forgotten) =>

        if $forgotten # if there were no errors
          @session.set_flashdata('message', @ion_auth.messages())
          @redirect("auth/login", 'refresh')# we should display a confirmation page here instead of the login page

        else
          @session.set_flashdata('message', @ion_auth.errors())
          @redirect("auth/forgot_password", 'refresh')
        
      
    
  
  # reset password - final step for forgotten password
  reset_password: ($code) ->

    @ion_auth.forgotten_password_check $code, ($err, $user) =>

      if $user # if the code is valid then display the password reset form

        @form_validation.set_rules('new', 'New Password', 'required|min_length[' + @config.item('min_password_length', 'ion_auth') + ']|max_length[' + @config.item('max_password_length', 'ion_auth') + ']|matches[new_confirm]')
        @form_validation.set_rules('new_confirm', 'Confirm New Password', 'required')

        if @form_validation.run() is false# display the form
          # set the flash data error message if there is one
          @data['message'] = if (validation_errors()) then validation_errors() else @session.flashdata('message')

          @data['min_password_length'] = @config.item('min_password_length', 'ion_auth')
          @data['new_password'] =
            name:     'new',
            id:       'new',
            type:     'password',
            pattern:  '^.{' + @data['min_password_length'] + '}.*$',

          @data['new_password_confirm'] =
            name:     'new_confirm',
            id:       'new_confirm',
            type:     'password',
            pattern:  '^.{' + @data['min_password_length'] + '}.*$',

          @data['user_id'] =
            name:     'user_id',
            id:       'user_id',
            type:     'hidden',
            value:    $user.id,

          @data['csrf'] = @_get_csrf_nonce()
          @data['code'] = $code

          # render
          @load.view('auth/reset_password', @data)

        else
          #  do we have a valid request?
          if @_valid_csrf_nonce() is false or $user.id isnt @input.post('user_id')

            # something fishy might be up
            @ion_auth.clear_forgotten_password_code $code, ($err) =>

              show_404()

          else
            #  finally change the password
            $identity = $user[@config.item('identity', 'ion_auth')]

            @ion_auth.reset_password $identity, @input.post('new'), ($err, $change) =>

              if $change # if the password was successfully changed
                @session.set_flashdata('message', @ion_auth.messages())
                @logout()

              else
                @session.set_flashdata('message', @ion_auth.errors())
                @redirect('auth/reset_password/' + $code, 'refresh')

      else  # if the code is invalid then send them back to the forgot password page
        @session.set_flashdata('message', @ion_auth.errors())
        @redirect("auth/forgot_password", 'refresh')


  
  # activate the user
  activate : ($id, $code = false) ->

    if $code isnt false
      @ion_auth.activate $id, $code, ($err, $activation) =>

        if $activation
          # @redirect them to the auth page
          @session.set_flashdata('message', @ion_auth.messages())
          @redirect("auth", 'refresh')
        else
          # @redirect them to the forgot password page
          @session.set_flashdata('message', @ion_auth.errors())
          @redirect("auth/forgot_password", 'refresh')

    else
      @ion_auth.is_admin ($err, $is_admin) =>
        if $is_admin
          @ion_auth.activate $id, ($err, $activation) =>

            if $activation
              # @redirect them to the auth page
              @session.set_flashdata('message', @ion_auth.messages())
              @redirect("auth", 'refresh')
            else
              # @redirect them to the forgot password page
              @session.set_flashdata('message', @ion_auth.errors())
              @redirect("auth/forgot_password", 'refresh')

        else
          @session.set_flashdata('message', @ion_auth.errors())
          @redirect("auth/forgot_password", 'refresh')


  # deactivate the user# create a new user
  deactivate : ($id = null) ->
    #  no funny business, force to integer
    $id = parseInt($id, 10)

    @load.library('form_validation')
    @form_validation.set_rules('confirm', 'confirmation', 'required')
    @form_validation.set_rules('id', 'user ID', 'required|is_natural')

    if @form_validation.run() is false
      #  insert csrf check
      @data['csrf'] = @_get_csrf_nonce()
      @data['user'] = @ion_auth.user($id).row()

      @load.view('auth/deactivate_user', @data)

    else
      #  do we really want to deactivate?
      if @input.post('confirm') is 'yes'
        #  do we have a valid request?
        if @_valid_csrf_nonce() is false or $id isnt @input.post('id')
          return show_404()

        #  do we have the right userlevel?
        if @ion_auth.logged_in()
          @ion_auth.is_admin ($err, $is_admin) =>
            if $is_admin
              @ion_auth.deactivate $id, ($err) =>
                @redirect('auth', 'refresh')
            @redirect('auth', 'refresh')
      # @redirect them back to the auth page
      @redirect('auth', 'refresh')
        
  create_user :  ->
    @data['title'] = "Create User"

    if not @ion_auth.logged_in()
      return @redirect('auth', 'refresh')

    @ion_auth.is_admin ($err, $is_admin) =>

      if $is_admin
        # validate form input
        @form_validation.set_rules('first_name', 'First Name', 'required|xss_clean')
        @form_validation.set_rules('last_name', 'Last Name', 'required|xss_clean')
        @form_validation.set_rules('email', 'Email Address', 'required|valid_email')
        @form_validation.set_rules('phone1', 'First Part of Phone', 'required|xss_clean|min_length[3]|max_length[3]')
        @form_validation.set_rules('phone2', 'Second Part of Phone', 'required|xss_clean|min_length[3]|max_length[3]')
        @form_validation.set_rules('phone3', 'Third Part of Phone', 'required|xss_clean|min_length[4]|max_length[4]')
        @form_validation.set_rules('company', 'Company Name', 'required|xss_clean')
        @form_validation.set_rules('password', 'Password', 'required|min_length[' + @config.item('min_password_length', 'ion_auth') + ']|max_length[' + @config.item('max_password_length', 'ion_auth') + ']|matches[password_confirm]')
        @form_validation.set_rules('password_confirm', 'Password Confirmation', 'required')

        if @form_validation.run() is true
          $username = strtolower(@input.post('first_name')) + ' ' + strtolower(@input.post('last_name'))
          $email = @input.post('email')
          $password = @input.post('password')

          $additional_data =
            first_name: @input.post('first_name')
            last_name:  @input.post('last_name')
            company:    @input.post('company')
            phone:      @input.post('phone1') + '-' + @input.post('phone2') + '-' + @input.post('phone3')

        if @form_validation.run() is true
          # check to see if we are creating the user
          @ion_auth.register $username, $password, $email, $additional_data, ($err) =>
            # @redirect them back to the admin page
            @session.set_flashdata('message', "User Created")
            @redirect("auth", 'refresh')

        else  # display the create user form
          # set the flash data error message if there is one
          @data['message'] = if validation_errors() then validation_errors()
          else if @ion_auth.errors() then @ion_auth.errors() else @session.flashdata('message')

          @data['first_name'] =
            name:   'first_name',
            id:     'first_name',
            type:   'text',
            value:  @form_validation.set_value('first_name')

          @data['last_name'] =
            name:   'last_name',
            id:     'last_name',
            type:   'text',
            value:  @form_validation.set_value('last_name')

          @data['email'] =
            name:   'email',
            id:     'email',
            type:   'text',
            value:  @form_validation.set_value('email')

          @data['company'] =
            name:   'company',
            id:     'company',
            type:   'text',
            value:  @form_validation.set_value('company')

          @data['phone1'] =
            name:   'phone1',
            id:     'phone1',
            type:   'text',
            value:  @form_validation.set_value('phone1')

          @data['phone2'] =
            name:   'phone2',
            id:     'phone2',
            type:   'text',
            value:  @form_validation.set_value('phone2')

          @data['phone3'] =
            name:   'phone3',
            id:     'phone3',
            type:   'text',
            value:  @form_validation.set_value('phone3')

          @data['password'] =
            name:   'password',
            id:     'password',
            type:   'password',
            value:  @form_validation.set_value('password')

          @data['password_confirm'] =
            name:   'password_confirm',
            id:     'password_confirm',
            type:   'password',
            value:  @form_validation.set_value('password_confirm')

          @load.view('auth/create_user', @data)

      else
        @redirect('auth', 'refresh')

  # edit a user
  edit_user : ($id) ->

    @data['title'] = "Edit User"

    if not @ion_auth.logged_in() then return @redirect('auth', 'refresh')

    @ion_auth.is_admin ($err, $is_admin) =>
      if $is_admin

        @ion_auth.user $id, ($err, $query) =>
          $user = $query.row()

          # process the phone number
          if $user.phone?  and  not empty($user.phone)
            $user.phone = explode('-', $user.phone)


          # validate form input
          @form_validation.set_rules('first_name', 'First Name', 'required|xss_clean')
          @form_validation.set_rules('last_name', 'Last Name', 'required|xss_clean')
          @form_validation.set_rules('phone1', 'First Part of Phone', 'required|xss_clean|min_length[3]|max_length[3]')
          @form_validation.set_rules('phone2', 'Second Part of Phone', 'required|xss_clean|min_length[3]|max_length[3]')
          @form_validation.set_rules('phone3', 'Third Part of Phone', 'required|xss_clean|min_length[4]|max_length[4]')
          @form_validation.set_rules('company', 'Company Name', 'required|xss_clean')

          if $_POST? and not empty($_POST)
            #  do we have a valid request?
            if @_valid_csrf_nonce() is false or $id isnt @input.post('id')
              return show_error('This form post did not pass our security checks.')

            $data =
              first_name: @input.post('first_name')
              last_name:  @input.post('last_name')
              company:    @input.post('company')
              phone:      @input.post('phone1') + '-' + @input.post('phone2') + '-' + @input.post('phone3')


            # update the password if it was posted
            if @input.post('password')
              @form_validation.set_rules('password', 'Password', 'required|min_length[' + @config.item('min_password_length', 'ion_auth') + ']|max_length[' + @config.item('max_password_length', 'ion_auth') + ']|matches[password_confirm]')
              @form_validation.set_rules('password_confirm', 'Password Confirmation', 'required')

              $data['password'] = @input.post('password')

            if @form_validation.run() is true
              @ion_auth.update $user.id, $data, ($err) =>

                # check to see if we are creating the user
                # redirect them back to the admin page
                @session.set_flashdata('message', "User Saved")
                return redirect("auth", 'refresh')

          # display the edit user form
          @data['csrf'] = @_get_csrf_nonce()

          # set the flash data error message if there is one
          @data['message'] = if validation_errors() then validation_errors() else (if @ion_auth.errors() then @ion_auth.errors() else @session.flashdata('message'))

          # pass the user to the view
          @data['user'] = $user

          @data['first_name'] =
            name:   'first_name'
            id:     'first_name'
            type:   'text'
            value:  @form_validation.set_value('first_name', $user.first_name)

          @data['last_name'] =
            name:   'last_name'
            id:     'last_name'
            type:   'text'
            value:  @form_validation.set_value('last_name', $user.last_name)

          @data['company'] =
            name:   'company'
            id:     'company'
            type:   'text'
            value:  @form_validation.set_value('company', $user.company)

          @data['phone1'] =
            name:   'phone1',
            id:     'phone1',
            type:   'text',
            value:  @form_validation.set_value('phone1', $user.phone[0])

          @data['phone2'] =
            name:   'phone2',
            id:     'phone2',
            type:   'text',
            value:  @form_validation.set_value('phone2', $user.phone[1])

          @data['phone3'] =
            name:   'phone3',
            id:     'phone3',
            type:   'text',
            value:  @form_validation.set_value('phone3', $user.phone[2])

          @data['password'] =
            name:   'password',
            id:     'password',
            type:   'password'

          @data['password_confirm'] =
            name:   'password_confirm',
            id:     'password_confirm',
            type:   'password'

          @load.view('auth/edit_user', @data)

      else
        @redirect('auth', 'refresh')


  #  create a new group
  create_group: ()  ->

    @data['title'] = "Create Group"

    if not @ion_auth.logged_in() then return @redirect('auth', 'refresh')

    @ion_auth.is_admin ($err, $is_admin) =>
      if $is_admin

        # validate form input
        @form_validation.set_rules('group_name', 'Group name', 'required|alpha_dash|xss_clean')
        @form_validation.set_rules('description', 'Description', 'xss_clean')

        if @form_validation.run() is true
          @ion_auth.create_group @input.post('group_name'), @input.post('description'), ($err, $new_group_id) =>
            #if $new_group_id
            #  check to see if we are creating the group
            #  redirect them back to the admin page
            @session.set_flashdata('message', @ion_auth.messages())
            @redirect("auth", 'refresh')

        else
          # display the create group form
          # set the flash data error message if there is one
          @data['message'] = if validation_errors() then validation_errors() else (if @ion_auth.errors() then @ion_auth.errors() else @session.flashdata('message'))

          @data['group_name'] =
            name:   'group_name',
            id:     'group_name',
            type:   'text',
            value:  @form_validation.set_value('group_name')

          @data['description'] =
            name:   'description',
            id:     'description',
            type:   'text',
            value:  @form_validation.set_value('description')

          @load.view('auth/create_group', @data)

      else
        @redirect('auth', 'refresh')



  # edit a group
  edit_group : ($id) ->
    #  bail if no group id given
    if not $id or empty($id)
      @redirect('auth', 'refresh')

    @data['title'] = "Edit Group"

    if not @ion_auth.logged_in() then return @redirect('auth', 'refresh')

    @ion_auth.is_admin ($err, $is_admin) =>
      if $is_admin

        @ion_auth.group $id, ($err, $query) =>

          $group = $query.row()

          # validate form input
          @form_validation.set_rules('group_name', 'Group name', 'required|alpha_dash|xss_clean')
          @form_validation.set_rules('group_description', 'Group Description', 'xss_clean')

          if $_POST?  and  not empty($_POST)
            if @form_validation.run() is true
              @ion_auth.update_group $id, $_POST['group_name'], $_POST['group_description'], ($err, $group_update) =>

                if $group_update
                  @session.set_flashdata('message', "Group Saved")

                else
                  @session.set_flashdata('message', @ion_auth.errors())

                @redirect("auth", 'refresh')

          # set the flash data error message if there is one
          @data['message'] = if validation_errors() then validation_errors() else if @ion_auth.errors() then @ion_auth.errors() else @session.flashdata('message')

          # pass the user to the view
          @data['group'] = $group

          @data['group_name'] =
            name:   'group_name'
            id:     'group_name'
            type:   'text'
            value:  @form_validation.set_value('group_name', $group.name)

          @data['group_description'] =
            name:   'group_description'
            id:     'group_description'
            type:   'text'
            value:  @form_validation.set_value('group_description', $group.description)

          @load.view('auth/edit_group', @data)

      else
        @redirect('auth', 'refresh')


  _get_csrf_nonce :  ->
    $string = @load.helper('string')
    $key = $string.random_string('alnum', 8)
    $value = $string.random_string('alnum', 20)
    @session.set_flashdata('csrfkey', $key)
    @session.set_flashdata('csrfvalue', $value)

    return $key:$value

  _valid_csrf_nonce :  ->
    if @input.post(@session.flashdata('csrfkey')) isnt false and @input.post(@session.flashdata('csrfkey')) is @session.flashdata('csrfvalue')
      return true

    else
      return false
        


module.exports = Auth