#+--------------------------------------------------------------------+
#| ConnectServer.coffee
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
#	Server_connect - Server driver for connectjs
#
#
#
#	Server_connect Class
#
#   An adapter to the connect server instance
#   it exposes adapter registration points for each of these core classes:
#
#       * Config
#       * Output
#       * Input
#       * Session
#       * URI
#
#

require SYSPATH+'core/Server.coffee'

class application.core.ConnectServer extends system.core.Server

  connect         = require("connect")            # High performance middleware framework
  eco             = require('eco')                # Embedded CoffeeScript templates
  fs              = require("fs")                 # File system
  cookie          = require('cookie')             # cookie parsing and serialization
  sign            = require('cookie-signature')   # Sign and unsign cookies
  parseUrl        = connect.utils.parseUrl        # Parse the `req` url with memoization.

  #
  # Set the server instance
  #
    # @param  [Object]    # @return [Void]  #
  constructor: ($config = {}) ->

    log_message('debug', "Connect Driver Initialized")

    super $config, connect()
    @app.use @patch()

  #
  # Add view helpers
  #
    # @param  [Array]  # @return [Object]  #
  setHelpers: ($helpers) ->
    for $key, $val of $helpers
      Variables::[$key] = $val
    $helpers

  #  --------------------------------------------------------------------

  #
  # Start me up ...
  #
    # @return [Void]  #
  start: ($router) ->
    super $router, =>

      @_port = @_port || 3000

      @app.use @error_5xx()
      @app.use @error_404()

      @app.listen @_port, =>

        @banner()

        if @_preview
          #
          # preview in appjs
          #
          {exec} = require('child_process')
          exec "node --harmony bin/preview #{@_port}", ($err, $stdout, $stderr) ->
            console.log $stderr if $stderr?
            console.log $stdout if $stdout?
            process.exit()

        return
      return
    return


  #  --------------------------------------------------------------------

  #
  # Config registration
  #
  #   called by the core/Config class constructor
  #
    # @param  [Object]  exspresso.config
  # @return [Void]  #
  config: ($config) ->

    super $config
    @app.use connect.logger(@_logger)

    Variables::['settings'] =
      site_name:    @_site_name
      site_slogan:  @_site_slogan

    #
    # Expose asset folders
    #
    @app.use connect.static(APPPATH+"assets/")
    @app.use connect.static(DOCPATH)

    #
    # Favorites icon
    #
    if $config.favicon?
      @app.use connect.favicon(APPPATH+"assets/" + $config.favicon)

    else
      @app.use connect.favicon()

    @app.use connect.query()
    @app.use connect.bodyParser()
    @app.use connect.methodOverride()
    return


  #
  # Patch the connect server objects
  #
    # @param  [Object]    # @param  [Object]    # @param  [Function]    # @return [Void]  #
  patch: -> ($req, $res, $next) =>

    #
    # Set expected request object properties
    #

    defineProperties $req,
      protocol:   get: -> if $req.connection.encrypted then 'https' else 'http'
      secure:     get: -> if $req.protocol is 'https' then true else false
      path:       value: parseUrl($req).pathname
      host:       value: $req.headers.host
      ip:         value: $req.connection.remoteAddress

    exspresso.config.setItem('base_url', $req.protocol+'://'+ $req.headers['host'])


    #
    # Send
    #
    #   send response string
    #
        # @param  [String]      # @return [Void]  #
    $res.send = ($data) ->
      $res.writeHead 200,
        'Content-Length': $data.length
        'Content-Type': 'text/html; charset=utf-8'
      $res.end $data


    #
    # Redirect
    #
    #   Redirect to url
    #
        # @param  [String]      # @return [Void]  #
    $res.redirect = ($url) ->
      $res.writeHead 302,
        'Location': $url
      $res.end null

    #$res._error_handler = ($err) ->
    #  $next $err

    #
    # Render
    #
    #   called by the controller to display a view
    #
        # @param  [String]     path to view
    # @param  [Object]     data to render in the view
    # @param  [Function]   callback
    # @return [Void]  #
    $res.render = ($view, $data = {}, $next) ->

      #
      # $data argument is optional
      #
      if typeof $data is 'function' then [$data, $next] = [{}, $data]

      #
      # $next argument is optional
      #
      $next = $next ? ($err, $str) -> if $err then $next($err) else $res.send($str)

      #
      # load the view and render it with data+helpers
      #
      fs.readFile $view, 'utf8', ($err, $str) ->
        if $err then $next($err)
        else
          try
            $data.filename = $view
            $next null, eco.render($str, new Variables($data, flashdata: $res.flashdata))
          catch $err
            console.log $err
            $next($err)

    $next()


module.exports = application.core.ConnectServer

class Variables

  #
  # Provides variables to a view
  #
    # @param  [Array]  # @return [Void]  #
  constructor: ($args...) ->

    for $data in $args
      for $key, $val of $data
        @[$key] = $val




# End of file ConnectServer.coffee
# Location: .application/core/ConnectServer.coffee