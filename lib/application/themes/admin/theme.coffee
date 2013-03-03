#+--------------------------------------------------------------------+
#| theme.coffee.coffee
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
#	theme.coffee - Default
#
#
#

exports.id =            'default'
exports.name =          'Exspresso Theme'
exports.author =        'darkoverlordofdata'
exports.website =       'http://darkoverlordofdata.com'
exports.version =       '1.0'
exports.description =   'Exspresso Default Public Theme'
exports.location =      APPPATH+'themes/public'

exports.layout = 'layout.eco'

exports.script =
  default: [
    'js/bootstrap.min.js'
    'js/jquery-1.8.1.min.js'
    'js/jquery-ui-1.8.24.custom.min.js'
  ]

exports.css =
  default: [
    'css/bootstrap.min.css'
    'css/jquery-ui-1.8.24.custom.css'
    'css/site.css'
  ]

# End of file theme.coffee
# Location = .application/themes/public/theme.coffee