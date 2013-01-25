#+--------------------------------------------------------------------+
#| server.coffee
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
#| -------------------------------------------------------------------
#| SERVER SETTINGS
#| -------------------------------------------------------------------
#| This file will contain the settings needed to start the http server.
#|
#| -------------------------------------------------------------------
#| EXPLANATION OF VARIABLES
#| -------------------------------------------------------------------
#|
#|  ['driver']    connect|express|appjs
#|	['url']       Optional url. Base url
#|	['secure']    Secure (https)? .
#|	['protocol']  Prototcol - http
#|	['host']      Hostname - localhost
#|	['version']   http version - 1.1
#|	['ip']        127.0.0.1
#|
#| The $active_server variable lets you choose which server group to
#| make active.  By default there is only one group (the 'default' group).
#

exports['active_server'] = 'express'
exports['server'] =

  connect:
    'driver'            : 'connect'

  express:
    'driver'            : 'express'

  appjs:
    'driver'            : 'appjs'
    'secure'            : false
    'protocol'          : 'http'
    'host'              : 'appjs'
    'httpVersion'       : '1.1'
    'ip'                : '127.0.0.1'
    'url'               : 'http://appjs/'
    'window'            :
      'width'           : 1280
      'height'          : 920
      'icons'           : process.cwd() + "/bin/icons"
      'left'            : -1 			# optional, -1 centers
      'top'             : -1			# optional, -1 centers
      'autoResize'      : false 	# resizes in response to html content
      'resizable'       : true		# controls whether window is resizable by user
      'showChrome'      : true		# show border and title bar
      'opacity'         : 1 			# opacity from 0 to 1 (Linux)
      'alpha'           : false 	# alpha composited background (Windows & Mac)
      'fullscreen'      : false 	# covers whole screen and has no border
      'disableSecurity' : true		# allow cross origin requests


#  End of file server.coffee
#  Location: ./application/config/server.coffee