#+--------------------------------------------------------------------+
#| theme.coffee
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
#	  Default Theme Manifest
#
#
#

exports.id =            'default'
exports.name =          'Exspresso Theme'
exports.author =        'darkoverlordofdata'
exports.website =       'http://darkoverlordofdata.com'
exports.version =       '1.0'
exports.description =   'Exspresso Default Public Theme'
exports.location =      APPPATH+'themes/'

exports.regions =
  header          : 'Header'
  navigation      : 'Navigation bar'
  highlighted     : 'Highlighted'
  help            : 'Help'
  content         : 'Content'
  sidebar_first   : 'First sidebar'
  sidebar_second  : 'Second sidebar'
  footer          : 'Footer'
  bottom          : 'Page bottom'
  page_top        : 'Page top'
  page_bottom     : 'Page bottom'


#
# Layout
#
# This is the main page layout template
#
#exports.layout = 'html.tpl'


#
# Menu
#
# Defines the main page menu
#
exports.menu =
  tabs: # tabs | pills

    # Text    Uri
    Welcome : ['/welcome', "About Exspresso"]
    Home    : ['/', 'Blog']
    Travel  : ['/travel', 'DB Demo']
    Admin   : ['/admin', 'Login']




#
# Scripts
#
# The script blocks available to this template
#
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

#
# CSS
#
# The style sheets available to this template
#
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

