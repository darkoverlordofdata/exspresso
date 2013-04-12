#+--------------------------------------------------------------------+
#| Custom_html_helper.coffee
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
#	Custom_html_helper
#
#
#
#  ------------------------------------------------------------------------

#
# stylesheet_decl
#
# Generates an HTML stylesheet declaration.
#
# @param  [String]  # @return	[String]
#
if not function_exists('stylesheet')
  exports.stylesheet = stylesheet = ($content = '', $type = 'text/css') ->
    "<style type=\"#{$type}\">\n#{$content}\n</style>"

#
# javascript_tag
#
# Generates an HTML javascript tag.
#
# @param  [String]  # @return	[String]
#
if not function_exists('javascript_tag')
  exports.javascript_tag = javascript_tag = ($src = '', $type = 'text/javascript') ->
    $src = exspresso.config.slashItem('base_url')+$src
    "<script src=\"#{$src}\" type=\"#{$type}\"></script>"

#
# javascript_decl
#
# Generates an HTML javascript declaration.
#
# @param  [String]  # @return	[String]
#
if not function_exists('javascript_decl')
  exports.javascript_decl = javascript_decl = ($content = '', $type = 'text/javascript') ->
    "<script>\n#{$content}\n</script>"




# End of file Custom_html_helper.coffee
# Location: ./Custom_html_helper.coffee