#+--------------------------------------------------------------------+
#  ion_auth_model.coffee
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
# Name:  Ion Auth Model
#
# Author:  Ben Edmunds
# 		   ben.edmunds@gmail.com
#	  	   @benedmunds
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

class global.Ion_auth_model extends CI_Model

  #
  # Holds an array of tables used
  #
  # @var string
  #
  tables: null
  
  #
  # activation code
  #
  # @var string
  #
  activation_code: ''
  
  #
  # forgotten password key
  #
  # @var string
  #
  forgotten_password_code: ''
  
  #
  # new password
  #
  # @var string
  #
  new_password: ''
  
  #
  # Identity
  #
  # @var string
  #
  identity: ''
  
  #
  # Where
  #
  # @var array
  #
  _ion_where: null
  
  #
  # Select
  #
  # @var string
  #
  _ion_select: null
  
  #
  # Limit
  #
  # @var string
  #
  _ion_limit: ''
  
  #
  # Offset
  #
  # @var string
  #
  _ion_offset: ''
  
  #
  # Order By
  #
  # @var string
  #
  _ion_order_by: ''
  
  #
  # Order
  #
  # @var string
  #
  _ion_order: ''
  
  #
  # Hooks
  #
  # @var object
  #
  _ion_hooks: null
  
  #
  # Response
  #
  # @var string
  #
  response: ''
  
  #
  # message (uses lang file)
  #
  # @var string
  #
  messages: null
  
  #
  # error message (uses lang file)
  #
  # @var string
  #
  errors: null
  
  #
  # error start delimiter
  #
  # @var string
  #
  error_start_delimiter: ''
  
  #
  # error end delimiter
  #
  # @var string
  #
  error_end_delimiter: ''
  
  constructor: ($CI) ->

    super($CI)

    @CI.load.database()
    @CI.load.config('ion_auth', true)
    @CI.load.helper('cookie')
    @CI.load.helper('date')
    @CI.load.library('session')
    @CI.lang.load('ion_auth')

    # initialize db tables data
    @tables = @config.item('tables', 'ion_auth')

    # initialize data
    @identity_column = @config.item('identity', 'ion_auth')
    @store_salt = @config.item('store_salt', 'ion_auth')
    @salt_length = @config.item('salt_length', 'ion_auth')
    @join = @config.item('join', 'ion_auth')


    # initialize hash method options (Bcrypt)
    @hash_method = @config.item('hash_method', 'ion_auth')
    @default_rounds = @config.item('default_rounds', 'ion_auth')
    @random_rounds = @config.item('random_rounds', 'ion_auth')
    @min_rounds = @config.item('min_rounds', 'ion_auth')
    @max_rounds = @config.item('max_rounds', 'ion_auth')

    @_ion_where = []
    @_ion_select = []

    # initialize messages and error
    @messages = []
    @errors = []
    @message_start_delimiter = @config.item('message_start_delimiter', 'ion_auth')
    @message_end_delimiter = @config.item('message_end_delimiter', 'ion_auth')
    @error_start_delimiter = @config.item('error_start_delimiter', 'ion_auth')
    @error_end_delimiter = @config.item('error_end_delimiter', 'ion_auth')

    # initialize our hooks object
    @_ion_hooks = {}

    @trigger_events('model_constructor')

  #
  # Misc functions
  #
  # Hash password : Hashes the password to be stored in the database.
  # Hash password db : This function takes a password and validates it
  # against an entry in the users table.
  # Salt : Generates a random salt value.
  #
  # @author Mathew
  #
  
  #
  # Hashes the password to be stored in the database.
  #
  # @return void
  # @author Mathew
  #
  hash_password: ($password, $salt = false, $use_sha1_override = false) ->

    if empty($password)
      return false

    # bcrypt
    if $use_sha1_override is false and @hash_method is 'bcrypt'
      
      if @random_rounds
        $rand = rand(@min_rounds, @max_rounds)
        $rounds = 'rounds':$rand

      else 
        $rounds = 'rounds':@default_rounds

      @CI.load.library('bcrypt', $rounds)
      return @CI.bcrypt.hash($password)

    if @store_salt and $salt
      return sha1($password + $salt)
      
    else 
      $salt = @salt()
      return $salt + substr(sha1($salt + $password), 0,  - @salt_length)
      
  
  #
  # This function takes a password and validates it
  # against an entry in the users table.
  #
  # @return void
  # @author Mathew
  #
  hash_password_db: ($id, $password, $use_sha1_override = false, $next) ->

    if empty($id) or empty($password)
      return $next false

    @trigger_events('extra_where')

    @db.select('password, salt').where('id', $id).limit(1)
    @db.get @tables['users'], ($err, $query) =>

      if $err then return $next $err

      $hash_password_db = $query.row()

      if $query.num_rows isnt 1
        return $next null, false

      #  bcrypt
      if $use_sha1_override is false and @hash_method is 'bcrypt'

        @CI.load.library('bcrypt', null)
        $next null, @CI.bcrypt.verify($password, $hash_password_db.password)

      else if @store_salt

        $next null, sha1($password + $hash_password_db.salt)

      else

        $salt = substr($hash_password_db.password, 0, @salt_length)
        $next null, $salt + substr(sha1($salt + $password), 0,  - @salt_length)


  #
  # Generates a random salt value for forgotten passwords or any other keys. Uses SHA1.
  #
  # @return void
  # @author Mathew
  #
  hash_code: ($password) ->

    return @hash_password($password, false, true)

  #
  # Generates a random salt value.
  #
  # @return void
  # @author Mathew
  #
  salt: () ->

    return substr(md5(uniqid(rand(), true)), 0, @salt_length)

  #
  # Activation functions
  #
  # Activate : Validates and removes activation code.
  # Deactivae : Updates a users row with an activation code.
  #
  # @author Mathew
  #
  
  #
  # activate
  #
  # @return void
  # @author Mathew
  #
  activate: ($id, $code = false, $next = null) ->

    if $next is null
      $next = $code
      $code = false

    $finish = ($err) =>
      if $err then return $next $err

      $return = @db.affected_rows() is 1
      if $return
        @trigger_events(['post_activate', 'post_activate_successful'])
        @set_message('activate_successful')

      else
        @trigger_events(['post_activate', 'post_activate_unsuccessful'])
        @set_error('activate_unsuccessful')

      return $next null, $return


    @trigger_events('pre_activate')

    if $code isnt false
      @db.select(@identity_column).where('activation_code', $code).limit(1)
      @db.get @tables['users'], ($err, $query) =>

        if $err then return $next $err

        $result = $query.row()

        if $query.num_rows isnt 1
          @trigger_events(['post_activate', 'post_activate_unsuccessful'])
          @set_error('activate_unsuccessful')
          return $next null, false

        $data =
          activation_code:  null,
          active:           1
        $where = array(@identity_column, $result[@identity_column])
        @trigger_events('extra_where')
        @db.update(@tables['users'], $data, $where, $finish)

    else

      $data =
        activation_code:  null,
        active:           1
      $where = 'id':$id
      @trigger_events('extra_where')
      @db.update(@tables['users'], $data, $where, $finish)



  #
  # Deactivate
  #
  # @return void
  # @author Mathew
  #
  deactivate: ($id = null, $next) ->

    @trigger_events('deactivate')

    if not $id?
      @set_error('deactivate_unsuccessful')
      return $next null, false

    $activation_code = sha1(md5(microtime()))
    @activation_code = $activation_code

    $data =
      activation_code:  $activation_code,
      active:           0

    @trigger_events('extra_where')
    @db.update @tables['users'], $data, {'id':$id}, ($err) ->

      if $err then return $next $err

      $return = @db.affected_rows() is 1
      if $return then @set_message('deactivate_successful')
      else @set_error('deactivate_unsuccessful')

      return $next null, $return


  clear_forgotten_password_code: ($code, $next) ->

    if empty($code) then return $next null, false

    @db.where('forgotten_password_code', $code)
    @db.count_all_results @tables['users'], ($err, $count) =>

      if $err then return $next $err

      if $count <= 0 then return $next null, false

      $password = @salt()

      $data =
        'password':   @hash_password($password, $salt)
        'forgotten_password_code':  null
        'forgotten_password_time':  null

      @db.update @tables['users'], $data, {forgotten_password_code: $code}, ($err) =>

        if $err then return $next $err
        return $next null, true

  #
  # reset password
  #
  # @return bool
  # @author Mathew
  #
  reset_password: ($identity, $new, $next) ->

    @trigger_events('pre_change_password')

    if not @identity_check($identity)
      @trigger_events(['post_change_password', 'post_change_password_unsuccessful'])
      return $next null, false

    @trigger_events('extra_where')
    @db.select('id, password, salt').where(@identity_column, $identity).limit(1)
    @db.get @tables['users'], ($err, $query) =>

      if $err then return $next $err

      $result = $query.row()
      $new = @hash_password($new, $result.salt)

      # store the new password and reset the remember code so all remembered instances have to re-login
      # also clear the forgotten password code
      $data =
        password:                 $new
        remember_code:            null
        forgotten_password_code:  null
        active:                   1

      @trigger_events('extra_where')
      @db.update @tables['users'], $data, @identity_column:$identity, ($err) =>

        if $err then return $next $err

        $return = @db.affected_rows() is 1
        if $return
          @trigger_events(['post_change_password', 'post_change_password_successful'])
          @set_message('password_change_successful')

        else
          @trigger_events(['post_change_password', 'post_change_password_unsuccessful'])
          @set_error('password_change_unsuccessful')

        return $next null, $return

  #
  # change password
  #
  # @return bool
  # @author Mathew
  #
  change_password: ($identity, $old, $new, $next) ->

    @trigger_events('pre_change_password')
    @trigger_events('extra_where')

    @db.select('id, password, salt').where(@identity_column, $identity).limit(1)
    @db.get @tables['users'], ($err, $query) =>

      if $err then return $next $err

      if $query.num_rows isnt 1
        @trigger_events(['post_change_password', 'post_change_password_unsuccessful'])
        @set_error('password_change_unsuccessful')
        return $next null, false

      $result = $query.row()

      $db_password = $result.password
      $old = @hash_password_db($result.id, $old)
      $new = @hash_password($new, $result.salt)

      if @hash_method is 'sha1' and $db_password is $old or @hash_method is 'bcrypt' and $old is true
        # store the new password and reset the remember code so all remembered instances have to re-login
        $data =
          'password':       $new
          'remember_code':  null

        @trigger_events('extra_where')
        @db.update @tables['users'], $data, @identity_column:$identity, ($err) =>

          if $err then return $next $err

          $return = @db.affected_rows() is 1
          if $return
            @trigger_events(['post_change_password', 'post_change_password_successful'])
            @set_message('password_change_successful')

          else
            @trigger_events(['post_change_password', 'post_change_password_unsuccessful'])
            @set_error('password_change_unsuccessful')

          return $next null, $return

      else

        @set_error('password_change_unsuccessful')
        return $next null, false

  #
  # Checks username
  #
  # @return bool
  # @author Mathew
  #
  username_check: ($username = '', $next) ->

    @trigger_events('username_check')
    if empty($username) then return $next null, false

    @trigger_events('extra_where')
    @db.where('username', $username)
    @db.count_all_results @tables['users'], ($err, $count) =>

      if $err then return $next $err
      return $next null, ($count > 0)

  #
  # Checks email
  #
  # @return bool
  # @author Mathew
  #
  email_check: ($email = '', $next) ->

    @trigger_events('email_check')
    if empty($email) then return $next null, false

    @trigger_events('extra_where')
    @db.where('email', $email)
    @db.count_all_results @tables['users'], ($err, $count) =>

      if $err then return $next $err
      return $next null, ($count > 0)


  #
  # Identity check
  #
  # @return bool
  # @author Mathew
  #
  identity_check: ($identity = '', $next) ->

    @trigger_events('identity_check')
    if empty($identity) then return $next null, false

    @db.where(@identity_column, $identity)
    @db.count_all_results @tables['users'], ($err, $count) =>

      if $err then return $next $err
      return $next null, ($count > 0)

  #
  # Insert a forgotten password key.
  #
  # @return bool
  # @author Mathew
  # @updated Ryan
  #
  forgotten_password: ($identity, $next) ->

    if empty($identity)
      @trigger_events(['post_forgotten_password', 'post_forgotten_password_unsuccessful'])
      return $next null, false

    $key = @hash_code(microtime() + $identity)
    @forgotten_password_code = $key
    @trigger_events('extra_where')
    $update =
      'forgotten_password_code':$key
      'forgotten_password_time':time()

    @db.update @tables['users'], $update, array(@identity_column:$identity), ($err) =>

      if $err then return $next $err

      $return = @db.affected_rows() is 1

      if $return then @trigger_events(['post_forgotten_password', 'post_forgotten_password_successful'])
      else @trigger_events(['post_forgotten_password', 'post_forgotten_password_unsuccessful'])

      return $next null, $return

  #
  # Forgotten Password Complete
  #
  # @return string
  # @author Mathew
  #
  forgotten_password_complete: ($code, $salt = false, $next) ->

    @trigger_events('pre_forgotten_password_complete')
    if empty($code)
      @trigger_events(['post_forgotten_password_complete', 'post_forgotten_password_complete_unsuccessful'])
      return $next null, false

    $profile = @where('forgotten_password_code', $code).users().row()# pass the code to profile

    if $profile
      if @config.item('forgot_password_expiration', 'ion_auth') > 0
        # Make sure it isn't expired
        $expiration = @config.item('forgot_password_expiration', 'ion_auth')
        if time() - $profile.forgotten_password_time > $expiration
          # it has expired
          @set_error('forgot_password_expired')
          @trigger_events(['post_forgotten_password_complete', 'post_forgotten_password_complete_unsuccessful'])
          return $next null, false

      $password = @salt()
      $data =
        password:                   @hash_password($password, $salt)
        forgotten_password_code:    null
        active:                     1

      @db.update @tables['users'], $data, {forgotten_password_code:$code}, ($err) =>

        if $err then return $next $err

        @trigger_events(['post_forgotten_password_complete', 'post_forgotten_password_complete_successful'])
        return $next null, $password

    else

      @trigger_events(['post_forgotten_password_complete', 'post_forgotten_password_complete_unsuccessful'])
      return $next null, false

  #
  # register
  #
  # @return bool
  # @author Mathew
  #
  register: ($username, $password, $email, $additional_data = {}, $groups = {}, $next) ->

    @trigger_events('pre_register')

    $manual_activation = @config.item('manual_activation', 'ion_auth')

    if @identity_column is 'email'
      @email_check $email, ($err, $found) =>
        if $err then return $next $err
        if $found
          @set_error('account_creation_duplicate_email')
          return $next null, false

        if @identity_column is 'username'
          @username_check $username, ($err, $found) =>
            if $err then return $next $err
            if $found
              @set_error('account_creation_duplicate_username')
              return $next null, false

            #  IP Address
            $ip_address = @input.ip_address()
            $salt = if @store_salt then @salt() else false
            $password = @hash_password($password, $salt)

            #  Users table.
            $data =
              username:   $username
              password:   $password
              email:      $email
              ip_address: sprintf('%u', ip2long($ip_address))
              created_on: time()
              last_login: time()
              active:     if $manual_activation is false then 1 else 0

            if @store_salt
              $data['salt'] = $salt

            # filter out any data passed that doesnt have a matching column in the users table
            # and merge the set user data and the additional data
            $user_data = array_merge(@_filter_data(@tables['users'], $additional_data), $data)

            @trigger_events('extra_set')

            @db.insert @tables['users'], $user_data, ($err) =>

              if $err then return $next $err

              $id = @db.insert_id()

              if not empty($groups)
                # add to groups
                for $group in $groups
                  @add_to_group($group, $id)

              # add to default group if not already set
              $default_group = @where('name', @config.item('default_group', 'ion_auth')).group().row()
              if $default_group.id?  and $groups?  and  not empty($groups) and  not in_array($default_group.id, $groups) or  not $groups?  or empty($groups)
                @add_to_group($default_group.id, $id)

              @trigger_events('post_register')

              return $next null, if $id? then $id else false

  #
  # login
  #
  # @return bool
  # @author Mathew
  #
  login: ($identity, $password, $remember = false, $next) ->

    @trigger_events('pre_login')

    if empty($identity) or empty($password)
      @set_error('login_unsuccessful')
      return $next null, false

    @trigger_events('extra_where')

    @db.select(@identity_column + ', username, email, id, password, active, last_login')
    @db.where(sprintf("(" + @identity_column + " = '%1\$s')", @db.escape_str($identity))).limit(1)
    @db.get @tables['users'], ($err, $query) =>

      if $err then return $next $err

      if $query.num_rows is 1
        $user = $query.row()

        $password = @hash_password_db($user.id, $password)

        if @hash_method is 'sha1' and $user.password is $password or @hash_method is 'bcrypt' and $password is true
          if $user.active is 0
            @trigger_events('post_login_unsuccessful')
            @set_error('login_unsuccessful_not_active')
            return $next null, false

          $session_data =
            identity:       $user[@identity_column]
            username:       $user.username
            email:          $user.email
            user_id:        $user.id # everyone likes to overwrite id so we'll use user_id
            old_last_login: $user.last_login

          @update_last_login $user.id, ($err) =>

            if $err then return $next $err
            @session.set_userdata($session_data)

            if $remember and @config.item('remember_users', 'ion_auth')
              @remember_user $user.id, ($err) =>

                if $err then return $next $err
                @trigger_events(['post_login', 'post_login_successful'])
                @set_message('login_successful')

                return $next null, true

            @trigger_events(['post_login', 'post_login_successful'])
            @set_message('login_successful')

            return $next null, true

      @trigger_events('post_login_unsuccessful')
      @set_error('login_unsuccessful')

      return $next null, false

  limit: ($limit) ->

    @trigger_events('limit')
    @_ion_limit = $limit
    return @


  offset: ($offset) ->

    @trigger_events('offset')
    @_ion_offset = $offset
    return @

  where: ($where, $value = null) ->

    @trigger_events('where')
    if not is_array($where)
      $where = array($where, $value)
    array_push(@_ion_where, $where)
    return @

  select: ($select) ->

    @trigger_events('select')
    @_ion_select.push $select
    return @

  order_by: ($by, $order = 'desc') ->

    @trigger_events('order_by')
    @_ion_order_by = $by
    @_ion_order = $order
    return @

  row: () ->

    @trigger_events('row')
    $row = @response.row()
    @response.free_result()
    return $row

  row_array: () ->

    @trigger_events(['row', 'row_array'])
    $row = @response.row_array()
    @response.free_result()
    return $row

  result: () ->

    @trigger_events('result')
    $result = @response.result()
    @response.free_result()
    return $result

  result_array: () ->

    @trigger_events(['result', 'result_array'])
    $result = @response.result_array()
    @response.free_result()
    return $result

  #
  # users
  #
  # @return object Users
  # @author Ben Edmunds
  #
  users: ($groups = null, $next = null) ->

    if $next is null
      $next = $groups
      $groups = null

    @trigger_events('users')

    # default selects
    @db.select([
      @tables['users'] + '.*',
      @tables['users'] + '.id as id',
      @tables['users'] + '.id as user_id'
      ])

    if @_ion_select?
      for $select in @_ion_select
        @db.select($select)
      @_ion_select = []

    # filter by group id(s) if passed
    if $groups?
      # build an array if only one group was passed
      if is_numeric($groups)
        $groups = [$groups]

      # join and then run a where_in against the group ids
      if $groups?  and  not empty($groups)
        @db.join(
          @tables['users_groups'],
          @tables['users_groups'] + '.user_id = ' + @tables['users'] + '.id',
          'inner'
        )

        @db.where_in(@tables['users_groups'] + '.group_id', $groups)

    @trigger_events('extra_where')

    # run each where that was passed
    if @_ion_where?
      for $where in @_ion_where
        @db.where($where)

      @_ion_where = []

    if @_ion_limit?  and @_ion_offset?
      @db.limit(@_ion_limit, @_ion_offset)

      @_ion_limit = null
      @_ion_offset = null

    # set the order
    if @_ion_order_by?  and @_ion_order?
      @db.order_by(@_ion_order_by, @_ion_order)

      @_ion_order = null
      @_ion_order_by = null

    @db.get @tables['users'], $next


  #
  # user
  #
  # @return object
  # @author Ben Edmunds
  #
  user: ($id = null, $next) ->

    @trigger_events('user')
    # if no id was passed use the current users id
    $id or ($id = @session.userdata('user_id'))
    
    @limit(1)
    @where(@tables['users'] + '.id', $id)
    @users(null, $next)

  #
  # get_users_groups
  #
  # @return array
  # @author Ben Edmunds
  #
  get_users_groups: ($id = false, $next) ->

    @trigger_events('get_users_group')
    # if no id was passed use the current users id
    $id or ($id = @session.userdata('user_id'))
    @db.select(@tables['users_groups'] + '.' + @join['groups'] + ' as id, ' + @tables['groups'] + '.name, ' + @tables['groups'] + '.description').where(@tables['users_groups'] + '.' + @join['users'], $id).join(@tables['groups'], @tables['users_groups'] + '.' + @join['groups'] + '=' + @tables['groups'] + '.id')
    @db.get @tables['users_groups'], $next

  #
  # add_to_group
  #
  # @return bool
  # @author Ben Edmunds
  #
  add_to_group: ($group_id, $user_id = false, $next) ->

    @trigger_events('add_to_group')
    # if no id was passed use the current users id
    $user_id or ($user_id = @session.userdata('user_id'))
    @db.insert(@tables['users_groups'], array(@join['groups'], $group_id), array(@join['users'], $user_id), $next)

  #
  # remove_from_group
  #
  # @return bool
  # @author Ben Edmunds
  #
  remove_from_group: ($group_id = false, $user_id = false, $next) ->

    @trigger_events('remove_from_group')
    # if no id was passed use the current users id
    $user_id or ($user_id = @session.userdata('user_id'))
    #  if no group id is passed remove user from all groups
    if not empty($group_id)
      return @db.delete(@tables['users_groups'], array_merge(array(@join['groups'], $group_id), array(@join['users'], $user_id)), $next)

    else
      return @db.delete(@tables['users_groups'], array(@join['users'], $user_id), $next)

  #
  # groups
  #
  # @return object
  # @author Ben Edmunds
  #
  groups: ($next) ->

    @trigger_events('groups')

    # run each where that was passed
    if @_ion_where?
      for $where in @_ion_where
        @db.where($where)
      @_ion_where = {}

    if @_ion_limit?  and @_ion_offset?
      @db.limit(@_ion_limit, @_ion_offset)

      @_ion_limit = null
      @_ion_offset = null

    # set the order
    if @_ion_order_by?  and @_ion_order?
      @db.order_by(@_ion_order_by, @_ion_order)

    @response = @db.get(@tables['groups'], $next)

  #
  # group
  #
  # @return object
  # @author Ben Edmunds
  #
  group: ($next) ->

    @trigger_events('group')
    @limit(1)
    @groups($next)

  #
  # update
  #
  # @return bool
  # @author Phil Sturgeon
  #
  update: ($id, $data, $next) ->

    @trigger_events('pre_update_user')
    $user = @user($id).row()
    @db.trans_begin ($err) =>

      if $err then return $next $err

      if array_key_exists(@identity_column, $data) and @identity_check($data[@identity_column]) and $user[@identity_column] isnt $data[@identity_column]
        @db.trans_rollback ($err) =>

          if $err then return $next $err

          @set_error('account_creation_duplicate_' + @identity_column)
          @trigger_events(['post_update_user', 'post_update_user_unsuccessful'])
          @set_error('update_unsuccessful')
          return $next null, false

      #  Filter the data passed
      $data = @_filter_data(@tables['users'], $data)
      if array_key_exists('username', $data) or array_key_exists('password', $data) or array_key_exists('email', $data)
        if array_key_exists('password', $data)
          $data['password'] = @hash_password($data['password'], $user.salt)

      @trigger_events('extra_where')
      @db.update @tables['users'], $data, {id:$user.id}, ($err) =>

        if $err then return $next $err

        if @db.trans_status() is false
          @db.trans_rollback ($err) =>

            if $err then return $next $err
            @trigger_events(['post_update_user', 'post_update_user_unsuccessful'])
            @set_error('update_unsuccessful')
            return $next null, false

        @db.trans_commit ($err) =>

          if $err then return $next $err
          @trigger_events(['post_update_user', 'post_update_user_successful'])
          @set_message('update_successful')
          return $next null, true

  #
  # delete_user
  #
  # @return bool
  # @author Phil Sturgeon
  #
  delete_user: ($id, $next) ->

    @trigger_events('pre_delete_user')
    @db.trans_begin ($err) =>

      if $err then return $next $err

      @db.delete @tables['users'], {id:$id}, ($err) =>

        if $err then return $next $err

        @remove_from_group null, $id, ($err) =>

          if $err then return $next $err

          if @db.trans_status() is false

            @db.trans_rollback ($err) =>

              if $err then return $next $err

              @trigger_events(['post_delete_user', 'post_delete_user_unsuccessful'])
              @set_error('delete_unsuccessful')
              return $next null, false

          @db.trans_commit ($err) =>

            if $err then return $next $err

            @trigger_events(['post_delete_user', 'post_delete_user_successful'])
            @set_message('delete_successful')
            return $next null, true

  #
  # update_last_login
  #
  # @return bool
  # @author Ben Edmunds
  #
  update_last_login: ($id, $next) ->

    @trigger_events('update_last_login')
    @load.helper('date')
    @trigger_events('extra_where')
    @db.update @tables['users'], {last_login:time(), id:$id}, ($err) =>

      if $err then return $next $err
      return $next null, (@db.affected_rows() is 1)


  #
  # set_lang
  #
  # @return bool
  # @author Ben Edmunds
  #
  set_lang: ($lang = 'en') ->

    @trigger_events('set_lang')
    @CI.input.set_cookie(
      name:     'lang_code',
      value:    $lang,
      expire:   @config.item('user_expire', 'ion_auth' + time())
    )
    return true

  #
  # remember_user
  #
  # @return bool
  # @author Ben Edmunds
  #
  remember_user: ($id, $next) ->

    @trigger_events('pre_remember_user')

    if not $id
      return $next null, false

    $user = @user($id).row()
    $salt = sha1($user.password)
    @db.update @tables['users'], {'remember_code':$salt, 'id':$id}, ($err) =>

      if $err then return $next $err

      if @db.affected_rows() >  - 1
        @CI.input.set_cookie(
          name:     'identity',
          value:    $user[@identity_column],
          expire:   @config.item('user_expire', 'ion_auth')
        )

        @CI.input.set_cookie(
          name:     'remember_code',
          value:    $salt,
          expire:   @config.item('user_expire', 'ion_auth')
        )

        @trigger_events(['post_remember_user', 'remember_user_successful'])
        return $next null, true

      @trigger_events(['post_remember_user', 'remember_user_unsuccessful'])
      return $next null, false


  #
  # login_remembed_user
  #
  # @return bool
  # @author Ben Edmunds
  #
  login_remembered_user: ($next) ->

    @trigger_events('pre_login_remembered_user')
    # check for valid data
    if not get_cookie('identity') or  not get_cookie('remember_code') or  not @identity_check(get_cookie('identity'))
      @trigger_events(['post_login_remembered_user', 'post_login_remembered_user_unsuccessful'])
      return $next null, false

    # get the user
    @trigger_events('extra_where')
    @db.select(@identity_column + ', id').where(@identity_column, get_cookie('identity')).where('remember_code', get_cookie('remember_code')).limit(1)
    @db.get @tables['users'], ($err, $query) =>

      if $err then return $next $err
      # if the user was found, sign them in
      if $query.num_rows is 1
        $user = $query.row()
        @update_last_login $user.id, ($err) =>

          if $err then return $next $err

          $session_data =
            @identity_column:   $user[@identity_column]
            id:                 $user.id # kept for backwards compatibility
            user_id:            $user.id # everyone likes to overwrite id so we'll use user_id

          @session.set_userdata($session_data)
          # extend the users cookies if the option is enabled
          if @config.item('user_extend_on_login', 'ion_auth')
            @remember_user $user.id, ($err) =>

              if $err then return $next $err

              @trigger_events(['post_login_remembered_user', 'post_login_remembered_user_successful'])
              return $next null, true


          @trigger_events(['post_login_remembered_user', 'post_login_remembered_user_successful'])
          return $next null, true

      @trigger_events(['post_login_remembered_user', 'post_login_remembered_user_unsuccessful'])
      return $calback null, false

  set_hook: ($event, $name, $class, $method, $arguments) ->

    if not @_ion_hooks[$event]? then @_ion_hooks[$event] = {}

    @_ion_hooks[$event][$name] = 
      class:      $class
      method:     $method
      arguments:  $arguments
  
  remove_hook: ($event, $name) ->

    if @_ion_hooks[$event]?
      if @_ion_hooks[$event][$name]?
        delete @_ion_hooks[$event][$name]
    
  
  remove_hooks: ($event) ->

    if @_ion_hooks[$event]?
      delete @_ion_hooks[$event]
  
  _call_hook: ($event, $name) ->

    if @_ion_hooks[$event]?
      if @_ion_hooks[$event][$name]?  and method_exists(@_ion_hooks[$event][$name].class, @_ion_hooks[$event][$name].method)
        $hook = @_ion_hooks[$event][$name]
        return call_user_func_array([$hook.class, $hook.method], $hook.arguments)
    return false
  
  trigger_events: ($events) ->

    if is_array($events) and  not empty($events)
      for $event in $events
        @trigger_events($event)

    else
      if @_ion_hooks[$events]  and  not empty(@_ion_hooks[$events])
        for $name, $hook of @_ion_hooks.$events
          @_call_hook($events, $name)
        

  #
  # set_message_delimiters
  #
  # Set the message delimiters
  #
  # @return void
  # @author Ben Edmunds
  #
  set_message_delimiters: ($start_delimiter, $end_delimiter) ->

    @message_start_delimiter = $start_delimiter
    @message_end_delimiter = $end_delimiter
    return true

  #
  # set_error_delimiters
  #
  # Set the error delimiters
  #
  # @return void
  # @author Ben Edmunds
  #
  set_error_delimiters: ($start_delimiter, $end_delimiter) ->

    @error_start_delimiter = $start_delimiter
    @error_end_delimiter = $end_delimiter
    return true

  #
  # set_message
  #
  # Set a message
  #
  # @return void
  # @author Ben Edmunds
  #
  set_message: ($message) ->

    @messages.push $message
    return $message

  #
  # messages
  #
  # Get the messages
  #
  # @return void
  # @author Ben Edmunds
  #
  messages: () ->

    $_output = ''
    for $message in @messages
      $messageLang = if @lang.line($message) then @lang.line($message) else '##' + $message + '##'
      $_output+=@message_start_delimiter + $messageLang + @message_end_delimiter
    return $_output

  #
  # set_error
  #
  # Set an error message
  #
  # @return void
  # @author Ben Edmunds
  #
  set_error: ($error) ->

    @errors.push $error
    return $error

  #
  # errors
  #
  # Get the error message
  #
  # @return void
  # @author Ben Edmunds
  #
  errors: () ->

    $_output = ''
    for $error in @errors
      $errorLang = if @lang.line($error) then @lang.line($error) else '##' + $error + '##'
      $_output+=@error_start_delimiter + $errorLang + @error_end_delimiter
    return $_output

  _filter_data: ($table, $data) ->

    $filtered_data = {}
    $columns = @db.list_fields($table)

    if is_array($data)
      for $column in $columns
        if array_key_exists($column, $data)
          $filtered_data[$column] = $data[$column]
    return $filtered_data

module.exports = Ion_auth_model