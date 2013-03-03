#+--------------------------------------------------------------------+
#| user_model.coffee
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
#   User Data Model
#
class global.User_model extends ExspressoModel

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
  # @access	public
  # @return	object
  #
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
  # @access	public
  # @return	object
  #
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
  # @access	public
  # @return	object
  #
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
  # @access	public
  # @return	object
  #
  add_role: ($uid, $role, $next) ->

    #
    # Remove role from user
    #
    # @access	public
    # @return	object
    #
  remove_role: ($uid, $role, $next) ->

  #
  # Delete a user
  #
  # @access	public
  # @return	object
  #
  delete: ($uid, $next) ->


  #
  # Installation check
  #
  #   create session table if it doesn't exist
  #   this is called by Exspresso.server.start
  #
  # @access	public
  # @return	void
  #
  installCheck: () ->

    # Create the session table
    Exspresso.queue ($next) ->
      $migrate = new Migrate_session()
      $migrate.up $next

    # Create the roles table
    Exspresso.queue ($next) ->
      $migrate = new Migrate_roles()
      $migrate.up $next

    # Create the users table
    Exspresso.queue ($next) ->
      $migrate = new Migrate_users()
      $migrate.up $next

    # Create the user_roles table
    Exspresso.queue ($next) ->
      $migrate = new Migrate_user_roles()
      $migrate.up $next

# END CLASS User_model

module.exports = User_model

#  ------------------------------------------------------------------------

#
# Class Migrate
#
#   Base class for database migrations
#
class Migrate

  name        : ''      # table name
  pkey        : ''      # primary key
  key         : null    # secondary key(s)
  fields      : null    # database column definitions
  data        : null    # data rows to insert
  #
  # Apply database changes
  #
  #
  up: ($next) =>

    # check if the migration is needed
    Exspresso.db.tableExists @name, ($err, $table_exists) =>

      return $next($err) if $err
      return $next(null) if $table_exists

      # The table doesn't exist, create it
      Exspresso.load.dbforge()
      Exspresso.dbforge.addField @fields
      Exspresso.dbforge.addKey @pkey, true
      Exspresso.dbforge.addKey $key for $key in @key
      Exspresso.dbforge.createTable @name, ($err) =>

        # populate the table
        return $next($err) if $err
        return if @data.length is 0 then $next()
        else Exspresso.db.insertBatch @name, @data, $next

# --------------------------------------------------------------------

#
# Migrate Session table
#
class Migrate_session extends Migrate

  #
  # sessions Table
  #
  name  : 'sessions'
  #
  # sid Primary key
  #
  pkey  : 'sid'
  #
  # Indexes
  #
  key   : ['last_activity']
  #
  # Fields
  #
  fields:
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
  # Initial data
  #
  data  : []



# --------------------------------------------------------------------

#
# Migrate roles
#
class Migrate_roles extends Migrate

  #
  # Table name
  #
  name  : 'roles'
  #
  # Primary key
  #
  pkey  : 'rid'
  #
  # Indexes
  #
  key   :  []
  #
  # Fields
  #
  fields:
        rid:
          type:'INT', constraint:10, unsigned:true, null:false, auto_increment:true
        name:
          type:'VARCHAR', constraint:'20', null:false
        description:
          type:'VARCHAR', constraint:'100', null:false

  #
  # Initial data
  #
  data  : [
    {rid: User_model.RID_ANONYMOUS, name:'anon', description:'Anonymous'}
    {rid: User_model.RID_ADMIN, name:'admin', description:'Administrator'}
    {rid: User_model.RID_MEMBER, name:'member', description:'Member'}
  ]

# --------------------------------------------------------------------

#
# Migrate users
#
class Migrate_users extends Migrate

  #
  # Table name
  #
  name  : 'users'
  #
  # Primary key
  #
  pkey  : 'uid'
  #
  # Indexes
  #
  key   :  []
  #
  # Fields
  #
  fields:
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

  #
  # Initial data
  #
  data  : [
    {uid: User_model.UID_ANONYMOUS, name: 'anonymous', password: '', salt: '', email: '', created_on: 1268889823, last_login: 1268889823, active: 1}
    {uid: User_model.UID_ADMIN, name: 'admin', password: '$2a$10$G6QlZBj3Ie4dIirolpBGje', salt: 'X9AToNatEwEGPc6FM0rA.sqnH51AGli', email: 'admin@admin.com', created_on: 1268889823, last_login: 1268889823, active: 1}
    {uid: User_model.UID_TEST, name: 'shaggy', password: '$2a$10$G6QlZBj3Ie4dIirolpBGje', salt: 'X9AToNatEwEGPc6FM0rA.sqnH51AGli', email: 'admin@admin.com', created_on: 1268889823, last_login: 1268889823, active: 1}
  ]

# --------------------------------------------------------------------

#
# Migrate users x roles
#
class Migrate_user_roles extends Migrate

  #
  # Table name
  #
  name  : 'user_roles'
  #
  # Primary key
  #
  pkey  : 'id'
  #
  # Indexes
  #
  key   : []
  #
  # Fields
  #
  fields:
        id:
          type:'INT', constraint:10, 'unsigned':true, null:false, auto_increment:true
        uid:
          type:'INT', constraint:10, 'unsigned':true, null:false
        rid:
          type:'INT', constraint:10, 'unsigned':true, null:false
  #
  # Initial data
  #
  data  : [
    {uid: User_model.UID_ANONYMOUS, rid: User_model.RID_ANONYMOUS}
    {uid: User_model.UID_ADMIN,     rid: User_model.RID_ADMIN}
    {uid: User_model.UID_ADMIN,     rid: User_model.RID_ANONYMOUS}
    {uid: User_model.UID_ADMIN,     rid: User_model.RID_MEMBER}
    {uid: User_model.UID_TEST,      rid: User_model.RID_MEMBER}
  ]


# End of file user_model.coffee
# Location: .modules/user/models/user_model.coffee