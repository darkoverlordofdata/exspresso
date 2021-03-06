#+--------------------------------------------------------------------+
#  html_helper.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+

#
# Exspresso HTML Helpers
#

#
# Heading
#
# Generates an HTML heading tag.  First param is the data.
# Second param is the size of the heading tag.
#
# @param  [String]
# @param  [Integer]
# @return	[String]
#
exports.heading = heading = ($data = '', $h = '1') ->
  return "<h" + $h + ">" + $data + "</h" + $h + ">"
    
#
# Unordered List
#
# Generates an HTML unordered list from an single or multi-dimensional array.
#
# @param  [Array]
# @param  [Mixed]
# @return	[String]
#
exports.ul = ul = ($list, $attributes = '') ->
  return _list('ul', $list, $attributes)
    
  
#
# Ordered List
#
# Generates an HTML ordered list from an single or multi-dimensional array.
#
# @param  [Array]
# @param  [Mixed]
# @return	[String]
#
exports.ol = ol = ($list, $attributes = '') ->
  return _list('ol', $list, $attributes)
    
#
# Generates the list
#
# Generates an HTML ordered list from an single or multi-dimensional array.
#
# @private
# @param  [String]
# @param  [Mixed]
# @param  [Mixed]
# @param  [Integer]
# @return	[String]
#
$_last_list_item = {}

exports._list = _list = ($type = 'ul', $list, $attributes = '', $depth = 0) ->
  #  If an array wasn't submitted there's nothing to do...
  if not is_array($list)
    return $list


  #  Set the indentation based on the depth
  $out = str_repeat(" ", $depth)

  #  Were any attributes submitted?  If so generate a string
  if is_array($attributes)
    $atts = ''
    for $key, $val of $attributes
      $atts+=' ' + $key + '="' + $val + '"'

    $attributes = $atts


  #  Write the opening list tag
  $out+="<" + $type + $attributes + ">\n"

  #  Cycle through the list elements.  If an array is
  #  encountered we will recursively call _list()

  $_last_list_item = $_last_list_item ? {}
  for $key, $val of $list
    $_last_list_item = $key

    $out+=str_repeat(" ", $depth + 2)
    $out+="<li>"

    if not is_array($val)
      $out+=$val

    else
      $out+=$_last_list_item + "\n"
      $out+=_list($type, $val, '', $depth + 4)
      $out+=str_repeat(" ", $depth + 2)


    $out+="</li>\n"


  #  Set the indentation for the closing tag
  $out+=str_repeat(" ", $depth)

  #  Write the closing list tag
  $out+="</" + $type + ">\n"

  return $out

#
# Generates HTML BR tags based on number supplied
#
# @param  [Integer]
# @return	[String]
#
exports.br = br = ($num = 1) ->
  return str_repeat("<br />", $num)
    
#
# Image
#
# Generates an <img /> element
#
# @param  [Mixed]
# @return	[String]
#
exports.img = img = ($src = '', $index_page = false) ->
  if not is_array($src)
    $src = 'src':$src


  #  If there is no alt attribute defined, set it to an empty string
  if not $src['alt']?
    $src['alt'] = ''


  $img = '<img'

  for $k, $v of $src

    if $k is 'src' and $v.indexOf('://') is -1

      if $index_page is true
        $img+=' src="' + exspresso.config.siteUrl($v) + '"'

      else
        if $v.substr(0,2) is '//'
          $img+=' src="' + $v + '"'
        else
          $img+=' src="' + exspresso.config.slashItem('base_url') + $v + '"'


    else
      $img+=" #{$k}=\"#{$v}\""



  $img+='/>'

  return $img

#
# Doctype
#
# Generates a page document type declaration
#
# Valid options are xhtml-11, xhtml-strict, xhtml-trans, xhtml-frame,
# html4-strict, html4-trans, and html4-frame.  Values are saved in the
# doctypes config file.
#
# @param  [String]  type	The doctype to be generated
# @return	[String]
#
$_doctypes = null # static cache for doctypes

exports.doctype = doctype = ($type = 'xhtml1-strict') ->

  if not is_array($_doctypes)
    if is_file(APPPATH + 'config/' + ENVIRONMENT + '/doctypes' + EXT)
      $_doctypes = require(APPPATH + 'config/' + ENVIRONMENT + '/doctypes' + EXT)

    else if is_file(APPPATH + 'config/doctypes' + EXT)
      $_doctypes = require(APPPATH + 'config/doctypes' + EXT)

    if not is_array($_doctypes)
      return false

  if $_doctypes[$type]?
    return $_doctypes[$type]

  else
    return false

#
# Link
#
# Generates link to a CSS file
#
# @param  [Mixed]  stylesheet hrefs or an array
# @param  [String]  rel
# @param  [String]  type
# @param  [String]  title
# @param  [String]  media
# @return	[Boolean]ean	should index_page be added to the css path
# @return	[String]
#
exports.link_tag = link_tag = ($href = '', $rel = 'stylesheet', $type = 'text/css', $title = '', $media = '', $index_page = false) ->

  $link = '<link '

  if is_array($href)
    for $k, $v of $href
      if $k is 'href' and $v.indexOf('://') is -1
        if $index_page is true
          $link+='href="' + exspresso.config.siteUrl($v) + '" '

        else
          $link+='href="' + exspresso.config.slashItem('base_url') + $v + '" '

      else
        $link+="$k=\"$v\" "



    $link+="/>"

  else
    if $href.indexOf('://') isnt -1 or $href.substr(0,2) is '//'
      $link+='href="' + $href + '" '

    else if $index_page is true
      $link+='href="' + exspresso.config.siteUrl($href) + '" '

    else
      $link+='href="' + exspresso.config.slashItem('base_url') + $href + '" '

    $link+='rel="' + $rel + '" type="' + $type + '" '

    if $media isnt ''
      $link+='media="' + $media + '" '


    if $title isnt ''
      $link+='title="' + $title + '" '


    $link+='/>'



  return $link

#
# stylesheet_decl
#
# Generates an HTML stylesheet declaration.
#
# @param  [String]
# @return	[String]
#
exports.stylesheet = ($content = '', $type = 'text/css') ->
  "<style type=\"#{$type}\">\n#{$content}\n</style>"

#
# javascript_tag
#
# Generates an HTML javascript tag.
#
# @param  [String]
# @return	[String]
#
exports.javascript_tag = ($src = '', $type = 'text/javascript') ->
  if $src.indexOf('//') is -1
    $src = exspresso.config.slashItem('base_url')+$src
  "<script src=\"#{$src}\" type=\"#{$type}\"></script>"

#
# javascript_decl
#
# Generates an HTML javascript declaration.
#
# @param  [String]
# @return	[String]
#
exports.javascript_decl = ($content = '', $type = 'text/javascript') ->
  "<script>\n#{$content}\n</script>"


#
# Generates meta tags from an array of key/values
#
# @param  [Array]
# @return	[String]
#
exports.meta = meta = ($name = '', $content = '', $type = 'name', $newline = "\n") ->
  #  Since we allow the data to be passes as a string, a simple array
  #  or a multidimensional one, we need to do a little prepping.
  if 'string' is typeof($name)
    $name = ['name':$name, 'content':$content, 'type':$type, 'newline':$newline]

  else
    #  Turn single array into multidimensional
    if $name['name']?
      $name = [$name]

  $str = ''
  for $meta in ($data = $name)

    $type = if not $meta['type']? then 'name' else $meta['type']
    $name = if not $meta['name']? then '' else $meta['name']
    $content = if not $meta['content']? then '' else $meta['content']
    $newline = if not $meta['newline']? then "\n" else $meta['newline']

    $content = ' content="' + $content + '"' if $content
    $str+='<meta ' + $type + '="' + $name + '"' + $content + ' />' + $newline


  return $str
    
#
# Generates non-breaking space entities based on number supplied
#
# @param  [Integer]
# @return	[String]
#
exports.nbs = nbs = ($num = 1) ->
  return str_repeat("&nbsp;", $num)

