#+--------------------------------------------------------------------+
#| UserModel.coffee
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

#
#   User Data Model
#

class modules.user.models.UserModel extends system.core.Model

  @UID_ANONYMOUS       = 1
  @UID_ADMIN           = 2
  @UID_TEST            = 3
  @RID_ANONYMOUS       = 1
  @RID_ADMIN           = 2
  @RID_MEMBER          = 3

  #
  # Load by id
  #
  #   load user by uid
  #
  # @return [Object]  #
  loadById: ($id, $next) ->

    @db.where 'uid', $id
    @db.get 'users', ($err, $user) =>
      return $next($err) if $err
      $user = $user.row()
      @load_roles $user.uid, ($err, $roles) =>
        $user.roles = $roles
        $next(null, $user)

  #
  # Load by name
  #
  #   load user by name
  #
  # @return [Object]  #
  loadByName: ($name, $next) ->

    @db.where 'name', $name
    @db.get 'users', ($err, $user) =>
      return $next($err) if $err
      $user = $user.row()
      @load_roles $user.uid, ($err, $roles) =>
        $user.roles = $roles
        $next(null, $user)

  #
  # Load roles for a user
  #
  # @return [Object]  #
  load_roles: ($uid, $next) ->

    @db.select 'roles.rid, name, description'
    @db.from 'roles'
    @db.join 'user_roles', 'user_roles.rid = roles.rid'
    @db.where 'uid', $uid
    @db.get ($err, $roles) =>
      if $err then $next(null, [])
      else $next(null, $roles.result())


  #
  # Add role to user
  #
  # @return [Object]  #
  add_role: ($uid, $role, $next) ->

    #
    # Remove role from user
    #
      # @return [Object]  #
  remove_role: ($uid, $role, $next) ->

  #
  # Delete a user
  #
  # @return [Object]  #
  delete: ($uid, $next) ->


  #
  # Installation
  #
  #   Create session tables if they don't exist.
  #   This is called from Server.start as part
  #   of the boot sequence.
  #
  # @return [Void]
  #
  install: ->
    @load.dbforge() unless @dbforge?
    @queue @install_session
    @queue @install_roles
    @queue @install_users
    @queue @install_user_roles


  #
  # Step 1:
  # Install Check
  #
  # Create the sessions table
  #
  install_session: ($next) =>

    @dbforge.createTable 'sessions', $next, ($sessions) ->
      $sessions.addKey 'sid', true
      $sessions.addKey ['last_activity']
      $sessions.addField
        sid:
          type: 'VARCHAR', constraint: 24, default: '0', null: false
        uid:
          type: 'INT', constraint: 10, unsigned: true, default: 1, null: false
        ip_address:
          type: 'VARCHAR', constraint: 45, default: '0', null: false
        user_agent:
          type: 'VARCHAR', constraint: 120, null: false
        last_activity:
          type: 'INT', constraint: 10, unsigned: true, default: 0, null: false
        user_data:
          type: 'TEXT', null: true

  #
  # Step 2:
  # Install Roles
  #
  # Create the roles table
  #
  install_roles: ($next) =>

    @dbforge.createTable 'roles', $next, ($roles) ->
      $roles.addKey 'rid', true
      $roles.addField
        rid:
          type:'INT', constraint:10, unsigned:true, null:false, auto_increment:true
        name:
          type:'VARCHAR', constraint:'20', null:false
        description:
          type:'VARCHAR', constraint:'100', null:false

      $roles.addData [
          {rid: UserModel.RID_ANONYMOUS, name:'anon', description:'Anonymous'}
          {rid: UserModel.RID_ADMIN, name:'admin', description:'Administrator'}
          {rid: UserModel.RID_MEMBER, name:'member', description:'Member'}
        ]

  #
  # Step 3:
  # Install Users
  #
  # Create the users table
  #
  install_users: ($next) =>

    @dbforge.createTable 'users', $next, ($users) ->
      $users.addKey 'uid', true
      $users.addField
        uid:
          type:'INT', constraint:10, unsigned:true, null:false, auto_increment:true
        name:
          type:'VARCHAR', constraint:'100', null:false
        password:
          type:'VARCHAR', constraint:'40', null:false
        salt:
          type:'VARCHAR', constraint:'40', null:true
        email:
          type:'VARCHAR', constraint:'100', null:false
        created_on:
          type:'int', constraint:'11', unsigned:true, null:false
        last_login:
          type:'int', constraint:'11', unsigned:true, null:true
        active:
          type:'tinyint', constraint:'1', unsigned:true, null:true

      $users.addData [
          {uid: UserModel.UID_ANONYMOUS, name: 'anonymous', password: '', salt: '', email: '', created_on: 1268889823, last_login: 1268889823, active: 1}
          {uid: UserModel.UID_ADMIN, name: 'admin', password: '$2a$10$G6QlZBj3Ie4dIirolpBGje', salt: 'X9AToNatEwEGPc6FM0rA.sqnH51AGli', email: 'admin@admin.com', created_on: 1268889823, last_login: 1268889823, active: 1}
          {uid: UserModel.UID_TEST, name: 'shaggy', password: '$2a$10$G6QlZBj3Ie4dIirolpBGje', salt: 'X9AToNatEwEGPc6FM0rA.sqnH51AGli', email: 'admin@admin.com', created_on: 1268889823, last_login: 1268889823, active: 1}
        ]

  #
  # Step 4:
  # Install User/Roles index
  #
  # Create the user_roles table
  #
  install_user_roles: ($next) =>

    @dbforge.createTable 'user_roles', $next, ($user_roles) ->
      $user_roles.addKey 'id', true
      $user_roles.addField
        id:
          type:'INT', constraint:10, 'unsigned':true, null:false, auto_increment:true
        uid:
          type:'INT', constraint:10, 'unsigned':true, null:false
        rid:
          type:'INT', constraint:10, 'unsigned':true, null:false

      $user_roles.addData [
          {uid: UserModel.UID_ANONYMOUS, rid: UserModel.RID_ANONYMOUS}
          {uid: UserModel.UID_ADMIN,     rid: UserModel.RID_ADMIN}
          {uid: UserModel.UID_ADMIN,     rid: UserModel.RID_ANONYMOUS}
          {uid: UserModel.UID_ADMIN,     rid: UserModel.RID_MEMBER}
          {uid: UserModel.UID_TEST,      rid: UserModel.RID_MEMBER}
        ]




# END CLASS UserModel

module.exports = UserModel = modules.user.models.UserModel


# End of file UserModel.coffee
# Location: .modules/user/models/UserModel.coffee