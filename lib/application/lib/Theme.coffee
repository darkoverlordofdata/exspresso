#+--------------------------------------------------------------------+
#| Theme.coffee
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
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#  ------------------------------------------------------------------------
#
#	  Theme Class
#
#   Provision a theme
#
#
#
class application.lib.Theme

  _location       : ''
  _path           : ''
  _id             : ''
  _name           : ''
  _author         : ''
  _website        : ''
  _version        : ''
  _description    : ''
  _location       : ''
  _favicon        : ''
  _layout         : null
  _meta           : null
  _script         : null
  _css            : null
  _menu           : null

  constructor: ($controller, $config = {}) ->

    # Initialize the config preferences
    for $key, $val of $config
      if @['_'+$key]?
        @['_'+$key] = $val

    log_message('debug', "Theme Class Initialized")

    $theme = @_name ? 'default'
    @loadTheme $theme

  #
  # Loads a theme manifest
  #
  #   @access	public
  #   @param	string theme name
  # @return [Object]  #
  loadTheme: ($theme) ->

    if file_exists(APPPATH + 'themes/all/theme' + EXT)
      $config = require(APPPATH + 'themes/all/theme' + EXT)

    if file_exists(APPPATH + 'themes/' + $theme + '/theme' + EXT)
      $config = array_merge_recursive($config, require(APPPATH + 'themes/' + $theme + '/theme' + EXT))

    @['_'+$key] = $val for $key, $val of $config
    @_path = @_location + $theme + '/theme' + EXT
    
    @


  #
  # Initialize a template with theme resources
  #
  #   @access	public
  #   @param	string	template
  # @param  [Array]  extra theme elements
  # @return [Object]  #
  init: ($template, $extra = []) ->

    @template = $template
    $template._metadata = []
    $template._script = []
    $template._css = []
    $template._menu = {}

    if @_layout?
      $template.setLayout @_layout

    if @_menu?
      $template.setMenu @_menu

    if @_meta?
      $template.setMeta @_meta

    if @_css? and @_css.default?
      $template.setCss @_css.default

    if @_script? and @_script.default?
      $template.setScript @_script.default

    if not Array.isArray($extra) then $extra = [$extra]
    if @output._enable_profiler is true
      if $extra.indexOf('prettify') is -1
        $extra.push 'prettify'

    for $name in $extra
      if @_css[$name]?
        $template.setCss @_css[$name]

      if @_script[$name]?
        $template.setScript @_script[$name]
    @

  more: ($extra...) ->

    if @output._enable_profiler is true
      if $extra.indexOf('prettify') is -1
        $extra.push 'prettify'

    for $name in $extra
      if @_css[$name]?
        @template.setCss @_css[$name]

      if @_script[$name]?
        @template.setScript @_script[$name]
    @

module.exports = application.lib.Theme

# End of file Theme.coffee
# Location: .application/lib/Theme.coffee