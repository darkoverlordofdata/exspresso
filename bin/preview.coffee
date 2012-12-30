#+--------------------------------------------------------------------+
#| preview.coffee
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
#	preview in appjs
#
#
appjs = require('appjs')

#
# Point the browser window to Exspresso running on localhost
#

port = process.argv[2]
window = appjs.createWindow("http://localhost:#{port}/",
  width           : 1280,
  height          : 920,
  icons						: __dirname + '/icons',
  left            : -1,			# optional, -1 centers
  top             : -1,			# optional, -1 centers
  autoResize      : false,	# resizes in response to html content
  resizable       : true,		# controls whether window is resizable by user
  showChrome      : true,		# show border and title bar
  opacity         : 1,			# opacity from 0 to 1 (Linux)
  alpha           : false,	# alpha composited background (Windows & Mac)
  fullscreen      : false,	# covers whole screen and has no border
  disableSecurity : true		# allow cross origin requests
)

#
# show Exspresso output
#
window.on 'create',  ->

  window.frame.show()
  window.frame.center()
  return


#
# enable debugger window
#
window.on 'ready', ->

  window.addEventListener 'keydown', (e) ->

    if e.keyIdentifier is 'F12'
      window.frame.openDevTools()
    return

  return


# End of file preview.coffee
# Location: ./bin/preview.coffee