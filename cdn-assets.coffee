#+--------------------------------------------------------------------+
# cdn-assets.coffee
#+--------------------------------------------------------------------+
# Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# CDN Assets
#
# use:
#   cake build:assets
#


module.exports =

  default:
    css: [
      'css/bootstrap.min.css'
      'css/site.css'
      'css/jquery-ui-1.8.24.custom.css'
    ]

  katralib:
    js: [
      'js/json2.js'
      'js/underscore-min.js'
      'js/backbone-min.js'
      'js/jquery.console.js'
      'js/coffee-script.js'
    ]

  signin:
    css:  'css/signin.css'

  sidenav:
    css: 'css/sidenav.css'
