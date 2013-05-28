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
  analytics       : 'Google Analytics'


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
    Katra  :
      uri   : '/katra'
      tip   : 'Live Long And Prosper'
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
    '//ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min.js'
    '//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js'
    '//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/js/bootstrap.min.js'
    """
    Exspresso_base_url = "#{config_item('base_url')}";
    """
  ]

  ckeditor: [
    '//d16acdn.herokuapp.com/ckeditor/ckeditor.js'
    """
    CKEDITOR.replace( 'blog', {
      extraPlugins: 'divarea'
    });
    """
  ]
  tinymce: '//tinymce.cachefly.net/4.0/tinymce.min.js'
  coffeescript: '//cdnjs.cloudflare.com/ajax/libs/coffee-script/1.6.2/coffee-script.min.js'
  prettify: [
    '//google-code-prettify.googlecode.com/svn/loader/run_prettify.js'
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
  default: '//d16acdn.herokuapp.com/css/default.min.css'
  #  default: [
  #    'css/bootstrap.min.css'
  #    'css/site.css'
  #    'css/jquery-ui-1.8.24.custom.css'
  #  ]
  prettify:  [
    '//google-code-prettify.googlecode.com/svn/loader/prettify.css'
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

