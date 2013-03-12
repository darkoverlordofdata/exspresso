#+--------------------------------------------------------------------+
#| MyConnect.coffee
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

#	MyConnect driver
#
#   Extends the connect driver to use express using
#   the subclass_prefix 'My'
#

require SYSPATH+'core/Connect.coffee'

class application.core.MyConnect extends system.core.Connect

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

    # since we're not using
    delete @patch

    @app = if $driver.version[0] is '3' then $driver() else $driver.createServer()
    @port = @controller.config.item('port')

    @app.set 'env', ENVIRONMENT
    @app.set 'port', @port
    @app.set 'site_name', @controller.config.item('site_name')
    @app.set 'site_slogan', @controller.config.item('site_slogan')

    @app.use $driver.logger(@controller.config.item('logger'))

    #
    # Expose assets & views
    #
    @app.set 'views', APPPATH + @controller.config.item('views')
    @app.use $driver.static(APPPATH+"assets/")
    @app.use $driver.static(DOCPATH) unless DOCPATH is false
    @app.set 'view engine', ltrim(@controller.config.item('view_ext'), '.')
    if $driver.version[0] is '3'
      #
      # express v3.x
      #
      @app.engine @controller.config.item('view_ext'), ($view, $data, $next) ->

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
      @app.register @controller.config.item('view_ext'), eco
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
    @app.use @controller.parseBaseUrl()



module.exports = application.core.MyConnect

# End of file MyConnect.coffee
# Location: .application/core/MyConnect.coffee