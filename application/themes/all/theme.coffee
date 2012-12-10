#+--------------------------------------------------------------------+
#| theme.coffee.coffee
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
#	theme.coffee - All
#
#
#

exports.id =           'all'
exports.name =         'Exspresso Base Theme'
exports.author =       'darkoverlordofdata'
exports.website =      'http://darkoverlordofdata.com'
exports.version =      '1.0'
exports.description =  'Exspresso Base Theme'
exports.location =      APPPATH+'themes/all'
exports.favicon =      'favicon.png'
exports.meta = [
  {type: 'charset',       name: 'UTF-8'}
  {name: 'author',        content: 'darkoverlordofdata'}
  {name: 'copyright',     content: 'darkoverlordofdata'}
  {name: 'resource-type', content: 'document'}
  {name: 'language',      content: 'en'}
]

exports.script =
  ckeditor: 'ckeditor/ckeditor.js'
  prettify:  [
    'google-code-prettify/prettify.js'
    """
    $(function() {
    prettyPrint();
    });
    """
  ]

exports.css = [
  prettify:  """
    code {font-size: 90%};
    """
  ]

# End of file theme.coffee
# Location = .application/themes/default/theme.coffee