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

  _sess_table_name    : ''
  _sess_expiration    : 0


  ## --------------------------------------------------------------------

  #
  # Constructor
  #
  #   If needed, create the table and cleanup jobs
  #
  # @return 	nothing
  #
  constructor: ($config) ->

    @_sess_table_name = $config.sess_table_name
    @_sess_expiration = $config.sess_expiration
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

        $next null, if $result.num_rows is 0 then null else JSON.parse($result.row().session)


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

        if $result.num_rows is 0
          $data =
            sid     : $sid
            session : JSON.stringify($session)
            expires : new Date(Date.now()+@_sess_expiration).getTime()

          Exspresso.db.insert @_sess_table_name, $data, ($err) =>
            return $next($err) if log_message('error', 'Session::set insert %s', $err) if $err
            $next()

        else
          $data =
            session : JSON.stringify($session)
            expires : new Date(Date.now()+@_sess_expiration).getTime()

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
  fields:
    sid:
      type: 'VARCHAR', constraint: 24, default: '0', null: false
    uid:
      type: 'INT', constraint: 10, unsigned: true, default: 0, null: false
    expires:
      type: 'INT', constraint: 11, unsigned: true, default: 0, null: false
    session:
      type: 'TEXT', null: true
  data: []



## --------------------------------------------------------------------

#
# Class Migrate
#
class Migrate_roles extends Migrate

  name: 'roles'
  pkey: 'rid'
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