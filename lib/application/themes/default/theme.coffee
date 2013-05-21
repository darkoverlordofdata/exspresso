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
  content         : 'Content'
  footer          : 'Footer'
  bottom          : 'Page bottom'


#
# Menu
#
# Defines the main page menu
#
exports.menu =
  Welcome :
    uri   : '/welcome'
    tip   : "About Exspresso"
  Home    :
    uri   : '/'
    tip   : 'Blog'
  Demos:
    Travel  :
      uri   : '/travel'
      tip   : 'DB Demo'
    Wine  :
      uri   : '/wines'
      tip   : 'Ajax Demo'
  Admin   :
    uri   : '/admin'
    tip   : 'Login'


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
    """
    Exspresso_base_url = "#{config_item('base_url')}";
    """
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

