#+--------------------------------------------------------------------+
#| Application.coffee
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
#	Application class
#
#   An adapter to the appjs application instance
#
express         = require('express')                    # Web development framework 2.5.9
appjs           = require("appjs")                      # Desktop development framework 0.0.20
utils           = require("util")
fs              = require("fs")
path            = require("path")

class global.CI_Application

  #  --------------------------------------------------------------------

  #
  # Validate the express version
  #
  # @access	public
  # @return	void
  #
  constructor: ->
    if express.version[0] is '3'
      throw 'Incompatible expressjs version '+express.version

  #  --------------------------------------------------------------------

  #
  # Send requests for views back to Exspresso
  #
  # @access	public
  # @return	void
  #
  client: ($server) ->

    $public = 'application/themes/default/assets'

    # override AppJS's built in request handler with connect
    appjs.serveFilesFrom path.join(__dirname, $public)

    # Get a copy of the original handle function
    $handle = appjs.router.handle

    appjs.router.handle = ($req, $res) ->

      # Check if this is a request for static content
      $fullpath = path.join($public, $req.pathname)
      if file_exists($fullpath) and is_file($fullpath)
        $handle.apply appjs.router, arguments
      else
        $req.originalUrl = $req.url
        $req.url = $req.pathname
        $server.handle.apply $server, arguments


    # create window
    $window = appjs.createWindow(
      width: 1280 # 640
      height: 920 # 460
      icons: __dirname + "/public/icons"
    )

    # show the window after initialization
    $window.on 'create', ->
      $window.frame.show()
      $window.frame.center()


    # add require/process/module to the window global object for debugging from the DevTools
    $window.on 'ready', ->
      $window.require = require
      $window.process = process
      $window.module = module
      $window.addEventListener 'keydown', (e) ->
        $window.frame.openDevTools()  if e.keyIdentifier is "F12"





module.exports = CI_Application

# End of file Application.coffee
# Location: .application/core/Application.coffee