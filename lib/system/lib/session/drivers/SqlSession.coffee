#+--------------------------------------------------------------------+
#| SqlSession.coffee
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
#   Sql Session store driver
#
#
module.exports = class system.lib.session.SqlSession extends require(exspresso.server.driver).session.Store

  Users = require(APPPATH+'modules/user/models/Users.coffee')

  parent                  : null        # The parent class for this driver
  controller              : null        # the system controller

  #
  # Load the user data model
  #
  # @param  [system.lib.DriverLibrary]  parent  the drivers parent object
  # @param  [system.core.Exspresso] controller  the system controller
  # @return 	nothing
  #
  constructor: ($parent, $controller) ->

    Object.defineProperties @,
      parent        : {enumerable: true, writeable: false, value: $parent}
      controller    : {enumerable: true, writeable: false, value: $controller}

    @controller.load.model('Users')
    return


  #
  # Get the session data
  #
  # @param  [String]  session id
  # @param  [Function]  next
  # @return 	nothing
  #
  get: ($sid, $next) ->

    # Ensure that we have a live database connection
    @controller.db.reconnect ($err) =>

      return $next($err) if log_message('error', 'Session::get connect %s', $err) if $err

      # Get the record for this session
      @controller.db.where 'sid', $sid
      @controller.db.get @parent.sess_table_name, ($err, $result) =>

        return $next($err) if log_message('error', 'Session::get %s %s', $sid, $err) if $err

        return $next(null, null) if $result.num_rows is 0

        # unpack the data
        $data                   = $result.row()
        $session                = JSON.parse($data.user_data)
        $session.uid            = $data.uid || Users.UID_ANONYMOUS
        $session.ip_address     = $data.ip_address
        $session.user_agent     = $data.user_agent
        $session.last_activity  = $data.last_activity

        $next null, $session

  #
  # Set the session data
  #
  # @param  [String]  session id
  # @param  [String]  session data
  # @param  [Function]  next
  # @return 	nothing
  #
  set: ($sid, $session, $next) ->

    # Ensure that we have a live database connection
    @controller.db.reconnect ($err) =>

      return $next($err) if log_message('error', 'Session::set connect %s', $err) if $err

      # Get the record for this session
      @controller.db.where 'sid', $sid
      @controller.db.get @parent.sess_table_name, ($err, $result) =>

        return $next($err) if log_message('error', 'Session::set %s %s', $sid, $err) if $err

        # pack up the data
        $user_data = {}
        $user_data[$key] = $val for $key, $val of $session
        $data =
          uid             : fetch($user_data, 'uid', Users.UID_ANONYMOUS)
          ip_address      : fetch($user_data, 'ip_address')
          user_agent      : fetch($user_data, 'user_agent').substr(0, 120)
          last_activity   : fetch($user_data, 'last_activity')
          user_data       : JSON.stringify($user_data)

        if $result.num_rows is 0

          # Add primary key data so we can insert a new record
          $data['sid'] = $sid
          @controller.db.insert @parent.sess_table_name, $data, ($err) =>
            return $next($err) if log_message('error', 'Session::set insert %s', $err) if $err
            $next()

        else

          # Just update the data
          @controller.db.where 'sid', $sid
          @controller.db.update @parent.sess_table_name, $data, ($err) =>
            return $next($err) if log_message('error', 'Session::set update %s', $err) if $err
            $next()

  #
  # Delete the session data
  #
  # @param  [String]  session id
  # @param  [Function]  $next
  # @return 	nothing
  #
  destroy: ($sid, $next) ->

    # Ensure that we have a live database connection
    @controller.db.reconnect ($err) =>

      return $next($err) if log_message('error', 'Session::destroy connect %s', $err) if $err

      # Nuke the record for this session
      @controller.db.where 'sid', $sid
      @controller.db.delete @parent.sess_table_name, =>
        return $next($err) if log_message('error', 'Session::destroy delete %s', $err) if $err
        $next()

  #
  # Installation
  #
  #   create user & session tables if they doesn't exist
  #   called when Session library is auto loaded during boot
  #   deferred to the Users, due to the dependencies on User
  #
  # @return [Void]
  #
  install: ->
    @controller.users.install()
    @

  #
  # Fetch
  #
  #   Retrieve an item from a table and remove it
  #   If not found, return the default value
  #
  # @param  [Object]  # @param  [String]  # @param  [String]  # @return string
  #
  fetch = ($table, $key, $default='') ->
    if $table[$key]?
      $val = $table[$key]
      delete $table[$key]
    else $val = $default
    return $val


