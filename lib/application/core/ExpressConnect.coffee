#+--------------------------------------------------------------------+
#| ExpressConnect.coffee
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
#	ExpressConnect driver
#
#   Extends the connect driver to use express using
#   the subclass_prefix 'Express'
#
#   Set using option  --subclass Express
#
require SYSPATH+'core/Connect.coffee'

module.exports = class application.core.ExpressConnect extends system.core.Connect

  eco             = require('eco')                # Embedded CoffeeScript templates
  fs              = require("fs")                 # File system

  #
  # @property [String] http driver: connect
  #
  driver          : 'express'

  #
  # Set view helpers
  #
  # @param  [Object] helpers hash of helpers to add
  # @return [Object] the helpers hash
  #
  setHelpers: ($helpers) ->

    @app.locals $helpers
    $helpers


  #
  # Initialize the driver
  #
  # @param  [Object]  driver  http server object
  # @return [Void]
  #
  initialize:($driver) ->

    @app = if $driver.version[0] is '3' then $driver() else $driver.createServer()
    @port = @controller.config.item('http_port')

    @app.set 'env', ENVIRONMENT
    @app.set 'port', @port

    @app.use $driver.logger(@controller.config.item('log_http'))

    #
    # Expose asset folders
    #
    @app.set 'views', APPPATH + 'views'
    @app.use $driver.static(APPPATH+"assets/")
    @app.use $driver.static(DOCPATH) unless DOCPATH is false
    #
    # Set rendering
    #
    @app.set 'view engine', 'eco'
    if $driver.version[0] is '3'
      #
      # express v3.x
      #
      @app.engine '.eco', ($view, $data, $next) ->

        fs.readFile $view, 'utf8', ($err, $str) ->
          if $err then $next($err)
          else
            try
              $data.filename = $view
              $next null, eco.render($str, $data)
            catch $err
              $next $err

    else
      #
      # express v2.x
      #
      @app.register '.eco', eco
      # don't use express layouts,
      # Exspresso has it's own templating
      @app.set('view options', { layout: false });
    #
    # Favorites icon
    #
    @app.use $driver.favicon(APPPATH+"assets/" + @controller.config.item('favicon'))

    #
    # Request parsing
    #
    @app.use $driver.query()
    @app.use $driver.bodyParser()
    @app.use $driver.methodOverride()

