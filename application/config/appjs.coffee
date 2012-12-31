#--------------------------------------------------------------------+
# appjs.coffee
#--------------------------------------------------------------------+
# Copyright DarkOverlordOfData (c) 2012
#--------------------------------------------------------------------+
#
# This file is a part of Exspresso
#
# Exspresso is free software you can copy, modify, and distribute
# it under the terms of the GNU General Public License Version 3
#
#--------------------------------------------------------------------+
#
#	appjs config
#
#

#
#|--------------------------------------------------------------------------
#| appjs URL
#|--------------------------------------------------------------------------
#|
#| URL to your appjs root. Typically this will be your base URL,
#| WITH a trailing slash:
#|
#|	http://appjs/
#|
#
exports['url']    = 'http://appjs/'


#
#|--------------------------------------------------------------------------
#| Window Settings
#|--------------------------------------------------------------------------
#|
#| Default window settings used by appjs to create a window
#|
#
exports['window'] =
  width            : 1280
  height           : 920
  icons            : process.cwd() + "/bin/icons"
  left             : -1 			# optional, -1 centers
  top              : -1			# optional, -1 centers
  autoResize       : false 	# resizes in response to html content
  resizable        : true		# controls whether window is resizable by user
  showChrome       : true		# show border and title bar
  opacity          : 1 			# opacity from 0 to 1 (Linux)
  alpha            : false 	# alpha composited background (Windows & Mac)
  fullscreen       : false 	# covers whole screen and has no border
  disableSecurity  : true		# allow cross origin requests


# End of file appjs.coffee
# Location: .application/config/appjs.coffee