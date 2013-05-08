#+--------------------------------------------------------------------+
#  my_html_helper.coffee
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
# Application MyHTML Helpers
#
#
# Menu
#
# Main menu
#
# @param  [Object]  items hash of menu items
# @param  [String]  active  the active menu item
# @return [String]  the html
#
exports.menu = ($items, $active) ->

  $k = keys($items)[0]
  $active = '/'+$active

  $menu = "<ul class=\"nav nav-#{$k}\">\n"
  for $name, $val of $items[$k]
    [$uri, $tip] = $val
    if $uri is $active
      $menu+="<li class=\"active\"><a href=\"#{$uri}\">#{$name}</a></li>\n"
    else
      $menu+="<li><a href=\"#{$uri}\" title=\"#{$tip}\">#{$name}</a></li>\n"

  $menu+"</ul>\n"


#
# Sidenav
#
# side-bar navigation menu
#
# @param  [Object]  items hash of menu items
# @param  [String]  active  the active menu item
# @return [String]  the html
#
exports.sidenav = ($items, $active) ->

  $menu = "<ul class=\"nav nav-list sidenav\">\n"


  for $k, $u of $items
    if $k is $active
      $menu += "<li class=\"active\">"
    else
      $menu += "<li>"
    $menu += "<a href=\"#{$u}\"><i class=\"icon-chevron-right\"></i> #{$k}</a></li>\n"
  $menu += "</ul>\n"

#
# Submenu
#
# sub menu
#
# @param  [Object]  items hash of menu items
# @param  [String]  active  the active menu item
# @return [String]  the html
#
exports.submenu = ($modules, $module) ->

  $active = ucfirst($module)

  $menu = "<ul class=\"nav nav-tabs\">\n"
  for $k, $u of $modules
    if $k is $active
      $menu += "<li class=\"active\">\n"
    else
      $menu += "<li>\n"
    $menu += "<a href=\"#{$u}\" title=\"#{$k}\">#{$k}</a>\n</li>\n"
  $menu += "</ul>\n"


#
# Flash
#
# Create the html for flash messages
#
# @return [String]  the html
#
exports.flash = ($error, $info) ->

  $flash = []

  if $error isnt false
    $flash.push "<div class='alert alert-error'>"
    $flash.push "<p><b>Error:</b> #{$error}</p>"
    $flash.push "</div>"

  if $info isnt false
    $flash.push "<div class='alert alert-info'>"
    $flash.push "<p><b>Info:</b> #{$info}</p>"
    $flash.push "</div>"

  $flash.join('')


