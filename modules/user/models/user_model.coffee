#+--------------------------------------------------------------------+
#| user_model.coffee
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
#	User Model
#
#
#
#  --------------------------------------------------------------------

class global.User_model extends Exspresso_Model

  @UID_ANONYMOUS       = 1
  @UID_ADMIN           = 2
  @UID_TEST            = 3
  @RID_ANONYMOUS       = 1
  @RID_ADMIN           = 2
  @RID_MEMBER          = 3

  _anonymous_user:
    uid           : User_model.UID_ANONYMOUS
    name          : 'anonymous'
    email         : ''
    created_on    : Date.now()
    last_login    : Date.now()
    active        : 1 # $config.allow_anonymous
    roles         : [
      {rid: User_model.RID_ANONYMOUS, name:'anon', description:'Anonymous'}
    ]

  ## --------------------------------------------------------------------

  #
  # Anonymous user
  #
  #   Get the default anonymous use record
  #
  # @access	public
  # @return	object
  #
  anonymous_user: () -> @_anonymous_user

  ## --------------------------------------------------------------------

  #
  # Load by id
  #
  #   load user by uid
  #
  # @access	public
  # @return	object
  #
  load_by_id: ($id, $next) =>

    @db.where 'uid', $id
    @db.get 'users', ($err, $user) =>
      $user = $user.row() unless $err
      $next $err, $user

  ## --------------------------------------------------------------------

  #
  # Load by name
  #
  #   load user by name
  #
  # @access	public
  # @return	object
  #
  load_by_name: ($name, $next) =>

    @db.where 'name', $name
    @db.get 'users', ($err, $user) =>
      $user = $user.row() unless $err
      $next $err, $user

  load_roles: ($uid, $next) =>

    @db.select 'roles.rid, name, description'
    @db.from 'roles'
    @db.join 'user_roles', 'user_roles.rid = roles.rid'
    @db.where 'uid', $uid
    @db.get ($err, $roles) =>
      $roles = $roles.result() unless $err
      $next $err, $roles



  delete: ($uid, $next) ->


  ## --------------------------------------------------------------------

  #
  # Session Database setup
  #
  #   create session table if it doesn't exist
  #   this is called by Exspresso.server.start
  #
  # @access	public
  # @return	void
  #
  setup: () ->

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

module.exports = User_model
## --------------------------------------------------------------------

#
# Class Migrate
#
class Migrate
  up: ($next) =>

    Exspresso.db.table_exists @name, ($err, $table_exists) =>

      if $err then return $next $err
      if $table_exists then return $next null

      Exspresso.load.dbforge()
      Exspresso.dbforge.add_field @fields
      Exspresso.dbforge.add_key @pkey, true
      Exspresso.dbforge.add_key $key for $key in @key
      Exspresso.dbforge.create_table @name, ($err) =>

        if $err then return $next $err
        if @data.length is 0
          $next()
        else
          Exspresso.db.insert_batch @name, @data, $next

## --------------------------------------------------------------------

#
# Class Migrate
#
class Migrate_session extends Migrate

  name: 'sessions'
  pkey: 'sid'
  key: ['last_activity']
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
  data: []



## --------------------------------------------------------------------

#
# Class Migrate
#
class Migrate_roles extends Migrate

  name: 'roles'
  pkey: 'rid'
  key:  []
  fields:
        rid:
          type:'INT', constraint:10, unsigned:true, null:false, auto_increment:true
        name:
          type:'VARCHAR', constraint:'20', null:false
        description:
          type:'VARCHAR', constraint:'100', null:false

  data: [
    {rid: User_model.RID_ANONYMOUS, name:'anon', description:'Anonymous'}
    {rid: User_model.RID_ADMIN, name:'admin', description:'Administrator'}
    {rid: User_model.RID_MEMBER, name:'member', description:'Member'}
  ]

## --------------------------------------------------------------------

#
# Class Migrate
#
class Migrate_users extends Migrate

  name: 'users'
  pkey: 'uid'
  key:  []
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

  data: [
    {uid: User_model.UID_ANONYMOUS, name: 'anonymous', password: '', salt: '', email: '', created_on: 1268889823, last_login: 1268889823, active: 1}
    {uid: User_model.UID_ADMIN, name: 'admin', password: '$2a$10$G6QlZBj3Ie4dIirolpBGje', salt: 'X9AToNatEwEGPc6FM0rA.sqnH51AGli', email: 'admin@admin.com', created_on: 1268889823, last_login: 1268889823, active: 1}
    {uid: User_model.UID_TEST, name: 'shaggy', password: '$2a$10$G6QlZBj3Ie4dIirolpBGje', salt: 'X9AToNatEwEGPc6FM0rA.sqnH51AGli', email: 'admin@admin.com', created_on: 1268889823, last_login: 1268889823, active: 1}
  ]

## --------------------------------------------------------------------

#
# Class Migrate
#
class Migrate_user_roles extends Migrate

  name: 'user_roles'
  pkey: 'id'
  key:  []
  fields:
        id:
          type:'INT', constraint:10, 'unsigned':true, null:false, auto_increment:true
        uid:
          type:'INT', constraint:10, 'unsigned':true, null:false
        rid:
          type:'INT', constraint:10, 'unsigned':true, null:false
  data: [
    {uid: User_model.UID_ANONYMOUS, rid: User_model.RID_ANONYMOUS}
    {uid: User_model.UID_ADMIN, rid: User_model.RID_ADMIN}
    {uid: User_model.UID_ADMIN, rid: User_model.RID_ANONYMOUS}
    {uid: User_model.UID_ADMIN, rid: User_model.RID_MEMBER}
    {uid: User_model.UID_TEST, rid: User_model.RID_MEMBER}
  ]


# End of file user_model.coffee
# Location: .modules/user/models/user_model.coffee