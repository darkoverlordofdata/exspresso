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

exports.menu =
  tabs: # tabs | pills

    # Text    Uri
    Welcome : ['/welcome', "About Exspresso"]
    Home    : ['/', 'Blog']
    Travel  : ['/travel', 'DB Demo']
    Admin   : ['/admin', 'Login']


exports.script =
  default: [
    'js/jquery-1.8.1.min.js'
    'js/jquery-ui-1.8.24.custom.min.js'
    'js/bootstrap.min.js'
  ]
  ckeditor: 'ckeditor/ckeditor.js'
  prettify: [
    'google-code-prettify/prettify.js'
    """
    $(function() {
    prettyPrint();
    });
    """
  ]

exports.css =
  default: [
    'css/bootstrap.min.css'
    'css/site.css'
    'css/bootstrap-responsive.min.css'
    'css/jquery-ui-1.8.24.custom.css'
  ]
  prettify:  [
    'google-code-prettify/prettify.css'
    """
    code {font-size: 100%};
    """
  ]
  signin: [
    'css/signin.css'
  ]
  sidenav: [
    'css/sidenav.css'
  ]

# End of file theme.coffee
# Location = .application/themes/public/theme.coffee