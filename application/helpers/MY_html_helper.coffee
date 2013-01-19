#+--------------------------------------------------------------------+
#| MY_html_helper.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#	MY_html_helper
#
#
#
#  ------------------------------------------------------------------------

#
# stylesheet_decl
#
# Generates an HTML stylesheet declaration.
#
# @access	public
# @param	string
# @return	string
#
if not function_exists('stylesheet')
  exports.stylesheet = stylesheet = ($content = '', $type = 'text/css') ->
    "<style type=\"#{$type}\">\n#{$content}\n</style>"

#
# javascript_tag
#
# Generates an HTML javascript tag.
#
# @access	public
# @param	string
# @return	string
#
if not function_exists('javascript_tag')
  exports.javascript_tag = javascript_tag = ($src = '', $type = 'text/javascript') ->
    $CI = Exspresso
    $src = $CI.config.slash_item('base_url')+$src
    "<script src=\"#{$src}\" type=\"#{$type}\"></script>"

#
# javascript_decl
#
# Generates an HTML javascript declaration.
#
# @access	public
# @param	string
# @return	string
#
if not function_exists('javascript_decl')
  exports.javascript_decl = javascript_decl = ($content = '', $type = 'text/javascript') ->
    "<script>\n#{$content}\n</script>"




# End of file MY_html_helper.coffee
# Location: ./MY_html_helper.coffee