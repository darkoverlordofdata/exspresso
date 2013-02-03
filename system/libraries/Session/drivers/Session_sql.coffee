#+--------------------------------------------------------------------+
#| Session_sql.coffee
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
# Mysql Session store driver
#
#
class Exspresso_Session_sql extends require('express').session.Store

  DEFAULT_UID               = 1 # anonymus user id

  fetch = ($obj, $key, $default='') ->
    if $obj[$key]?
      $val = $obj[$key]
      delete $obj[$key]
    else $val = $default
    return $val

  _sess_encrypt_cookie      : false
  _sess_use_database        : false
  _sess_table_name          : 'sessions'
  _sess_expiration          : 7200
  _sess_expire_on_close     : false
  _sess_match_ip            : false
  _sess_match_useragent     : true
  _sess_cookie_name         : 'sid'
  _cookie_prefix            : 'connect.'
  _cookie_path              : ''
  _cookie_domain            : ''
  _cookie_secure            : false
  _sess_time_to_update      : 300
  _encryption_key           : ''
  _time_reference           : 'local'


  ## --------------------------------------------------------------------

  #
  # Constructor
  #
  #   copy the config values
  #
  # @return 	nothing
  #
  constructor: ($config) ->

    for $key, $val of $config
      if @['_'+$key]?
        @['_'+$key] = $val

    return



  ## --------------------------------------------------------------------

  #
  # get
  #
  #   Gets the session data
  #
  # @param string session id
  # @param function next
  # @return 	nothing
  #
  get: ($sid, $next) ->

    Exspresso.db.reconnect ($err) =>

      return $next($err) if log_message('error', 'Session::get connect %s', $err) if $err

      Exspresso.db.where 'sid', $sid
      Exspresso.db.get @_sess_table_name, ($err, $result) ->

        return $next($err) if log_message('error', 'Session::get %s %s', $sid, $err) if $err

        return $next null, null if $result.num_rows is 0

        $data = $result.row()
        $session = JSON.parse($data.user_data)
        $session.uid = $data.uid || DEFAULT_UID
        $session.ip_address = $data.ip_address
        $session.user_agent = $data.user_agent
        $session.last_activity = $data.last_activity
        $next null, $session


  ## --------------------------------------------------------------------

  #
  # set
  #
  #   Sets the session data
  #
  # @param string session id
  # @param string session data
  # @param function next
  # @return 	nothing
  #
  set: ($sid, $session, $next) ->

    Exspresso.db.reconnect ($err) =>

      return $next($err) if log_message('error', 'Session::set connect %s', $err) if $err

      Exspresso.db.where 'sid', $sid
      Exspresso.db.get @_sess_table_name, ($err, $result) =>

        return $next($err) if log_message('error', 'Session::set %s %s', $sid, $err) if $err

        $user_data = array_merge({}, $session)

        if $result.num_rows is 0
          $data =
            sid             : $sid
            uid             : fetch($user_data, 'uid', DEFAULT_UID)
            ip_address      : fetch($user_data, 'ip_address')
            user_agent      : substr(fetch($user_data, 'user_agent'), 0, 120)
            last_activity   : fetch($user_data, 'last_activity')
            user_data       : JSON.stringify($user_data)

          Exspresso.db.insert @_sess_table_name, $data, ($err) =>
            return $next($err) if log_message('error', 'Session::set insert %s', $err) if $err
            $next()

        else
          delete $user_data['uid']
          delete $user_data['ip_address']
          delete $user_data['user_agent']
          $data =
            last_activity   : fetch($user_data, 'last_activity')
            user_data       : JSON.stringify($user_data)

          Exspresso.db.where 'sid', $sid
          Exspresso.db.update @_sess_table_name, $data, ($err) =>
            return $next($err) if log_message('error', 'Session::set update %s', $err) if $err
            $next()


  ## --------------------------------------------------------------------

  #
  # destroy
  #
  #   Delete the session data
  #
  # @param string session id
  # @param function $next
  # @return 	nothing
  #
  destroy: ($sid, $next) ->

    Exspresso.db.reconnect ($err) =>

      return $next($err) if log_message('error', 'Session::destroy connect %s', $err) if $err

      Exspresso.db.where 'sid', $sid
      Exspresso.db.delete @_sess_table_name, =>
        return $next($err) if log_message('error', 'Session::destroy delete %s', $err) if $err
        $next()

  #  --------------------------------------------------------------------

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
    {rid: 1, name:'anon', description:'Anonymous'}
    {rid: 2, name:'admin', description:'Administrator'}
    {rid: 3, name:'member', description:'Member'}
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
    {uid: 1, name: 'anonymous', password: '', salt: '', email: '', created_on: 1268889823, last_login: 1268889823, active: 1}
    {uid: 2, name: 'admin', password: '59beecdf7fc966e2f17fd8f65a4a9aeb09d4a3d4', salt: '9462e8eee0', email: 'admin@admin.com', created_on: 1268889823, last_login: 1268889823, active: 1}
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
    {id: 1, uid: 1, rid: 1}
    {id: 2, uid: 2, rid: 2}
  ]
    
module.exports = Exspresso_Session_sql
# End of file Session_sql.coffee
# Location: ./system/libraries/Session/drivers/Session_sql.coffee